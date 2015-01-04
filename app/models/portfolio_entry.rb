class PortfolioEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :security
end
