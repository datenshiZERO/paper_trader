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

    it 'should create a new record for all missing securities' do
      expect { PseParser.new.parse_ticker }.to change { Security.count }.by(27)
    end

    it 'should update security volume' do
      create(:security, volume_traded: 0)
      expect { PseParser.new.parse_ticker }.to change { Security.first.volume_traded }.by(23000)
    end
  end

  describe 'StockDayLog' do
    it 'should create a new record for each Security' do
      expect { PseParser.new.parse_ticker }.to change { StockDayLog.count }.by(27)
    end

    #it 'should not create a new record when same timestamp already exists' do
      #create(:ticker_log)
      #expect { PseParser.new.parse_ticker }.to change { TickerLog.count }.by(0)
    #end
  end

  describe 'StockTickerLog' do
    it 'should create a new record for each Security' do
      expect { PseParser.new.parse_ticker }.to change { StockTickerLog.count }.by(27)
    end

    #it 'should not create a new record when same timestamp already exists' do
      #create(:ticker_log)
      #expect { PseParser.new.parse_ticker }.to change { TickerLog.count }.by(0)
    #end
  end
end
