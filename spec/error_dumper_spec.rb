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
  def ago
    DateTime.now - self.to_i
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

describe Ixtlan::Errors::ErrorDumper do

  before :each do
    @dumper = Ixtlan::Errors::ErrorDumper.new
    @dumper.dump_dir = "target"
    @controller = Controller.new
  end

  it "should dump env and not send notification" do
    file = @dumper.dump(@controller, StandardError.new("dump it"))
    File.exists?(file).should be_true
    @dumper.email_from = "asd"
    file = @dumper.dump(@controller, StandardError.new("dump it"))
    File.exists?(file).should be_true
    @dumper.email_from = nil
    @dumper.email_to = "dsa"
    file = @dumper.dump(@controller, StandardError.new("dump it"))
    File.exists?(file).should be_true
  end

  it "should clean up error dumps" do
    @dumper.keep_dumps = 0
    @dumper.dump(@controller, StandardError.new("dump it"))
    Dir['target/error-*'].size.should == 1
    @dumper.dump(@controller, StandardError.new("dump it"))
    Dir['target/error-*'].size.should == 1
  end

  it "should send notifications" do
    @dumper.email_to = "das"
    @dumper.email_from = "asd"
    @dumper.dump(@controller, StandardError.new("dump it"))
    Ixtlan::Errors::ActionMailer::Base.delivered.should be_true
  end
end
