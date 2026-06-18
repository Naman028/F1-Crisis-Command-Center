CLASS lhc_CrisisCase DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      BEGIN OF ty_factor_spec,
        factor_no    TYPE zrap200_cc_fact-factor_no,
        factor_type  TYPE zrap200_cc_fact-factor_type,
        impact_level TYPE zrap200_cc_fact-impact_level,
        impact_score TYPE zrap200_cc_fact-impact_score,
        description  TYPE zrap200_cc_fact-description,
        active_flag  TYPE zrap200_cc_fact-active_flag,
      END OF ty_factor_spec.

    TYPES tt_factor_specs TYPE STANDARD TABLE OF ty_factor_spec WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_resource_spec,
        resource_no          TYPE zrap200_cc_cres-resource_no,
        resource_id          TYPE zrap200_cc_cres-resource_id,
        resource_name        TYPE zrap200_cc_cres-resource_name,
        resource_type        TYPE zrap200_cc_cres-resource_type,
        approval_status      TYPE zrap200_cc_cres-approval_status,
        available_flag       TYPE zrap200_cc_cres-available_flag,
        lead_hours           TYPE zrap200_cc_cres-lead_hours,
        base_cost            TYPE zrap200_cc_cres-base_cost,
        currency             TYPE zrap200_cc_cres-currency,
        performance_loss_pct TYPE zrap200_cc_cres-performance_loss_pct,
        reliability_risk_pct TYPE zrap200_cc_cres-reliability_risk_pct,
        co2_kg               TYPE zrap200_cc_cres-co2_kg,
        fit_score            TYPE zrap200_cc_cres-fit_score,
        selected_flag        TYPE zrap200_cc_cres-selected_flag,
        reason_text          TYPE zrap200_cc_cres-reason_text,
      END OF ty_resource_spec.

    TYPES tt_resource_specs TYPE STANDARD TABLE OF ty_resource_spec WITH EMPTY KEY.

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

    METHODS setRaceNameFromRaceID
      FOR DETERMINE ON MODIFY
      IMPORTING keys FOR CrisisCase~setRaceNameFromRaceID.

    METHODS validateRaceID
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR CrisisCase~validateRaceID.

    METHODS get_next_case_id
      RETURNING
        VALUE(rv_case_id) TYPE zrap200_cc_case-case_id.

    METHODS get_timestamp_text
      RETURNING
        VALUE(rv_timestamp_text) TYPE zrap200_cc_case-created_at.

    METHODS get_current_user
      RETURNING
        VALUE(rv_user) TYPE zrap200_cc_case-created_by.

    METHODS build_crisis_factors
      IMPORTING
        iv_case_id     TYPE zrap200_cc_case-case_id
        iv_crisis_type TYPE zrap200_cc_case-crisis_type
        iv_severity    TYPE zrap200_cc_case-severity
      RETURNING
        VALUE(rt_factors) TYPE tt_factor_specs.

    METHODS build_case_resources
      IMPORTING
        iv_case_id     TYPE zrap200_cc_case-case_id
        iv_crisis_type TYPE zrap200_cc_case-crisis_type
        iv_severity    TYPE zrap200_cc_case-severity
      RETURNING
        VALUE(rt_resources) TYPE tt_resource_specs.

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


  METHOD build_crisis_factors.

    DATA(lv_base_score) = SWITCH i(
      iv_severity
      WHEN 'CRITICAL' THEN 95
      WHEN 'HIGH'     THEN 85
      WHEN 'MEDIUM'   THEN 65
      WHEN 'LOW'      THEN 40
      ELSE 55
    ).

    CASE iv_crisis_type.

      WHEN 'WEATHER'.

        rt_factors = VALUE #(
          (
            factor_no    = '001'
            factor_type  = 'TRACK_CONDITION'
            impact_level = iv_severity
            impact_score = lv_base_score
            description  = |Track condition risk generated for case { iv_case_id }.|
            active_flag  = abap_true
          )
          (
            factor_no    = '002'
            factor_type  = 'RAIN_PROBABILITY'
            impact_level = iv_severity
            impact_score = lv_base_score - 5
            description  = |Weather uncertainty affects tyre and race strategy.|
            active_flag  = abap_true
          )
          (
            factor_no    = '003'
            factor_type  = 'SAFETY_RISK'
            impact_level = iv_severity
            impact_score = lv_base_score - 10
            description  = |Safety risk considered for wet or changing race conditions.|
            active_flag  = abap_true
          )
        ).

      WHEN 'CRASH'.

        rt_factors = VALUE #(
          (
            factor_no    = '001'
            factor_type  = 'DAMAGE_SEVERITY'
            impact_level = iv_severity
            impact_score = lv_base_score
            description  = |Crash damage severity generated for case { iv_case_id }.|
            active_flag  = abap_true
          )
          (
            factor_no    = '002'
            factor_type  = 'PARTS_AVAILABILITY'
            impact_level = iv_severity
            impact_score = lv_base_score - 8
            description  = |Availability of replacement parts affects recovery decision.|
            active_flag  = abap_true
          )
          (
            factor_no    = '003'
            factor_type  = 'REPAIR_TIME'
            impact_level = iv_severity
            impact_score = lv_base_score - 12
            description  = |Repair time pressure is considered before recommendation.|
            active_flag  = abap_true
          )
        ).

      WHEN 'LOGISTICS'.

        rt_factors = VALUE #(
          (
            factor_no    = '001'
            factor_type  = 'SHIPPING_DELAY'
            impact_level = iv_severity
            impact_score = lv_base_score
            description  = |Shipping delay pressure generated for case { iv_case_id }.|
            active_flag  = abap_true
          )
          (
            factor_no    = '002'
            factor_type  = 'SPARE_PART_ACCESS'
            impact_level = iv_severity
            impact_score = lv_base_score - 7
            description  = |Spare part access affects logistics recovery planning.|
            active_flag  = abap_true
          )
          (
            factor_no    = '003'
            factor_type  = 'CREW_PRESSURE'
            impact_level = iv_severity
            impact_score = lv_base_score - 11
            description  = |Crew workload and time pressure are included in decision context.|
            active_flag  = abap_true
          )
        ).

      WHEN 'COMPLIANCE'.

        rt_factors = VALUE #(
          (
            factor_no    = '001'
            factor_type  = 'FIA_APPROVAL'
            impact_level = iv_severity
            impact_score = lv_base_score
            description  = |FIA approval risk generated for case { iv_case_id }.|
            active_flag  = abap_true
          )
          (
            factor_no    = '002'
            factor_type  = 'REGULATION_RISK'
            impact_level = iv_severity
            impact_score = lv_base_score - 5
            description  = |Regulation risk affects whether the option can be executed.|
            active_flag  = abap_true
          )
          (
            factor_no    = '003'
            factor_type  = 'DOCUMENTATION'
            impact_level = iv_severity
            impact_score = lv_base_score - 10
            description  = |Documentation readiness is considered for compliance handling.|
            active_flag  = abap_true
          )
        ).

      WHEN OTHERS.

        rt_factors = VALUE #(
          (
            factor_no    = '001'
            factor_type  = 'GENERAL_RISK'
            impact_level = iv_severity
            impact_score = lv_base_score
            description  = |General crisis risk generated for case { iv_case_id }.|
            active_flag  = abap_true
          )
          (
            factor_no    = '002'
            factor_type  = 'EXECUTION_PRESSURE'
            impact_level = iv_severity
            impact_score = lv_base_score - 5
            description  = |Execution pressure affects recovery planning.|
            active_flag  = abap_true
          )
          (
            factor_no    = '003'
            factor_type  = 'OPERATIONAL_IMPACT'
            impact_level = iv_severity
            impact_score = lv_base_score - 10
            description  = |Operational impact is included in recommendation context.|
            active_flag  = abap_true
          )
        ).

    ENDCASE.

  ENDMETHOD.


  METHOD build_case_resources.

    DATA(lv_primary_fit) = SWITCH i(
      iv_severity
      WHEN 'CRITICAL' THEN 96
      WHEN 'HIGH'     THEN 90
      WHEN 'MEDIUM'   THEN 78
      WHEN 'LOW'      THEN 65
      ELSE 72
    ).

    CASE iv_crisis_type.

      WHEN 'WEATHER'.

        rt_resources = VALUE #(
          (
            resource_no          = '001'
            resource_id          = 'DYNWET001'
            resource_name        = 'Wet Tyre Strategy Set'
            resource_type        = 'TYRE'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 2
            base_cost            = '18000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.50'
            reliability_risk_pct = '4.00'
            co2_kg               = '70.00'
            fit_score            = lv_primary_fit
            selected_flag        = abap_true
            reason_text          = |Selected for weather crisis because tyre response is time critical.|
          )
          (
            resource_no          = '002'
            resource_id          = 'DYNMET002'
            resource_name        = 'Weather Radar Support'
            resource_type        = 'STRATEGY'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 1
            base_cost            = '9000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '3.00'
            co2_kg               = '20.00'
            fit_score            = lv_primary_fit - 8
            selected_flag        = abap_false
            reason_text          = |Supports live weather monitoring and strategy updates.|
          )
          (
            resource_no          = '003'
            resource_id          = 'DYNSET003'
            resource_name        = 'Setup Adjustment Crew'
            resource_type        = 'CREW'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 3
            base_cost            = '22000.00'
            currency             = 'EUR'
            performance_loss_pct = '1.00'
            reliability_risk_pct = '5.00'
            co2_kg               = '55.00'
            fit_score            = lv_primary_fit - 15
            selected_flag        = abap_false
            reason_text          = |Useful if weather requires setup change before session.|
          )
        ).

      WHEN 'CRASH'.

        rt_resources = VALUE #(
          (
            resource_no          = '001'
            resource_id          = 'DYNFW001'
            resource_name        = 'Front Wing Replacement Kit'
            resource_type        = 'AERO'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 4
            base_cost            = '85000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '5.00'
            co2_kg               = '420.00'
            fit_score            = lv_primary_fit
            selected_flag        = abap_true
            reason_text          = |Selected for crash crisis because aero replacement is fastest safe recovery.|
          )
          (
            resource_no          = '002'
            resource_id          = 'DYNSUS002'
            resource_name        = 'Suspension Repair Kit'
            resource_type        = 'MECHANICAL'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 6
            base_cost            = '65000.00'
            currency             = 'EUR'
            performance_loss_pct = '1.50'
            reliability_risk_pct = '8.00'
            co2_kg               = '210.00'
            fit_score            = lv_primary_fit - 9
            selected_flag        = abap_false
            reason_text          = |Supports structural recovery after crash impact.|
          )
          (
            resource_no          = '003'
            resource_id          = 'DYNINS003'
            resource_name        = 'Damage Inspection Crew'
            resource_type        = 'CREW'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 2
            base_cost            = '12000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '2.00'
            co2_kg               = '40.00'
            fit_score            = lv_primary_fit - 14
            selected_flag        = abap_false
            reason_text          = |Required to confirm safety before returning car to session.|
          )
        ).

      WHEN 'LOGISTICS'.

        rt_resources = VALUE #(
          (
            resource_no          = '001'
            resource_id          = 'DYNSHP001'
            resource_name        = 'Emergency Air Freight'
            resource_type        = 'LOGISTICS'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 6
            base_cost            = '65000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '10.00'
            co2_kg               = '900.00'
            fit_score            = lv_primary_fit
            selected_flag        = abap_true
            reason_text          = |Selected for logistics crisis because emergency freight reduces delivery delay.|
          )
          (
            resource_no          = '002'
            resource_id          = 'DYNLOC002'
            resource_name        = 'Local Supplier Backup'
            resource_type        = 'SUPPLIER'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 12
            base_cost            = '38000.00'
            currency             = 'EUR'
            performance_loss_pct = '2.00'
            reliability_risk_pct = '12.00'
            co2_kg               = '180.00'
            fit_score            = lv_primary_fit - 8
            selected_flag        = abap_false
            reason_text          = |Useful if primary shipment cannot arrive before deadline.|
          )
          (
            resource_no          = '003'
            resource_id          = 'DYNTRK003'
            resource_name        = 'Fast Track Customs Support'
            resource_type        = 'TRANSPORT'
            approval_status      = 'PENDING'
            available_flag       = abap_true
            lead_hours           = 8
            base_cost            = '24000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '15.00'
            co2_kg               = '130.00'
            fit_score            = lv_primary_fit - 16
            selected_flag        = abap_false
            reason_text          = |Reduces customs delay but has approval dependency.|
          )
        ).

      WHEN 'COMPLIANCE'.

        rt_resources = VALUE #(
          (
            resource_no          = '001'
            resource_id          = 'DYNFIA001'
            resource_name        = 'FIA Documentation Package'
            resource_type        = 'APPROVAL'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 3
            base_cost            = '15000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '3.00'
            co2_kg               = '25.00'
            fit_score            = lv_primary_fit
            selected_flag        = abap_true
            reason_text          = |Selected for compliance crisis because documentation approval is mandatory.|
          )
          (
            resource_no          = '002'
            resource_id          = 'DYNREG002'
            resource_name        = 'Regulation Review Engineer'
            resource_type        = 'REGULATION'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 5
            base_cost            = '18000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '5.00'
            co2_kg               = '30.00'
            fit_score            = lv_primary_fit - 7
            selected_flag        = abap_false
            reason_text          = |Checks legality risk before option execution.|
          )
          (
            resource_no          = '003'
            resource_id          = 'DYNSCR003'
            resource_name        = 'Scrutineering Support Crew'
            resource_type        = 'APPROVAL'
            approval_status      = 'PENDING'
            available_flag       = abap_true
            lead_hours           = 7
            base_cost            = '21000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '9.00'
            co2_kg               = '45.00'
            fit_score            = lv_primary_fit - 14
            selected_flag        = abap_false
            reason_text          = |Useful when FIA inspection support is required.|
          )
        ).

      WHEN OTHERS.

        rt_resources = VALUE #(
          (
            resource_no          = '001'
            resource_id          = 'DYNGEN001'
            resource_name        = 'General Recovery Crew'
            resource_type        = 'CREW'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 4
            base_cost            = '30000.00'
            currency             = 'EUR'
            performance_loss_pct = '1.00'
            reliability_risk_pct = '8.00'
            co2_kg               = '100.00'
            fit_score            = lv_primary_fit
            selected_flag        = abap_true
            reason_text          = |Selected as general recovery support for this crisis.|
          )
          (
            resource_no          = '002'
            resource_id          = 'DYNOPS002'
            resource_name        = 'Operations Support Desk'
            resource_type        = 'OPERATIONS'
            approval_status      = 'APPROVED'
            available_flag       = abap_true
            lead_hours           = 2
            base_cost            = '12000.00'
            currency             = 'EUR'
            performance_loss_pct = '0.00'
            reliability_risk_pct = '4.00'
            co2_kg               = '20.00'
            fit_score            = lv_primary_fit - 10
            selected_flag        = abap_false
            reason_text          = |Supports operational coordination for crisis handling.|
          )
          (
            resource_no          = '003'
            resource_id          = 'DYNBKP003'
            resource_name        = 'Backup Parts Access'
            resource_type        = 'PARTS'
            approval_status      = 'PENDING'
            available_flag       = abap_true
            lead_hours           = 10
            base_cost            = '42000.00'
            currency             = 'EUR'
            performance_loss_pct = '2.00'
            reliability_risk_pct = '12.00'
            co2_kg               = '160.00'
            fit_score            = lv_primary_fit - 18
            selected_flag        = abap_false
            reason_text          = |Backup resource if primary recovery path becomes unavailable.|
          )
        ).

    ENDCASE.

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


  METHOD setRaceNameFromRaceID.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      FIELDS (
        RaceID
        RaceName
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    DATA lt_update TYPE TABLE FOR UPDATE zi_rap200_cc_case.

    LOOP AT lt_cases INTO DATA(ls_case).

      IF ls_case-RaceID IS INITIAL.

        IF ls_case-RaceName IS NOT INITIAL.
          APPEND VALUE #(
            %tky     = ls_case-%tky
            RaceName = ''
          ) TO lt_update.
        ENDIF.

        CONTINUE.

      ENDIF.

      SELECT SINGLE
        FROM zrap200_cc_race
        FIELDS race_name
        WHERE race_id = @ls_case-RaceID
          AND active_flag = @abap_true
        INTO @DATA(lv_race_name).

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      IF ls_case-RaceName = lv_race_name.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        %tky     = ls_case-%tky
        RaceName = lv_race_name
      ) TO lt_update.

    ENDLOOP.

    IF lt_update IS NOT INITIAL.

      MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
        ENTITY CrisisCase
        UPDATE FIELDS (
          RaceName
        )
        WITH lt_update
        FAILED DATA(ls_failed_race_name)
        REPORTED DATA(ls_reported_race_name).

    ENDIF.

  ENDMETHOD.


  METHOD validateRaceID.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      FIELDS (
        RaceID
      )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    LOOP AT lt_cases INTO DATA(ls_case).

      IF ls_case-RaceID IS INITIAL.

        APPEND VALUE #(
          %tky = ls_case-%tky
        ) TO failed-crisiscase.

        APPEND VALUE #(
          %tky = ls_case-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Please select a valid F1 race from the Race value help.'
                 )
          %element-RaceID = if_abap_behv=>mk-on
        ) TO reported-crisiscase.

        CONTINUE.

      ENDIF.

      SELECT SINGLE
        FROM zrap200_cc_race
        FIELDS race_id
        WHERE race_id = @ls_case-RaceID
          AND active_flag = @abap_true
        INTO @DATA(lv_valid_race_id).

      IF sy-subrc <> 0.

        APPEND VALUE #(
          %tky = ls_case-%tky
        ) TO failed-crisiscase.

        APPEND VALUE #(
          %tky = ls_case-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Invalid Race. Please select a race from the Race value help.'
                 )
          %element-RaceID = if_abap_behv=>mk-on
        ) TO reported-crisiscase.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD generateAndRecommendOptions.

    DATA(lo_dec_engine) = NEW zcl_rap200_cc_dec_engine( ).
    DATA(lo_score_srv)  = NEW zcl_rap200_cc_score_srv( ).
    DATA(lo_log_srv)    = NEW zcl_rap200_cc_log_srv( ).

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

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase BY \_CrisisFactors
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_existing_factors).

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase BY \_CaseResources
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_existing_case_resources).

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

        DATA(lv_is_recommended) = VALUE zrap200_cc_opt-is_recommended( ).
        DATA(lv_option_reason)  = VALUE zrap200_cc_opt-reason_text( ).

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

      LOOP AT lt_existing_factors USING KEY entity INTO DATA(ls_existing_factor_delete)
        WHERE CaseUUID = ls_case_for_scoring-CaseUUID.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY CrisisFactor
          DELETE FROM VALUE #(
            (
              %tky = ls_existing_factor_delete-%tky
            )
          )
          FAILED DATA(ls_failed_factor_delete)
          REPORTED DATA(ls_reported_factor_delete).

      ENDLOOP.

      DATA(lt_generated_factors) = build_crisis_factors(
        iv_case_id     = ls_case_for_scoring-CaseID
        iv_crisis_type = ls_case_for_scoring-CrisisType
        iv_severity    = ls_case_for_scoring-Severity
      ).

      IF lt_generated_factors IS NOT INITIAL.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY CrisisCase
          CREATE BY \_CrisisFactors
          FIELDS (
            FactorNo
            CaseID
            FactorType
            ImpactLevel
            ImpactScore
            Description
            ActiveFlag
          )
          WITH VALUE #(
            (
              %tky = ls_case_for_scoring-%tky
              %target = VALUE #(
                FOR ls_generated_factor IN lt_generated_factors
                (
                  %cid        = |FAC{ ls_case_for_scoring-CaseID }{ ls_generated_factor-factor_no }|
                  FactorNo    = ls_generated_factor-factor_no
                  CaseID      = ls_case_for_scoring-CaseID
                  FactorType  = ls_generated_factor-factor_type
                  ImpactLevel = ls_generated_factor-impact_level
                  ImpactScore = ls_generated_factor-impact_score
                  Description = ls_generated_factor-description
                  ActiveFlag  = ls_generated_factor-active_flag
                )
              )
            )
          )
          FAILED DATA(ls_failed_factor_create)
          REPORTED DATA(ls_reported_factor_create).

      ENDIF.

      LOOP AT lt_existing_case_resources USING KEY entity INTO DATA(ls_existing_resource_delete)
        WHERE CaseUUID = ls_case_for_scoring-CaseUUID.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY CaseResource
          DELETE FROM VALUE #(
            (
              %tky = ls_existing_resource_delete-%tky
            )
          )
          FAILED DATA(ls_failed_resource_delete)
          REPORTED DATA(ls_reported_resource_delete).

      ENDLOOP.

      DATA(lt_generated_resources) = build_case_resources(
        iv_case_id     = ls_case_for_scoring-CaseID
        iv_crisis_type = ls_case_for_scoring-CrisisType
        iv_severity    = ls_case_for_scoring-Severity
      ).

      IF lt_generated_resources IS NOT INITIAL.

        MODIFY ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
          ENTITY CrisisCase
          CREATE BY \_CaseResources
          FIELDS (
            ResourceNo
            CaseID
            ResourceID
            ResourceName
            ResourceType
            ApprovalStatus
            AvailableFlag
            LeadHours
            BaseCost
            Currency
            PerformanceLossPct
            ReliabilityRiskPct
            Co2Kg
            FitScore
            SelectedFlag
            ReasonText
          )
          WITH VALUE #(
            (
              %tky = ls_case_for_scoring-%tky
              %target = VALUE #(
                FOR ls_generated_resource IN lt_generated_resources
                (
                  %cid                  = |RES{ ls_case_for_scoring-CaseID }{ ls_generated_resource-resource_no }|
                  ResourceNo            = ls_generated_resource-resource_no
                  CaseID                = ls_case_for_scoring-CaseID
                  ResourceID            = ls_generated_resource-resource_id
                  ResourceName          = ls_generated_resource-resource_name
                  ResourceType          = ls_generated_resource-resource_type
                  ApprovalStatus        = ls_generated_resource-approval_status
                  AvailableFlag         = ls_generated_resource-available_flag
                  LeadHours             = ls_generated_resource-lead_hours
                  BaseCost              = ls_generated_resource-base_cost
                  Currency              = ls_generated_resource-currency
                  PerformanceLossPct    = ls_generated_resource-performance_loss_pct
                  ReliabilityRiskPct    = ls_generated_resource-reliability_risk_pct
                  Co2Kg                 = ls_generated_resource-co2_kg
                  FitScore              = ls_generated_resource-fit_score
                  SelectedFlag          = ls_generated_resource-selected_flag
                  ReasonText            = ls_generated_resource-reason_text
                )
              )
            )
          )
          FAILED DATA(ls_failed_resource_create)
          REPORTED DATA(ls_reported_resource_create).

      ENDIF.

      DATA(ls_log_entry) = lo_log_srv->build_recommendation_log(
        is_log_entry = VALUE zcl_rap200_cc_log_srv=>ty_log_entry(
          case_uuid               = ls_case_for_scoring-CaseUUID
          case_id                 = ls_case_for_scoring-CaseID
          crisis_type             = ls_case_for_scoring-CrisisType
          severity                = ls_case_for_scoring-Severity
          recommended_option_id   = ls_recommendation-option_id
          recommended_option_type = ls_recommendation-option_type
          recommended_score       = ls_recommendation-total_score
          recommended_rating      = ls_recommendation-rating
          reason_text             = lv_reason_text
        )
      ).

      IF ls_log_entry-log_no IS NOT INITIAL.

        MODIFY ENTITIES OF zi_rap200_cc_log
          ENTITY DecisionLog
          CREATE FIELDS (
            CaseUUID
            LogNo
            CaseID
            CrisisType
            Severity
            RecommendedOptionID
            RecommendedOptionType
            RecommendedScore
            RecommendedRating
            ReasonText
            CreatedBy
            CreatedAt
          )
          WITH VALUE #(
            (
              %cid                  = |LOG{ ls_log_entry-log_no }|
              CaseUUID              = ls_log_entry-case_uuid
              LogNo                 = ls_log_entry-log_no
              CaseID                = ls_log_entry-case_id
              CrisisType            = ls_log_entry-crisis_type
              Severity              = ls_log_entry-severity
              RecommendedOptionID   = ls_log_entry-recommended_option_id
              RecommendedOptionType = ls_log_entry-recommended_option_type
              RecommendedScore      = ls_log_entry-recommended_score
              RecommendedRating     = ls_log_entry-recommended_rating
              ReasonText            = ls_log_entry-reason_text
              CreatedBy             = ls_log_entry-created_by
              CreatedAt             = ls_log_entry-created_at
            )
          )
          FAILED DATA(ls_failed_log_create)
          REPORTED DATA(ls_reported_log_create).

      ENDIF.

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
