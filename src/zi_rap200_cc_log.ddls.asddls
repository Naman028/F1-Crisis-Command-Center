@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Decision Log Interface View'
define view entity ZI_RAP200_CC_LOG
  as select from zrap200_cc_log
{
  key case_uuid as CaseUUID,
  key log_no    as LogNo
}
