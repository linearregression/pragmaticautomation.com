require 'test/RublogTestCase'
require 'Request'

class MockRequest < WebRequest
  def initialize(environment = {})
    @environment = {
      "HTTP_REFERER"=>"http://localhost/cgi-bin/rublog/intellij", 
                    "SERVER_NAME"=>"localhost", 
                    "SERVER_ADDR"=>"127.0.0.1", 
                    "SERVER_PORT"=>"80", 
                    "REQUEST_URI"=>"/cgi-bin/rublog/intellij/KnownIssues.txt", 
                    "SCRIPT_NAME"=>"/cgi-bin/rublog/", 
                    "PATH_INFO"=>"/intellij/KnownIssues.txt"
    }
    
    @environment.update(environment)
    
    @parameters = {}
    super()
  end
end
