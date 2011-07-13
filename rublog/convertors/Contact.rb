# The RDoc converter reads files in RDoc format. The first line is
# a title, the rest is the body

require 'RDocMarkup'
require 'HyperLink'

class ContactConvertor < BaseConvertor

  handles_regexp %r{/Contacts/Full/}, %r{FredBloggs}

  KNOWN_FIELD = {
    "name" => 1,
    "address1" => 1, "address2" => 1, "city" => 1, "state" => 1,
    "zip" => 1, "country" => 1, "email" => 1, "title" => 1, "org" => 1
  }

  Field = Struct.new(:name, :value)


  def convert_html(file_name, file, all_entries)
    body = "<table cellspacing=2 cellpadding=0>"
    fields = {}
    other_fields = []

    while line = file.gets
      line.chomp!
      break unless line =~ /^(\w+):\s*(.*)/
      original_field = $1
      field = $1.downcase
      value = $2
      
      if KNOWN_FIELD[field]
        fields[field] = value
      else
        other_fields << Field.new(original_field, value)
      end
    end

    title = fields["name"] || unknown

    address = build_address(fields)
    body << row("Address", address) if address

    email = fields["email"]
    if email
      body << row("E-Mail", %{<a href="mailto:#{email}">#{email}</a>})
    end

    other_fields.each do |f|
      body << row(f.name, f.value)
    end


    body << "</table>"
    rest = (file.read || '').strip
    if rest.size > 0
      body << "<hr>" 
      body << convert_notes(file_name, rest, all_entries)
    end

    synopsis = nil

    HTMLEntry.new(title, body, synopsis, self)
  end

  def convert_plain(file_name, f, all_entries)
    f.read
  end


  private

  def build_address(fields)
    add = ""
    if fields["name"]
      if fields =~ /^\w+,/
        last, first = fields["name"].split(/,\s*/, 2)
        add << first << " " << last << "<br>"
      else
        add << fields["name"] << "<br>"
      end
    end

    title = ""
    if fields["title"]
      title = fields["title"]
    end
    if fields["org"]
      title << ", " if title.size > 0
      title << fields["org"]
    end
    add << title << "<br>" if title.size > 0

    if fields["address1"]
      add << fields["address1"] << "<br>"
    end
    if fields["address2"]
      add << fields["address2"] << "<br>"
    end

    last = ""
    if fields["city"]
      last << fields["city"]
    end

    if fields["state"]
      last << ", " if last.size > 0
      last << fields["state"] << " "
    end

    if fields["zip"]
      last << fields["zip"]
    end

    if last.size > 0
      add << last << "<br>"
    end

    if fields["country"]
      add << fields["country"]
    end
    add
  end

  def row(name, value)
    %{<tr valign="top"><td>#{name}: </td><td>&nbsp;</td><td>#{value}</td></tr>}
  end

  def convert_notes(file_name, notes, all_entries)
    res = ""
    entries = notes.split(/^(\d\d\d\d-\d\d-\d\d.*)/)
    until entries.empty?
      head = entries.shift.strip
      next if head == "Notes:"
      if head =~ /^(\d\d\d\d-\d\d-\d\d)\s+(.*?)<(.*?)>/
        res << "<h4>" << $1 
        res << %{: <a href="mailto:#$3">#$2</a></h4>\n}
      else
        res <<  bulletlist(file_name, head, all_entries)
      end
    end
    res
  end

  def bulletlist(file_name, entry, all_entries)
    markup = RDocMarkup.new
    h = HyperLinkHtml.new(file_name, all_entries)
    markup.convert(entry, h)
  end

end

