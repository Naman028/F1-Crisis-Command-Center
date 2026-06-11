CLASS zcl_rap200_cc_mock_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_race_id TYPE c LENGTH 12.

    TYPES: BEGIN OF ty_race_context,
             race_id         TYPE ty_race_id,
             race_name       TYPE c LENGTH 60,
             circuit_name    TYPE c LENGTH 60,
             weather_status  TYPE c LENGTH 20,
             track_condition TYPE c LENGTH 20,
             resource_status TYPE c LENGTH 20,
             budget_status   TYPE c LENGTH 20,
           END OF ty_race_context.

    METHODS get_race_context
      IMPORTING
        iv_race_id        TYPE ty_race_id
      RETURNING
        VALUE(rs_context) TYPE ty_race_context.

ENDCLASS.

CLASS zcl_rap200_cc_mock_api IMPLEMENTATION.

  METHOD get_race_context.

    rs_context-race_id         = iv_race_id.
    rs_context-race_name       = 'Monaco Grand Prix'.
    rs_context-circuit_name    = 'Circuit de Monaco'.
    rs_context-weather_status  = 'RAIN'.
    rs_context-track_condition = 'WET'.
    rs_context-resource_status = 'LIMITED'.
    rs_context-budget_status   = 'CONTROLLED'.

  ENDMETHOD.

ENDCLASS.
