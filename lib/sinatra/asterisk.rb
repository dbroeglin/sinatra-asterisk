require 'sinatra/base'
require 'java'
require File.expand_path(File.dirname(__FILE__)) + '/asterisk-java-0.3.1.jar'

module Sinatra
  module Asterisk
    java_import org.asteriskjava.fastagi.BaseAgiScript
    java_import org.asteriskjava.fastagi.MappingStrategy
    java_import org.asteriskjava.fastagi.DefaultAgiServer
    
    module Helpers
    end
    
    # TODO: implement proxy to Sinatra::Application ?
    class AgiContext
      instance_methods.each { |m| undef_method m unless m =~ /^(__|instance_eval)/ }
      attr_reader :request, :channel
      
      def initialize(*args)
        @request, @channel = *args
      end
      
      def execute(&block)
        instance_eval(&block)
      end
    end

    class SinatraAgiScript < BaseAgiScript
      attr_accessor :agi_handlers

      include MappingStrategy
      
      # Implements MappingStrategy
      def determineScript(request)
        self
      end
      
      # Implements AgiScript
      def service(request, channel)
        catch(:halt) do
          block = @agi_handlers.each do |script_pattern, block|
            catch :pass do
              throw :pass unless script_pattern.nil? || script_pattern.match(request.script)
              throw :halt, AgiContext::new(request, channel).execute(&block)
            end
          end
        end
      end
    end
    
    def start_agi_server
      agi_script = SinatraAgiScript::new()
      agi_script.agi_handlers = agi_handlers
      
      @agi_server = DefaultAgiServer::new()
      @agi_server.mappingStrategy = agi_script
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
      manager_connection.login

      set :manager, manager_connection
    end
    
    def agi(uri_pattern = nil, conditions = {}, &block)
      uri_pattern = Regexp::new(uri) if uri_pattern
      agi_handlers << [uri_pattern, Proc::new(&block)]
    end
    
    private
    
    def agi_handlers
      @agi_handlers ||= []
    end
  
    def self.registered(app)
      app.helpers Helpers
    end
  end
  
  register Asterisk
end