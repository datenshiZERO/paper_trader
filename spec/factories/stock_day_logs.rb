FactoryGirl.define do
  factory :stock_day_log do
    security
    day_ticker_log 
    volume_traded "23000"
    open_price "3.5"
    high_price "3.5"
    low_price "3.34"
  end

end
