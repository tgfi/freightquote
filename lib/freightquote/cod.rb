module FreightQuote #:nodoc:
  class Cod #:nodoc:
    # == Description
    # This cod object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    # 
    # == Example Usage
    #   cod = FreightQuote::Cod.new(
    #     :amount_to_collect => 1000.00, 
    #     :remit_to_name => 50, 
    #     :remit_to_address => 76, 
    #     :remit_to_city => 80, 
    #     :remit_to_state => 'IN'
    #   )
    #   
    #   cod.valid? # => true
    #

    include Validateable
    
    ## Attributes
    attr_accessor :amount_to_collect, :remit_to_name, :remit_to_address, :remit_to_city, :remit_to_state, :remit_to_zip_code
        
    def initialize(attributes)
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end
    
    def amount_to_collect?
      @amount_to_collect.to_f != 0.00
    end
    
    def remit_to_name?
      !@remit_to_name.blank?
    end
        
    def remit_to_address?
      !@remit_to_address.blank?
    end
    
    def remit_to_city?
      !@remit_to_city.blank?
    end
    
    def remit_to_state?
      !@remit_to_state.blank?
    end
    
    def remit_to_zip_code?
      !@remit_to_zip_code.blank?
    end
    
    def to_xml(xml)
      
      xml.tag!('cod') do 
        xml.tag!('amounttocollect', amount_to_collect)
        xml.tag!('remittoname', remit_to_name)
        xml.tag!('remittoaddress', remit_to_address)
        xml.tag!('remittocity', remit_to_city)
        xml.tag!('remittostate', remit_to_state)
        xml.tag!('remittozip', remit_to_zip_code)
      end
      
    end

    def validate
      
      errors.add :amount_to_collect, "is not a valid amount (> 0.00)" unless amount_to_collect? and amount_to_collect.is_a?(Float)
      
      errors.add :remit_to_name, "is required" unless remit_to_name?      
      errors.add :remit_to_address, "is required" unless remit_to_address?
      errors.add :remit_to_city, "is required" unless remit_to_city?
      errors.add :remit_to_state, "is required" unless remit_to_state?
      errors.add :remit_to_zip_code, "is required" unless remit_to_zip_code?

    end
    
  end  
 end