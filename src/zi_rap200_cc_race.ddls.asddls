@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Race Event Interface View'
define view entity ZI_RAP200_CC_RACE
  as select from zrap200_cc_race
{
  key race_id      as RaceID,

      race_name    as RaceName,
      race_country as RaceCountry,
      race_city    as RaceCity,
      circuit_name as CircuitName,
      round_no     as RoundNo,
      season_year  as SeasonYear,
      sprint_flag  as SprintFlag,
      active_flag  as ActiveFlag
}
