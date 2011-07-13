
######################################################################
# An HTML entry contains the title, the body, and a reference to
# the original convertor

HTMLEntry = Struct.new(:title, :body, :synopsis, :convertor)  



# Define input converters. Each one handles files of with a particular
# extension, converting its contents to HTML.

class BaseConvertor

  ConvDef = Struct.new(:regexp, :convertor)

  CONVERTORS = []

  def BaseConvertor.handles(*extensions)
    regexps = extensions.map {|e| Regexp.new("\.#{Regexp.quote(e)}$")}
    handles_regexp(*regexps)
  end

  def BaseConvertor.handles_regexp(*regexps)
    me = self.new
    regexps.each {|re| CONVERTORS << ConvDef.new(re, me) }
  end

  def BaseConvertor.for(filename)
    CONVERTORS.each do |conv|
      return conv.convertor if conv.regexp =~ filename
    end
    nil
  end
end
