@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Factor Projection View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_FACT
  as select from ZI_RAP200_CC_FACT
{
  key CaseUUID,
  key FactorNo
}
