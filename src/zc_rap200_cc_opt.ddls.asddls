@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Recovery Option Projection View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_OPT
  as select from ZI_RAP200_CC_OPT
{
  key CaseUUID,
  key OptionNo
}
