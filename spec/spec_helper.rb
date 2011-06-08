require "java"
require "sinatra/asterisk"
require "sinatra" # needed to test classical style

def mock_request(script = "test" , headers = {})
  unless @mock_request
    @mock_request = mock("MockAgiRequest[script=#{script}]")
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

def mock_event(name = :Reload, *args)
  args = ["mock_source"] if args.empty?
  unless @mock_event
    @mock_event = eval("org.asteriskjava.manager.event.#{name}Event")::new(*args)
  end
  @mock_event
end

def mock_manager
  unless @mock_manager
    @mock_manager = mock('MockManager')
  end
  @mock_manager
end

def mock_channel
  unless @mock_channel
    @mock_channel = mock('MockChannel')
  end
  @mock_channel
end
