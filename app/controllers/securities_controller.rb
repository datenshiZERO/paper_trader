class SecuritiesController < ApplicationController
  before_action :authenticate_user!, only: [:buy, :process_buy, :sell, :process_sell]

  def index
    @securities = Security.order(:symbol).all
    @day_ticker_log = DayTickerLog.last
  end

  def show
    @security = Security.find(params[:id])
    @day_ticker_log = DayTickerLog.last
    history = StockDayLog.find_by_sql([
      "SELECT log_at, open_price, high_price, low_price, closing_price, volume_traded
       FROM stock_day_logs
       INNER JOIN day_ticker_logs
         ON (stock_day_logs.day_ticker_log_id = day_ticker_logs.id)
       WHERE stock_day_logs.security_id = ?
       ORDER BY stock_day_logs.created_at", @security.id])
    @json_history = JSON.generate(history.map do |d|
      [d.log_at.to_datetime.to_i * 1000,
       d.open_price.to_f,
       d.high_price.to_f,
       d.low_price.to_f,
       d.closing_price.to_f, 
       d.volume_traded.to_i]
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
