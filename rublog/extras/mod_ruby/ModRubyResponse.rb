require 'Response'

# mod_ruby response handler by Bruce Williams
# bruce@codedbliss.com 

class ModRubyResponse < CGIResponse
  def write_headers
    r = Apache.request
    @headers.each do |key,value|  
      if key =~ /Content-type/i
        r.content_type = value
      else
        r.headers_out[key] = value
      end
    end    
    r.send_http_header
  end
end
