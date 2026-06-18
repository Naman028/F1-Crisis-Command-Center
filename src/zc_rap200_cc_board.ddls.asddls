@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Decision Board Report'
@Metadata.allowExtensions: true
@Search.searchable: true

@UI.headerInfo: {
  typeName: 'Decision Board Entry',
  typeNamePlural: 'Decision Board',
  title: {
    type: #STANDARD,
    value: 'CaseID'
  },
  description: {
    value: 'CaseTitle'
  }
}

@UI.presentationVariant: [
  {
    sortOrder: [
      {
        by: 'CaseID',
        direction: #ASC
      }
    ],
    visualizations: [
      {
        type: #AS_LINEITEM
      }
    ]
  }
]

define view entity ZC_RAP200_CC_BOARD
  as select from ZI_RAP200_CC_CASE
{
  @UI.facet: [
    {
      id: 'DecisionSummaryFacet',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Decision Summary',
      position: 10,
      targetQualifier: 'DecisionSummary'
    },
    {
      id: 'RecommendationFacet',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Recommendation',
      position: 20,
      targetQualifier: 'Recommendation'
    },
    {
      id: 'AuditFacet',
      purpose: #STANDARD,
      type: #FIELDGROUP_REFERENCE,
      label: 'Audit Information',
      position: 30,
      targetQualifier: 'AuditInfo'
    }
  ]

  @UI.hidden: true
  key CaseUUID,

  @EndUserText.label: 'Case ID'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 10,
      label: 'Case ID',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 10
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 10,
      label: 'Case ID'
    }
  ]
  CaseID,

  @EndUserText.label: 'Case Title'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 20,
      label: 'Case Title',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 20
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 20,
      label: 'Case Title'
    }
  ]
  CaseTitle,

  @EndUserText.label: 'Race'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 30,
      label: 'Race',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 30
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 30,
      label: 'Race'
    }
  ]
  RaceName,

  @EndUserText.label: 'Race ID'
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 40,
      label: 'Race ID'
    }
  ]
  RaceID,

  @EndUserText.label: 'Crisis Type'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 40,
      label: 'Crisis Type',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 40
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 50,
      label: 'Crisis Type'
    }
  ]
  CrisisType,

  @EndUserText.label: 'Severity'
  @UI.lineItem: [
    {
      position: 50,
      label: 'Severity',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 50
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 60,
      label: 'Severity'
    }
  ]
  Severity,

  @EndUserText.label: 'Status'
  @UI.lineItem: [
    {
      position: 60,
      label: 'Status',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 60
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'DecisionSummary',
      position: 70,
      label: 'Status'
    }
  ]
  Status,

  @EndUserText.label: 'Recommended Option Type'
  @UI.lineItem: [
    {
      position: 70,
      label: 'Recommended Option',
      importance: #HIGH
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'Recommendation',
      position: 10,
      label: 'Recommended Option Type'
    }
  ]
  RecommendedOptionType,

  @EndUserText.label: 'Recommended Option ID'
  @UI.fieldGroup: [
    {
      qualifier: 'Recommendation',
      position: 20,
      label: 'Recommended Option ID'
    }
  ]
  RecommendedOptionID,

  @EndUserText.label: 'Recommended Score'
  @UI.lineItem: [
    {
      position: 80,
      label: 'Score',
      importance: #HIGH
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'Recommendation',
      position: 30,
      label: 'Recommended Score'
    }
  ]
  RecommendedScore,

  @EndUserText.label: 'Recommended Rating'
  @UI.lineItem: [
    {
      position: 90,
      label: 'Rating',
      importance: #HIGH
    }
  ]
  @UI.selectionField: [
    {
      position: 70
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'Recommendation',
      position: 40,
      label: 'Recommended Rating'
    }
  ]
  RecommendedRating,

  @EndUserText.label: 'Recommendation Text'
  @UI.lineItem: [
    {
      position: 100,
      label: 'Recommendation Text',
      importance: #MEDIUM
    }
  ]
  @UI.fieldGroup: [
    {
      qualifier: 'Recommendation',
      position: 50,
      label: 'Recommendation Text'
    }
  ]
  RecommendedText,

  @EndUserText.label: 'Created By'
  @UI.fieldGroup: [
    {
      qualifier: 'AuditInfo',
      position: 10,
      label: 'Created By'
    }
  ]
  CreatedBy,

  @EndUserText.label: 'Created At'
  @UI.fieldGroup: [
    {
      qualifier: 'AuditInfo',
      position: 20,
      label: 'Created At'
    }
  ]
  CreatedAt,

  @EndUserText.label: 'Last Changed By'
  @UI.fieldGroup: [
    {
      qualifier: 'AuditInfo',
      position: 30,
      label: 'Last Changed By'
    }
  ]
  LastChangedBy,

  @EndUserText.label: 'Last Changed At'
  @UI.fieldGroup: [
    {
      qualifier: 'AuditInfo',
      position: 40,
      label: 'Last Changed At'
    }
  ]
  LastChangedAt
}
