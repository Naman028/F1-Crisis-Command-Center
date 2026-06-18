@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Case Resource Interface View'
define view entity ZI_RAP200_CC_CRES
  as select from zrap200_cc_cres
  association to parent ZI_RAP200_CC_CASE as _CrisisCase
    on $projection.CaseUUID = _CrisisCase.CaseUUID
{
  key case_uuid            as CaseUUID,
  key resource_no          as ResourceNo,

      case_id              as CaseID,
      resource_id          as ResourceID,
      resource_name        as ResourceName,
      resource_type        as ResourceType,
      approval_status      as ApprovalStatus,
      available_flag       as AvailableFlag,
      lead_hours           as LeadHours,
      base_cost            as BaseCost,
      currency             as Currency,
      performance_loss_pct as PerformanceLossPct,
      reliability_risk_pct as ReliabilityRiskPct,
      co2_kg               as Co2Kg,
      fit_score            as FitScore,
      selected_flag        as SelectedFlag,
      reason_text          as ReasonText,

      _CrisisCase
}
