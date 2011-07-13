require 'test/RublogTestCase'
require 'Template'

class TestTemplate < RublogTestCase

  def get_html_as_array(input_string, value_hash)
    array = []
    template = Template.new(input_string)
    template.write_html_on(array, value_hash)
  end
  
  def test_smoke
    template = Template.new("Hello")
  end
  
  def test_simple_var
    result = get_html_as_array("%me%", {"me"=>"Hello World"})
    assert_equal("Hello World\n", result[0])
  end

  
  def test_if
    text = "IF:mykey\nHello World\nENDIF:mykey\n"
    result = get_html_as_array(text, {})
    assert_equal("\n", result[0])

    result = get_html_as_array(text, {"mykey" => ""})
    assert_equal("Hello World\n", result[0])
  end

  
  def test_complex
    text = "IF:mykey\n%me%\nENDIF:mykey\n"
    result = get_html_as_array(text, {"mykey"=>"","me"=>"Hello"})
    assert_equal("Hello\n", result[0])
  end
  
  def test_start
    text = "START:people\nHello %person%\nEND:people\n"
    hasharray = [{"person"=>"Jeremy"}, {"person"=>"Bob"}]
    result = get_html_as_array(text, {"people"=>hasharray})
    assert_equal("Hello Jeremy\n\nHello Bob\n\n", result[0])
  end
end
