@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Case Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_RAP200_CC_CASE
  provider contract transactional_query
  as projection on ZI_RAP200_CC_CASE
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
  LastChangedAt
}
