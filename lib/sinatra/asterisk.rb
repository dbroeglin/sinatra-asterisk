require 'sinatra/base'
require 'java'
require File.expand_path(__FILE__ + '/../asterisk/asterisk-java-1.0.0.M3.jar')

require 'sinatra/asterisk/utils'

module Sinatra
  module Asterisk
    java_import org.asteriskjava.fastagi.BaseAgiScript
    java_import org.asteriskjava.fastagi.MappingStrategy
    java_import org.asteriskjava.fastagi.DefaultAgiServer
    java_import org.asteriskjava.manager.ManagerConnectionFactory
    java_import org.asteriskjava.manager.ManagerEventListener


    module Helpers
    end

    class SinatraAgiScript < BaseAgiScript
      include MappingStrategy
      attr_accessor :agi_handlers, :sinatra_app
      
      # Implements MappingStrategy
      def determineScript(request)
        self
      end
     
      def eval_in_sinatra(request, channel, &block)
          sinatra = sinatra_app::new!
          sinatra_eigenclass = (class <<sinatra; self; end)
          sinatra_eigenclass.class_eval do
              # TODO: do this with a module ?
              define_method(:request) { request } 
              define_method(:channel) { channel } 
          end

          sinatra.instance_eval(&block)
      end

      # Implements AgiScript
      def service(request, channel)
        catch(:halt) do
          block = @agi_handlers.each do |script_pattern, conditions, block|
            catch :pass do
              throw :pass unless script_pattern.nil? || script_pattern.match(request.script)
              throw :halt, eval_in_sinatra(request, channel, &block) 
            end
          end
        end
      end
    end

    class SinatraManagerEventListener
      include ManagerEventListener

      def initialize(*args)
        @event_handlers, @sinatra_app = *args 
      end
      
      def eval_in_sinatra(event, &block)
          sinatra = @sinatra_app::new!
          sinatra_eigenclass = (class <<sinatra; self; end)
          sinatra_eigenclass.class_eval do
              # TODO: do this with a module ?
              define_method(:event) { event }
          end

          sinatra.instance_eval(&block)
      end

      # implements ManagerEventListener
      def onManagerEvent(event)
        event_name = event.class.name.gsub(/^.*::/, '').gsub(/Event$/, '')
        catch(:halt) do
          block = @event_handlers.each do |event_class, block|
            catch :pass do
              throw :pass unless event_class.nil? || Utils::camelize(event_class) == event_name
              throw :halt, eval_in_sinatra(event, &block) 
            end
          end
        end
      end
    end
    
    def start_agi_server
      @agi_script = SinatraAgiScript::new
      @agi_script.agi_handlers = agi_handlers
      @agi_script.sinatra_app  = self
      
      @agi_server = DefaultAgiServer::new()
      @agi_server.mappingStrategy = @agi_script
      Thread.new do
        begin
          @agi_server.startup
        rescue  => e
          puts "ERROR: #{e}: #{e.backtrace.join("\n")}"
        end
      end
    end
    
    def connect_to_manager(hostname, username, password)
      factory = ManagerConnectionFactory::new(hostname, username, password)
      manager_connection = factory.createManagerConnection
      initialize_manager_event_listener(manager_connection)
      manager_connection.login

      set :manager, manager_connection
    end

    def initialize_manager_event_listener(manager_connection)
      @manager_event_listener = SinatraManagerEventListener::new(event_handlers, self)
      manager_connection.addEventListener(@manager_event_listener)
    end

    def agi(uri_pattern = nil, conditions = {}, &block)
      uri_pattern = Regexp::new(uri_pattern) if uri_pattern && !uri_pattern.respond_to?(:match)
      agi_handlers << [uri_pattern, conditions, Proc::new(&block)]
    end

    def on_event(event_class = nil, &block)
      event_handlers << [event_class, Proc::new(&block)]
    end
    
    private
    
    def agi_handlers
      @agi_handlers ||= []
    end
    
    def event_handlers
      @event_handlers ||= []
    end
  
    def self.registered(app)
      app.helpers Helpers
    end
  end
  
  register Asterisk
end
