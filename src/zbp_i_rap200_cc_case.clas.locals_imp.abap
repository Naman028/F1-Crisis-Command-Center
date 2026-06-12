CLASS lhc_CrisisCase DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_generated_option,
             option_no         TYPE zrap200_cc_opt-option_no,
             option_id         TYPE zrap200_cc_opt-option_id,
             option_type       TYPE zrap200_cc_opt-option_type,
             option_text       TYPE zrap200_cc_opt-option_text,
             cost_score        TYPE zrap200_cc_opt-cost_score,
             time_score        TYPE zrap200_cc_opt-time_score,
             risk_score        TYPE zrap200_cc_opt-risk_score,
             feasibility_score TYPE zrap200_cc_opt-feasibility_score,
             total_score       TYPE zrap200_cc_opt-total_score,
             rating            TYPE zrap200_cc_opt-rating,
             is_recommended    TYPE zrap200_cc_opt-is_recommended,
             reason_text       TYPE zrap200_cc_opt-reason_text,
           END OF ty_generated_option.

    TYPES tt_generated_options TYPE STANDARD TABLE OF ty_generated_option WITH EMPTY KEY.

    METHODS generateAndRecommendOptions
      FOR MODIFY
      IMPORTING keys FOR ACTION CrisisCase~generateAndRecommendOptions
      RESULT result.

    METHODS setInitialCaseData
      FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CrisisCase~setInitialCaseData.

    METHODS calculate_score_for_option
      CHANGING
        cs_option TYPE ty_generated_option.

    METHODS get_next_case_id
      RETURNING
        VALUE(rv_case_id) TYPE zrap200_cc_case-case_id.

ENDCLASS.


