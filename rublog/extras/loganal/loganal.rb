# Analyze an Apache access_log and work out
# what the blog usage is. We analyze stats for the last 24 hours

log_name = ARGV[0] || "/var/log/httpd/access_log"

blog_name_pattern = Regexp.new(ARGV[1] || " /pragdave")

LogLine = Struct.new(:remote, :remote_id, :remote_user,
		     :time, :request, :status, :bytes, :user_agent)

CUTOFF = Time.now - 24*60*60

class Integer
  def hours
    self*3600
  end
  def minutes
    self*60
  end
end
 
class LogLine
  def LogLine.parse(line)
    return nil unless line =~ /^(\S+)
                                  \s
                                (\S+)
                                  \s
				(\S+)
				  \s
				\[([^\]]+)\]
				  \s
				"([^"]+)"
				  \s
				(\d+)
				  \s
				(\d+|-)
				("\s([^"]+)")?/x
    entry = LogLine.new($1, $2, $3, $4, $5, $6, $7.to_i, $9)

    if entry.time =~ %r{^(\d\d)/(\w\w\w)/(\d\d\d\d):(\d\d):(\d\d):(\d\d) ([-+]\d\d\d\d)}

      d, m, y, hh, mm, ss = $1, $2, $3, $4, $5, $6

      entry.time = Time.local(y, m, d, hh, mm, ss)
      return entry
    end
    nil
  rescue
    nil
  end
end
    

class Stats
  
  def initialize
    @remote = Hash.new(0)
    @data_requests  = Hash.new(0)
    @rss_requests   = Hash.new(0)
    @data_size      = 0
    @earliest       = nil
  end

  def process_line(line)
    entry = LogLine.parse(line)
    return if entry.nil? || entry.time < CUTOFF

    @earliest ||= entry.time

    # Look for unique remote addresses
    @remote[entry.remote] += 1

    # is it an RSS request
    if entry.request =~ /\?rss|index\.rss/
      summer = @rss_requests
    else
      summer = @data_requests
    end

    summer[entry.status] += 1 

    # and sum the data
    @data_size += entry.bytes
  end

  def dump
    puts "Blog Traffic"
    puts "#{duration} to #{Time.now.strftime('%b %d %H:%M')}<br />"

    keys = (@rss_requests.keys | @data_requests.keys).sort

    totals = {}
    keys.each { |k| totals[k] = @rss_requests[k] + @data_requests[k] }

    puts '<table cellpadding="0" class="sidebartable" border="0" cellspacing="2">'
    
    puts "<tr><td></td><td class=\"ctitle\">" +
          keys.join("</td><td class=\"ctitle\">") + "</td></tr>"
    
    do_row(keys, "RSS", @rss_requests)
    do_row(keys, "Pages", @data_requests)
    do_row(keys, "TOTAL", totals, "ctotal")
 
    puts "</table>"
    
    if @data_size > 1_000_000
      size = sprintf("%.2fMb", @data_size/1000000.0)
    elsif @data_size > 10_000
      size = sprintf("%.2fkb", @data_size/1000.0)
    else
      size = sprintf("%.2f bytes", @data_size)
    end

    puts "Data: #{size}<br />"
    puts "Unique remote IPs: #{@remote.size}"

  end

  def duration
    if @earliest.nil?
      "No entries"
    else
      diff = Time.now - @earliest
      if diff > 3.hours
        "#{((diff + 30.minutes)/1.hours).to_i} hours"
      else
        "#{(diff/1.minutes).to_i} minutes"
      end
    end
  end
end

def do_row(keys, label, data, cls="c")
  print "<tr><td class=\"c\">#{label}</td>"
  keys.each do |k|
    print "<td align=\"right\" class=\"#{cls}\">#{data[k].to_s }</td>"
  end
  puts "</tr>"
end


stats = Stats.new

File.foreach(log_name) do |line|
  stats.process_line(line) if blog_name_pattern =~ line
end

stats.dump
