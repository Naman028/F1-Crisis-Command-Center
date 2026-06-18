@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Scoring Guide View'
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_SCORE_GUIDE
  as select from ZI_RAP200_CC_SCORE_GUIDE
{
  key CaseUUID,
  key GuideID,

  GuideTitle,
  ScoreRange,
  Meaning,
  WeightPercent,
  UsageText
}
