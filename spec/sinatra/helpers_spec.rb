require File.expand_path(__FILE__ + "/../../spec_helper.rb")


class Sinatra::Asterisk::HelpersTestApp < Sinatra::Application 
  include Sinatra::Asterisk
end

self.class.send :include_package, "org.asteriskjava.manager.action"

describe Sinatra::Asterisk::HelpersTestApp::new! do

  before do
    Sinatra::Asterisk::HelpersTestApp::set :manager, mock_manager
  end


  it "should send action the Java way" do
    action = PingAction::new 
    mock_manager.should_receive(:send_action).with(action)

    subject.send_action action 
  end

  it "should send an action based on it's name" do
    mock_manager.should_receive(:send_action).with(an_instance_of(PingAction))
    mock_manager.should_receive(:send_action).with(an_instance_of(ListCommandsAction))

    subject.send_action :ping
    subject.send_action :list_commands
  end
  
  it "should send an action initialized through it's constructor based on it's name" do
    mock_manager.should_receive(:send_action).with do |action|
      action.kind_of? GetVarAction
      action.variable.should == "foo"
    end

    subject.send_action :get_var, "foo"
  end
  
  it "should send an action initialized through a block based on it's name" do
    mock_manager.should_receive(:send_action).with do |action|
      action.kind_of? OriginateAction
      action.exten.should == "foo"
    end

    subject.send_action :originate do
      self.exten= "foo"
    end
  end
  
  it "should send an action initialized through a block based on it's class" do
    mock_manager.should_receive(:send_action).with do |action|
      action.kind_of? OriginateAction
      action.exten.should == "foo"
    end

    subject.send_action OriginateAction do
      self.exten= "foo"
    end
  end
  
  it "should send an action initialized through a Hash based on it's class" do
    mock_manager.should_receive(:send_action).with do |action|
      action.kind_of? OriginateAction
      action.exten.should == "foo"
      action.priority.should == 1
    end

    subject.send_action OriginateAction, :exten => "foo", :priority => 1
  end
end

