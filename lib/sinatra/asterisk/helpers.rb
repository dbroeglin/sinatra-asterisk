module Sinatra
  module Asterisk
    java_import org.asteriskjava.manager.action.PingAction

    module Helpers
      #
      # Define request, channel, manager and event accessors
      #
      attr_writer :request, :channel, :event

      def request
        method_missing :request if @request.nil?
        @request
      end
      
      def channel
        method_missing :channel if @channel.nil?
        @channel
      end
      
      def event
        method_missing :event if @event.nil?
        @event
      end

      def manager
        settings.manager
      end

      def _simulate_env
        # simulate Sinatra env, TODO: review
        @env = {} 
        @env['rack.errors'] = $stderr 
        @response = Struct.new(:status).new
      end

      #
      # AGI helpers
      #
      include_package "org.asteriskjava.manager.action"

      def send_action(action, *args)
        if args.last.kind_of? Hash
          hash = args.pop
        end
        case action
          when Symbol, String 
            action = Utils::camelize action.to_s
            class_name = "#{action}Action"  
            action = Helpers.const_get(class_name)::new(*args)
          when Class 
            action = action::new(*args)
        end
        if hash
          hash.each_pair do |name, value|
            action.__send__("#{name}=", value)
          end
        end
        if block_given?
          action.instance_eval(&Proc::new)
        end
        manager.send_action action
      end

      def play(*args)
        channel.streamFile(*args) 
      end

      def start_music_on_hold(*args)
        channel.startMusicOnHold(*args)
      end

      def stop_music_on_hold
        channel.stopMusicOnHold
      end

      def hangup
        channel.hangup
      end

      def answer
        channel.answer
      end

      def exec(app, options = "")
        if options.kind_of? Array
          options = options.join(",")
        end
        channel.exec app.to_s, options.to_s
      end
    end
  end
end
