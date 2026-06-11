@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Factor Interface View'
define view entity ZI_RAP200_CC_FACT
  as select from zrap200_cc_fact
{
  key case_uuid as CaseUUID,
  key factor_no as FactorNo
}
