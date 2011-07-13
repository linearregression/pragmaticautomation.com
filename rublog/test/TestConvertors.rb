require 'BaseConvertor'
require 'test/RublogTestCase'
require 'convertors/RDoc'
require 'convertors/Html'
require 'convertors/Text'
require 'convertors/Usemod'


class FakeFile
  def initialize(contents)
    @contents = contents
  end
  
  def gets
    @contents.sub!(/(.*)\n?/, '')
    $1
  end
  
  def read
    @contents
  end
end

class TestConvertors < RublogTestCase
  def test_fake_file
    file = FakeFile.new("a\nbc")
    assert_equal("a", file.gets)
    assert_equal("bc", file.read)
  end
  
  def test_html
    assert_equal(HtmlConvertor, CONVERTORS["html"].class)
    assert_equal(HtmlConvertor, CONVERTORS["htm"].class)
  end
  
  def test_rdoc
    assert_equal(RDocConvertor, CONVERTORS["rdoc"].class)
  end
  
  def test_text
    assert_equal(PlainTextConvertor, CONVERTORS["text"].class)
    assert_equal(PlainTextConvertor, CONVERTORS["txt"].class)
  end
  
  def test_usemod
    assert_equal(UsemodConvertor, CONVERTORS["db"].class)
  end
  
  def test_convert_from_html
    html = "<html><title>mytitle</title><body>" +
           "<summary>mysynopsis</summary>mybody</body></html>"
    entry = convert_html(HtmlConvertor.new, html)
    assert_equal("mytitle", entry.title)
    assert_equal("mysynopsis", entry.synopsis)
    assert_equal(html, entry.body)
  end

  def test_convert_from html_without_stuff
    entry = convert_html(HtmlConvertor.new, "<html><body></body></html>")
    assert_equal("Untitled", entry.title)
    assert_equal("", entry.synopsis)
    assert_equal("<html><body></body></html>", entry.body)
  end
  
  def test_convert_from_rdoc
    html = "=mytitle\nsummary::mysynopsis\n\nmybody"
    entry = convert_html(RDocConvertor.new, html)
    assert_equal("mytitle", entry.title)
    assert_equal("mysynopsis\n\n", entry.synopsis) 
    assert_equal("mysynopsis\n\n<p>\nmybody\n</p>\n", entry.body)
  end
 
  def test_convert_from_rdoc_without_stuff
    entry = convert_html(RDocConvertor.new, "")
    assert_equal("", entry.title)
    assert_nil(entry.synopsis)
    assert_equal("", entry.body)
  end
  
  def test_convert_from_text
    entry = convert_html(PlainTextConvertor.new, "mytitle\nmybody")
    assert_equal("mytitle", entry.title)
    assert_equal("mybody", entry.body)
  end
  
  def convert_html(convertor, text)
    file = FakeFile.new(text)
    convertor.convert_html("a", file, nil)
  end
end
