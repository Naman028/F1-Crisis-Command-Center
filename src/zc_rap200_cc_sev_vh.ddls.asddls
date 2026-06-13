@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'F1 Crisis Severity Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZC_RAP200_CC_SEV_VH
  as select distinct from zrap200_cc_case
{
  @EndUserText.label: 'Severity'
  @ObjectModel.text.element: [ 'SeverityText' ]
  key cast( 'LOW' as abap.char(20) ) as Severity,

  @EndUserText.label: 'Description'
  cast( 'Minor operational impact' as abap.char(80) ) as SeverityText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'MEDIUM' as abap.char(20) ) as Severity,
  cast( 'Manageable issue requiring attention' as abap.char(80) ) as SeverityText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'HIGH' as abap.char(20) ) as Severity,
  cast( 'Serious issue affecting strategy' as abap.char(80) ) as SeverityText
}

union all select distinct from zrap200_cc_case
{
  key cast( 'CRITICAL' as abap.char(20) ) as Severity,
  cast( 'Immediate high-priority race impact' as abap.char(80) ) as SeverityText
}
