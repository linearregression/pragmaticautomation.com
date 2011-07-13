require 'FileEntry'
require 'Day'

######################################################################
# Manage the list of all files in and below the data
# dir. 

class FileEntries

  attr_reader :entries, :base_dir, :base_dir_name, :latest_mtime

  # Proc which returns the mtime we use for a file, given
  # the file name and a stat structure for that file
  DEFAULT_MTIME_GETTER = proc {|name,stat| stat.mtime}


  class EntryDir
    attr_reader :full_name, :relative_name, :entry_count

    def initialize(dir_name, strip_leading)
      @full_name     = dir_name
      @relative_name = dir_name[strip_leading, 999]
      @relative_name.slice!(0) if @relative_name[0] == ?/
      @subdirs       = []
      @entry_count   = 0
    end

    def inc_count
      @entry_count += 1
    end
    def add_subdir(dir)
      @subdirs << dir
    end
    def each_subdir
      @subdirs.each {|sd| yield sd}
    end
  end

  # construct a list of all the entries below a given
  # point. Only store those with an extension matching
  # one handled by a known convertor and with a last modified
  # min <= time <= max

  def initialize(data_dir, 
		 ignore_directory_pattern,
		 ignore_filename_pattern,
		 min,
		 max,
                 mtime_getter = DEFAULT_MTIME_GETTER)  

    @ignore_directory_pattern = ignore_directory_pattern
    @ignore_filename_pattern  = ignore_filename_pattern
    @entries = []
    @base_dir_name = File.expand_path(data_dir)
    @strip_leading = @base_dir_name.length
    @base_dir = EntryDir.new(@base_dir_name, @strip_leading)
    @min = min
    @max = max
    @mtime_getter = mtime_getter
    @latest_mtime  = Time.at(0)
    @days_with_entries = {}
    traverse(@base_dir)
#    $stderr.puts "Days = #{@days_with_entries.inspect}"
#    $stderr.puts caller
  end

  # return a list of all the entries below a given point, up to a
  # maximum depth

  def entries_below(dir, max_depth)
    base_depth = dir.count("/")
    @entries.find_all {|e| e.starts?(dir) && e.dir_depth <= base_depth + max_depth }
  end

  # Look for an index file in the given path

  def look_for_index_in(relative_path)
    if relative_path.empty?
      name = "Index"
    else
      name = File.join(relative_path, "Index")
    end

    res = @entries.find {|e| e.name_part == name}
    unless res
      if relative_path.empty?
        name = "index"
      else
        name = File.join(relative_path, "index")
      end
      res = @entries.find {|e| e.name_part == name}
    end
    if res
      [res]
    else
      []
    end
  end

  # Find an index file in the same directory as a given file
  def index_corresponding_to(name)
    path = File.dirname(name)
    path = '' if path == "."
    res = look_for_index_in(path)
    if res.empty?
      nil
    else
      res[0]
    end
  end

  # Find an entry in the source article's directory with the
  # given name

  def find_local_entry(source, target)
    target = File.join(File.dirname(source.name_part), target).sub(%r{^./}, '')
    find_any_entry_named(target)
  end

  # Find entries anywhere in the tree whose file name equals +target+

  def find_entries_with_root_name(name)
    @entries.find_all { |entry| entry.root_name == name }
  end

  # Find an entry with a given name
  def find_any_entry_named(name)
    @entries.each do |entry|
      return entry if entry.name_part == name
    end
    nil
  end

  # Return true if there's an entry for the given day
  def has_entry_on?(day)
    @days_with_entries[day]
  end

  # Return the day of an entry preceeding the given one
  def day_of_entry_preceding(day)
    res = nil
    sorted_dates.each do |d|
      break if d >= day
      res = d
    end
    res
  end

  # Return the first entry after a given day
  def day_of_entry_after(day)
    sorted_dates.each do |d|
      return d if d > day
    end
    nil
  end


  def each
    @entries.each {|e| yield e}
  end

  
  #######
  private
  #######

  def traverse(entry_dir)
    Dir.glob(File.join(entry_dir.full_name, "*")).each do |filename|
      filename.untaint
      next if filename =~ /~$/
      stat = File.stat(filename) rescue next
      if stat.directory?
        next if filename =~ /CVS$/
	next if @ignore_directory_pattern && @ignore_directory_pattern =~ filename
        subdir = EntryDir.new(filename, @strip_leading)
        entry_dir.add_subdir(subdir)
        traverse(subdir)
      else
	full_filename = filename.dup
        cvs_flag = filename.sub!(/,v$/, '')
        conv = BaseConvertor.for(filename)
        ignore = @ignore_filename_pattern && @ignore_filename_pattern =~ filename
        if conv && !ignore
	  catch (:ignore) do
	    time = @mtime_getter.call(full_filename, stat)
	    @latest_mtime = time if time > @latest_mtime
	    
	    if time >= @min && time <= @max 
	      @entries << FileEntry.new(filename, time, conv,
					self, @entries.size, cvs_flag)
	      entry_dir.inc_count
	    end
	    @days_with_entries[Day.new(time.mday, time.month, time.year)] = 1
	  end
        end
      end
    end
  end

  def sorted_dates
    @sorted_dates ||= @days_with_entries.keys.sort
  end

end


