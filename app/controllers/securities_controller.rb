class SecuritiesController < ApplicationController
  def index
    @securities = Security.order(:symbol).all
    @day_ticker_log = DayTickerLog.last
  end

  def show
    @security = Security.find(params[:id])
    @day_ticker_log = DayTickerLog.last
  end
end
