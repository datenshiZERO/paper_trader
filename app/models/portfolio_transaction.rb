class PortfolioTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :security
  belongs_to :stock_ticker_log
  belongs_to :portfolio_entry
end
