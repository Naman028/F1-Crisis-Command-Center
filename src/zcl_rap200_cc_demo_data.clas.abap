CLASS zcl_rap200_cc_demo_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

ENDCLASS.


CLASS zcl_rap200_cc_demo_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA lv_timestamp TYPE timestampl.
    GET TIME STAMP FIELD lv_timestamp.

    DATA(lv_timestamp_text) = |{ lv_timestamp }|.

    out->write( 'F1 Crisis Command Center - Demo Case Generator' ).
    out->write( '------------------------------------------------' ).
    out->write( 'Deleting old demo cases and generated options...' ).

    SELECT
      FROM zrap200_cc_case
      FIELDS case_uuid
      WHERE case_id IN ( 'CASE001', 'CASE002', 'CASE003', 'CASE004' )
      INTO TABLE @DATA(lt_old_case_uuids).

    LOOP AT lt_old_case_uuids INTO DATA(ls_old_case_uuid).
      DELETE FROM zrap200_cc_opt
        WHERE case_uuid = @ls_old_case_uuid-case_uuid.
    ENDLOOP.

    DELETE FROM zrap200_cc_case
      WHERE case_id IN ( 'CASE001', 'CASE002', 'CASE003', 'CASE004' ).

    DATA lt_cases TYPE STANDARD TABLE OF zrap200_cc_case.

    TRY.

        DATA(lv_case_uuid_1) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_case_uuid_2) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_case_uuid_3) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(lv_case_uuid_4) = cl_system_uuid=>create_uuid_x16_static( ).

      CATCH cx_uuid_error.

        out->write( 'Could not create UUIDs.' ).
        RETURN.

    ENDTRY.

    lt_cases = VALUE #(
      (
        case_uuid             = lv_case_uuid_1
        case_id               = 'CASE001'
        case_title            = 'Rain crisis during Monaco GP'
        race_id               = 'RACE001'
        race_name             = 'Monaco Grand Prix'
        crisis_type           = 'WEATHER'
        severity              = 'HIGH'
        status                = 'OPEN'
        created_by            = sy-uname
        created_at            = lv_timestamp_text
        last_changed_by       = sy-uname
        last_changed_at       = lv_timestamp_text
        local_last_changed_at = lv_timestamp
      )
      (
        case_uuid             = lv_case_uuid_2
        case_id               = 'CASE002'
        case_title            = 'Crash damage before qualifying'
        race_id               = 'RACE002'
        race_name             = 'Silverstone Grand Prix'
        crisis_type           = 'CRASH'
        severity              = 'CRITICAL'
        status                = 'OPEN'
        created_by            = sy-uname
        created_at            = lv_timestamp_text
        last_changed_by       = sy-uname
        last_changed_at       = lv_timestamp_text
        local_last_changed_at = lv_timestamp
      )
      (
        case_uuid             = lv_case_uuid_3
        case_id               = 'CASE003'
        case_title            = 'Delayed upgrade package shipment'
        race_id               = 'RACE003'
        race_name             = 'Singapore Grand Prix'
        crisis_type           = 'LOGISTICS'
        severity              = 'MEDIUM'
        status                = 'OPEN'
        created_by            = sy-uname
        created_at            = lv_timestamp_text
        last_changed_by       = sy-uname
        last_changed_at       = lv_timestamp_text
        local_last_changed_at = lv_timestamp
      )
      (
        case_uuid             = lv_case_uuid_4
        case_id               = 'CASE004'
        case_title            = 'Technical regulation inspection issue'
        race_id               = 'RACE004'
        race_name             = 'Monza Grand Prix'
        crisis_type           = 'COMPLIANCE'
        severity              = 'HIGH'
        status                = 'OPEN'
        created_by            = sy-uname
        created_at            = lv_timestamp_text
        last_changed_by       = sy-uname
        last_changed_at       = lv_timestamp_text
        local_last_changed_at = lv_timestamp
      )
    ).

    INSERT zrap200_cc_case FROM TABLE @lt_cases.

    out->write( |Created demo crisis cases: { lines( lt_cases ) }| ).
    out->write( 'No recovery options were inserted by demo data.' ).
    out->write( 'Open Fiori preview and click Generate Recommendation for each case.' ).
    out->write( '------------------------------------------------' ).

    LOOP AT lt_cases INTO DATA(ls_case).

      out->write(
        |{ ls_case-case_id } - { ls_case-crisis_type } - { ls_case-severity } - { ls_case-case_title }|
      ).

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
