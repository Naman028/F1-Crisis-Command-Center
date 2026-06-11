@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Race Event Interface View'
define view entity ZI_RAP200_CC_RACE
  as select from zrap200_cc_race
{
  key race_id as RaceID
}
