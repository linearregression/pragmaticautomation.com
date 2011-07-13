# We hold the information needed to process a particular incoming request.
# We're invoked by RubLog#process_request when an incoming request is
# detected.
#
# As well as handling the request itself, our objects act as delegators for
# both the Request object and the RubLog object, so that other code can
# get parameters from a single source.

class ThisRublogRequest

  attr_reader   :page_size
  attr_reader   :all_entries
  attr_reader   :position

  attr_accessor :displayed_entries
  attr_accessor :start_index
  attr_accessor :warnings

  def initialize(rublog, request)
    @rublog  = rublog
    @request = request
    @page_size = @request.entries_per_page || @rublog.max_entries_per_page
    @warnings = []

    # Generate all the file entries
    @all_entries = FileEntries.new(@rublog.data_dir, 
                                   @rublog.ignore_directory_pattern,
                                   @rublog.ignore_filename_pattern,
                                   @request.min_time,
                                   @request.max_time,
                                   @rublog.mtime_getter)

    @request.handle(self)
  end

  # Is this page past the date requested by the client?
  # Typically this is used in RSS feeds where the client
  # sends an if-modified-since header, and we respond NOT MODIFIED
  # if the document date is <= the date in that header
  def page_is_past_requested_date
    @request.wants_page_dated(@all_entries.latest_mtime)
  end

  # Return the day of the latest entry before the
  # given day
  def day_of_entry_preceeding(day)
    @all_entries.day_of_entry_preceding(day)
  end

  # Return 
  def day_of_entry_after(day)
    @all_entries.day_of_entry_after(day)
  end

  def set_warnings(warnings)
    @warnings = warnings
  end

  # If we asked for articles with a specific name, return them.
  # Otherwise, we may have a directory name. Look for an entry called
  # '[iI]ndex in that directory. If found, display it, otherwise
  # return the list of articles at or below the requested path

  def find_appropriate_entries
    result = []
    name = @request.show_article_with_name
    if name
      result = @all_entries.find_entries_with_root_name(name)
    end

    if result.empty?
      result = @all_entries.look_for_index_in(@request.path)

      if result.empty?
        path = File.join(@rublog.data_dir, @request.path)
        result = @all_entries.entries_below(path, 999).sort
        if result.size > 1
          result = result.reject {|e| e.root_name == "Index"}
        end
      end
    end

    # Never summarize the first 'n' articles in the blog
    unless result.empty?
      count = @rublog.dont_summarize_count
      result.each do |e|
        break if count <= 0
        e.force_full_display
        count -= 1
      end
    end

    result
    #    if extra_filter
    #      $stderr.puts "Calling #{extra_filter}"
    #      result = call_filter(result)
    #    end
    #    result
  end

=begin
     # Call the user-defined filter on our result set, generating
     # a new result set
     def call_filter(original_list)
       path = File.join("filters", extra_filter)
       begin
         require path
         klass = eval(extra_filter)
         original_list = klass.filter(@request, original_list)
       rescue
         $stderr.puts $!
       end
       return original_list
     end
=end

   def process_default_display
     entries = find_appropriate_entries

     # Remove deleted CVS entries unless we explicitly asked for a CVS directory
     unless @request.path =~ /Attic/
       entries.delete_if {|e| e.base_name =~ /Attic/}
     end

     total_entries = entries.size
     displayed = @page_size
     @position = ""

     @start_index = 0

     # Skip to the 'start_from' one
     if @request.start_from
       entries.each_with_index do |e, i| 
         if e.base_name == @request.start_from
           @start_index = i
           break
         end
       end
     end

     if @start_index > 0
       displayed  = @start_index + @page_size
       @position = "#{@start_index+1} to "
     end

     displayed = total_entries if displayed > total_entries
     @position << "#{displayed} of #{total_entries} article#{total_entries == 1 ? '':'s'}"

     if entries.empty?
       entries = [ NotFoundEntry.new(@all_entries) ]
       @start_index = 0
     end
     @displayed_entries = entries
   end

   # Process the results of a search. we're given a list of
   # article names, and we simple queue 'em all up for display
   def process_search_results(results)
     @displayed_entries = []
     results.each do |result|
       entry = @all_entries.find_any_entry_named(result.name)
       @displayed_entries << entry if entry
     end
     if @displayed_entries.empty?
       results.each do |result|
         $stderr.puts "!!! Article #{result.name} deleted after search"
       end
       @warnings << "Article deleted"
       process_default_display
     else
       @start_index = 0
       @position = "Search results..."
     end
   end

   # Return true if there's a blog entry on the specified day
   def has_entry_on?(day)
     @all_entries.has_entry_on?(day)
   end

   # What style to use
   def style
     @request.style || @rublog.style
   end

   # Is this an rss request
   def is_rss_request
     @request.is_rss
   end

   # and is this a synopsis rss requesty
   def is_synopsis_rss
     @request.is_synopsis_rss
   end

   # Delegate configuration stuff to the global rublog object

   def top_title()        @rublog.top_title;        end
   def rss_image_title()  @rublog.rss_image_title;  end
   def rss_image_link()   @rublog.rss_image_link;   end
   def rss_image_url()    @rublog.rss_image_url;    end
   def rss_encoding()     @rublog.rss_encoding;     end
   def rss_description()  @rublog.rss_description;  end
   def url_of_script()    @request.url_of_script;   end
   def info_url()         @rublog.info_url;         end
   def copyright()        @rublog.copyright;        end
   def use_dynamic_urls() @rublog.use_dynamic_urls; end
   def print_style_name() @rublog.print_style_name; end
   def allow_synopsis()   @rublog.allow_synopsis;   end
   def max_time()         @request.max_time;        end
   def date_range_to_s()  @request.date_range_to_s; end
   def path()             @request.path;            end
   def always_synopsis_rss()   @rublog.always_synopsis_rss;   end
   def external_stylesheet()   @rublog.external_stylesheet;                       end
   def comment_email_address() @rublog.comment_email_address;                     end
   def rss_ref()               File.join(@request.my_url, "index.rss");           end
   def fulltext_rss_url()      File.join(@request.url_of_script, "index.rss");    end
   def synopsis_rss_url()      File.join(@request.url_of_script, "synopsis.rss"); end

   def make_url(relative)
     @request.make_url(relative)
   end

   def get_parameter(name)
     @request.get_parameter(name)
   end
 end
