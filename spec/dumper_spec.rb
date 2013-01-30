require 'dm-core'
require 'dm-migrations'
require 'slf4r/ruby_logger'
require 'ixtlan/errors/resource'

Error = Ixtlan::Errors::Error

require 'pony'
Pony.options = { :via => :test }

require 'ixtlan/errors/dumper'
require 'date'
require 'logger'

class Controller < Hash

  def request
    self
  end
  def env
    @env ||= {:one => 1, :two => 2, :three => 3}
  end

  def response
    self
  end

  def headers
    @headers ||= { 'ONE' => 1, "TWO" => 2 }
  end

  def session
    @session ||= { "user" => "me" }
  end

  def params
    @params ||= { :query => "all" }
  end
end

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.auto_migrate!

describe Ixtlan::Errors::Dumper do

  before :each do
    @dumper = Ixtlan::Errors::Dumper.new
    @dumper.model = Error
    @dumper.base_url = "http://localhost"
    @controller = Controller.new
  end

  it "should dump env and not send notification" do
    send = @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    send.should be_false

    @dumper.from_email = "asd"
    send = @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    send.should be_false

    @dumper.from_email = nil
    @dumper.to_emails = "dsa"
    send = @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    send.should be_false
  end

  it "should clean up error dumps" do
    Error.create(:message => 'msg', :clazz => StandardError.to_s)
    Error.all.size.should > 0
    @dumper.keep_dumps = 0
    Error.all.size.should == 0

    @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    Error.all.size.should == 1

    @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    Error.all.size.should == 2
  end

  it "should send notifications" do
    @dumper.to_emails = "das"
    @dumper.from_email = "asd"
    
    send = @dumper.dump(StandardError.new("dump it"), @controller.request, @controller.response, @controller.session, @controller.params)
    send.should be_true
  end
end
