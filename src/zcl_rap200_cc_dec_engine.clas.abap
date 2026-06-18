CLASS zcl_rap200_cc_dec_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_case_uuid   TYPE sysuuid_x16.
    TYPES ty_option_id   TYPE zrap200_cc_opt-option_id.
    TYPES ty_option_type TYPE zrap200_cc_opt-option_type.
    TYPES ty_rating      TYPE zrap200_cc_opt-rating.

    TYPES:
      BEGIN OF ty_case_context,
        crisis_type TYPE zrap200_cc_case-crisis_type,
        severity    TYPE zrap200_cc_case-severity,
        race_name   TYPE zrap200_cc_case-race_name,
      END OF ty_case_context.

    TYPES:
      BEGIN OF ty_option,
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
      END OF ty_option.

    TYPES tt_options TYPE STANDARD TABLE OF ty_option WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_recommendation,
        option_id   TYPE ty_option_id,
        option_type TYPE ty_option_type,
        total_score TYPE i,
        rating      TYPE ty_rating,
        reason_text TYPE zrap200_cc_opt-reason_text,
      END OF ty_recommendation.

    TYPES:
      BEGIN OF ty_decision_result,
        options        TYPE tt_options,
        recommendation TYPE ty_recommendation,
      END OF ty_decision_result.

    METHODS build_decision
      IMPORTING
        is_case_context     TYPE ty_case_context
      RETURNING
        VALUE(rs_decision)  TYPE ty_decision_result.

    METHODS generate_options
      IMPORTING
        is_case_context    TYPE ty_case_context
      RETURNING
        VALUE(rt_options)  TYPE tt_options.

    METHODS recommend_best_option
      IMPORTING
        it_options                TYPE tt_options
      RETURNING
        VALUE(rs_recommendation)  TYPE ty_recommendation.

    METHODS recommend_best_option_for_case
      IMPORTING
        iv_case_uuid              TYPE ty_case_uuid
      RETURNING
        VALUE(rs_recommendation)  TYPE ty_recommendation.

    METHODS generate_recommend_for_case
      IMPORTING
        iv_case_uuid              TYPE ty_case_uuid
      RETURNING
        VALUE(rs_recommendation)  TYPE ty_recommendation.

  PRIVATE SECTION.

    CONSTANTS:
      gc_weather    TYPE string VALUE 'WEATHER',
      gc_crash      TYPE string VALUE 'CRASH',
      gc_logistics  TYPE string VALUE 'LOGISTICS',
      gc_compliance TYPE string VALUE 'COMPLIANCE'.

    METHODS normalize_crisis_type
      IMPORTING
        iv_crisis_type        TYPE zrap200_cc_case-crisis_type
      RETURNING
        VALUE(rv_crisis_type) TYPE string.

    METHODS get_severity_boost
      IMPORTING
        iv_severity        TYPE zrap200_cc_case-severity
      RETURNING
        VALUE(rv_boost)    TYPE i.

    METHODS score_options
      CHANGING
        ct_options TYPE tt_options.

ENDCLASS.


