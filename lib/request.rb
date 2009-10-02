# Request module Copyright (c) 2005-2007 Tobias Luetke via ActiveMerchant
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module FreightQuote #:nodoc:
    
  class ConnectionError < FreightQuoteError
  end
  
  class RetriableConnectionError < ConnectionError
  end
  
  module Request  #:nodoc:
    MAX_RETRIES = 3
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 20
    
    def self.included(base)
      base.superclass_delegating_accessor :ssl_strict
      base.ssl_strict = true
      
      base.class_inheritable_accessor :pem_password
      base.pem_password = false
      
      base.class_inheritable_accessor :retry_safe
      base.retry_safe = false

      base.superclass_delegating_accessor :open_timeout
      base.open_timeout = OPEN_TIMEOUT

      base.superclass_delegating_accessor :read_timeout
      base.read_timeout = READ_TIMEOUT
    end
    
    def ssl_get(url, headers={})
      ssl_request(:get, url, nil, headers)
    end
    
    def ssl_post(url, data, headers = {})
      ssl_request(:post, url, data, headers)
    end
    
    private
    
    def retry_exceptions
      retries = MAX_RETRIES
      begin
        yield
      rescue RetriableConnectionError => e
        retries -= 1
        retry unless retries.zero?
        raise ConnectionError, e.message
      rescue ConnectionError
        retries -= 1
        retry if retry_safe && !retries.zero?
        raise
      end
    end
    
    
    def ssl_request(method, url, data, headers = {})
      if method == :post
        # Ruby 1.8.4 doesn't automatically set this header
        headers['Content-Type'] ||= "application/x-www-form-urlencoded"
      end
      
      headers['User-Agent'] ||= "Mozilla/5.0 (Windows; U; Windows NT 6.0; en-us) AppleWebKit/531.9 (KHTML, like Gecko) Version/4.0.3 Safari/531.9"
      
      uri   = URI.parse(url)

      http = Net::HTTP.new(uri.host, uri.port)
      # http.set_debug_output $stderr if RAILS_ENV == "development"
      http.open_timeout = self.class.open_timeout
      http.read_timeout = self.class.read_timeout
            
      if uri.scheme == "https"
        http.use_ssl = true
        
        if ssl_strict
          http.verify_mode    = OpenSSL::SSL::VERIFY_PEER
          http.ca_file        = File.dirname(__FILE__) + '/certs/cacert.pem'
        else
          http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
        end
      
        if @options && !@options[:pem].blank?
          http.cert           = OpenSSL::X509::Certificate.new(@options[:pem])
        
          if pem_password
            raise ArgumentError, "The private key requires a password" if @options[:pem_password].blank?
            http.key            = OpenSSL::PKey::RSA.new(@options[:pem], @options[:pem_password])
          else
            http.key            = OpenSSL::PKey::RSA.new(@options[:pem])
          end
        end
      end

      retry_exceptions do 
        begin
          case method
          when :get
            http.get(uri.request_uri, headers).body
          when :post
            http.post(uri.request_uri, data, headers).body
          end
        rescue EOFError => e
          raise ConnectionError, "The remote server dropped the connection"
        rescue Errno::ECONNRESET => e
          raise ConnectionError, "The remote server reset the connection"
        rescue Errno::ECONNREFUSED => e
          raise RetriableConnectionError, "The remote server refused the connection"
        rescue Timeout::Error, Errno::ETIMEDOUT => e
          raise ConnectionError, "The connection to the remote server timed out"
        end
      end
    end
    
  end
end