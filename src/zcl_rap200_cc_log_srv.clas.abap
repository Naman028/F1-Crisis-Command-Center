CLASS zcl_rap200_cc_log_srv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_case_id  TYPE c LENGTH 12.
    TYPES ty_log_type TYPE c LENGTH 30.

    TYPES: BEGIN OF ty_log_entry,
             case_id  TYPE ty_case_id,
             log_type TYPE ty_log_type,
             log_text TYPE string,
           END OF ty_log_entry.

    METHODS build_log_text
      IMPORTING
        is_log_entry      TYPE ty_log_entry
      RETURNING
        VALUE(rv_message) TYPE string.

ENDCLASS.

CLASS zcl_rap200_cc_log_srv IMPLEMENTATION.

  METHOD build_log_text.

    rv_message =
      |[{ is_log_entry-log_type }] Case { is_log_entry-case_id }: { is_log_entry-log_text }|.

  ENDMETHOD.

ENDCLASS.
