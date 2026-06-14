@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Factor Interface View'
define view entity ZI_RAP200_CC_FACT
  as select from zrap200_cc_fact
  association to parent ZI_RAP200_CC_CASE as _CrisisCase
    on $projection.CaseUUID = _CrisisCase.CaseUUID
{
  key case_uuid    as CaseUUID,
  key factor_no    as FactorNo,

      case_id       as CaseID,
      factor_type   as FactorType,
      impact_level  as ImpactLevel,
      impact_score  as ImpactScore,
      description   as Description,
      active_flag   as ActiveFlag,

      _CrisisCase
}
