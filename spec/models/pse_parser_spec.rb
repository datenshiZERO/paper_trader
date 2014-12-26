require 'rails_helper'

RSpec.describe PseParser do
  it 'should be able to get JSON data from ticker' do
    json = PseParser.new.get_json

    expect(json.first["securitySymbol"]).to eq "Stock Update As of"
  end
end
