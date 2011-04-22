require File.expand_path(__FILE__ + "/../../spec_helper.rb")

class Sinatra::Asterisk::TestApp < Sinatra::Application 
    include Sinatra::Asterisk
    agi /^test/ do
        block_called
    end
end

describe Sinatra::Asterisk::TestApp do
  describe "register" do
    it "pending" do
      puts subject.inspect
    end
  end

end
