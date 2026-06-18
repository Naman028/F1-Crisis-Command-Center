@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Race Value Help'
@Search.searchable: true
@ObjectModel.resultSet.sizeCategory: #XS

@UI.presentationVariant: [
  {
    sortOrder: [
      {
        by: 'RoundNo',
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

define view entity ZC_RAP200_CC_RACE_VH
  as select from ZI_RAP200_CC_RACE
{
  @EndUserText.label: 'Race ID'
  @UI.hidden: true
  key RaceID,

  @EndUserText.label: 'Race'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 10,
      label: 'Race'
    }
  ]
  RaceName,

  @EndUserText.label: 'Round'
  @UI.lineItem: [
    {
      position: 20,
      label: 'Round'
    }
  ]
  RoundNo,

  @EndUserText.label: 'Country'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.lineItem: [
    {
      position: 30,
      label: 'Country'
    }
  ]
  RaceCountry,

  @EndUserText.label: 'City'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.hidden: true
  RaceCity,

  @EndUserText.label: 'Circuit'
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  @UI.hidden: true
  CircuitName,

  @EndUserText.label: 'Season'
  @UI.hidden: true
  SeasonYear,

  @EndUserText.label: 'Sprint Race'
  @UI.hidden: true
  SprintFlag,

  @EndUserText.label: 'Active'
  @UI.hidden: true
  ActiveFlag
}
where ActiveFlag = 'X'
