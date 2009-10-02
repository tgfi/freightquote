begin
  require 'active_support'
rescue LoadError
  activesupport_path = "#{File.dirname(__FILE__)}/../../activesupport/lib"
  if File.directory?(activesupport_path)
    $:.unshift activesupport_path
    require 'active_support'
  end
end

require 'net/http'
require 'net/https'

require 'error'
require 'request'
require 'validateable'

module FreightQuote
  
  def self.load_all!
    [Base]
  end
  
  autoload :Base, 'freightquote/base'
  autoload :Carrier, 'freightquote/carrier'
  autoload :Cod, 'freightquote/cod'
  autoload :Destination, 'freightquote/destination'
  autoload :Origin, 'freightquote/origin'
  autoload :Pickup, 'freightquote/pickup'
  autoload :PickupConfirm, 'freightquote/pickup_confirm'
  autoload :Quote, 'freightquote/quote'
  autoload :Shipment, 'freightquote/shipment'
  autoload :Stop, 'freightquote/stop'
  
end