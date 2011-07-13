# Given a repository containing our contact-style entries
# look for lines containing "Action: ..." and extract them for use in a sidebar

require 'date'

ROOT = ARGV[0] || "/home/CVSROOT/PP/Contacts/Full/"
URI  = ARGV[1] || "http://www.pragprog.com/cgi-bin/contacts.cgi"

class Action

  attr_reader :date, :text, :link

  def Action.from_text(text, link)
    if text =~ %r{\d\d\d\d[/-]\d\d[/-]\d\d}
      date = Date.parse($&)
    else
      date = Date.today
    end

    return Action.new(date, text, link)
  end

  def initialize(date, text, link)
    @date = date
    @text = text
    @link = link
  end

  def <=>(other)
    @date <=> other.date
  end
end


actions = []

Dir.glob(File.join(ROOT, "**/*"))  do |name|
  next if name =~ /~$/
  next if name =~ %r{/CVS/}
  next if File.directory?(name)
  
  if name =~ /,v$/
    stream = IO.popen("co -q -p #{name}")
  else
    stream = File.open(name)
  end

  content = stream.read
  stream.close

  content.scan(/Action:\s+(.*)/) do |action,|
    rel_name = name.sub(/,v$/, '').sub(/^#{ROOT}/, '')
    link = URI + rel_name
    actions << Action.from_text(action, link)
  end
end

puts "Pending Actions"
puts "<ul>"
if actions.empty?
  puts "None..."
else
  actions.sort {|a,b| b <=> a}.each do |action|
    puts %{<li><a href="#{action.link}">#{action.text}</a>}
  end
end

puts "</ul>"
