module FreightQuote #:nodoc:    
  class Carrier #:nodoc:
   
    attr_accessor :option_id, :name, :scac, :rate, :freight_cost, :fuel_surcharge, :transit
    
    def initialize(attributes)
      
      return if attributes.nil?
    
      attributes.stringify_keys!
    
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
      
    end
    
  end
end