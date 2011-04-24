require File.expand_path(__FILE__ + "/../../spec_helper.rb")

class Sinatra::Asterisk::TestApp < Sinatra::Application 
    include Sinatra::Asterisk

    start_agi_server
    helpers do
        def test_helper
            request.helper_was_called
        end
    end

    agi /^test/ do
       request.block_was_called
       test_helper
    end
end

def mock_request(script, headers = {})
  unless @mock_request
    @mock_request = mock('MockAgiRequest')
    @mock_request.stub!(
        :extension  => "test",
        :priority   => "1",
        :context    => "default",
        :uniqueId   => "123456789.7", 
        :language   => "en",
        :channel    => "SIP/127.0.0.1-00000003",
        :type       => "SIP",
        :script     => script,
        :requestURL => "agi://fake_test_host:1234/#{script}") #[?param1=value1&param2=value2]. "
  end
  @mock_request
end

describe Sinatra::Asterisk::TestApp do
  it "should call the block" do
    mock_request("test").should_receive(:block_was_called)
    @mock_request.should_receive(:helper_was_called)

    Sinatra::Asterisk::TestApp.instance_variable_get("@agi_script").service(@mock_request, nil)
  end
end
