require File.expand_path(__FILE__ + "/../../spec_helper.rb")

TestClass = Sinatra::new(Sinatra::Base) do
    register Sinatra::Asterisk
end

class MyException < Exception; end

def build_app(base=TestClass, &block)
  Sinatra::new(base) do
    instance_eval(&block)
    start_agi_server(:noop => true)
  end
end

describe "generic agi error handler " do
  subject do 
    build_app do
      configure { disable :show_exceptions, :dump_errors }
      agi "generic error handler" do raise RuntimeError, "bar" end 
      error { request.helper_was_called }
    end
  end

  it "should intercept all exceptions and access the request scope" do
    mock_request("generic error handler").should_receive(:helper_was_called)
    subject.class_eval { agi_script }.service(mock_request, nil)
  end
end

describe "MyException agi error handler " do

  subject do 
    build_app do
      configure { disable :show_exceptions, :dump_errors }
      agi /^MyException1/ do raise MyException, "foo"  end
      agi /^MyException2/ do raise RuntimeError, "bar" end 
      error MyException do request.handling_my_exception; true end 
      error do request.handling_generic_exception; true end 
    end
  end

  it "should intercept MyException and access the request scope" do
    mock_request("MyException1").should_receive(:handling_my_exception)
    mock_request("MyException1").should_not_receive(:handling_generic_exception)
    subject.instance_eval { agi_script }.service(mock_request, nil)
  end
  
  it "should not intercept RuntimeError and not access the request scope" do
    mock_request("MyException2").should_not_receive(:handling_my_exception)
    mock_request("MyException2").should_receive(:handling_generic_exception)
    subject.instance_eval { agi_script }.service(mock_request, nil)
  end
end  

describe "generic event error handler " do
  subject do 
    manager_connection = mock("manager_connection")
    manager_connection.should_receive(:addEventListener)
    build_app do
      initialize_manager_event_listener(manager_connection)
      configure { disable :show_exceptions, :dump_errors }
      on_event :reload do raise RuntimeError, "foo" end 
      error do event.handling_generic_exception; true end 
    end
  end

  it "should intercept all exceptions and access the request scope" do
    mock_event.should_receive(:handling_generic_exception)
    
    subject.instance_eval { @manager_event_listener }.onManagerEvent(mock_event)
  end
end

describe "MyException event error handler " do
  subject do 
    manager_connection = mock("manager_connection")
    manager_connection.should_receive(:addEventListener)
    build_app do
      initialize_manager_event_listener(manager_connection)
      configure { disable :show_exceptions, :dump_errors }
      on_event :reload do raise RuntimeError, "foo" end 
      on_event :alarm do raise MyException, "bar" end 
      error MyException do event.handling_my_exception; true end 
      error do event.handling_generic_exception; true end 
    end
  end

  it "should intercept MyException and access the request scope" do
    mock_event(:Alarm).should_receive(:handling_my_exception)
    mock_event.should_not_receive(:handling_generic_exception)

    subject.instance_eval { @manager_event_listener }.onManagerEvent(mock_event)
  end

  it "should not intercept RuntimeError and not access the event scope" do
    mock_event(:Reload).should_not_receive(:handling_my_exception)
    mock_event.should_receive(:handling_generic_exception)

    subject.instance_eval { @manager_event_listener }.onManagerEvent(mock_event)
  end
end
