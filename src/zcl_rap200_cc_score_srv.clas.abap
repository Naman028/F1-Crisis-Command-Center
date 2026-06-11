CLASS zcl_rap200_cc_score_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_rating TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_score_input,
             cost_score        TYPE i,
             time_score        TYPE i,
             risk_score        TYPE i,
             feasibility_score TYPE i,
           END OF ty_score_input.

    TYPES: BEGIN OF ty_score_result,
             total_score TYPE i,
             rating      TYPE ty_rating,
           END OF ty_score_result.

    METHODS calculate_total_score
      IMPORTING
        is_input         TYPE ty_score_input
      RETURNING
        VALUE(rs_result) TYPE ty_score_result.

  PRIVATE SECTION.

    METHODS normalize_score
      IMPORTING
        iv_score        TYPE i
      RETURNING
        VALUE(rv_score) TYPE i.

ENDCLASS.

CLASS zcl_rap200_cc_score_srv IMPLEMENTATION.

  METHOD calculate_total_score.

    DATA(lv_cost) = normalize_score(
      iv_score = is_input-cost_score
    ).

    DATA(lv_time) = normalize_score(
      iv_score = is_input-time_score
    ).

    DATA(lv_risk) = normalize_score(
      iv_score = is_input-risk_score
    ).

    DATA(lv_feasibility) = normalize_score(
      iv_score = is_input-feasibility_score
    ).

    " Weighted decision score:
    " Cost control = 20%
    " Time impact = 30%
    " Risk control = 25%
    " Feasibility = 25%
    rs_result-total_score =
        ( lv_cost * 20
        + lv_time * 30
        + lv_risk * 25
        + lv_feasibility * 25 ) / 100.

    IF rs_result-total_score >= 80.
      rs_result-rating = 'EXCELLENT'.
    ELSEIF rs_result-total_score >= 60.
      rs_result-rating = 'GOOD'.
    ELSEIF rs_result-total_score >= 40.
      rs_result-rating = 'MEDIUM'.
    ELSE.
      rs_result-rating = 'WEAK'.
    ENDIF.

  ENDMETHOD.

  METHOD normalize_score.

    rv_score = iv_score.

    IF rv_score < 0.
      rv_score = 0.
    ELSEIF rv_score > 100.
      rv_score = 100.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
