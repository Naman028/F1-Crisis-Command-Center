CLASS lhc_CrisisCase DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS recommendBestOption
      FOR MODIFY
      IMPORTING keys FOR ACTION CrisisCase~recommendBestOption
      RESULT result.

ENDCLASS.

CLASS lhc_CrisisCase IMPLEMENTATION.

  METHOD recommendBestOption.

    LOOP AT keys INTO DATA(ls_key).

      DATA(lo_engine) = NEW zcl_rap200_cc_dec_engine( ).

      DATA(ls_recommendation) = lo_engine->recommend_best_option_for_case(
        iv_case_uuid = ls_key-CaseUUID
      ).

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
            %tky                  = ls_key-%tky
            RecommendedOptionID   = ls_recommendation-option_id
            RecommendedOptionType = ls_recommendation-option_type
            RecommendedScore      = ls_recommendation-total_score
            RecommendedRating     = ls_recommendation-rating
            RecommendedText       = ls_recommendation-reason_text
            Status                = 'RECOMMENDED'
          )
        )
        FAILED failed
        REPORTED reported.

    ENDLOOP.

    READ ENTITIES OF zi_rap200_cc_case IN LOCAL MODE
      ENTITY CrisisCase
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_cases).

    result = VALUE #( FOR ls_case IN lt_cases
      (
        %tky   = ls_case-%tky
        %param = ls_case
      )
    ).

  ENDMETHOD.

ENDCLASS.
