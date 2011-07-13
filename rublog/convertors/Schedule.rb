
# The Schedule converor is not really generally useful: it's something I put
# together to help Andy and me plan a project.
#
# The input is a set of months. For each month you give the month name and 
# a list of topics and the associated activitie.
#
# June
# Coding: Base libraries
# Documentation: Requirements
# Food: Pizza
#
# July
# Coding: Base Libraries
# Documentation: Library API
# Food: Greek Salad
# QA: Build test system
#
# The filter converts this in to a horizontal table, and merges cells
# between months that have identical content

class ScheduleConvertor < BaseConvertor
  handles "sched"

  def convert_html(file_name, f, all_entries)
    title = CGI.escapeHTML(f.gets)
    body  = gen_schedule(f.read)
    HTMLEntry.new(title, body, '', self)
  end


  private

  def gen_schedule(text)
    text.sub!(/^\n+/, '')
    text.sub!(/\n\n\n+/, '\n\n')
    months = text.split(/\n\n/)
    month_names = []
    topics = {}
    all_topics = []
    months.each_with_index do |month, month_index|
      lines = month.split(/\n/)
      month_names << lines.shift
      lines.each do |line|
        topic, desc = line.split(/:/, 2)
        unless topics[topic]
          topics[topic] = []
          all_topics << topic
        end
        topics[topic][month_index] = desc
      end
    end

    # now generate the HTML

    res = "<table border=\"2\">\n"

    # Month names
    res << "<tr class=\"schedhead\"><th></th><th>" << month_names.join("</th><th>") << "</th></tr>\n"

    # and each row
    all_topics.each do |topic|
      res << "<tr><td class=\"schedhead\">#{topic}</td>"

      
      i = 0
      list = topics[topic]

      while i < months.size
        desc = list[i]
        i += 1
        span = 1
        while i < months.size && list[i] == desc
          i += 1
          span += 1
        end
        cls = desc ? "schedentry" : "schedempty"
        desc ||= '&nbsp;'
        if span == 1
          res << "<td class=\"#{cls}\">#{desc}</td>"
        else
          res << "<td colspan=\"#{span}\" class=\"#{cls}\">#{desc}</td>"
        end
      end

      res << "</tr>\n"
    end

    res << "</table>\n"
    res
  end
end


