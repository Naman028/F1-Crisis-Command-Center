@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Budget Interface View'
define view entity ZI_RAP200_CC_BUD
  as select from zrap200_cc_bud
{
  key budget_id as BudgetID
}
