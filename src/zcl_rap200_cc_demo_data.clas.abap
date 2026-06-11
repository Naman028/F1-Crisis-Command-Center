CLASS zcl_rap200_cc_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.

CLASS zcl_rap200_cc_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( 'F1 Crisis Command Center demo data generator skeleton.' ).
  ENDMETHOD.

ENDCLASS.
