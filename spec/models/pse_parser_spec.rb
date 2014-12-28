require 'rails_helper'

RSpec.describe PseParser do
  it 'should be able to get JSON data from ticker' do
    json = PseParser.new.get_json

    expect(json.first["securitySymbol"]).to eq "Stock Update As of"
  end

  describe 'DayTickerLog' do
    it 'should create a new record' do
      expect { PseParser.new.parse_ticker }.to change { DayTickerLog.count }.by(1)
    end

    it 'should not create a new record when same date already exists' do
      create(:day_ticker_log)
      expect { PseParser.new.parse_ticker }.to change { DayTickerLog.count }.by(0)
    end
  end

  describe 'TickerLog' do
    it 'should create a new record' do
      expect { PseParser.new.parse_ticker }.to change { TickerLog.count }.by(1)
    end

    it 'should not create a new record when same timestamp already exists' do
      create(:ticker_log)
      expect { PseParser.new.parse_ticker }.to change { TickerLog.count }.by(0)
    end
  end

  describe 'Security' do
    it 'should create a new record for missing security' do
      expect { PseParser.new.parse_ticker }.to change { Security.where(symbol: '2GO').count }.by(1)
    end

  end
end
