@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZC_RAP200_CC_CTYPE_VH
  as select distinct from zrap200_cc_case
{
  @EndUserText.label: 'Crisis Type'
  @ObjectModel.text.element: [ 'CrisisTypeText' ]
  key cast( 'WEATHER' as abap.char(30) ) as CrisisType,

  @EndUserText.label: 'Description'
  cast( 'Weather, rain, or track condition issue' as abap.char(80) ) as CrisisTypeText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'CRASH' as abap.char(30) ) as CrisisType,
  cast( 'Crash, accident, or car damage issue' as abap.char(80) ) as CrisisTypeText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'LOGISTICS' as abap.char(30) ) as CrisisType,
  cast( 'Shipment, parts, or resource delay' as abap.char(80) ) as CrisisTypeText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'COMPLIANCE' as abap.char(30) ) as CrisisType,
  cast( 'Regulation, inspection, or rule issue' as abap.char(80) ) as CrisisTypeText
}
