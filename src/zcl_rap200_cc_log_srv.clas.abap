CLASS zcl_rap200_cc_log_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_case_uuid TYPE zrap200_cc_log-case_uuid.
    TYPES ty_case_id   TYPE zrap200_cc_log-case_id.
    TYPES ty_log_no    TYPE zrap200_cc_log-log_no.
    TYPES ty_log_type  TYPE c LENGTH 30.

    TYPES:
      BEGIN OF ty_log_entry,
        case_uuid               TYPE zrap200_cc_log-case_uuid,
        log_no                  TYPE zrap200_cc_log-log_no,
        case_id                 TYPE zrap200_cc_log-case_id,
        crisis_type             TYPE zrap200_cc_log-crisis_type,
        severity                TYPE zrap200_cc_log-severity,
        recommended_option_id   TYPE zrap200_cc_log-recommended_option_id,
        recommended_option_type TYPE zrap200_cc_log-recommended_option_type,
        recommended_score       TYPE zrap200_cc_log-recommended_score,
        recommended_rating      TYPE zrap200_cc_log-recommended_rating,
        reason_text             TYPE zrap200_cc_log-reason_text,
        created_by              TYPE zrap200_cc_log-created_by,
        created_at              TYPE zrap200_cc_log-created_at,
      END OF ty_log_entry.

    TYPES:
      BEGIN OF ty_text_entry,
        case_id  TYPE ty_case_id,
        log_type TYPE ty_log_type,
        log_text TYPE string,
      END OF ty_text_entry.

    METHODS build_log_text
      IMPORTING
        is_log_entry      TYPE ty_text_entry
      RETURNING
        VALUE(rv_message) TYPE string.

    METHODS build_recommendation_log
      IMPORTING
        is_log_entry        TYPE ty_log_entry
      RETURNING
        VALUE(rs_log_entry) TYPE ty_log_entry.

  PRIVATE SECTION.

    METHODS get_next_log_no
      IMPORTING
        iv_case_uuid     TYPE ty_case_uuid
      RETURNING
        VALUE(rv_log_no) TYPE ty_log_no.

    METHODS get_timestamp_text
      RETURNING
        VALUE(rv_timestamp_text) TYPE zrap200_cc_log-created_at.

    METHODS get_current_user
      RETURNING
        VALUE(rv_user) TYPE zrap200_cc_log-created_by.

ENDCLASS.


CLASS zcl_rap200_cc_log_srv IMPLEMENTATION.

  METHOD build_log_text.

    rv_message =
      |[{ is_log_entry-log_type }] Case { is_log_entry-case_id }: { is_log_entry-log_text }|.

  ENDMETHOD.


  METHOD build_recommendation_log.

    rs_log_entry = is_log_entry.

    IF rs_log_entry-case_uuid IS INITIAL.
      RETURN.
    ENDIF.

    rs_log_entry-log_no     = get_next_log_no( rs_log_entry-case_uuid ).
    rs_log_entry-created_by = get_current_user( ).
    rs_log_entry-created_at = get_timestamp_text( ).

  ENDMETHOD.


  METHOD get_next_log_no.

    DATA lv_max_number TYPE i VALUE 0.
    DATA lv_log_no     TYPE i.

    SELECT FROM zrap200_cc_log
      FIELDS log_no
      WHERE case_uuid = @iv_case_uuid
      INTO TABLE @DATA(lt_log_numbers).

    LOOP AT lt_log_numbers INTO DATA(ls_log_number).

      TRY.
          lv_log_no = CONV i( ls_log_number-log_no ).

          IF lv_log_no > lv_max_number.
            lv_max_number = lv_log_no.
          ENDIF.

        CATCH cx_sy_conversion_no_number.
      ENDTRY.

    ENDLOOP.

    lv_max_number = lv_max_number + 1.

    rv_log_no = |{ lv_max_number WIDTH = 4 ALIGN = RIGHT PAD = '0' }|.

  ENDMETHOD.


  METHOD get_timestamp_text.

    DATA(lv_system_date) = cl_abap_context_info=>get_system_date( ).
    DATA(lv_system_time) = cl_abap_context_info=>get_system_time( ).

    rv_timestamp_text = |{ lv_system_date DATE = ISO } { lv_system_time TIME = ISO }|.

  ENDMETHOD.


  METHOD get_current_user.

    rv_user = cl_abap_context_info=>get_user_technical_name( ).

  ENDMETHOD.

ENDCLASS.
