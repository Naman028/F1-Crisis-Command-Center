CLASS zcl_rap200_cc_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_rap200_cc_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lv_case_uuid TYPE sysuuid_x16.
    DATA lv_old_case_uuid TYPE sysuuid_x16.

    TRY.
        lv_case_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        out->write( 'Could not create UUID.' ).
        RETURN.
    ENDTRY.

    GET TIME STAMP FIELD DATA(lv_timestamp).

    DATA(lv_timestamp_text) = |{ lv_timestamp }|.

    out->write( 'F1 Crisis Command Center - Full DB Workflow Test' ).
    out->write( '------------------------------------------------' ).

    SELECT SINGLE case_uuid
      FROM zrap200_cc_case
      WHERE case_id = 'CASE001'
      INTO @lv_old_case_uuid.

    IF lv_old_case_uuid IS NOT INITIAL.
      DELETE FROM zrap200_cc_opt
        WHERE case_uuid = @lv_old_case_uuid.
    ENDIF.

    DELETE FROM zrap200_cc_case
      WHERE case_id = 'CASE001'.

    DATA ls_case TYPE zrap200_cc_case.

    ls_case-case_uuid   = lv_case_uuid.
    ls_case-case_id     = 'CASE001'.
    ls_case-case_title  = 'Rain crisis during Monaco GP'.
    ls_case-race_id     = 'RACE001'.
    ls_case-race_name   = 'Monaco Grand Prix'.
    ls_case-crisis_type = zcl_rap200_cc_constants=>gc_crisis_weather.
    ls_case-severity    = zcl_rap200_cc_constants=>gc_severity_high.
    ls_case-status      = zcl_rap200_cc_constants=>gc_status_open.
    ls_case-created_by  = sy-uname.
    ls_case-created_at  = lv_timestamp_text.

    INSERT zrap200_cc_case FROM @ls_case.

    DATA lt_options TYPE STANDARD TABLE OF zrap200_cc_opt.

    lt_options = VALUE #(
      (
        case_uuid         = lv_case_uuid
        option_no         = '001'
        option_id         = 'OPT001'
        option_type       = zcl_rap200_cc_constants=>gc_option_pitstop
        option_text       = 'Immediate pit stop and tyre change'
        cost_score        = 60
        time_score        = 75
        risk_score        = 80
        feasibility_score = 70
      )
      (
        case_uuid         = lv_case_uuid
        option_no         = '002'
        option_id         = 'OPT002'
        option_type       = zcl_rap200_cc_constants=>gc_option_continue_race
        option_text       = 'Continue race without stopping'
        cost_score        = 90
        time_score        = 85
        risk_score        = 35
        feasibility_score = 60
      )
      (
        case_uuid         = lv_case_uuid
        option_no         = '003'
        option_id         = 'OPT003'
        option_type       = zcl_rap200_cc_constants=>gc_option_strategy_change
        option_text       = 'Change strategy and manage pace'
        cost_score        = 80
        time_score        = 70
        risk_score        = 75
        feasibility_score = 85
      )
    ).

    INSERT zrap200_cc_opt FROM TABLE @lt_options.

    DATA(lo_dec_engine) = NEW zcl_rap200_cc_dec_engine( ).

    DATA(ls_recommendation) = lo_dec_engine->recommend_best_option_for_case(
      iv_case_uuid = lv_case_uuid
    ).

    UPDATE zrap200_cc_case
      SET recommended_option_id   = @ls_recommendation-option_id,
          recommended_option_type = @ls_recommendation-option_type,
          recommended_score       = @ls_recommendation-total_score,
          recommended_rating      = @ls_recommendation-rating,
          recommended_text        = @ls_recommendation-reason_text,
          status                  = 'RECOMMENDED',
          last_changed_by         = @sy-uname,
          last_changed_at         = @lv_timestamp_text
      WHERE case_uuid = @lv_case_uuid.

    out->write( |Created Case UUID: { lv_case_uuid }| ).
    out->write( |Created Case ID: CASE001| ).
    out->write( |Recommended Option: { ls_recommendation-option_type }| ).
    out->write( |Score: { ls_recommendation-total_score }| ).
    out->write( |Rating: { ls_recommendation-rating }| ).
    out->write( |Reason: { ls_recommendation-reason_text }| ).

    out->write( '------------------------------------------------' ).
    out->write( 'Now open CrisisCase preview and click Go.' ).

  ENDMETHOD.

ENDCLASS.
