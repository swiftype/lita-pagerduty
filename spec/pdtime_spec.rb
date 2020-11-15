require 'spec_helper'

describe PDTime do
  it 'get_last_day_of_month' do
    expect(PDTime.get_last_day_of_month(10)).to eq(31)
    expect(PDTime.get_last_day_of_month(11)).to eq(30)
    expect(PDTime.get_last_day_of_month(12)).to eq(31)
  end
  it 'get_whole_week next week' do
    allow(DateTime).to receive(:now).and_return DateTime.new(2020,11,11)
    expect(PDTime.get_whole_week('America/New_York', 1)).to eq(
      {
        "now_begin"=>"2020-11-15T23:59:59",
        "now_end"=>"2020-11-22T00:00:00"
      })
  end
  it 'get_whole_week this week' do
    allow(DateTime).to receive(:now).and_return DateTime.new(2020,11,11)
    expect(PDTime.get_whole_week('America/New_York', 0)).to eq(
      {
        "now_begin"=>"2020-11-08T23:59:59",
        "now_end"=>"2020-11-15T00:00:00"
      })
  end
  it 'get_whole_week last week' do
    allow(DateTime).to receive(:now).and_return DateTime.new(2020,11,11)
    expect(PDTime.get_whole_week('America/New_York', -1)).to eq(
      {
        "now_begin"=>"2020-11-01T23:59:59",
        "now_end"=>"2020-11-08T00:00:00"
      })
  end
end
