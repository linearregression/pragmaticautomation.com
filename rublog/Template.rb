# Cheap-n-cheerful HTML page template system. You create a 
# template containing:
#
# * variable names between percent signs (<tt>%fred%</tt>)
# * blocks of repeating stuff:
#
#     START:key
#       ... stuff
#     END:key
#
# You feed the code a hash. For simple variables, the values
# are resolved directly from the hash. For blocks, the hash entry
# corresponding to +key+ will be an array of hashes. The block will
# be generated once for each entry. Blocks can be nested arbitrarily
# deeply.
#
# The template may also contain
#
#   IF:key
#     ... stuff
#   ENDIF:key
#
# _stuff_ will only be included in the output if the corresponding
# key is set in the value hash.
#
# Usage:  Given a set of templates <tt>T1, T2,</tt> etc
#
#            values = { "name" => "Dave", state => "TX" }
#
#            t = Template.new(T1, T2, T3)
#            File.open(name, "w") {|f| t.write_html_on(f, values)}
#         or
#            res = ''
#            t.write_html_on(res, values)
#
#

require 'cgi'

class Template

  # Nasty hack to allow folks to insert tags if they really, really want to
  OPEN_TAG = "\001"
  CLOSE_TAG = "\002"

  BR = OPEN_TAG + "br" + CLOSE_TAG

  ##########
  # A HashStack holds a stack of key/value pairs (like a symbol
  # table). When asked to resolve a key, it first searches the top of
  # the stack, then the next level, and so on until it finds a match
  # (or runs out of entries)

  class HashStack
    def initialize
      @stack = []
    end

    def push(hash)
      @stack.push(hash)
    end

    def pop
      @stack.pop
    end

    # Find a scalar value, throwing an exception if not found. This
    # method is used when substituting the %xxx% constructs

    def find_scalar_raw(key)
      @stack.reverse_each do |level|
        if level.has_key?(key)
          val = level[key]
          return val unless val.kind_of? Array
        end
      end
      raise "Template error: can't find variable '#{key}'"
    end

    def find_scalar(key)
      find_scalar_raw(key) || ''
    end

    # Lookup any key in the stack of hashes

    def lookup(key)
      @stack.reverse_each do |level|
        return level[key] if level.has_key?(key)
      end
      nil
    end
  end

  #########
  # Simple class to read lines out of a string

  class LineReader
    # we're initialized with an array of lines
    def initialize(lines)
      @lines = lines
    end

    # read the next line 
    def read
      @lines.shift
    end

    # Return a list of lines up to the line that matches
    # a pattern. That last line is discarded.
    def read_up_to(pattern)
      res = []
      while line = read
        if pattern.match(line)
          return LineReader.new(res) 
        else
          res << line
        end
      end
      raise "Missing end tag in template: #{pattern.source}"
    end

    # Return a copy of ourselves that can be modified without
    # affecting us
    def dup
      LineReader.new(@lines.dup)
    end
  end



  # +templates+ is an array of strings containing the templates.
  # We start at the first, and substitute in subsequent ones
  # where the string <tt>!INCLUDE!</tt> occurs. For example,
  # we could have the overall page template containing
  #
  #   <html><body>
  #     <h1>Master</h1>
  #     !INCLUDE!
  #   </bost></html>
  #
  # and substitute subpages in to it by passing [master, sub_page].
  # This gives us a cheap way of framing pages

  def initialize(*templates)
    result = templates.shift.dup
    
    templates.each do |content|
      result.sub!(/!INCLUDE!/, content)
    end
    @lines = LineReader.new(result.split($/))
  end

  # Render the templates into HTML, storing the result on +op+ 
  # using the method <tt><<</tt>. The <tt>value_hash</tt> contains
  # key/value pairs used to drive the substitution (as described above)

  def write_html_on(op, value_hash)
    esc = proc { |str| CGI.escapeHTML(str) }
    op << write_common(value_hash, esc)
  end

  # Render templates as TeX
  def write_tex_on(op, value_hash)
    esc = proc do |str|
      str.
        gsub(/&lt;/, '<').
        gsub(/&gt;/, '>').
        gsub(/&amp;/) { '\\&' }.
        gsub(/([$&%\#{}_])/) { "\\#$1" }.
        gsub(/>/, '$>$').
        gsub(/</, '$<$')
    end
    str = ""
    
    str << write_common(value_hash, esc)
    $stderr.puts str.inspect
    op << str
  end

  # Render templates as plain text
  def write_plain_on(op, value_hash)
    esc = proc {|str| str}
    op << write_common(value_hash, esc)
  end


  def write_common(values, esc)
    @value_stack = HashStack.new
    substitute_into(@lines, values, esc).
      tr("\000", '\\').
      tr(OPEN_TAG, '<').
      tr(CLOSE_TAG, '>')
  end

  # Substitute a set of key/value pairs into the given template. 
  # Keys with scalar values have them substituted directly into
  # the page. Those with array values invoke <tt>substitute_array</tt>
  # (below), which examples a block of the template once for each 
  # row in the array.
  #
  # This routine also copes with the <tt>IF:</tt>_key_ directive,
  # removing chunks of the template if the corresponding key
  # does not appear in the hash, and the START: directive, which
  # loops its contents for each value in an array

  def substitute_into(lines, values, value_escaper)
    @value_stack.push(values)
    skip_to = nil
    result = []

    while line = lines.read

      case line

      when /^IF:(\w+)/
        val = @value_stack.lookup($1)
        lines.read_up_to(/^ENDIF:#$1/) unless val

      when /^IFNOTBLANK:(\w+)/
        val = @value_stack.lookup($1)
        lines.read_up_to(/^ENDIF:#$1/) if val.nil? || val.empty?

      when /^IFBLANK:(\w+)/
        val = @value_stack.lookup($1)
        lines.read_up_to(/^ENDIF:#$1/) if val && !val.empty?

      when /^IFNOT:(\w+)/
        lines.read_up_to(/^ENDIF:#$1/) if @value_stack.lookup($1)

      when /^ENDIF:/
        ;

      when /^START:(\w+)/
        tag = $1
        body = lines.read_up_to(/^END:#{tag}/)
        inner_values = @value_stack.lookup(tag)
        raise "unknown start tag: #{tag}" unless inner_values
        raise "not array: #{tag}"   unless inner_values.kind_of?(Array)
        inner_values.each do |vals|
          result << substitute_into(body.dup, vals, value_escaper)
        end
      else
        result << expand_line(line.dup, value_escaper)
      end
    end

    @value_stack.pop

    result.join("\n") << "\n"
  end

  # Given an individual line, we look for %xxx% constructs and 
  # HREF:ref:name: constructs, substituting for each.

  def expand_line(line, value_escaper)
    # Generate a cross reference if a reference is given,
    # otherwise just fill in the name part

    line.gsub!(/HREF:(\w+?):(\w+?):/) {
      ref = @value_stack.lookup($1)
      name = @value_stack.find_scalar($2)

      if ref and !ref.kind_of?(Array)
	"<a href=\"#{ref}\">#{name}</a>"
      else
	name
      end
    }

    # Substitute in values for %xxx% constructs.  If th sequuence
    # starts %-xxx%, then don't escape HTML. This is made complex
    # because the replacement string may contain characters that are
    # meaningful to the regexp (like \1)

    line = line.gsub(/%(-?)([a-zA-Z]\w*)%/) {
      val = @value_stack.find_scalar($2).to_s
      unless $1
        val = value_escaper.call(val)
      end
      val.tr('\\', "\000")
    }

    # Look for various controls (ddlb's etc)

    line = line.gsub(/%check:(\w+?)%/) { check($1) }

    line = line.gsub(/%date:(\w+?)%/)  { date($1) }

    line = line.gsub(/%popup:(\w+?):(\w+?)%/) { popup($1, $2) }

    line = line.gsub(/%ddlb:(\w+?):(\w+?)%/) { ddlb($1, $2) }

    line = line.gsub(/%vsortddlb:(\w+?):(\w+?)%/) { ddlb($1, $2, 1) }

    line = line.gsub(/%radio:(\w+?):(\w+?)%/) { radio($1, $2) }

    line = line.gsub(/%radioone:(\w+?):(\w+?)%/) { radio($1, $2, "") }

    line = line.gsub(/%input:(\w+?):(\d+?):(\d+?)%/) { input($1, $2, $3) }

    line = line.gsub(/%text:(\w+?):(\d+?):(\d+?)%/)  { text($1, $2, $3) }

    line = line.gsub(/%pwinput:(\w+?):(\d+?):(\d+?)%/) { input($1, $2, $3, "password") }

    line = line.gsub(/%pair(\d)?:([^:]+):(\w+?)%/) { pair($2, $3, $1) }

    line
  rescue Exception => e
    err =  Exception.new("Template error: #{e} in '#{line}'")
    err.set_backtrace(e.backtrace)
    raise err
  end

  def pair(label, name, colspan=nil)
    value = @value_stack.find_scalar(name).to_s
    value = case value
            when "true" then "Yes"
            when "false" then "No"
            else value
            end

    td = colspan ? "<td colspan=\"#{colspan}\">" : "<td>"
      
    Html.tag(label) + td + value + "</td>"
  end

  def popup(url, text)
    text = @value_stack.find_scalar(text).to_s
    url = @value_stack.find_scalar(url).to_s
    %{<a href="#{url}" target="Popup" class="methodtitle"
       onClick="popup('#{url}');return false;">#{text}</a>}
  end

  def input(name, wid, max, iptype="text")
    value = @value_stack.find_scalar(name).to_s
    "<input type=\"#{iptype}\"  name=\"#{name}\" " +
      "value=\"#{value}\" size=\"#{wid}\" maxsize=\"#{max}\">"
  end

  def text(name, wid, height)
    value = @value_stack.find_scalar(name).to_s
    "<textarea name=\"#{name}\" cols=\"#{wid}\" rows=\"#{height}\">\n" +
      CGI.escapeHTML(value) +
      "\n</textarea>"
  end


  # a date field has three input areas
  def date(name)
    input(name + "_m", 2, 2) + "&nbsp;/&nbsp;" +
      input(name + "_d", 2, 2) + "&nbsp;/&nbsp;" +
      input(name + "_y", 4, 4)
  end


  def check(name)
    value = @value_stack.find_scalar_raw(name)
    checked = value ? " checked" : ""
    "<input type=\"checkbox\"  name=\"#{name}\"#{checked}>"
  end

  def ddlb(value_name, options_name, sort_on=0)
    value = @value_stack.find_scalar(value_name).to_s
    options = @value_stack.lookup(options_name)

    unless options && options.kind_of?(Hash)
      raise "Missing options #{options_name} for ddlb #{value_name}"
    end

    res = "<select name=\"#{value_name}\">"

    sorted = options.to_a.sort do |a,b| 
      if a[0] == -1
        -1
      elsif b[0] == -1
        1
      else
        a[sort_on] <=> b[sort_on] 
      end
    end

    sorted.each do |key, val|
      selected = (key.to_s == value) ? " selected" : ""
      res << "<option value=\"#{key}\"#{selected}>#{val}</option>"
    end

    res << "</select>"
  end

  def radio(value_name, options_name, br="<br />")
    value = @value_stack.find_scalar(value_name).to_s
    options = @value_stack.lookup(options_name)

    
    unless options && options.kind_of?(Hash)
      raise "Missing options #{options_name} for radio #{value_name}"
    end

    res = ""

    options.keys.sort.each do |key|
      val = options[key]
      checked = (key.to_s == value) ? " checked" : ""
      res << %{<label>
               <input type="radio" name="#{value_name}" 
                      value="#{key}"#{checked}>#{val}</label>#{br}}
    end
    res
  end

end

