######################################################################
# Sidebars - defined as subclasses of Sidebar, and rendered in
# the order they are added 
# they're defined
#
# See sidebar/*.rb for examples of sidebars

class Sidebar
  @@sidebars = []

  def Sidebar.add(sidebar)
    @@sidebars << sidebar
  end

  def Sidebar.sidebars
    @@sidebars
  end


  # Hash mapping handler names to objects
  @@handlers = {}

  def handles(name)
    @@handlers[name] = self
  end

  def Sidebar.find_handler(name)
    @@handlers[name]
  end

  # generate each of the sidebars, returning an array of title,body hashes,
  # or nil if there are no sidebars

  def Sidebar.generate_all(blog)
    return nil if @@sidebars.empty?
    @@sidebars.map do |sb|
      sb.generate(blog)
      {
        'title' => sb.title,
        'body'  => sb.body
      }
    end
  end

  def initialize
    Sidebar.add(self)
    begin
      handles(self.class.const_get(:HANDLES))
    rescue NameError
      ;
    end
  end

  # Sidebars must implement +generate+ to create their content..
  def generate(blog)
  end

  # and +title+ and +body+ to return it
  attr_reader :title, :body

end
