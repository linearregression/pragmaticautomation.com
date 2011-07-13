# Used to write responses in different execution environments
# such as CGI and Webrick.
#
# If you want to create a new response object, you'll need to implement
# three methods:
#
# [add_header(key, value)]
#   add to the list of headers to be sent back to the client
#
# [write_headers()]
#   write the accumulated headers back to the client
#
# [<<(string)]
#   write the string to the client
#
# The Response object is instantiated with an output stream which
# must supply +<<+ and +puts+ methods.
#
# The class CGIResponse below is an example of a response object. 
# Also see rublog_servlet for an example of a Webrick response object


class CGIResponse
  def initialize(output_stream = $stdout)
    @headers = {}
    @output_stream = output_stream
  end

  def add_header(key, value)
    @headers[key] = value
  end

  def write_headers
    @headers.each do |key,value|
      @output_stream.puts "#{key}: #{value}\r\n"
    end
    @output_stream.puts
  end

  def <<(string)
    @output_stream << string
  end
end
