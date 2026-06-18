CLASS zcl_rap200_cc_race_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    METHODS reset_race_data.
ENDCLASS.


CLASS zcl_rap200_cc_race_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    reset_race_data( ).

    out->write( 'F1 race master data generated successfully.' ).

  ENDMETHOD.


  METHOD reset_race_data.

    DATA lt_races TYPE STANDARD TABLE OF zrap200_cc_race WITH EMPTY KEY.

    DELETE FROM zrap200_cc_race.

    lt_races = VALUE #(
      (
        race_id      = 'RACE001'
        race_name    = 'Australian Grand Prix'
        race_country = 'Australia'
        race_city    = 'Melbourne'
        circuit_name = 'Albert Park Circuit'
        round_no     = '01'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE002'
        race_name    = 'Chinese Grand Prix'
        race_country = 'China'
        race_city    = 'Shanghai'
        circuit_name = 'Shanghai International Circuit'
        round_no     = '02'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE003'
        race_name    = 'Japanese Grand Prix'
        race_country = 'Japan'
        race_city    = 'Suzuka'
        circuit_name = 'Suzuka Circuit'
        round_no     = '03'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE004'
        race_name    = 'Miami Grand Prix'
        race_country = 'United States'
        race_city    = 'Miami'
        circuit_name = 'Miami International Autodrome'
        round_no     = '04'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE005'
        race_name    = 'Canadian Grand Prix'
        race_country = 'Canada'
        race_city    = 'Montreal'
        circuit_name = 'Circuit Gilles Villeneuve'
        round_no     = '05'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE006'
        race_name    = 'Monaco Grand Prix'
        race_country = 'Monaco'
        race_city    = 'Monte Carlo'
        circuit_name = 'Circuit de Monaco'
        round_no     = '06'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE007'
        race_name    = 'Barcelona-Catalunya Grand Prix'
        race_country = 'Spain'
        race_city    = 'Barcelona'
        circuit_name = 'Circuit de Barcelona-Catalunya'
        round_no     = '07'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE008'
        race_name    = 'Austrian Grand Prix'
        race_country = 'Austria'
        race_city    = 'Spielberg'
        circuit_name = 'Red Bull Ring'
        round_no     = '08'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE009'
        race_name    = 'British Grand Prix'
        race_country = 'Great Britain'
        race_city    = 'Silverstone'
        circuit_name = 'Silverstone Circuit'
        round_no     = '09'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE010'
        race_name    = 'Belgian Grand Prix'
        race_country = 'Belgium'
        race_city    = 'Spa-Francorchamps'
        circuit_name = 'Circuit de Spa-Francorchamps'
        round_no     = '10'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE011'
        race_name    = 'Hungarian Grand Prix'
        race_country = 'Hungary'
        race_city    = 'Budapest'
        circuit_name = 'Hungaroring'
        round_no     = '11'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE012'
        race_name    = 'Dutch Grand Prix'
        race_country = 'Netherlands'
        race_city    = 'Zandvoort'
        circuit_name = 'Circuit Zandvoort'
        round_no     = '12'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE013'
        race_name    = 'Italian Grand Prix'
        race_country = 'Italy'
        race_city    = 'Monza'
        circuit_name = 'Monza Circuit'
        round_no     = '13'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE014'
        race_name    = 'Spanish Grand Prix'
        race_country = 'Spain'
        race_city    = 'Madrid'
        circuit_name = 'Madring'
        round_no     = '14'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE015'
        race_name    = 'Azerbaijan Grand Prix'
        race_country = 'Azerbaijan'
        race_city    = 'Baku'
        circuit_name = 'Baku City Circuit'
        round_no     = '15'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE016'
        race_name    = 'Singapore Grand Prix'
        race_country = 'Singapore'
        race_city    = 'Singapore'
        circuit_name = 'Marina Bay Street Circuit'
        round_no     = '16'
        season_year  = '2026'
        sprint_flag  = abap_true
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE017'
        race_name    = 'United States Grand Prix'
        race_country = 'United States'
        race_city    = 'Austin'
        circuit_name = 'Circuit of The Americas'
        round_no     = '17'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE018'
        race_name    = 'Mexico City Grand Prix'
        race_country = 'Mexico'
        race_city    = 'Mexico City'
        circuit_name = 'Autodromo Hermanos Rodriguez'
        round_no     = '18'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE019'
        race_name    = 'Sao Paulo Grand Prix'
        race_country = 'Brazil'
        race_city    = 'Sao Paulo'
        circuit_name = 'Interlagos'
        round_no     = '19'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE020'
        race_name    = 'Las Vegas Grand Prix'
        race_country = 'United States'
        race_city    = 'Las Vegas'
        circuit_name = 'Las Vegas Strip Circuit'
        round_no     = '20'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE021'
        race_name    = 'Qatar Grand Prix'
        race_country = 'Qatar'
        race_city    = 'Lusail'
        circuit_name = 'Lusail International Circuit'
        round_no     = '21'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
      (
        race_id      = 'RACE022'
        race_name    = 'Abu Dhabi Grand Prix'
        race_country = 'United Arab Emirates'
        race_city    = 'Abu Dhabi'
        circuit_name = 'Yas Marina Circuit'
        round_no     = '22'
        season_year  = '2026'
        sprint_flag  = abap_false
        active_flag  = abap_true
      )
    ).

    INSERT zrap200_cc_race FROM TABLE @lt_races.

  ENDMETHOD.

ENDCLASS.
