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

    DATA(lo_score_srv) = NEW zcl_rap200_cc_score_srv( ).

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

    LOOP AT keys INTO DATA(ls_key).

      READ TABLE lt_cases INTO DATA(ls_case)
        WITH KEY %tky = ls_key-%tky.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(lv_has_options) = abap_false.

      LOOP AT lt_existing_options INTO DATA(ls_existing_option)
        WHERE CaseUUID = ls_case-CaseUUID.
        lv_has_options = abap_true.
        EXIT.
      ENDLOOP.

      IF lv_has_options = abap_true.
        CONTINUE.
      ENDIF.

      DATA(lv_crisis_type_for_create) = to_upper( val = ls_case-CrisisType ).

      IF lv_crisis_type_for_create = 'WEATHER'.

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
                (
                  %cid             = 'OPT001'
                  OptionNo         = '001'
                  OptionID         = 'OPT001'
                  OptionType       = 'PITSTOP'
                  OptionText       = |Weather response for { ls_case-RaceName }: immediate pit stop and tyre change|
                  CostScore        = 60
                  TimeScore        = 85
                  RiskScore        = 80
                  FeasibilityScore = 80
                )
                (
                  %cid             = 'OPT002'
                  OptionNo         = '002'
                  OptionID         = 'OPT002'
                  OptionType       = 'CONTINUE_RACE'
                  OptionText       = |Weather response for { ls_case-RaceName }: continue race without stopping|
                  CostScore        = 90
                  TimeScore        = 85
                  RiskScore        = 25
                  FeasibilityScore = 60
                )
                (
                  %cid             = 'OPT003'
                  OptionNo         = '003'
                  OptionID         = 'OPT003'
                  OptionType       = 'STRATEGY_CHANGE'
                  OptionText       = |Weather response for { ls_case-RaceName }: change strategy and manage pace|
                  CostScore        = 80
                  TimeScore        = 80
                  RiskScore        = 75
                  FeasibilityScore = 85
                )
              )
            )
          )
          FAILED DATA(ls_failed_weather_create)
          REPORTED DATA(ls_reported_weather_create).

      ELSEIF lv_crisis_type_for_create = 'CRASH'.

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
                (
                  %cid             = 'OPT001'
                  OptionNo         = '001'
                  OptionID         = 'OPT001'
                  OptionType       = 'REPAIR_COMPONENT'
                  OptionText       = |Crash response for { ls_case-RaceName }: repair damaged component|
                  CostScore        = 75
                  TimeScore        = 40
                  RiskScore        = 65
                  FeasibilityScore = 60
                )
                (
                  %cid             = 'OPT002'
                  OptionNo         = '002'
                  OptionID         = 'OPT002'
                  OptionType       = 'USE_OLD_SPEC'
                  OptionText       = |Crash response for { ls_case-RaceName }: use older approved specification|
                  CostScore        = 85
                  TimeScore        = 80
                  RiskScore        = 70
                  FeasibilityScore = 85
                )
                (
                  %cid             = 'OPT003'
                  OptionNo         = '003'
                  OptionID         = 'OPT003'
                  OptionType       = 'EMERGENCY_REBUILD'
                  OptionText       = |Crash response for { ls_case-RaceName }: emergency rebuild before session deadline|
                  CostScore        = 45
                  TimeScore        = 70
                  RiskScore        = 75
                  FeasibilityScore = 85
                )
              )
            )
          )
          FAILED DATA(ls_failed_crash_create)
          REPORTED DATA(ls_reported_crash_create).

      ELSEIF lv_crisis_type_for_create = 'LOGISTICS'.

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
                (
                  %cid             = 'OPT001'
                  OptionNo         = '001'
                  OptionID         = 'OPT001'
                  OptionType       = 'EMERGENCY_SHIP'
                  OptionText       = |Logistics response for { ls_case-RaceName }: emergency shipment of critical resource|
                  CostScore        = 45
                  TimeScore        = 90
                  RiskScore        = 70
                  FeasibilityScore = 80
                )
                (
                  %cid             = 'OPT002'
                  OptionNo         = '002'
                  OptionID         = 'OPT002'
                  OptionType       = 'USE_LOCAL_BACKUP'
                  OptionText       = |Logistics response for { ls_case-RaceName }: use local backup resource|
                  CostScore        = 80
                  TimeScore        = 75
                  RiskScore        = 65
                  FeasibilityScore = 75
                )
                (
                  %cid             = 'OPT003'
                  OptionNo         = '003'
                  OptionID         = 'OPT003'
                  OptionType       = 'DELAY_UPGRADE'
                  OptionText       = |Logistics response for { ls_case-RaceName }: delay upgrade package to reduce pressure|
                  CostScore        = 90
                  TimeScore        = 60
                  RiskScore        = 85
                  FeasibilityScore = 90
                )
              )
            )
          )
          FAILED DATA(ls_failed_logistics_create)
          REPORTED DATA(ls_reported_logistics_create).

      ELSEIF lv_crisis_type_for_create = 'COMPLIANCE'.

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
                (
                  %cid             = 'OPT001'
                  OptionNo         = '001'
                  OptionID         = 'OPT001'
                  OptionType       = 'USE_APPROVED_SPEC'
                  OptionText       = |Compliance response for { ls_case-RaceName }: switch to approved specification|
                  CostScore        = 85
                  TimeScore        = 80
                  RiskScore        = 90
                  FeasibilityScore = 90
                )
                (
                  %cid             = 'OPT002'
                  OptionNo         = '002'
                  OptionID         = 'OPT002'
                  OptionType       = 'REQUEST_RECHECK'
                  OptionText       = |Compliance response for { ls_case-RaceName }: request inspection re-check|
                  CostScore        = 70
                  TimeScore        = 55
                  RiskScore        = 60
                  FeasibilityScore = 65
                )
                (
                  %cid             = 'OPT003'
                  OptionNo         = '003'
                  OptionID         = 'OPT003'
                  OptionType       = 'ESCALATE_STEWARD'
                  OptionText       = |Compliance response for { ls_case-RaceName }: escalate to race control/stewards|
                  CostScore        = 60
                  TimeScore        = 50
                  RiskScore        = 75
                  FeasibilityScore = 60
                )
              )
            )
          )
          FAILED DATA(ls_failed_compliance_create)
          REPORTED DATA(ls_reported_compliance_create).

      ELSE.

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
                (
                  %cid             = 'OPT001'
                  OptionNo         = '001'
                  OptionID         = 'OPT001'
                  OptionType       = 'STANDARD_RECOVERY'
                  OptionText       = |Standard recovery for { ls_case-RaceName }|
                  CostScore        = 70
                  TimeScore        = 70
                  RiskScore        = 70
                  FeasibilityScore = 70
                )
                (
                  %cid             = 'OPT002'
                  OptionNo         = '002'
                  OptionID         = 'OPT002'
                  OptionType       = 'ESCALATE'
                  OptionText       = |Escalate case for management decision|
                  CostScore        = 50
                  TimeScore        = 60
                  RiskScore        = 80
                  FeasibilityScore = 75
                )
              )
            )
          )
          FAILED DATA(ls_failed_default_create)
          REPORTED DATA(ls_reported_default_create).

      ENDIF.

    ENDLOOP.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase BY \_RecoveryOptions
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_reloaded_options).

    LOOP AT lt_cases INTO DATA(ls_case_for_scoring).

      DATA lv_best_score TYPE i VALUE -1.
      DATA ls_best_option LIKE LINE OF lt_reloaded_options.
      DATA ls_best_score_result TYPE zcl_rap200_cc_score_srv=>ty_score_result.

      LOOP AT lt_reloaded_options INTO DATA(ls_option)
        WHERE CaseUUID = ls_case_for_scoring-CaseUUID.

        DATA(ls_score) = lo_score_srv->calculate_total_score(
          is_input = VALUE zcl_rap200_cc_score_srv=>ty_score_input(
            cost_score        = ls_option-CostScore
            time_score        = ls_option-TimeScore
            risk_score        = ls_option-RiskScore
            feasibility_score = ls_option-FeasibilityScore
          )
        ).

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY RecoveryOption
          UPDATE FIELDS (
            TotalScore
            Rating
            IsRecommended
            ReasonText
          )
          WITH VALUE #(
            (
              %tky          = ls_option-%tky
              TotalScore    = ls_score-total_score
              Rating        = ls_score-rating
              IsRecommended = ''
              ReasonText    = ''
            )
          )
          FAILED DATA(ls_failed_score_update)
          REPORTED DATA(ls_reported_score_update).

        IF ls_score-total_score > lv_best_score.
          lv_best_score        = ls_score-total_score.
          ls_best_option       = ls_option.
          ls_best_score_result = ls_score.
        ENDIF.

      ENDLOOP.

      IF lv_best_score < 0.
        CONTINUE.
      ENDIF.

      DATA(lv_reason_text) =
        |Recommended option { ls_best_option-OptionType } for { ls_case_for_scoring-CrisisType } crisis with score { ls_best_score_result-total_score }.|.

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY RecoveryOption
        UPDATE FIELDS (
          TotalScore
          Rating
          IsRecommended
          ReasonText
        )
        WITH VALUE #(
          (
            %tky          = ls_best_option-%tky
            TotalScore    = ls_best_score_result-total_score
            Rating        = ls_best_score_result-rating
            IsRecommended = 'X'
            ReasonText    = lv_reason_text
          )
        )
        FAILED DATA(ls_failed_best_update)
        REPORTED DATA(ls_reported_best_update).

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        UPDATE FIELDS (
          RecommendedOptionID
          RecommendedOptionType
          RecommendedScore
          RecommendedRating
          RecommendedText
          Status
        )
        WITH VALUE #(
          (
            %tky                  = ls_case_for_scoring-%tky
            RecommendedOptionID   = ls_best_option-OptionID
            RecommendedOptionType = ls_best_option-OptionType
            RecommendedScore      = ls_best_score_result-total_score
            RecommendedRating     = ls_best_score_result-rating
            RecommendedText       = lv_reason_text
            Status                = 'RECOMMENDED'
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
