# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

if window.StockData?
  data = window.StockData
  ohlc = []
  volume = []
  dataLength = data.length
  groupingUnits = [
    [ 'week', [ 1 ] ]
    [ 'month', [ 1, 2, 3, 4, 6 ] ]
  ]
  for d in data
    ohlc.push [
      d[0]
      d[1]
      d[2]
      d[3]
      d[4]
    ]
    volume.push [
      d[0]
      d[5]
    ]

  # create the chart
  $('#chart-container').highcharts 'StockChart',
    rangeSelector: selected: 1
    title: text: 'AAPL Historical'
    yAxis: [
      {
        labels:
          align: 'right'
          x: -3
        title: text: 'OHLC'
        height: '60%'
        lineWidth: 2
      }
      {
        labels:
          align: 'right'
          x: -3
        title: text: 'Volume'
        top: '65%'
        height: '35%'
        offset: 0
        lineWidth: 2
      }
    ]
    series: [
      {
        type: 'candlestick'
        name: 'AAPL'
        data: ohlc
        dataGrouping: units: groupingUnits
      }
      {
        type: 'column'
        name: 'Volume'
        data: volume
        yAxis: 1
        dataGrouping: units: groupingUnits
      }
    ]
