@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Decision Log Projection View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_LOG
  as select from ZI_RAP200_CC_LOG
{
  key CaseUUID,
  key LogNo
}
