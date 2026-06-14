CLASS lhc_Resource DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Resource
      RESULT result.

ENDCLASS.


CLASS lhc_Resource IMPLEMENTATION.

  METHOD get_global_authorizations.

    "Demo project:
    "Allow resource maintenance through the generated Resource Management page.

    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%update = if_abap_behv=>mk-on.
      result-%update = if_abap_behv=>auth-allowed.
    ENDIF.

    IF requested_authorizations-%delete = if_abap_behv=>mk-on.
      result-%delete = if_abap_behv=>auth-allowed.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
