@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Case Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_RAP200_CC_CASE
  as select from ZI_RAP200_CC_CASE
{
  key CaseUUID
}
