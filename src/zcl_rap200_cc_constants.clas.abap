CLASS zcl_rap200_cc_constants DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Case status constants
    CONSTANTS gc_status_new      TYPE c LENGTH 20 VALUE 'NEW'.
    CONSTANTS gc_status_open     TYPE c LENGTH 20 VALUE 'OPEN'.
    CONSTANTS gc_status_analysis TYPE c LENGTH 20 VALUE 'ANALYSIS'.
    CONSTANTS gc_status_resolved TYPE c LENGTH 20 VALUE 'RESOLVED'.
    CONSTANTS gc_status_closed   TYPE c LENGTH 20 VALUE 'CLOSED'.

    " Severity constants
    CONSTANTS gc_severity_low      TYPE c LENGTH 10 VALUE 'LOW'.
    CONSTANTS gc_severity_medium   TYPE c LENGTH 10 VALUE 'MEDIUM'.
    CONSTANTS gc_severity_high     TYPE c LENGTH 10 VALUE 'HIGH'.
    CONSTANTS gc_severity_critical TYPE c LENGTH 10 VALUE 'CRITICAL'.

    " Crisis type constants
    CONSTANTS gc_crisis_engine   TYPE c LENGTH 30 VALUE 'ENGINE'.
    CONSTANTS gc_crisis_tyres    TYPE c LENGTH 30 VALUE 'TYRES'.
    CONSTANTS gc_crisis_weather  TYPE c LENGTH 30 VALUE 'WEATHER'.
    CONSTANTS gc_crisis_damage   TYPE c LENGTH 30 VALUE 'DAMAGE'.
    CONSTANTS gc_crisis_strategy TYPE c LENGTH 30 VALUE 'STRATEGY'.

    " Recovery option constants
    CONSTANTS gc_option_pitstop         TYPE c LENGTH 30 VALUE 'PITSTOP'.
    CONSTANTS gc_option_replace_part    TYPE c LENGTH 30 VALUE 'REPLACE_PART'.
    CONSTANTS gc_option_strategy_change TYPE c LENGTH 30 VALUE 'STRATEGY_CHANGE'.
    CONSTANTS gc_option_continue_race   TYPE c LENGTH 30 VALUE 'CONTINUE_RACE'.

    " Log type constants
    CONSTANTS gc_log_created        TYPE c LENGTH 30 VALUE 'CREATED'.
    CONSTANTS gc_log_scored         TYPE c LENGTH 30 VALUE 'SCORED'.
    CONSTANTS gc_log_recommended    TYPE c LENGTH 30 VALUE 'RECOMMENDED'.
    CONSTANTS gc_log_status_changed TYPE c LENGTH 30 VALUE 'STATUS_CHANGED'.

ENDCLASS.

CLASS zcl_rap200_cc_constants IMPLEMENTATION.
ENDCLASS.
