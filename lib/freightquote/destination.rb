module FreightQuote #:nodoc:
  class Destination #:nodoc:
    # == Description
    # This destination object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    # 
    # == Example Usage
    #   destination = FreightQuote::Destination.new(
    #     :loading_dock => false, 
    #     :residence => true, 
    #     :construction_site => false, 
    #     :inside => false, 
    #     :lift_gate => true,
    #     :zip_code => '95014'
    #   )
    #   
    #   destination.valid? # => true
    #

    include Validateable

    ## Attributes
    attr_accessor :loading_dock, :residence, :construction_site, :inside, :lift_gate, :zip_code
        
    def initialize(attributes)
      
      loading_dock = true
      residence = false
      construction_site = false
      inside = false
      lift_gate = false
      
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end
    
    def to_xml(xml)
      
      xml.tag!("destination") do 
        xml.tag!('zipcode', zip_code)
        xml.tag!('loadingdock', loading_dock)
        xml.tag!('residence', residence)
        xml.tag!('constructionsite', construction_site)
        xml.tag!('insidepickup', inside)
        xml.tag!('liftgatepickup', lift_gate)
      end
      
    end

    def validate
      errors.add :loading_dock, "is not a boolean (true/false) value" unless [true,false].include?(loading_dock)
      errors.add :residence, "is not a boolean (true/false) value" unless [true,false].include?(residence)
      errors.add :construction_site, "is not a boolean (true/false) value" unless [true,false].include?(construction_site)
      errors.add :inside, "is not a boolean (true/false) value" unless [true,false].include?(inside)
      errors.add :zip_code, "cannot be empty" if zip_code.blank?
      errors.add :zip_code, "is not a 5 or 9 digit zip code" unless zip_code =~ /(^\d{5}$)|(^\d{5}-\d{4}$)/
      errors.add :loading_dock, ", residence, construction_site, inside or lift_gate must be true" unless loading_dock == true or residence == true or construction == true or inside == true
    end
  end
 end