require 'dm-core'
require 'dm-migrations'
require 'slf4r/ruby_logger'

class Error
  include DataMapper::Resource

  property :id, Serial

  property :message, String
  property :clazz, String
  property :request, Text
  property :response, Text
  property :session, Text
  property :parameters, Text
  property :backtrace, Text

  property :created_at, DateTime

  before :save do
    self.created_at = DateTime.now
  end
end

module Ixtlan
  module Errors
    module ActionMailer
      class Base
        
        def self.method_missing(method, *args)
          self.new
        end

        def self.deliver(val = nul)
          @delivered = val if val
          @delivered
        end
        def deliver
          self.class.deliver(true)
        end
      end
    end
  end
end

require 'ixtlan/errors/error_dumper'
require 'date'
require 'logger'

class Controller

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

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    size == 0
  end
end

class Fixnum
  def days
    self
  end
  def ago
    DateTime.now - 86000 * self
  end
end

class DateTime
  def tv_sec
    sec
  end
  def tv_usec
    0
  end
end

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.finalize
DataMapper.repository.auto_migrate!

describe Ixtlan::Errors::ErrorDumper do

  before :each do
    @dumper = Ixtlan::Errors::ErrorDumper.new
    @dumper.base_url = "http://localhost"
    @controller = Controller.new
  end

  it "should dump env and not send notification" do
    url = @dumper.dump(@controller, StandardError.new("dump it"))
    url.should =~ /http:\/\/localhost\/[0-9]+/
    @dumper.from_email = "asd"
    url = @dumper.dump(@controller, StandardError.new("dump it"))
    url.should =~ /http:\/\/localhost\/[0-9]+/
    @dumper.from_email = nil
    @dumper.to_emails = "dsa"
    url = @dumper.dump(@controller, StandardError.new("dump it"))
    url.should =~ /http:\/\/localhost\/[0-9]+/
  end

  it "should clean up error dumps" do
    Error.create(:message => 'msg')
    Error.all.size.should > 0
    @dumper.keep_dumps = 0
    Error.all.size.should == 0
    @dumper.dump(@controller, StandardError.new("dump it"))
    Error.all.size.should == 1
    @dumper.dump(@controller, StandardError.new("dump it"))
    Error.all.size.should == 2
  end

  it "should send notifications" do
    @dumper.to_emails = "das"
    @dumper.from_email = "asd"
    @dumper.dump(@controller, StandardError.new("dump it"))
    Ixtlan::Errors::ActionMailer::Base.delivered.should be_true
  end
end
