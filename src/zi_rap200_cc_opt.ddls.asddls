@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Recovery Option Interface View'
define view entity ZI_RAP200_CC_OPT
  as select from zrap200_cc_opt
{
  key case_uuid as CaseUUID,
  key option_no as OptionNo
}
