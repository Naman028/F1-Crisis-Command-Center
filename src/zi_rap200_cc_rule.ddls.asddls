@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Rule Profile Interface View'
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
  typeName: 'Rule Profile',
  typeNamePlural: 'Rule Profiles',
  title: {
    type: #STANDARD,
    value: 'RuleProfileId'
  },
  description: {
    value: 'ActiveFlag'
  }
}

define view entity ZI_RAP200_CC_RULE
  as select from zrap200_cc_rule
{
  @EndUserText.label: 'Rule Profile ID'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 10,
      label: 'Rule Profile ID',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 10
    }
  ]
  key rule_profile_id as RuleProfileId,

  @EndUserText.label: 'Readiness Weight'
  @UI.lineItem: [
    {
      position: 20,
      label: 'Readiness Weight',
      importance: #HIGH
    }
  ]
  readiness_weight as ReadinessWeight,

  @EndUserText.label: 'Cost Weight'
  @UI.lineItem: [
    {
      position: 30,
      label: 'Cost Weight',
      importance: #HIGH
    }
  ]
  cost_weight as CostWeight,

  @EndUserText.label: 'Logistics Weight'
  @UI.lineItem: [
    {
      position: 40,
      label: 'Logistics Weight',
      importance: #HIGH
    }
  ]
  logistics_weight as LogisticsWeight,

  @EndUserText.label: 'Performance Weight'
  @UI.lineItem: [
    {
      position: 50,
      label: 'Performance Weight',
      importance: #MEDIUM
    }
  ]
  performance_weight as PerformanceWeight,

  @EndUserText.label: 'Priority Weight'
  @UI.lineItem: [
    {
      position: 60,
      label: 'Priority Weight',
      importance: #MEDIUM
    }
  ]
  priority_weight as PriorityWeight,

  @EndUserText.label: 'Sustainability Weight'
  @UI.lineItem: [
    {
      position: 70,
      label: 'Sustainability Weight',
      importance: #MEDIUM
    }
  ]
  sustainability_weight as SustainabilityWeight,

  @EndUserText.label: 'Green Threshold'
  @UI.lineItem: [
    {
      position: 80,
      label: 'Green Threshold',
      importance: #MEDIUM
    }
  ]
  green_threshold as GreenThreshold,

  @EndUserText.label: 'Yellow Threshold'
  @UI.lineItem: [
    {
      position: 90,
      label: 'Yellow Threshold',
      importance: #MEDIUM
    }
  ]
  yellow_threshold as YellowThreshold,

  @EndUserText.label: 'Active'
  @UI.lineItem: [
    {
      position: 100,
      label: 'Active',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 20
    }
  ]
  active_flag as ActiveFlag
}
