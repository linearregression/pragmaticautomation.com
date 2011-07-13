require "Sidebar"

# Generate a sidebar category listing. Invoke using
#
#  require 'sidebar/Content'
#  contents = OutlineSidebar.new(blog)
#

class OutlineSidebar < Sidebar
  def title
    "Categories"
  end

  def generate(blog)
    @body = add_dirs(blog.all_entries.base_dir, "")
  end

  #######
  private
  #######

  def add_dirs(dir, result)
    rel = dir.relative_name
    href = File.join(ENV['SCRIPT_NAME'], rel)
    if rel.empty?
      rel = "Top Level"
    else
      rel = File.basename(rel)
    end
    result << 
      "<a href=\"#{href}\">#{rel}</a>:&nbsp;" <<
      "<span class=\"catcount\">#{dir.entry_count}</span><br />\n"
    dir.each_subdir {|sd| add_sub_dirs(sd, result) }
    result
  end

  def add_sub_dirs(dir, result)
    result << "<div class=\"indent\">"
    add_dirs(dir, result)
    result << "</div>"
  end

end
