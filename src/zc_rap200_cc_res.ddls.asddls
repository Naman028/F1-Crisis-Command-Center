@EndUserText.label: 'F1 Resource Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@UI.headerInfo: {
  typeName: 'Resource',
  typeNamePlural: 'Resources',
  title: {
    type: #STANDARD,
    value: 'ResourceName'
  },
  description: {
    value: 'ResourceID'
  }
}
define root view entity ZC_RAP200_CC_RES
  provider contract transactional_query
  as projection on ZI_RAP200_CC_RES
{
  @UI.facet: [
    {
      id: 'General',
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'General Information',
      position: 10
    }
  ]

  @EndUserText.label: 'Resource ID'
  @UI.lineItem: [
    {
      position: 10,
      label: 'Resource ID'
    }
  ]
  @UI.identification: [
    {
      position: 10,
      label: 'Resource ID'
    }
  ]
  key ResourceID,

  @EndUserText.label: 'Resource Name'
  @UI.lineItem: [
    {
      position: 20,
      label: 'Resource Name'
    }
  ]
  @UI.identification: [
    {
      position: 20,
      label: 'Resource Name'
    }
  ]
  ResourceName,

  @EndUserText.label: 'Resource Type'
  @UI.lineItem: [
    {
      position: 30,
      label: 'Type'
    }
  ]
  @UI.identification: [
    {
      position: 30,
      label: 'Resource Type'
    }
  ]
  ResourceType,

  @EndUserText.label: 'Approval Status'
  @UI.lineItem: [
    {
      position: 40,
      label: 'Approval Status'
    }
  ]
  @UI.identification: [
    {
      position: 40,
      label: 'Approval Status'
    }
  ]
  ApprovalStatus,

  @EndUserText.label: 'Available'
  @UI.lineItem: [
    {
      position: 50,
      label: 'Available'
    }
  ]
  @UI.identification: [
    {
      position: 50,
      label: 'Available'
    }
  ]
  AvailableFlag,

  @EndUserText.label: 'Lead Hours'
  @UI.lineItem: [
    {
      position: 60,
      label: 'Lead Hours'
    }
  ]
  @UI.identification: [
    {
      position: 60,
      label: 'Lead Hours'
    }
  ]
  LeadHours,

  @EndUserText.label: 'Base Cost'
  @UI.lineItem: [
    {
      position: 70,
      label: 'Base Cost'
    }
  ]
  @UI.identification: [
    {
      position: 70,
      label: 'Base Cost'
    }
  ]
  BaseCost,

  @EndUserText.label: 'Currency'
  @UI.lineItem: [
    {
      position: 80,
      label: 'Currency'
    }
  ]
  @UI.identification: [
    {
      position: 80,
      label: 'Currency'
    }
  ]
  Currency,

  @EndUserText.label: 'Performance Loss %'
  @UI.lineItem: [
    {
      position: 90,
      label: 'Performance Loss %'
    }
  ]
  @UI.identification: [
    {
      position: 90,
      label: 'Performance Loss %'
    }
  ]
  PerformanceLossPct,

  @EndUserText.label: 'Reliability Risk %'
  @UI.lineItem: [
    {
      position: 100,
      label: 'Reliability Risk %'
    }
  ]
  @UI.identification: [
    {
      position: 100,
      label: 'Reliability Risk %'
    }
  ]
  ReliabilityRiskPct,

  @EndUserText.label: 'CO2 KG'
  @UI.lineItem: [
    {
      position: 110,
      label: 'CO2 KG'
    }
  ]
  @UI.identification: [
    {
      position: 110,
      label: 'CO2 KG'
    }
  ]
  Co2Kg,

  @EndUserText.label: 'Last Changed At'
  @UI.hidden: true
  LastChangedAt
}
