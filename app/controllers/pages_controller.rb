class PagesController < ApplicationController
  def index
    @day_ticker_log = DayTickerLog.last
    unless @day_ticker_log.nil?
      @most_active = Security.order("(volume_traded * last_price) desc").limit(10)
      @gainers = Security.order(percent_change_close: :desc).limit(10)
      @losers = Security.order(percent_change_close: :asc).limit(10)
    end
  end
end
