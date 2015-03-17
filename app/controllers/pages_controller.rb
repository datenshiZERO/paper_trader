class PagesController < ApplicationController
  def index
    @day_ticker_log = DayTickerLog.last
    unless @day_ticker_log.nil?
      @most_active = @day_ticker_log.securities.order("(securities.volume_traded * last_price) desc").limit(10)
      @gainers = @day_ticker_log.securities.order(percent_change_close: :desc).limit(10)
      @losers = @day_ticker_log.securities.order(percent_change_close: :asc).limit(10)
    end
  end
end
