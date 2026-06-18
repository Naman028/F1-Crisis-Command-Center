@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Budget Interface View'
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
  typeName: 'Budget Entry',
  typeNamePlural: 'Budget Reference',
  title: {
    type: #STANDARD,
    value: 'BudgetType'
  },
  description: {
    value: 'BudgetId'
  }
}

define view entity ZI_RAP200_CC_BUD
  as select from zrap200_cc_bud
{
  @EndUserText.label: 'Budget ID'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 10,
      label: 'Budget ID',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 10
    }
  ]
  key budget_id as BudgetId,

  @EndUserText.label: 'Season'
  @UI.lineItem: [
    {
      position: 20,
      label: 'Season',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 20
    }
  ]
  season as Season,

  @EndUserText.label: 'Budget Type'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 30,
      label: 'Budget Type',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 30
    }
  ]
  budget_type as BudgetType,

  @EndUserText.label: 'Cap Amount'
  @UI.lineItem: [
    {
      position: 40,
      label: 'Cap Amount',
      importance: #HIGH
    }
  ]
  cap_amount as CapAmount,

  @EndUserText.label: 'Used Amount'
  @UI.lineItem: [
    {
      position: 50,
      label: 'Used Amount',
      importance: #HIGH
    }
  ]
  used_amount as UsedAmount,

  @EndUserText.label: 'Reserved Amount'
  @UI.lineItem: [
    {
      position: 60,
      label: 'Reserved Amount',
      importance: #MEDIUM
    }
  ]
  reserved_amount as ReservedAmount,

  @EndUserText.label: 'Currency'
  @UI.lineItem: [
    {
      position: 70,
      label: 'Currency',
      importance: #MEDIUM
    }
  ]
  currency as Currency
}
