module FreightQuote #:nodoc:
  class Shipment #:nodoc:
    # == Description
    # This shipment object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    # 
    # == Example Usage
    #   shipment = FreightQuote::Shipment.new(
    #     :weight => 2000, 
    #     :weight_class => 50, 
    #     :length => 76, 
    #     :width => 80, 
    #     :height => 48,
    #     :nmfc => ,
    #     :product_description => 'hardwood flooring',
    #     :hazardous => false,
    #     :package_type => "PALLETS",
    #     :pieces => 1,
    #     :stackable => false
    #   )
    #   
    #   shipment.valid? # => true
    #

    include Validateable
    
    PACKAGE_TYPES = ["PALLETS","BAGS","BALES","BOXES","BUNCHES","CARPETS","COILS","CRATES","CYLINDERS","DRUMS","PAILS","REELS","ROLLS","TUBING/PIPE","MOTORCYCLE","ATV"]
    WEIGHT_CLASSES = [50,55,60,65,70,77.5,85,92.5,100,110,125,150,175,200,250,300,400,500]
    ## Attributes
    attr_accessor :weight, :weight_class, :length, :width, :height, :nmfc, :product_description, :hazardous, :package_type, :pieces, :stackable
        
    def initialize(attributes)
      
      package_type = "PALLETS"
      hazardous = false
      stackable = false
    
      return if attributes.nil?
      
      # attributes = new_attributes.dup
      attributes.stringify_keys!
      
      attributes.each do |k, v|
        respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(UnknownAttributeError, "unknown attribute: #{k}")
      end
    end
    
    def width?
      @width.to_i != 0
    end
    
    def height?
      @height.to_i != 0
    end
    
    def length?
      @length.to_i != 0
    end
    
    def weight?
      @weight.to_i != 0
    end
    
    def product_description?
      !@product_description.blank?
    end
    
    def package_type?
      !@package_type.blank?
    end
    
    def weight_class?
      !@weight_class.blank?
    end
    
    def pieces?
      @pieces.to_i != 0
    end
    
    def to_xml(xml, i)
      
      xml.tag!("shipment#{i+1 unless i == 0}") do 
        xml.tag!('weight', weight)
        xml.tag!('class', weight_class)
        xml.tag!('dimensions') do
          xml.tag!('length', length)
          xml.tag!('width', width)
          xml.tag!('height', height)
        end
        xml.tag!('nmfc', nmfc)
        xml.tag!('productdesc', product_description)
        xml.tag!('hzmt', hazardous)
        xml.tag!('packagetype', package_type)
        xml.tag!('pieces', pieces)
        xml.tag!('stackable', stackable)
      end
      
    end

    def validate
      
      errors.add :package_type, "is required" unless package_type?
      errors.add :package_type, "is not valid" if package_type? and not PACKAGE_TYPES.include?(package_type)
      
      errors.add :weight_class, "is required" unless weight_class?
      errors.add :weight_class, "is not valid" if weight_class? and not WEIGHT_CLASSES.include?(weight_class)
      
      errors.add :weight, "is required" unless weight?      
      errors.add :weight, "cannot be over 2000 lbs" if weight > 2000
        
      errors.add :length, "is required by package type #{package_type}" if ["MOTORCYCLE","ATV"].include?(package_type) and not length?
      errors.add :width,  "is required by package type #{package_type}" if ["MOTORCYCLE","ATV"].include?(package_type) and not width?
      errors.add :height, "is required by package type #{package_type}" if ["MOTORCYCLE","ATV"].include?(package_type) and not height?
      
      #If PALLET is not selected and the total weight of the shipment is greater than 1,200 lbs, dimensions are required.
      errors.add :length, "is required by package type #{package_type} over 1,200 lbs" if package_type != "PALLET" and weight? and weight > 1200 and not length?
      errors.add :width,  "is required by package type #{package_type} over 1,200 lbs" if package_type != "PALLET" and weight? and weight > 1200 and not width?
      errors.add :height, "is required by package type #{package_type} over 1,200 lbs" if package_type != "PALLET" and weight? and weight > 1200 and not height?
     
      errors.add :product_description, "is required" unless product_description?
      
      errors.add :hazardous, "is not a boolean (true/false) value" unless [true,false].include?(hazardous)
      errors.add :pieces, "are required" unless pieces? and pieces >= 1
      errors.add :stackable, "is not a boolean (true/false) value" unless [true,false].include?(stackable)

    end
    
    private
      
      def before_validation #:nodoc:
        self.weight = weight.to_i
        self.package_type.upcase! if package_type.respond_to?(:upcase)        
      end
  end
 end