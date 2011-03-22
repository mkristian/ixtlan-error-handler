require 'ixtlan/errors/error_handler'
#require 'date'
require 'logger'

class Controller
  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def respond_to(&block)
    block.call self
  end

  def html(&block)
    block.call self
  end

  def xml(&block)
    block.call self
  end
  
  def json(&block)
    block.call self
  end

  def stati
    @stati ||= []
  end

  def head(status)
    stati << status
  end

  def render(options = nil)
    @render = options if options
    @render
  end
end

class Rails
  def self.configuration
    self
  end

  def self.error_dumper
    self
  end
  
  def self.dump(controller, exception)
    @dumped = exception
  end

  def self.dumped
    r = @dumped
    @dumped = nil
    r
  end
end

describe Ixtlan::Errors::ErrorHandler do

  before :each do
    @controller = Controller.new
    Controller.send :include, Ixtlan::Errors::ErrorHandler
  end

  describe "without session" do
    
    it "should handle internal server error" do
      exp = StandardError.new("internal")
      @controller.send :internal_server_error, exp
      Rails.dumped.should == exp
      @controller.render.should_not be_nil
      @controller.render[:status].should == :internal_server_error
      @controller.render[:template].should == "errors/error"
      @controller.stati.should == [:internal_server_error, :internal_server_error]
    end

    it "should handle not found" do
      exp = StandardError.new("not found")
      @controller.send :page_not_found, exp
      Rails.dumped.should be_nil
      @controller.render.should_not be_nil
      @controller.render[:status].should == :not_found
      @controller.render[:template].should == "errors/error"
      @controller.stati.should == [:not_found, :not_found]
    end

    it "should handle stale resource" do
      exp = StandardError.new("stale")
      @controller.send :stale_resource, exp
      Rails.dumped.should be_nil
      @controller.render.should_not be_nil
      @controller.render[:status].should == :conflict
      @controller.render[:template].should == "errors/error"
      @controller.stati.should == [:conflict, :conflict]
    end
  end

  describe "with session" do
    
    before :each do
      def @controller.current_user
        Object.new
      end
    end
    
    it "should handle internal server error" do
      exp = StandardError.new("internal")
      @controller.send :internal_server_error, exp
      Rails.dumped.should == exp
      @controller.render.should_not be_nil
      @controller.render[:status].should == :internal_server_error
      @controller.render[:template].should == "errors/error_with_session"
      @controller.stati.should == [:internal_server_error, :internal_server_error]
    end

    it "should handle not found" do
      exp = StandardError.new("not found")
      @controller.send :page_not_found, exp
      Rails.dumped.should be_nil
      @controller.render.should_not be_nil
      @controller.render[:status].should == :not_found
      @controller.render[:template].should == "errors/error_with_session"
      @controller.stati.should == [:not_found, :not_found]
    end

    it "should handle stale resource" do
      exp = StandardError.new("stale")
      @controller.send :stale_resource, exp
      Rails.dumped.should be_nil
      @controller.render.should_not be_nil
      @controller.render[:status].should == :conflict
      @controller.render[:template].should == "errors/error_with_session"
      @controller.stati.should == [:conflict, :conflict]
    end
  end
end
