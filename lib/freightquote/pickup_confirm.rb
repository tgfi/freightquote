module FreightQuote
        
  class PickupConfirm
        
    def initialize(attributes)
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end
  end
    
end