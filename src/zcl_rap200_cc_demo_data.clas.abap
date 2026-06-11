CLASS zcl_rap200_cc_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_rap200_cc_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( 'F1 Crisis Command Center - Backend Logic Test' ).
    out->write( '------------------------------------------------' ).

    DATA(lo_mock_api) = NEW zcl_rap200_cc_mock_api( ).

    DATA(ls_context) = lo_mock_api->get_race_context(
      iv_race_id = 'RACE001'
    ).

    out->write( |Race ID: { ls_context-race_id }| ).
    out->write( |Race: { ls_context-race_name }| ).
    out->write( |Circuit: { ls_context-circuit_name }| ).
    out->write( |Weather: { ls_context-weather_status }| ).
    out->write( |Track: { ls_context-track_condition }| ).
    out->write( |Resources: { ls_context-resource_status }| ).
    out->write( |Budget: { ls_context-budget_status }| ).
    out->write( '------------------------------------------------' ).

    DATA(lt_options) = VALUE zcl_rap200_cc_dec_engine=>tt_options(
      (
        option_id         = 'OPT001'
        option_type       = zcl_rap200_cc_constants=>gc_option_pitstop
        cost_score        = 60
        time_score        = 75
        risk_score        = 80
        feasibility_score = 70
      )
      (
        option_id         = 'OPT002'
        option_type       = zcl_rap200_cc_constants=>gc_option_continue_race
        cost_score        = 90
        time_score        = 85
        risk_score        = 35
        feasibility_score = 60
      )
      (
        option_id         = 'OPT003'
        option_type       = zcl_rap200_cc_constants=>gc_option_strategy_change
        cost_score        = 80
        time_score        = 70
        risk_score        = 75
        feasibility_score = 85
      )
    ).

    DATA(lo_dec_engine) = NEW zcl_rap200_cc_dec_engine( ).

    DATA(ls_recommendation) = lo_dec_engine->recommend_best_option(
      it_options = lt_options
    ).

    out->write( |Recommended Option ID: { ls_recommendation-option_id }| ).
    out->write( |Recommended Option: { ls_recommendation-option_type }| ).
    out->write( |Total Score: { ls_recommendation-total_score }| ).
    out->write( |Rating: { ls_recommendation-rating }| ).
    out->write( |Reason: { ls_recommendation-reason_text }| ).
    out->write( '------------------------------------------------' ).

    DATA(lo_log_srv) = NEW zcl_rap200_cc_log_srv( ).

    DATA(lv_log_text) = lo_log_srv->build_log_text(
      VALUE zcl_rap200_cc_log_srv=>ty_log_entry(
        case_id  = 'CASE001'
        log_type = zcl_rap200_cc_constants=>gc_log_recommended
        log_text = ls_recommendation-reason_text
      )
    ).

    out->write( lv_log_text ).

  ENDMETHOD.

ENDCLASS.
