@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Recovery Option Interface View'
define root view entity ZI_RAP200_CC_OPT
  as select from zrap200_cc_opt
{
  key case_uuid as CaseUUID,
  key option_no as OptionNo,

  option_id as OptionID,
  option_type as OptionType,
  option_text as OptionText,

  cost_score as CostScore,
  time_score as TimeScore,
  risk_score as RiskScore,
  feasibility_score as FeasibilityScore,
  total_score as TotalScore,

  rating as Rating,
  is_recommended as IsRecommended,
  reason_text as ReasonText
}
