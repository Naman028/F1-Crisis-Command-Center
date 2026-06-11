@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Resource Interface View'
define view entity ZI_RAP200_CC_RES
  as select from zrap200_cc_res
{
  key resource_id as ResourceID
}
