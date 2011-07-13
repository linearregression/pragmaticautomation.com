require 'Sidebar'

# This sidebar takes a directory as a parameter. Each file in
# that directory (for which we have a converter) is converted into
# a separate sidebar entry. This means that we have a slightly different
# interface
#
#
# require 'sidebar/MiniBlog'
#
# MiniBlogs.create_for("dir")

class MiniBlog < Sidebar

  def initialize(title, body)
    super()

    @title = title
    @body = body
  end
end


class MiniBlogs

  def MiniBlogs.create_for(dir)
    entries = FileEntries.new(dir, 
			      nil,        # ignore_directory_pattern
			      nil,        # ignore_filename_pattern
			      Time.at(0), # request.min_time
			      Time.now)   # request.max_time

    entries.entries.sort {|a,b| a.file_name <=> b.file_name}.each do |entry|
      html_entry = entry.convert
      MiniBlog.new(html_entry.title, html_entry.body)
    end
  end

end