CLASS zcl_rap200_cc_dec_engine IMPLEMENTATION.

  METHOD build_decision.

    DATA(lt_options) = generate_options(
      is_case_context = is_case_context
    ).

    score_options(
      CHANGING
        ct_options = lt_options
    ).

    DATA(ls_recommendation) = recommend_best_option(
      it_options = lt_options
    ).

    LOOP AT lt_options ASSIGNING FIELD-SYMBOL(<ls_option>).

      CLEAR:
        <ls_option>-is_recommended,
        <ls_option>-reason_text.

      IF <ls_option>-option_id = ls_recommendation-option_id.
        <ls_option>-is_recommended = 'X'.
        <ls_option>-reason_text    = ls_recommendation-reason_text.
      ENDIF.

    ENDLOOP.

    rs_decision-options        = lt_options.
    rs_decision-recommendation = ls_recommendation.

  ENDMETHOD.


  METHOD generate_options.

    DATA(lv_crisis_type) = normalize_crisis_type(
      iv_crisis_type = is_case_context-crisis_type
    ).

    DATA(lv_boost) = get_severity_boost(
      iv_severity = is_case_context-severity
    ).

    DATA(lv_race_name) = is_case_context-race_name.

    IF lv_race_name IS INITIAL.
      lv_race_name = 'selected race'.
    ENDIF.

    CASE lv_crisis_type.

      WHEN gc_weather.

        rt_options = VALUE #(
          (
            option_no         = '001'
            option_id         = 'OPT001'
            option_type       = 'PITSTOP'
            option_text       = |Weather response for { lv_race_name }: pit stop and tyre change|
            cost_score        = 60
            time_score        = 75 + lv_boost
            risk_score        = 80
            feasibility_score = 70 + lv_boost
          )
          (
            option_no         = '002'
            option_id         = 'OPT002'
            option_type       = 'CONTINUE_RACE'
            option_text       = |Weather response for { lv_race_name }: continue without stopping|
            cost_score        = 90
            time_score        = 85
            risk_score        = 35 - lv_boost
            feasibility_score = 60
          )
          (
            option_no         = '003'
            option_id         = 'OPT003'
            option_type       = 'STRATEGY_CHANGE'
            option_text       = |Weather response for { lv_race_name }: change strategy and manage pace|
            cost_score        = 80
            time_score        = 70 + lv_boost
            risk_score        = 75
            feasibility_score = 85
          )
        ).

      WHEN gc_crash.

        rt_options = VALUE #(
          (
            option_no         = '001'
            option_id         = 'OPT001'
            option_type       = 'REPAIR_COMPONENT'
            option_text       = |Crash response for { lv_race_name }: repair damaged component|
            cost_score        = 75
            time_score        = 40 + lv_boost
            risk_score        = 65
            feasibility_score = 60
          )
          (
            option_no         = '002'
            option_id         = 'OPT002'
            option_type       = 'USE_OLD_SPEC'
            option_text       = |Crash response for { lv_race_name }: use older approved specification|
            cost_score        = 85
            time_score        = 80
            risk_score        = 70
            feasibility_score = 85
          )
          (
            option_no         = '003'
            option_id         = 'OPT003'
            option_type       = 'EMERGENCY_REBUILD'
            option_text       = |Crash response for { lv_race_name }: emergency rebuild before deadline|
            cost_score        = 45
            time_score        = 70
            risk_score        = 75
            feasibility_score = 70 + lv_boost
          )
        ).

      WHEN gc_logistics.

        rt_options = VALUE #(
          (
            option_no         = '001'
            option_id         = 'OPT001'
            option_type       = 'EMERGENCY_SHIP'
            option_text       = |Logistics response for { lv_race_name }: emergency shipment|
            cost_score        = 45
            time_score        = 90
            risk_score        = 70
            feasibility_score = 80
          )
          (
            option_no         = '002'
            option_id         = 'OPT002'
            option_type       = 'USE_LOCAL_BACKUP'
            option_text       = |Logistics response for { lv_race_name }: use local backup resource|
            cost_score        = 80
            time_score        = 75
            risk_score        = 65
            feasibility_score = 75
          )
          (
            option_no         = '003'
            option_id         = 'OPT003'
            option_type       = 'DELAY_UPGRADE'
            option_text       = |Logistics response for { lv_race_name }: delay upgrade package|
            cost_score        = 90
            time_score        = 60
            risk_score        = 85
            feasibility_score = 90
          )
        ).

      WHEN gc_compliance.

        rt_options = VALUE #(
          (
            option_no         = '001'
            option_id         = 'OPT001'
            option_type       = 'USE_APPROVED_SPEC'
            option_text       = |Compliance response for { lv_race_name }: switch to approved specification|
            cost_score        = 85
            time_score        = 80
            risk_score        = 90
            feasibility_score = 90
          )
          (
            option_no         = '002'
            option_id         = 'OPT002'
            option_type       = 'REQUEST_RECHECK'
            option_text       = |Compliance response for { lv_race_name }: request inspection re-check|
            cost_score        = 70
            time_score        = 55
            risk_score        = 60
            feasibility_score = 65
          )
          (
            option_no         = '003'
            option_id         = 'OPT003'
            option_type       = 'ESCALATE_STEWARD'
            option_text       = |Compliance response for { lv_race_name }: escalate to stewards|
            cost_score        = 60
            time_score        = 50
            risk_score        = 75
            feasibility_score = 60
          )
        ).

      WHEN OTHERS.

        rt_options = VALUE #(
          (
            option_no         = '001'
            option_id         = 'OPT001'
            option_type       = 'STANDARD_RECOVERY'
            option_text       = |Standard recovery for { lv_race_name }|
            cost_score        = 70
            time_score        = 70
            risk_score        = 70
            feasibility_score = 70
          )
          (
            option_no         = '002'
            option_id         = 'OPT002'
            option_type       = 'ESCALATE'
            option_text       = |Escalate { lv_race_name } for management decision|
            cost_score        = 50
            time_score        = 60
            risk_score        = 80
            feasibility_score = 75
          )
        ).

    ENDCASE.

    SORT rt_options BY option_no ASCENDING.

  ENDMETHOD.


  METHOD recommend_best_option.

    DATA(lt_options) = it_options.

    score_options(
      CHANGING
        ct_options = lt_options
    ).

    DATA(lv_best_score) = -1.

    LOOP AT lt_options INTO DATA(ls_option).

      IF ls_option-total_score > lv_best_score.
        lv_best_score                    = ls_option-total_score.
        rs_recommendation-option_id      = ls_option-option_id.
        rs_recommendation-option_type    = ls_option-option_type.
        rs_recommendation-total_score    = ls_option-total_score.
        rs_recommendation-rating         = ls_option-rating.
      ENDIF.

    ENDLOOP.

    IF rs_recommendation-option_id IS INITIAL.
      rs_recommendation-reason_text = 'No recovery option could be recommended.'.
    ELSE.
      rs_recommendation-reason_text =
        |Recommended option { rs_recommendation-option_type } with score { rs_recommendation-total_score }.|.
    ENDIF.

  ENDMETHOD.


  METHOD recommend_best_option_for_case.

    DATA lt_options TYPE tt_options.

    SELECT
      FROM zrap200_cc_opt
      FIELDS
        option_no,
        option_id,
        option_type,
        option_text,
        cost_score,
        time_score,
        risk_score,
        feasibility_score
      WHERE case_uuid = @iv_case_uuid
      INTO CORRESPONDING FIELDS OF TABLE @lt_options.

    rs_recommendation = recommend_best_option(
      it_options = lt_options
    ).

  ENDMETHOD.


  METHOD generate_recommend_for_case.

    SELECT SINGLE
      FROM zrap200_cc_case
      FIELDS
        crisis_type,
        severity,
        race_name
      WHERE case_uuid = @iv_case_uuid
      INTO @DATA(ls_case).

    IF sy-subrc <> 0.
      rs_recommendation-reason_text = 'Crisis case not found.'.
      RETURN.
    ENDIF.

    DATA(ls_decision) = build_decision(
      is_case_context = VALUE ty_case_context(
        crisis_type = ls_case-crisis_type
        severity    = ls_case-severity
        race_name   = ls_case-race_name
      )
    ).

    rs_recommendation = ls_decision-recommendation.

  ENDMETHOD.


  METHOD normalize_crisis_type.

    rv_crisis_type = to_upper(
      val = CONV string( iv_crisis_type )
    ).

    CONDENSE rv_crisis_type NO-GAPS.

  ENDMETHOD.


  METHOD get_severity_boost.

    DATA(lv_severity) = to_upper(
      val = CONV string( iv_severity )
    ).

    CONDENSE lv_severity NO-GAPS.

    CASE lv_severity.
      WHEN 'CRITICAL'.
        rv_boost = 15.
      WHEN 'HIGH'.
        rv_boost = 10.
      WHEN 'MEDIUM'.
        rv_boost = 5.
      WHEN OTHERS.
        rv_boost = 0.
    ENDCASE.

  ENDMETHOD.


  METHOD score_options.

    DATA(lo_score_srv) = NEW zcl_rap200_cc_score_srv( ).

    LOOP AT ct_options ASSIGNING FIELD-SYMBOL(<ls_option>).

      DATA(ls_score) = lo_score_srv->calculate_total_score(
        is_input = VALUE zcl_rap200_cc_score_srv=>ty_score_input(
          cost_score        = <ls_option>-cost_score
          time_score        = <ls_option>-time_score
          risk_score        = <ls_option>-risk_score
          feasibility_score = <ls_option>-feasibility_score
        )
      ).

      <ls_option>-total_score = ls_score-total_score.
      <ls_option>-rating      = ls_score-rating.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
