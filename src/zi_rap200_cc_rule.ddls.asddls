@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Rule Profile Interface View'
define view entity ZI_RAP200_CC_RULE
  as select from zrap200_cc_rule
{
  key rule_profile_id as RuleProfileID
}
