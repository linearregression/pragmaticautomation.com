require "Sidebar"
require "Day"
require 'time'


######################################################################

class Month

  DAYS_IN_MONTH = [ nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

  NAMES = %w{ January February March April May June July August
              September October November December }

  attr_reader :start_day

  def initialize(for_day)
    @for_day = for_day
    @start_day = CalDay.first_of_month(for_day)
    @num_days  = DAYS_IN_MONTH[@start_day.month]
    # No real need to worry about centuries... :)
    if @start_day.month == 2 && (@start_day.year % 4).zero?
      @num_days  += 1
    end
  end

  def start_dow
    @start_day.to_time.wday
  end

  def end_of_month
    @start_day + (@num_days - 1)
  end

  def each_day
    day = @start_day.dup
    today = CalDay.now
    (1..@num_days).each do
      day.css = "caltoday" if day == today
      yield day
      day = day.succ
    end
  end
end

######################################################################

# Add some display stuff to the standard day class
class CalDay < Day

  # set the CSS class for this day
  def css=(cls)
    @class = cls
  end

  # return ourselves as a table cell
  def as_td
    res = if @class
            %{<td style="text-align: center;" class="#@class">}
          else
	    %{<td style="text-align: center;">}
          end
    res << if @url
             %{<a href="#@url">#{@day.to_s}</a>}
           else
             @day.to_s
           end
    res << "</td>"
  end

end



######################################################################

class Weeks
  def initialize(dow)
    @rows = []
    @dow  = dow
    dummy_day = "<td></td>"
    def dummy_day.as_td() self; end
    @week = [ dummy_day ] * dow
  end
  
  def add(day)
    @week << day
    flush_week if @week.size == 7
  end

  def rows
    flush_week unless @week.empty?
    @rows
  end

  def flush_week
    @rows << @week
    @week = []
  end
end

######################################################################

class CalendarSidebar < Sidebar

  def initialize (cal = CAL) 
    super()
    @cal = cal
  end

  def generate(blog)
    for_date = CalDay.from_time(blog.max_time)
    generate_calendar(for_date, blog)
  end

  private

  CAL = %{
    <table cellspacing="0" width="100%" cellpadding="2">
    <tr>
      <td colspan="7" align="center">
IF:earlier
<a href="%earlier%">&laquo;</a>
ENDIF:earlier
%month%
IF:later
<a href="%later%">&raquo;</a>
ENDIF:later
</td>
    </tr>
    <tr class="sidebarsubhead">
      <td align="right">S</td>
      <td align="right">M</td>
      <td align="right">T</td>
      <td align="right">W</td>
      <td align="right">T</td>
      <td align="right">F</td>
      <td align="right">S</td>
    </tr>
START:weeks
%line%
END:weeks
    </table>
    }


  def generate_calendar(for_date, blog)
    @title = "Article Calendar"
    @body = gen_body(for_date, blog)
  end

  def format_month(for_date)
    "#{for_date.long_month_name}, #{for_date.year}"
  end

  def gen_body(for_date, blog)
    month = Month.new(for_date)
    weeks = Weeks.new(month.start_dow)

    month.each_day do |day|
      if blog.has_entry_on?(day)
        day.hyperlink(blog)
      end
      weeks.add(day)
    end

    values = {}
    rows = weeks.rows.map do |row|
      { 'line'=> ('<tr align="right">' << row.map {|d| d.as_td}.join << '</tr>') }
    end
    values['weeks'] = rows
    values['month'] = format_month(for_date)

    earlier = blog.day_of_entry_preceeding(month.start_day)
    if earlier
      values['earlier'] = earlier.hyperlink(blog, :whole_month)
    end

    later = blog.day_of_entry_after(month.end_of_month)
    if later
      values['later'] = later.hyperlink(blog, :whole_month)
    end

    template = Template.new(@cal)
    res = ""
    template.write_html_on(res, values)
    res
  end

end
