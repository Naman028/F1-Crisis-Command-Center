@EndUserText.label: 'F1 Resource Interface View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_RAP200_CC_RES
  as select from zrap200_cc_res
{
  key resource_id          as ResourceID,

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
      last_changed_at      as LastChangedAt
}
