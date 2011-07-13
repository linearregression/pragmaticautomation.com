class MockResponse 
  def initialize
    @content = ""
  end
  
  def add_header(key, value)
  end
  
  def write_headers
  end
  
  def <<(some_string)
    @content << some_string
  end
  
  def to_s
    @content
  end
end
