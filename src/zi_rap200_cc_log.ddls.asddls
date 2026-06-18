@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Decision Log Interface View'
define root view entity ZI_RAP200_CC_LOG
  as select from zrap200_cc_log
  association to ZI_RAP200_CC_CASE as _CrisisCase
    on $projection.CaseUUID = _CrisisCase.CaseUUID
{
  key case_uuid               as CaseUUID,
  key log_no                  as LogNo,

      case_id                 as CaseID,
      crisis_type             as CrisisType,
      severity                as Severity,

      recommended_option_id   as RecommendedOptionID,
      recommended_option_type as RecommendedOptionType,
      recommended_score       as RecommendedScore,
      recommended_rating      as RecommendedRating,
      reason_text             as ReasonText,

      created_by              as CreatedBy,
      created_at              as CreatedAt,

      _CrisisCase
}
