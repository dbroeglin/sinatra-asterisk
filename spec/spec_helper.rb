require "java"
require "sinatra/asterisk"
require "sinatra" # required for classical style testing

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

def mock_event()
  unless @mock_event
    @mock_event = mock('MockManagerEvent')
  end
  @mock_event
end

def mock_manager
  unless @mock_manager
    @mock_manager = mock('MockManager')
  end
  @mock_manager
end
