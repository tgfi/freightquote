# require 'validateable'
# 
# Dir[File.dirname(__FILE__) + '/freightquote/*.rb'].each{|g| require g}

module FreightQuote #:nodoc:
    
  # Raised when unknown attributes are supplied via mass assignment.
  class UnknownAttributeError < NoMethodError
  end
    
  class Base
    
    API_URL = 'https://b2b.Freightquote.com/dll/FQXMLQuoter.asp'
   
    attr_accessor :email, :password, :test
    # Before you can use the FreightQuote web services you need to provide 2 credentials:
    #
    # 1. Your freightquote email
    # 2. Your freightquote password
    #
    # These are the same used to login to your web account.
    # If you set it to test, we automatically change the logins to the test account.
    
    def initialize(attributes)
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
      
      @test = false unless test?
      
      if test?
        @email = "xmltest@freightquote.com"
        @password = "xml"
      end
      
    end
    
    def test?
      @test == true
    end
    
    def self.api_url
      API_URL
    end

    def quote(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @quote ||= Quote.new(attributes)
    end

    def pickup(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @pickup ||= Pickup.new(attributes)        
    end
    
    def pickup_confirm(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @pickup_confirm ||= PickupConfirm.new(attributes)
    end
    
    def track(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @track ||= Track.new(attributes)        
    end
    
    def view_xml_pickup(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @view_xml_pickup ||= ViewXmlPickup.new(attributes)
    end
    
    def view_xml_quote(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @view_xml_quote ||= ViewXmlQuote.new(attributes)
    end
    
    def terminal_info(attributes)
      attributes.merge!({ :email => @email, :password => @password, :test => @test})
      @terminal_info ||= TerminalInfo.new(attributes)
    end
  end
end