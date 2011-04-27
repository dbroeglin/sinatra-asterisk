# store top level for use during the tests
$top_level = self

require File.expand_path(__FILE__ + "/../../spec_helper.rb")

class Sinatra::Asterisk::TestApp < Sinatra::Application 
  include Sinatra::Asterisk

  start_agi_server

  helpers do
    def test_request_helper
      request.helper_was_called
    end

    def test_event_helper
      event.helper_was_called
    end
  end

  agi /^test/ do
   request.block_was_called
   test_request_helper
  end

  on_event :reload do
    event.reload_event_block_was_called
  end
  
  on_event do
    event.block_was_called
    test_event_helper
  end
end

describe Sinatra::Asterisk::TestApp do
  describe "when receiving an AGI request" do
    it "should access the request scope from an AGI" do
      mock_request("test").should_receive(:block_was_called)
      @mock_request.should_receive(:helper_was_called)

      Sinatra::Asterisk::TestApp.instance_variable_get("@agi_script").service(@mock_request, nil)
    end

    it "should not call a handler for script 'not_test'" do
      mock_request("not_test").should_not_receive(:block_was_called)
      @mock_request.should_not_receive(:helper_was_called)

      Sinatra::Asterisk::TestApp.instance_variable_get("@agi_script").service(@mock_request, nil)
    end

    it "should access the request scope from a classical AGI" do
      mock_request("test_top_level").should_receive(:block_was_called)
      $top_level.send :agi, /^test_top_level$/ do
        request.block_was_called
      end
      $top_level.send :start_agi_server, 4574
      Sinatra::Application.instance_variable_get("@agi_script").service(@mock_request, nil)
    end
  end
  describe "when receiving a ManagerEvent" do
    before do
      manager_connection = mock("manager_connection")
      manager_connection.should_receive(:addEventListener)
      Sinatra::Asterisk::TestApp.class_eval do
        initialize_manager_event_listener(manager_connection)
      end
    end

    it "should call handler for ReloadEvent" do
      ev = org.asteriskjava.manager.event.ReloadEvent::new("source")
      ev.should_receive(:reload_event_block_was_called)

      Sinatra::Asterisk::TestApp.instance_variable_get("@manager_event_listener").onManagerEvent(ev)
    end
  end
end
