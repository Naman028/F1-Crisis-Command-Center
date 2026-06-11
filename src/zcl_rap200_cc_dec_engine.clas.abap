CLASS zcl_rap200_cc_dec_engine DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_case_uuid   TYPE sysuuid_x16.
    TYPES ty_option_id   TYPE c LENGTH 12.
    TYPES ty_option_type TYPE c LENGTH 30.
    TYPES ty_rating      TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_option,
             option_id         TYPE ty_option_id,
             option_type       TYPE ty_option_type,
             cost_score        TYPE i,
             time_score        TYPE i,
             risk_score        TYPE i,
             feasibility_score TYPE i,
           END OF ty_option.

    TYPES tt_options TYPE STANDARD TABLE OF ty_option WITH EMPTY KEY.

    TYPES: BEGIN OF ty_recommendation,
             option_id   TYPE ty_option_id,
             option_type TYPE ty_option_type,
             total_score TYPE i,
             rating      TYPE ty_rating,
             reason_text TYPE string,
           END OF ty_recommendation.

    METHODS recommend_best_option
      IMPORTING
        it_options               TYPE tt_options
      RETURNING
        VALUE(rs_recommendation) TYPE ty_recommendation.

    METHODS recommend_best_option_for_case
      IMPORTING
        iv_case_uuid             TYPE ty_case_uuid
      RETURNING
        VALUE(rs_recommendation) TYPE ty_recommendation.

ENDCLASS.

CLASS zcl_rap200_cc_dec_engine IMPLEMENTATION.

  METHOD recommend_best_option.

    DATA(lo_score_srv) = NEW zcl_rap200_cc_score_srv( ).

    LOOP AT it_options INTO DATA(ls_option).

      DATA(ls_score) = lo_score_srv->calculate_total_score(
        is_input = VALUE zcl_rap200_cc_score_srv=>ty_score_input(
          cost_score        = ls_option-cost_score
          time_score        = ls_option-time_score
          risk_score        = ls_option-risk_score
          feasibility_score = ls_option-feasibility_score
        )
      ).

      IF ls_score-total_score > rs_recommendation-total_score.
        rs_recommendation-option_id   = ls_option-option_id.
        rs_recommendation-option_type = ls_option-option_type.
        rs_recommendation-total_score = ls_score-total_score.
        rs_recommendation-rating      = ls_score-rating.
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

    DATA(lo_score_srv) = NEW zcl_rap200_cc_score_srv( ).

    lo_score_srv->score_options_for_case(
      iv_case_uuid = iv_case_uuid
    ).

    SELECT
      FROM zrap200_cc_opt
      FIELDS
        option_id,
        option_type,
        total_score,
        rating
      WHERE case_uuid = @iv_case_uuid
      ORDER BY total_score DESCENDING
      INTO TABLE @DATA(lt_scored_options).

    READ TABLE lt_scored_options INTO DATA(ls_best_option) INDEX 1.

    IF sy-subrc <> 0.
      rs_recommendation-reason_text = 'No recovery option found for this crisis case.'.
      RETURN.
    ENDIF.

    rs_recommendation-option_id   = ls_best_option-option_id.
    rs_recommendation-option_type = ls_best_option-option_type.
    rs_recommendation-total_score = ls_best_option-total_score.
    rs_recommendation-rating      = ls_best_option-rating.
    rs_recommendation-reason_text =
      |Recommended option { rs_recommendation-option_type } with score { rs_recommendation-total_score }.|.

    UPDATE zrap200_cc_opt
      SET is_recommended = '',
          reason_text    = ''
      WHERE case_uuid = @iv_case_uuid.

    UPDATE zrap200_cc_opt
      SET is_recommended = 'X',
          reason_text    = @rs_recommendation-reason_text
      WHERE case_uuid = @iv_case_uuid
        AND option_id = @rs_recommendation-option_id.

  ENDMETHOD.

ENDCLASS.
