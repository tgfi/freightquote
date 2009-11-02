module FreightQuote #:nodoc:    
  class Quote #:nodoc:
    # == Description
    # This quote object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    
    BILL_TO = ['SHIPPER','RECEIVER','SITE']
    
    include Validateable
    include Request
    # include Response
    
    #request attributes
    attr_accessor :email, :password, :test, :bill_to, :origin, :stops, :destination, :shipments, :service_blind, :service_packaged, :service_cod, :hazmat_contact, :hazmat_phone
    
    # response attributes
    attr_accessor :quote_id, :carriers
      
    def initialize(attributes)
      
      return if attributes.nil?
      
      attributes.delete(:quote_id)
      attributes.delete(:carriers)
      
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
      
      @carriers = []
      @errors = {}
      
      make_request()
      
    end
    
    def bill_to?
      !@bill_to.blank?
    end
    
    def success?
      @errors.length == 0
    end
    
    def errors
      @errors
    end
    
    def cheapest_carrier
      
      low_rate = nil
      low_index = nil
      
      @carriers.each_with_index do |carrier, index|
        unless carrier.rate.blank? then
          carrier_rate = carrier.rate.scan(/\d+\.?\d*/).flatten.to_s.to_f
        
          if low_rate.nil? or low_rate > carrier_rate then
            low_rate = carrier_rate
            low_index = index
          end
          
        end
      end
      
      low_index == nil if low_rate == 0.00
      @carriers[low_index] unless low_index.nil?
      
    end
    
    def to_xml
      xml = Builder::XmlMarkup.new(:indent => 2)
       
      # xml.instruct!(:xml, :version => '1.0', :encoding => 'utf-8')
      xml.tag!('freightquote', :request => 'quote', :email => email, :password=> password, :billto => bill_to) do

        origin.to_xml(xml)
        
        stops.each_with_index do |stop, index|
          stop.to_xml(xml, index)
        end
        
        destination.to_xml(xml)
        
        shipments.each_with_index do |shipment, index|
          shipment.to_xml(xml, index)
        end
        
        xml.tag!('service') do
          !service_cod.nil? and service_cod.is_a?(FreightQuote::Cod) ? service_cod.to_xml(xml) : Cod.new().to_xml(xml)
          xml.tag!('blind', service_blind)
          xml.tag!('packaged', service_packaged)
        end
        
        xml.tag!('hazmat') do
          xml.tag!('contact', hazmat_contact)
          xml.tag!('phone', hazmat_phone)
        end
  
      end
      
    end
    
    private
        
    def make_request  
      if valid? then  
        body = to_xml
        body.upcase!
        xml = ssl_post(FreightQuote::Base.api_url, body, "Content-Type" => "text/xml")
      else
        xml = nil
      end
      
      parse(xml)
      
    end
    
    def parse(xml)
      
      if xml.nil? then  
        @errors["000"] = "INVALID QUOTE. CHECK ERRORS."
        return
      elsif xml.blank? then        
        @errors["001"] = "EMPTY RESPONSE FROM SERVER"
        return
      end
      
      doc = Hpricot.XML(xml)
      
      doc.search("//FQERROR").each do |error|
        
        type = error.at("ERRORTYPE").innerHTML
        desc = error.at("ERRORDESC").innerHTML
        @errors[type] = desc
        
      end
      
      if @errors.length == 0 then
              
        @quote_id = doc.at('FQQUOTE').attributes['QUOTEID']
                
        doc.search("//FQQUOTE/CARRIER").each do |carrier|
                
          @carriers << Carrier.new(
            :option_id => carrier.attributes['OPTIONID'],
            :name => carrier.at('CARRIERNAME').innerHTML,
            :scac => carrier.at('SCAC').innerHTML,
            :rate => carrier.at('RATE').innerHTML,
            :freight_cost => carrier.at('FREIGHTCOST').innerHTML,
            :fuel_surcharge => carrier.at('FUEL_SURCHARGE').innerHTML,
            :transit => carrier.at('TRANSIT').innerHTML
          )
          
        end
        
      end
      
      # <FQQUOTE QUOTEID="4894702">
      #   <CARRIER OPTIONID="1">
      #     <CARRIERNAME>USFREIGHTW AYS - DUGAN</CARRIERNAME> 
      #     <SCAC>DUGN</SCAC> 
      #     <RATE>$74.43</RATE> 
      #     <DETAIL>
      #       <FREIGHTCOST>$72.13</FREIGHTCOST> 
      #       <FUEL_SURCHARGE>$2.30</FUEL_SURCHARGE>
      #     </DETAIL>
      #     <TRANSIT>2</TRANSIT> 
      #   </CARRIER>
      #   <CARRIER OPTIONID="2">
      #   <CARRIERNAME>CENTRAL TRANSPORT INTERNATIONAL</CARRIERNAME>
      #     <SCAC>CTII</SCAC>
      #     <RATE>$79.27</RATE> 
      #     <DETAIL>
      #       <FREIGHTCOST>$76.80</FREIGHTCOST> 
      #       <FUEL_SURCHARGE>$2.47</FUEL_SURCHARGE>
      #     </DETAIL>
      #     <TRANSIT>3</TRANSIT>
      #   </CARRIER>
      # </FQQUOTE>
    end
    def validate
      
      errors.add :bill_to, "is not valid" if bill_to? and not BILL_TO.include?(bill_to)
      errors.add :origin, "should be a FreightQuote::Origin object" unless origin.is_a?(FreightQuote::Origin)
      
      unless stops.nil?
        if stops.is_a?(Array) then
          stops.each_with_index do |stop, index|
                        
            if stop.is_a?(FreightQuote::Stop) then
              errors.add_to_base "Stop #{index} does not validate" unless stop.valid?
            else
              errors.add_to_base "Stop #{index} should be FreightQuote::Stop object"
            end

          end
        else
          errors.add :stops, "should be an array of FreightQuote::Stop objects."
        end
      end
      
      errors.add :destination, "should be a FreightQuote::Destination object" unless destination.is_a?(FreightQuote::Destination)
      
      if shipments.is_a?(Array) then
        errors.add :shipments, "should contain at least one FreightQuote::Shipment object" unless shipments.length > 0 
        shipments.each_with_index do |shipment, index|
          
          if shipment.is_a?(FreightQuote::Shipment) then
            errors.add_to_base "Shipment #{index} does not validate" unless shipment.valid?
          else
            errors.add_to_base "Shipment #{index} should be FreightQuote::Shipment object"
          end
          
        end
      else
        errors.add :shipments, "should be an array of FreightQuote::Shipment objects." 
      end
      
      errors.add :service_cod, "should be a FreightQuote::Cod object" unless service_cod.nil? or service_cod.is_a?(FreightQuote::Cod)
            
    end
    
   end 
end