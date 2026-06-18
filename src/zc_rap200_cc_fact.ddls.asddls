@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Factor Projection View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_FACT
  as projection on ZI_RAP200_CC_FACT
{
  key CaseUUID,
  key FactorNo,

      CaseID,
      FactorType,
      ImpactLevel,
      ImpactScore,
      Description,
      ActiveFlag,

      _CrisisCase : redirected to parent ZC_RAP200_CC_CASE
}
