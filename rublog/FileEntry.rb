######################################################################
# Represent a particular file entry, and arrange for them
# to be reverse sorted on modification time



class FileEntry

  attr_accessor :file_name, :mtime, :converter, :all_entries, :index, :cvsfile

  attr_reader   :allow_synopsis

  def initialize(file_name, mtime, converter, all_entries, index, cvsfile)
    @file_name = file_name
    @mtime = mtime
    @converter = converter
    @all_entries = all_entries
    @index = index
    @cvsfile = cvsfile
    @allow_synopsis = true
  end

  def force_full_display
    @allow_synopsis = false
  end

  def <=>(other)
    other.mtime <=> mtime
  end
  
  def starts?(string)
    file_name >= string && file_name[0, string.length] == string
  end

  def dir_depth
    file_name.count("/")
  end

  def formatted_date
    mtime.strftime("%d %b %y")
  end

  def formatted_time
    mtime.strftime("%H:%M")
  end

  def convert
    open_file {|f| converter.convert_html(self, f, all_entries) }
  end

  def as_plain_text
    open_file {|f| converter.convert_plain(self, f, all_entries) }
  end

  def open_file
    f = if cvsfile
	  IO.popen("co -q -p '#{file_name}'")
	else
	  File.open(file_name)
	end
    result = yield f
    f.close
    return result
  end

  def base_name
    @base_name ||= file_name[all_entries.base_dir_name.length+1, 999]
  end

  def name_part
    @name_part ||= (base_name.sub(/\.[^.]+$/, ''))
  end

  # Given a file name of a/b/c/d/e.rdoc, return 'e'
  def root_name
    @root_name ||= File.basename(name_part)
  end

  # Given a file name of a/b/c/d/e.rdoc, return 'd'
  def dir_name
    @dir_name ||= File.basename(File.dirname(base_name))
  end


  # Does this entry have an index page?
  def index_page
    res = all_entries.index_corresponding_to(base_name)
  end

  # **MOVEME**
  def url
    @url ||= File.join(ENV['SCRIPT_NAME'], base_name) 
  end

end
