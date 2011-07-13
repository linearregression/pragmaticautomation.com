require 'ftools'

class MockRootDirectory

  def initialize(root_dir="tmp")
    @root_dir = root_dir
    @files_to_create = {}
  end
  
  def add(name, contents = "")
    @files_to_create[name] = contents
  end
  
  def create_temporarily
    begin
      @files_to_create.each() do |filename, contents| 
        filename = @root_dir + "/" + filename
        dir = File.dirname(filename)
        File.makedirs(dir)
        file = File.new(filename, "w")
        file << contents
        file.close
      end
      yield @root_dir
    ensure
      delete_dirs(@root_dir)
    end
  end	
  
  private

  def delete_dirs(dir) 
    if (File.exist?(dir))
      Dir[dir + "/*"].each do |file|
        if (File.stat(file).directory?)
          delete_dirs(file)
        else
          File.delete(file)
        end
      end
      begin
        Dir.delete(dir)
      rescue 
        #puts "couldn't delete #{dir}"
        #print(dir)
        Kernel.sleep(0.05)
        delete_dirs(dir)
      end
    end
  end
  
  def print(dir, indent = "") 
    Dir[dir + "/*"].each do |file|
      if (File.stat(file).directory?)
        puts indent + "+ " + file
        print(file, indent + "   ")
      else
        puts indent + "- " + file
      end
    end
  end
end
