@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Case Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_RAP200_CC_CASE
  provider contract transactional_query
  as projection on ZI_RAP200_CC_CASE

  association [0..*] to ZC_RAP200_CC_SCORE_GUIDE as _ScoringGuide
    on $projection.CaseUUID = _ScoringGuide.CaseUUID

  association [0..*] to ZC_RAP200_CC_LOG as _DecisionLogs
    on $projection.CaseUUID = _DecisionLogs.CaseUUID

{
  key CaseUUID,

  CaseID,
  CaseTitle,
  RaceID,
  RaceName,
  CrisisType,
  Severity,
  Status,

  RecommendedOptionID,
  RecommendedOptionType,
  RecommendedScore,
  RecommendedRating,
  RecommendedText,

  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt,

  _RecoveryOptions : redirected to composition child ZC_RAP200_CC_OPT,
  _CrisisFactors   : redirected to composition child ZC_RAP200_CC_FACT,
  _CaseResources   : redirected to composition child ZC_RAP200_CC_CRES,
  _ScoringGuide,
  _DecisionLogs
}
