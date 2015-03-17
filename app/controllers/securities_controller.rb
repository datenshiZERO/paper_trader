class SecuritiesController < ApplicationController
  before_action :authenticate_user!, only: [:buy, :process_buy, :sell, :process_sell]
  def index
    @securities = Security.order(:symbol).all
    @day_ticker_log = DayTickerLog.last
  end

  def rsi
    @day_ticker_log = DayTickerLog.last
    @securities = @day_ticker_log.securities.order("stock_day_logs.rsi").all
  end

  def show
    @security = Security.find(params[:id])
    @day_ticker_log = DayTickerLog.last
    history = StockDayLog.find_by_sql([
      "SELECT 
         log_at, open_price, high_price, low_price, closing_price, volume_traded,
         sma_10, ema_30, (ema_12 - ema_26) as macdt, macd_signal, macd_divergence, 
         rsi
       FROM stock_day_logs
       INNER JOIN day_ticker_logs
         ON (stock_day_logs.day_ticker_log_id = day_ticker_logs.id)
       WHERE stock_day_logs.security_id = ? AND high_price IS NOT NULL
       ORDER BY stock_day_logs.created_at", @security.id])
    @json_history = JSON.generate(history.map do |d|
      [d.log_at.to_datetime.to_i * 1000,
       d.open_price.to_f,
       d.high_price.to_f,
       d.low_price.to_f,
       d.closing_price.to_f, 
       d.volume_traded.to_i,
       (d.sma_10.nil? ? nil : d.sma_10.to_f),
       (d.ema_30.nil? ? nil : d.ema_30.to_f),
       (d.macdt.nil? ? nil : d.macdt.to_f),
       (d.macd_signal.nil? ? nil : d.macd_signal.to_f),
       (d.macd_divergence.nil? ? nil : d.macd_divergence.to_f),
       (d.rsi.nil? ? nil : d.rsi.to_f)
      ]
    end)
  end

  def buy
    @security = Security.find(params[:id])
    @transaction = current_user.portfolio_transactions.build
  end

  def sell
    @security = Security.find(params[:id])
  end
end
