require 'HyperLink'

# Present the content of a usemod wiki via RubLog
# Pass the Wiki's data directory to the RubLog constructor

class UsemodConvertor < BaseConvertor
  handles "db"

  def convert_html(file_entry, f, all_entries)

    title = file_entry.name_part.split("/").pop
    body = find_body(f)
    h = HyperLinkHtml.new(file_entry, all_entries)
    markup = RDocMarkup.new
    body  = markup.convert(body, h)
    HTMLEntry.new(title, body, '', self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end
    
  def find_body(f)
    body_found = false
    f.read.split(/\263[0-9]/).each do |element|
      if body_found == true then
	# convert common stuff in the wiki into RDoc format
	element.gsub!(%r{<h(\d)>(.+?)</h\1>}) { "\n#{'='*$1.to_i} #$2\n" }
	element.gsub!(%r{<pre>(.+?)</pre>}m) { pre = "  " + $1; pre.gsub("\n", "  \n") }
	return element
      end
      if element == "text" then
        body_found = true
      end
    end
  end
end
