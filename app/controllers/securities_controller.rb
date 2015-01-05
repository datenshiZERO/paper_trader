class SecuritiesController < ApplicationController
  before_action :authenticate_user!, only: [:buy, :process_buy, :sell, :process_sell]

  def index
    @securities = Security.order(:symbol).all
    @day_ticker_log = DayTickerLog.last
  end

  def show
    @security = Security.find(params[:id])
    @day_ticker_log = DayTickerLog.last
  end

  def buy
    @security = Security.find(params[:id])
    @transaction = current_user.portfolio_transactions.build
  end

  def sell
    @security = Security.find(params[:id])
  end
end
