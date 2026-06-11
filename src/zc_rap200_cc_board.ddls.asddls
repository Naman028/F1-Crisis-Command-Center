@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Decision Board View'
define view entity ZC_RAP200_CC_BOARD
  as select from ZI_RAP200_CC_CASE
{
  key CaseUUID
}
