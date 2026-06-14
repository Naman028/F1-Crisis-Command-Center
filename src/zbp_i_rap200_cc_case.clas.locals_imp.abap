CLASS lhc_CrisisCase DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR CrisisCase
      RESULT result.

    METHODS generateAndRecommendOptions
      FOR MODIFY
      IMPORTING keys FOR ACTION CrisisCase~generateAndRecommendOptions
      RESULT result.

    METHODS setInitialCaseData
      FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CrisisCase~setInitialCaseData.

    METHODS get_next_case_id
      RETURNING
        VALUE(rv_case_id) TYPE zrap200_cc_case-case_id.

    METHODS get_timestamp_text
      RETURNING
        VALUE(rv_timestamp_text) TYPE zrap200_cc_case-created_at.

    METHODS get_current_user
      RETURNING
        VALUE(rv_user) TYPE zrap200_cc_case-created_by.

ENDCLASS.


CLASS lhc_CrisisCase IMPLEMENTATION.

  METHOD get_global_authorizations.

    " Demo project:
    " No restriction is applied here.
    " The method exists because the behavior definition uses global authorization.

  ENDMETHOD.


  METHOD get_timestamp_text.

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time( ).

    rv_timestamp_text = |{ lv_system_date DATE = ISO } { lv_system_time TIME = ISO }|.

  ENDMETHOD.


  METHOD get_current_user.

    rv_user = cl_abap_context_info=>get_user_technical_name( ).

  ENDMETHOD.


  METHOD setInitialCaseData.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      FIELDS (
        CaseID
        Status
        CreatedBy
        CreatedAt
        LastChangedBy
        LastChangedAt
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    DATA(lv_timestamp_text) = get_timestamp_text( ).
    DATA(lv_user)           = get_current_user( ).

    DATA lt_update TYPE TABLE FOR UPDATE zi_rap200_cc_case.

    LOOP AT lt_cases INTO DATA(ls_case).

      DATA(lv_case_id) = ls_case-CaseID.
      DATA(lv_status)  = ls_case-Status.

      IF lv_case_id IS INITIAL.
        lv_case_id = get_next_case_id( ).
      ENDIF.

      IF lv_status IS INITIAL.
        lv_status = 'OPEN'.
      ENDIF.

      APPEND VALUE #(
        %tky          = ls_case-%tky
        CaseID        = lv_case_id
        Status        = lv_status
        CreatedBy     = lv_user
        CreatedAt     = lv_timestamp_text
        LastChangedBy = lv_user
        LastChangedAt = lv_timestamp_text
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        UPDATE FIELDS (
          CaseID
          Status
          CreatedBy
          CreatedAt
          LastChangedBy
          LastChangedAt
        )
        WITH lt_update
        FAILED DATA(ls_failed_initial)
        REPORTED DATA(ls_reported_initial).

    ENDIF.

  ENDMETHOD.


  METHOD generateAndRecommendOptions.

    DATA(lo_dec_engine) = NEW zcl_rap200_cc_dec_engine( ).
    DATA(lo_score_srv)  = NEW zcl_rap200_cc_score_srv( ).

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase BY \_RecoveryOptions
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_existing_options).

    " ------------------------------------------------------------------
    " Step 1:
    " If a case has no recovery options yet, generate default proposals
    " from the decision engine.
    "
    " If options already exist, keep them. This supports manual recovery
    " options entered by the user.
    " ------------------------------------------------------------------
    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_cases INTO DATA(ls_case)
        WITH TABLE KEY id COMPONENTS %tky = ls_key-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_has_options) = abap_false.

      LOOP AT lt_existing_options USING KEY entity INTO DATA(ls_existing_option)
        WHERE CaseUUID = ls_case-CaseUUID.
        lv_has_options = abap_true.
        EXIT.

      ENDLOOP.

      IF lv_has_options = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_decision) = lo_dec_engine->build_decision(
        is_case_context = VALUE zcl_rap200_cc_dec_engine=>ty_case_context(
          crisis_type = ls_case-CrisisType
          severity    = ls_case-Severity
          race_name   = ls_case-RaceName
        )
      ).

      IF ls_decision-options IS INITIAL.
        CONTINUE.
      ENDIF.

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        CREATE BY \_RecoveryOptions
        FIELDS (
          OptionNo
          OptionID
          OptionType
          OptionText
          CostScore
          TimeScore
          RiskScore
          FeasibilityScore
        )
        WITH VALUE #(
          (
            %tky = ls_key-%tky
            %target = VALUE #(
              FOR ls_generated_option IN ls_decision-options
              (
                %cid             = CONV #( ls_generated_option-option_id )
                OptionNo         = ls_generated_option-option_no
                OptionID         = ls_generated_option-option_id
                OptionType       = ls_generated_option-option_type
                OptionText       = ls_generated_option-option_text
                CostScore        = ls_generated_option-cost_score
                TimeScore        = ls_generated_option-time_score
                RiskScore        = ls_generated_option-risk_score
                FeasibilityScore = ls_generated_option-feasibility_score
              )
            )
          )
        )
        FAILED DATA(ls_failed_create_options)
        REPORTED DATA(ls_reported_create_options).

    ENDLOOP.

    " ------------------------------------------------------------------
    " Step 2:
    " Reload recovery options after possible creation.
    " Then score all options, pick the best one, update child options,
    " and update the parent recommendation fields.
    " ------------------------------------------------------------------
    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase BY \_RecoveryOptions
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reloaded_options).

    LOOP AT lt_cases INTO DATA(ls_case_for_scoring).

      DATA lt_engine_options TYPE zcl_rap200_cc_dec_engine=>tt_options.

      LOOP AT lt_reloaded_options USING KEY entity INTO DATA(ls_option)
        WHERE CaseUUID = ls_case_for_scoring-CaseUUID.

        DATA(lv_option_id) = ls_option-OptionID.

        IF lv_option_id IS INITIAL.
          lv_option_id = |OPT{ ls_option-OptionNo }|.
        ENDIF.

        DATA(ls_score) = lo_score_srv->calculate_total_score(
          is_input = VALUE zcl_rap200_cc_score_srv=>ty_score_input(
            cost_score        = ls_option-CostScore
            time_score        = ls_option-TimeScore
            risk_score        = ls_option-RiskScore
            feasibility_score = ls_option-FeasibilityScore
          )
        ).

        APPEND VALUE #(
          option_no         = ls_option-OptionNo
          option_id         = lv_option_id
          option_type       = ls_option-OptionType
          option_text       = ls_option-OptionText
          cost_score        = ls_option-CostScore
          time_score        = ls_option-TimeScore
          risk_score        = ls_option-RiskScore
          feasibility_score = ls_option-FeasibilityScore
          total_score       = ls_score-total_score
          rating            = ls_score-rating
        ) TO lt_engine_options.

      ENDLOOP.

      IF lt_engine_options IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(ls_recommendation) = lo_dec_engine->recommend_best_option(
        it_options = lt_engine_options
      ).

      IF ls_recommendation-option_id IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_reason_text) =
        |Recommended option { ls_recommendation-option_type } for { ls_case_for_scoring-CrisisType } crisis with score { ls_recommendation-total_score }.|.

      LOOP AT lt_reloaded_options USING KEY entity INTO DATA(ls_option_for_update)
        WHERE CaseUUID = ls_case_for_scoring-CaseUUID.

        DATA(lv_update_option_id) = ls_option_for_update-OptionID.

        IF lv_update_option_id IS INITIAL.
          lv_update_option_id = |OPT{ ls_option_for_update-OptionNo }|.
        ENDIF.

        READ TABLE lt_engine_options INTO DATA(ls_engine_option)
          WITH KEY option_no = ls_option_for_update-OptionNo.

        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        DATA lv_is_recommended TYPE zrap200_cc_opt-is_recommended.
        DATA lv_option_reason  TYPE zrap200_cc_opt-reason_text.

        IF lv_update_option_id = ls_recommendation-option_id.
          lv_is_recommended = 'X'.
          lv_option_reason  = lv_reason_text.
        ENDIF.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY RecoveryOption
          UPDATE FIELDS (
            OptionID
            TotalScore
            Rating
            IsRecommended
            ReasonText
          )
          WITH VALUE #(
            (
              %tky          = ls_option_for_update-%tky
              OptionID      = lv_update_option_id
              TotalScore    = ls_engine_option-total_score
              Rating        = ls_engine_option-rating
              IsRecommended = lv_is_recommended
              ReasonText    = lv_option_reason
            )
          )
          FAILED DATA(ls_failed_option_update)
          REPORTED DATA(ls_reported_option_update).

      ENDLOOP.

      DATA(lv_timestamp_text) = get_timestamp_text( ).
      DATA(lv_user)           = get_current_user( ).

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        UPDATE FIELDS (
          RecommendedOptionID
          RecommendedOptionType
          RecommendedScore
          RecommendedRating
          RecommendedText
          Status
          LastChangedBy
          LastChangedAt
        )
        WITH VALUE #(
          (
            %tky                  = ls_case_for_scoring-%tky
            RecommendedOptionID   = ls_recommendation-option_id
            RecommendedOptionType = ls_recommendation-option_type
            RecommendedScore      = ls_recommendation-total_score
            RecommendedRating     = ls_recommendation-rating
            RecommendedText       = lv_reason_text
            Status                = 'RECOMMENDED'
            LastChangedBy         = lv_user
            LastChangedAt         = lv_timestamp_text
          )
        )
        FAILED DATA(ls_failed_case_update)
        REPORTED DATA(ls_reported_case_update).

    ENDLOOP.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result_cases).

    result = VALUE #(
      FOR ls_result_case IN lt_result_cases
      (
        %tky   = ls_result_case-%tky
        %param = ls_result_case
      )
    ).

  ENDMETHOD.


  METHOD get_next_case_id.

    DATA lv_max_number  TYPE i VALUE 0.
    DATA lv_id_text     TYPE string.
    DATA lv_number_text TYPE string.
    DATA lv_number      TYPE i.

    SELECT
      FROM zrap200_cc_case
      FIELDS case_id
      WHERE case_id LIKE 'CASE%'
      INTO TABLE @DATA(lt_active_ids).

    LOOP AT lt_active_ids INTO DATA(ls_active_id).

      lv_id_text = CONV string( ls_active_id-case_id ).
      CONDENSE lv_id_text NO-GAPS.

      IF strlen( lv_id_text ) > 4
         AND substring( val = lv_id_text off = 0 len = 4 ) = 'CASE'.

        lv_number_text = substring( val = lv_id_text off = 4 ).

        TRY.
            lv_number = CONV i( lv_number_text ).

            IF lv_number > lv_max_number.
              lv_max_number = lv_number.
            ENDIF.

          CATCH cx_sy_conversion_no_number.
        ENDTRY.

      ENDIF.

    ENDLOOP.

    lv_max_number = lv_max_number + 1.

    rv_case_id = |CASE{ lv_max_number WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.

  ENDMETHOD.

ENDCLASS.


CLASS lhc_RecoveryOption DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS validateScoreRange
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR RecoveryOption~validateScoreRange.

    METHODS validateOptionRequired
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR RecoveryOption~validateOptionRequired.

ENDCLASS.


CLASS lhc_RecoveryOption IMPLEMENTATION.

  METHOD validateScoreRange.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY RecoveryOption
      FIELDS (
        CostScore
        TimeScore
        RiskScore
        FeasibilityScore
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_options).

    LOOP AT lt_options INTO DATA(ls_option).

      IF ls_option-CostScore > 100
         OR ls_option-TimeScore > 100
         OR ls_option-RiskScore > 100
         OR ls_option-FeasibilityScore > 100
         OR ls_option-CostScore < 0
         OR ls_option-TimeScore < 0
         OR ls_option-RiskScore < 0
         OR ls_option-FeasibilityScore < 0.

        APPEND VALUE #(
          %tky = ls_option-%tky
        ) TO failed-recoveryoption.

        APPEND VALUE #(
          %tky = ls_option-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Score values must be between 0 and 100.'
                 )
          %element-CostScore        = if_abap_behv=>mk-on
          %element-TimeScore        = if_abap_behv=>mk-on
          %element-RiskScore        = if_abap_behv=>mk-on
          %element-FeasibilityScore = if_abap_behv=>mk-on
        ) TO reported-recoveryoption.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD validateOptionRequired.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY RecoveryOption
      FIELDS (
        OptionType
        OptionText
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_options).

    LOOP AT lt_options INTO DATA(ls_option).

      IF ls_option-OptionType IS INITIAL
         OR ls_option-OptionText IS INITIAL.

        APPEND VALUE #(
          %tky = ls_option-%tky
        ) TO failed-recoveryoption.

        APPEND VALUE #(
          %tky = ls_option-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Option Type and Option Text are required. Option ID is filled automatically if empty.'
                 )
          %element-OptionType = if_abap_behv=>mk-on
          %element-OptionText = if_abap_behv=>mk-on
        ) TO reported-recoveryoption.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
