FactoryGirl.define do
  factory :security do
    symbol "2GO"
    company_name "2GO Group"
    company_profile "text"
    board_lot 1000
    last_price "3.34"
    volume_traded "23000"
    open_price "3.5"
    high_price "3.5"
    low_price "3.34"
    previous_close "3.45"
    percent_change_close 3.19
  end
end

