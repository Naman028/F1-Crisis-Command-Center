@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Case Interface View'
define root view entity ZI_RAP200_CC_CASE
  as select from zrap200_cc_case
{
  key case_uuid as CaseUUID
}
