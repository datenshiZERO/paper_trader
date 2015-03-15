# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#

if window.StockData?
  data = window.StockData
  sma10 = []
  ema30 = []
  macd = []
  macd_signal = []
  macd_divergence = []
  rsi = []
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
    sma10.push [
      d[0]
      d[6]
    ]
    ema30.push [
      d[0]
      d[7]
    ]
    macd.push [
      d[0]
      d[8]
    ]

    macd_signal.push [
      d[0]
      d[9]
    ]
    macd_divergence.push [
      d[0]
      d[10]
    ]
    rsi.push [
      d[0]
      d[11]
    ]

  # create the chart
  $('#chart-container').highcharts 'StockChart',
    rangeSelector: selected: 1
    title: text: "#{window.Stock} Historical"
    yAxis: [
      {
        title: text: 'OHLC'
        labels:
          align: 'right'
          x: -3
        height: '50%'
        lineWidth: 2
      }
      {
        title: text: 'RSI'
        labels:
          align: 'right'
          x: -3
        top: '54%'
        height: '13%'
        offset: 0
        lineWidth: 2
        min: 0
        max: 100
        plotLines: [
          {
            value: 70,
            width: 1,
            color: '#808080'
          }
          {
            value: 50,
            width: 1,
            color: '#c0c0c0'
          }
          {
            value: 30,
            width: 1,
            color: '#808080'
          }
        ]
      }
      {
        title: text: 'MACD'
        labels:
          align: 'right'
          x: -3
        top: '70%'
        height: '13%'
        offset: 0
        lineWidth: 2
      }
      {
        title: text: 'Volume'
        labels:
          align: 'right'
          x: -3
        top: '86%'
        height: '14%'
        offset: 0
        lineWidth: 2
      }
    ]
    series: [
      {
        type: 'candlestick'
        name: window.Stock
        data: ohlc
        dataGrouping: units: groupingUnits
        zIndex: 9
      }
      {
        type: 'column'
        name: 'Volume'
        data: volume
        yAxis: 3
        dataGrouping: units: groupingUnits
      }
      {
        type: 'line'
        name: 'SMA 10'
        data: sma10
        dataGrouping: units: groupingUnits
      }
      {
        type: 'line'
        name: 'EMA 30'
        data: ema30
        dataGrouping: units: groupingUnits
      }
      {
        type: 'line'
        name: 'MACD'
        data: macd
        yAxis: 2
        dataGrouping: units: groupingUnits
      }
      {
        type: 'line'
        name: 'MACD Signal'
        data: macd_signal
        yAxis: 2
        dataGrouping: units: groupingUnits
      }
      {
        type: 'column'
        name: 'MACD Divergence'
        data: macd_divergence
        yAxis: 2
        dataGrouping: units: groupingUnits
      }
      {
        type: 'line'
        name: 'RSI'
        data: rsi
        yAxis: 1
        dataGrouping: units: groupingUnits
      }
    ]
