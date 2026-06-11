@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Recovery Option Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_RAP200_CC_OPT
  provider contract transactional_query
  as projection on ZI_RAP200_CC_OPT
{
  key CaseUUID,
  key OptionNo,

  OptionID,
  OptionType,
  OptionText,

  CostScore,
  TimeScore,
  RiskScore,
  FeasibilityScore,
  TotalScore,

  Rating,
  IsRecommended,
  ReasonText
}