CLASS lhc_CrisisCase IMPLEMENTATION.

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

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time( ).
    DATA(lv_user)        = cl_abap_context_info=>get_user_technical_name( ).

    DATA(lv_timestamp_text) = |{ lv_system_date DATE = ISO } { lv_system_time TIME = ISO }|.

    DATA lt_update TYPE TABLE FOR UPDATE zi_rap200_cc_case\\CrisisCase.

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

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      FIELDS (
        CaseUUID
        CaseID
        CaseTitle
        RaceID
        RaceName
        CrisisType
        Severity
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_cases INTO DATA(ls_case)
        WITH KEY %tky = ls_key-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF ls_case-CaseID IS INITIAL.
        ls_case-CaseID = get_next_case_id( ).
      ENDIF.

      READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase BY \_RecoveryOptions
        FROM VALUE #(
          (
            %tky = ls_key-%tky
          )
        )
        RESULT DATA(lt_old_options).

      IF lt_old_options IS NOT INITIAL.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY RecoveryOption
          DELETE FROM VALUE #(
            FOR ls_old_option IN lt_old_options
            (
              %tky = ls_old_option-%tky
            )
          )
          FAILED DATA(ls_failed_delete)
          REPORTED DATA(ls_reported_delete).

      ENDIF.

      DATA lt_generated_options TYPE tt_generated_options.

      DATA(lv_crisis_type) = to_upper( val = ls_case-CrisisType ).
      DATA(lv_severity)    = to_upper( val = ls_case-Severity ).

      DATA(lv_severity_boost) = 0.

      CASE lv_severity.
        WHEN 'CRITICAL'.
          lv_severity_boost = 15.
        WHEN 'HIGH'.
          lv_severity_boost = 10.
        WHEN 'MEDIUM'.
          lv_severity_boost = 5.
        WHEN OTHERS.
          lv_severity_boost = 0.
      ENDCASE.

      CASE lv_crisis_type.

        WHEN 'WEATHER'.

          lt_generated_options = VALUE #(
            (
              option_no         = '001'
              option_id         = 'OPT001'
              option_type       = 'PITSTOP'
              option_text       = |Weather response for { ls_case-RaceName }: immediate pit stop and tyre change|
              cost_score        = 60
              time_score        = 75 + lv_severity_boost
              risk_score        = 80
              feasibility_score = 70 + lv_severity_boost
            )
            (
              option_no         = '002'
              option_id         = 'OPT002'
              option_type       = 'CONTINUE_RACE'
              option_text       = |Weather response for { ls_case-RaceName }: continue race without stopping|
              cost_score        = 90
              time_score        = 85
              risk_score        = 35 - lv_severity_boost
              feasibility_score = 60
            )
            (
              option_no         = '003'
              option_id         = 'OPT003'
              option_type       = 'STRATEGY_CHANGE'
              option_text       = |Weather response for { ls_case-RaceName }: change strategy and manage pace|
              cost_score        = 80
              time_score        = 70 + lv_severity_boost
              risk_score        = 75
              feasibility_score = 85
            )
          ).

        WHEN 'CRASH'.

          lt_generated_options = VALUE #(
            (
              option_no         = '001'
              option_id         = 'OPT001'
              option_type       = 'REPAIR_COMPONENT'
              option_text       = |Crash response for { ls_case-RaceName }: repair damaged component|
              cost_score        = 75
              time_score        = 55 - lv_severity_boost
              risk_score        = 65
              feasibility_score = 60
            )
            (
              option_no         = '002'
              option_id         = 'OPT002'
              option_type       = 'USE_OLD_SPEC'
              option_text       = |Crash response for { ls_case-RaceName }: use older approved specification|
              cost_score        = 85
              time_score        = 80
              risk_score        = 70
              feasibility_score = 85
            )
            (
              option_no         = '003'
              option_id         = 'OPT003'
              option_type       = 'EMERGENCY_REBUILD'
              option_text       = |Crash response for { ls_case-RaceName }: emergency rebuild before session deadline|
              cost_score        = 45
              time_score        = 70
              risk_score        = 75
              feasibility_score = 70 + lv_severity_boost
            )
          ).

        WHEN 'LOGISTICS'.

          lt_generated_options = VALUE #(
            (
              option_no         = '001'
              option_id         = 'OPT001'
              option_type       = 'EMERGENCY_SHIP'
              option_text       = |Logistics response for { ls_case-RaceName }: emergency shipment of critical resource|
              cost_score        = 45
              time_score        = 90
              risk_score        = 70
              feasibility_score = 80
            )
            (
              option_no         = '002'
              option_id         = 'OPT002'
              option_type       = 'USE_LOCAL_BACKUP'
              option_text       = |Logistics response for { ls_case-RaceName }: use local backup resource|
              cost_score        = 80
              time_score        = 75
              risk_score        = 65
              feasibility_score = 75
            )
            (
              option_no         = '003'
              option_id         = 'OPT003'
              option_type       = 'DELAY_UPGRADE'
              option_text       = |Logistics response for { ls_case-RaceName }: delay upgrade package to reduce pressure|
              cost_score        = 90
              time_score        = 60
              risk_score        = 85
              feasibility_score = 90
            )
          ).

        WHEN 'COMPLIANCE'.

          lt_generated_options = VALUE #(
            (
              option_no         = '001'
              option_id         = 'OPT001'
              option_type       = 'USE_APPROVED_SPEC'
              option_text       = |Compliance response for { ls_case-RaceName }: switch to approved specification|
              cost_score        = 85
              time_score        = 80
              risk_score        = 90
              feasibility_score = 90
            )
            (
              option_no         = '002'
              option_id         = 'OPT002'
              option_type       = 'REQUEST_RECHECK'
              option_text       = |Compliance response for { ls_case-RaceName }: request inspection re-check|
              cost_score        = 70
              time_score        = 55
              risk_score        = 60
              feasibility_score = 65
            )
            (
              option_no         = '003'
              option_id         = 'OPT003'
              option_type       = 'ESCALATE_STEWARD'
              option_text       = |Compliance response for { ls_case-RaceName }: escalate to race control/stewards|
              cost_score        = 60
              time_score        = 50
              risk_score        = 75
              feasibility_score = 60
            )
          ).

        WHEN OTHERS.

          lt_generated_options = VALUE #(
            (
              option_no         = '001'
              option_id         = 'OPT001'
              option_type       = 'STANDARD_RECOVERY'
              option_text       = |Standard recovery for { ls_case-RaceName }|
              cost_score        = 70
              time_score        = 70
              risk_score        = 70
              feasibility_score = 70
            )
            (
              option_no         = '002'
              option_id         = 'OPT002'
              option_type       = 'ESCALATE'
              option_text       = |Escalate case for management decision|
              cost_score        = 50
              time_score        = 60
              risk_score        = 80
              feasibility_score = 75
            )
          ).

      ENDCASE.

      LOOP AT lt_generated_options ASSIGNING FIELD-SYMBOL(<ls_generated_option>).

        calculate_score_for_option(
          CHANGING
            cs_option = <ls_generated_option>
        ).

      ENDLOOP.

      SORT lt_generated_options BY total_score DESCENDING.

      READ TABLE lt_generated_options INTO DATA(ls_best_option) INDEX 1.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_reason_text) =
        |Recommended option { ls_best_option-option_type } for { lv_crisis_type } crisis with score { ls_best_option-total_score }.|.

      LOOP AT lt_generated_options ASSIGNING <ls_generated_option>.

        IF <ls_generated_option>-option_id = ls_best_option-option_id.
          <ls_generated_option>-is_recommended = 'X'.
          <ls_generated_option>-reason_text    = lv_reason_text.
        ELSE.
          <ls_generated_option>-is_recommended = ''.
          <ls_generated_option>-reason_text    = ''.
        ENDIF.

      ENDLOOP.

      SORT lt_generated_options BY option_no ASCENDING.

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
          TotalScore
          Rating
          IsRecommended
          ReasonText
        )
        WITH VALUE #(
          (
            %tky = ls_key-%tky
            %target = VALUE #(
              FOR ls_generated_option IN lt_generated_options
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
                TotalScore       = ls_generated_option-total_score
                Rating           = ls_generated_option-rating
                IsRecommended    = ls_generated_option-is_recommended
                ReasonText       = ls_generated_option-reason_text
              )
            )
          )
        )
        FAILED DATA(ls_failed_create)
        REPORTED DATA(ls_reported_create).

      DATA(lv_system_date_update) = cl_abap_context_info=>get_system_date( ).
      DATA(lv_system_time_update) = cl_abap_context_info=>get_system_time( ).
      DATA(lv_user_update)        = cl_abap_context_info=>get_user_technical_name( ).

      DATA(lv_timestamp_text_update) = |{ lv_system_date_update DATE = ISO } { lv_system_time_update TIME = ISO }|.

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        UPDATE FIELDS (
          CaseID
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
            %tky                  = ls_key-%tky
            CaseID                = ls_case-CaseID
            RecommendedOptionID   = ls_best_option-option_id
            RecommendedOptionType = ls_best_option-option_type
            RecommendedScore      = ls_best_option-total_score
            RecommendedRating     = ls_best_option-rating
            RecommendedText       = lv_reason_text
            Status                = 'RECOMMENDED'
            LastChangedBy         = lv_user_update
            LastChangedAt         = lv_timestamp_text_update
          )
        )
        FAILED DATA(ls_failed_update)
        REPORTED DATA(ls_reported_update).

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


  METHOD calculate_score_for_option.

    DATA(lo_score_srv) = NEW zcl_rap200_cc_score_srv( ).

    DATA(ls_score) = lo_score_srv->calculate_total_score(
      is_input = VALUE zcl_rap200_cc_score_srv=>ty_score_input(
        cost_score        = cs_option-cost_score
        time_score        = cs_option-time_score
        risk_score        = cs_option-risk_score
        feasibility_score = cs_option-feasibility_score
      )
    ).

    cs_option-total_score = ls_score-total_score.
    cs_option-rating      = ls_score-rating.

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
