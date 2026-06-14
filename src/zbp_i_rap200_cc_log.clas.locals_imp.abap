CLASS lhc_DecisionLog DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR DecisionLog
      RESULT result.

ENDCLASS.


CLASS lhc_DecisionLog IMPLEMENTATION.

  METHOD get_global_authorizations.

    "Demo project:
    "Allow backend-created decision logs.
    "The log entity is not meant for manual user editing.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
