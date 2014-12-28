FactoryGirl.define do
  factory :ticker_log do
    ticker_as_of "2014-12-23 15:46:00"
    ticker_json "MyText"
    day_ticker_log
  end
end
