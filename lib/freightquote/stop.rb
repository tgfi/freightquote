module FreightQuote #:nodoc:
  class Stop #:nodoc:
    # == Description
    # This stop object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    # 
    # == Example Usage
    #   stop = FreightQuote::Stop.new(
    #     :zip_code => '46202-1234'
    #   )
    #   
    #   stop.valid? # => true
    #

    include Validateable

    ## Attributes
    attr_accessor :zip_code
        
    def initialize(attributes)
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end
    
    def to_xml(xml, i)
      
      xml.tag!("stop#{i+1}") do 
        xml.tag!('zipcode', zip_code)
      end
      
    end
    
    def validate
      errors.add :zip_code, "cannot be empty" if zip_code.blank?
      errors.add :zip_code, "is not a 5 or 9 digit zip code" unless zip_code =~ /(^\d{5}$)|(^\d{5}-\d{4}$)/
    end
  end
 end