# Represent a single day. We could use Data, but it's fairly heavyweight
# and we'd need to add extra stuff anyway

class Day
  include Comparable

  attr_reader :day, :month, :year

  def initialize(day, month, year)
    @day = day
    @month = month
    @year  = year
  end

  def Day.from_time(time)
    new(time.mday, time.month, time.year)
  end

  def Day.now
    from_time(Time.now)
  end
             
  # Return the day at the start of the month containing day
  def Day.first_of_month(containing_day)
    new(1, containing_day.month, containing_day.year)
  end

  def long_month_name
    Month::NAMES[@month - 1]
  end

  def succ
    self + 1
  end

  # Only works within a month
  def +(num)
    self.class.new(@day + num, @month, @year)
  end

  def ==(other)
    @day == other.day && @month == other.month && @year == other.year
  end

  def <=>(other)
    cmp =  @year - other.year
    return cmp unless cmp.zero?
    cmp =  @month - other.month
    return cmp unless cmp.zero?
    @day - other.day
  end

  def to_time
    Time.local(@year, @month, @day)
  end

  def inspect
    "Day: #@year/#@month/#@day"
  end

  # Create a hyperlink back to the blog for our date
  def hyperlink(blog, whole_month=false)
    @url = File.join(blog.url_of_script,
                     @year.to_s, @month.to_s)
    unless whole_month
      @url = File.join(@url, @day.to_s)
    end
    @url
  end

  # Stuff for hashing
  def hash
    @day.hash * 3 + @month.hash * 7 + @year.hash
  end

  def eql?(other)
    other.kind_of?(Day) && self == other
  end

end

