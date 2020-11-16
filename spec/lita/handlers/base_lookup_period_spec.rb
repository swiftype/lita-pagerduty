require 'spec_helper'

describe Lita::Handlers::Pagerduty, lita_handler: true do
  context 'base abc week' do
    it do
      is_expected.to route_command('pager base abc week').to(:base_lookup_period)
    end

    it 'schedule not found' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_raise(Exceptions::SchedulesEmptyList)
      send_command('pager base abc week')
      expect(replies.last).to eq('No matching schedules found for \'abc\'')
    end

    it 'period specified before schedule start date' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_return([{ id: 'abc123', name: 'abc', time_zone: 'America/Los_Angeles' }])
      expect_any_instance_of(Pagerduty).to receive(:get_users_from_layers).and_raise(Exceptions::SchedulesEmptyList)
      send_command('pager base abc week -50')
      expect(replies.last).to eq('No matching schedules found for \'abc\'')
    end

    it 'somebody on call' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_return([{ id: 'abc123', name: 'abc', time_zone: 'America/Los_Angeles' }])
      expect_any_instance_of(Pagerduty).to receive(:get_users_from_layers).and_return({"layer_name"=>"Layer 1", "layer_entries"=>["2020-11-22T23:59:59-05:00 - 2020-11-26T07:00:00-05:00  user1@elastic.co (User 1)", "2020-11-26T07:00:00-05:00 - 2020-11-29T00:00:00-05:00  user2@elastic.co (User 2)"], "override_entries"=>["None."]})
      send_command('pager base abc week')
      expect(replies.last).to eq("People on call for (Layer 1) of abc:\n"\
        "2020-11-22T23:59:59-05:00 - 2020-11-26T07:00:00-05:00  user1@elastic.co (User 1)\n"\
        "2020-11-26T07:00:00-05:00 - 2020-11-29T00:00:00-05:00  user2@elastic.co (User 2)\n"\
        "\n"\
        "Overrides:\n"\
        "None.")
    end

    it 'invalid unit' do
      expect_any_instance_of(Pagerduty).to receive(:get_schedules).and_return([{ id: 'abc123', name: 'abc', time_zone: 'America/Los_Angeles' }])
      send_command('pager base abc fortnight')
      expect(replies.last).to eq("I don't know the unit 'fortnight'. Expecting week, month or year.")
    end
  end
end
