@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Case Interface View'
define root view entity ZI_RAP200_CC_CASE
  as select from zrap200_cc_case
  composition [0..*] of ZI_RAP200_CC_OPT as _RecoveryOptions
  association [0..*] to ZI_RAP200_CC_LOG as _DecisionLogs
    on $projection.CaseUUID = _DecisionLogs.CaseUUID
{
  key case_uuid               as CaseUUID,

      case_id                 as CaseID,
      case_title              as CaseTitle,
      race_id                 as RaceID,
      race_name               as RaceName,
      crisis_type             as CrisisType,
      severity                as Severity,
      status                  as Status,

      recommended_option_id   as RecommendedOptionID,
      recommended_option_type as RecommendedOptionType,
      recommended_score       as RecommendedScore,
      recommended_rating      as RecommendedRating,
      recommended_text        as RecommendedText,

      created_by              as CreatedBy,
      created_at              as CreatedAt,
      last_changed_by         as LastChangedBy,
      last_changed_at         as LastChangedAt,
      local_last_changed_at   as LocalLastChangedAt,

      _RecoveryOptions,
      _DecisionLogs
}
