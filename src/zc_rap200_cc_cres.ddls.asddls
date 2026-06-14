@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Case Resource Projection View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_CRES
  as projection on ZI_RAP200_CC_CRES
{
  key CaseUUID,
  key ResourceNo,

      CaseID,
      ResourceID,
      ResourceName,
      ResourceType,
      ApprovalStatus,
      AvailableFlag,
      LeadHours,
      BaseCost,
      Currency,
      PerformanceLossPct,
      ReliabilityRiskPct,
      Co2Kg,
      FitScore,
      SelectedFlag,
      ReasonText,

      _CrisisCase : redirected to parent ZC_RAP200_CC_CASE
}
