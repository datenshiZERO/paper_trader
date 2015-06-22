class ParseTickerJob < ActiveJob::Base
  queue_as :default

  def perform
    PseParser.new.parse_ticker
  end
end
