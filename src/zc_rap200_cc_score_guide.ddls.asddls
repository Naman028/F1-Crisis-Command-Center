@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Scoring Guide View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_RAP200_CC_SCORE_GUIDE
  as select distinct from zrap200_cc_case
{
  key cast( 'COST' as abap.char(20) ) as GuideID,
      cast( 'Cost Score' as abap.char(40) ) as GuideTitle,
      cast( '0-20 costly, 41-60 medium, 81-100 cost-efficient' as abap.char(120) ) as ScoreRange,
      cast( 'Higher score means the option is cheaper or more cost-efficient.' as abap.char(120) ) as Meaning,
      cast( 20 as abap.int1 ) as WeightPercent,
      cast( 'Used in total score calculation.' as abap.char(120) ) as UsageText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'TIME' as abap.char(20) ) as GuideID,
      cast( 'Time Score' as abap.char(40) ) as GuideTitle,
      cast( '0-20 slow, 41-60 acceptable, 81-100 very fast' as abap.char(120) ) as ScoreRange,
      cast( 'Higher score means the option can be executed faster.' as abap.char(120) ) as Meaning,
      cast( 30 as abap.int1 ) as WeightPercent,
      cast( 'Most important factor because F1 crisis response is time-critical.' as abap.char(120) ) as UsageText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'RISK' as abap.char(20) ) as GuideID,
      cast( 'Risk Control Score' as abap.char(40) ) as GuideTitle,
      cast( '0-20 risky, 41-60 manageable, 81-100 very safe' as abap.char(120) ) as ScoreRange,
      cast( 'Higher score means the option has better risk control.' as abap.char(120) ) as Meaning,
      cast( 25 as abap.int1 ) as WeightPercent,
      cast( 'Used to avoid unsafe or regulation-risky decisions.' as abap.char(120) ) as UsageText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'FEASIBILITY' as abap.char(20) ) as GuideID,
      cast( 'Feasibility Score' as abap.char(40) ) as GuideTitle,
      cast( '0-20 hard, 41-60 possible, 81-100 easy to execute' as abap.char(120) ) as ScoreRange,
      cast( 'Higher score means the option is easier to execute with available resources.' as abap.char(120) ) as Meaning,
      cast( 25 as abap.int1 ) as WeightPercent,
      cast( 'Used to prefer practical recovery actions.' as abap.char(120) ) as UsageText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'WORKFLOW' as abap.char(20) ) as GuideID,
      cast( 'Workflow Guide' as abap.char(40) ) as GuideTitle,
      cast( 'Create or edit case, save draft, then generate recommendation' as abap.char(120) ) as ScoreRange,
      cast( 'The recommendation action calculates totals and selects the best option.' as abap.char(120) ) as Meaning,
      cast( 0 as abap.int1 ) as WeightPercent,
      cast( 'Use manual options when the team wants to compare custom recovery strategies.' as abap.char(120) ) as UsageText
}
