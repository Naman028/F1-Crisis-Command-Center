@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Case Resource Availability View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_CASE_RES
  as select from zrap200_cc_case as CrisisCase
    cross join zrap200_cc_res as Resource
{
  key CrisisCase.case_uuid          as CaseUUID,
  key Resource.resource_id          as ResourceID,

      CrisisCase.case_id            as CaseID,

      Resource.resource_name        as ResourceName,
      Resource.resource_type        as ResourceType,
      Resource.approval_status      as ApprovalStatus,
      Resource.available_flag       as AvailableFlag,
      Resource.lead_hours           as LeadHours,
      Resource.base_cost            as BaseCost,
      Resource.currency             as Currency,
      Resource.performance_loss_pct as PerformanceLossPct,
      Resource.reliability_risk_pct as ReliabilityRiskPct,
      Resource.co2_kg               as Co2Kg,
      Resource.last_changed_at      as LastChangedAt
}
