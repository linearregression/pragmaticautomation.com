# simple_markup moved when RDoc got rolled in to Ruby
begin
  begin
    require 'rdoc/markup/simple_markup'  # new location
    require 'rdoc/markup/simple_markup/to_html'
  rescue LoadError
    require 'markup/simple_markup'      # old location
    require 'markup/simple_markup/to_html'
  end
rescue LoadError
  puts "Content-type: text/html\r\n\r\n"
  puts <<-_EOT_
  RubLog needs to have RDoc installed if you're 
  using RDoc formatted input. You can get RDoc
  <a href="http://sourceforge.net/project/showfiles.php?group_id=42128">here</a>.
  <p>
  Alternatively, you can install the latest Ruby: as of December 1, 2003,
  Ruby now incorporates RDoc.
  _EOT_
  exit
end #' 

# Specialization of SimpleMarkup that supports the additional
# markup used by RubLog. We use apparent WikiWords as potential
# hyperlinks to files in the same directory, and apparenrt file
# paths as potential links to files in other directories

class RDocMarkup < SM::SimpleMarkup

  def initialize
    super
    # A wiki word is either CamelCase
    add_special(%r{\b([A-Z][a-z0-9]+[A-Z]\w+)}, :LOCALLINK)

    # Or an apparent filename
    add_special(%r{\b(\w+/[\w/]+\w+)}, :ANYLINK)

    # Or a sequence of words between doubled brackets
    add_special(/(\[\[\w[\-\s\w]+\w\]\])/, :WIKISENTENCE)

    # and links of the form  <text>[<url>] or {text with spaces}[<url>]
    add_special(/(((\{.*?\})|\b\S+?)\[\S+?\.\S+?\])/, :TIDYLINK)

    # and external references
    add_special(/((link:|http:|mailto:|ftp:|www\.)\S+\w\/?)/, :HYPERLINK)
  end

  def convert(text, handler)
    res = super
    res.sub!(/^<p>\n/, '')
    res.sub!(/<\/p>$/, '')
    res
  end

end
