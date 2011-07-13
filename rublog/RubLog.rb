RUBLOG_VERSION = "1.0"

require 'find'
require 'cgi'

require 'Template'

require 'BaseConvertor.rb'
require 'Day'
require 'FileEntries'
require 'NotFoundEntry'
require 'Response'
require 'View'
require 'Request'
require 'ThisRubLogRequest'

######################################################################
#    M A I N    P R O G R A M
######################################################################

# This top-level RubLog object holds session-independent configuration.
# When a request comes along, its <tt>process_request</tt> method is
# called. This creates a per-request ThisRubLogRequest object
# that merges together the global parameters from here and the
# local parameters specified in the request

class RubLog

  # We use this to find stuff relative to our own source path
  RUBLOG_DIR = File.dirname(__FILE__)


  # Attributes which are options are defined this way
  def RubLog.option(name)
    attr_accessor name
    eval %{
      def set_#{name}(val)
	@#{name} = val
      end
    }
  end

  option :top_title
  option :max_entries_per_page
  option :rss_description
  option :rss_image_title
  option :rss_image_link
  option :rss_image_url
  option :rss_encoding
  option :info_url
  option :ignore_directory_pattern
  option :ignore_filename_pattern
  option :copyright
  option :external_stylesheet
  option :use_dynamic_urls
  option :extra_filter
  option :mtime_getter
  option :allow_synopsis
  option :dont_summarize_count
  option :print_style_name
  option :comment_email_address
  option :style
  option :always_synopsis_rss

  attr_reader   :data_dir

  # Load up a list of input convertors, looking for the files in the
  # convertors/ subdirectory relative to this file

  def self.load_convertors(*convertors)
    for conv in convertors
      path = File.join("convertors", conv)
      begin
        require path
      rescue LoadError
        puts "Content-type: text/html\r\n\r\n"
        puts "RubLog configuration error: cannot find convertor '#{conv}'"
        exit
      end
    end
  end
  
  def initialize(data_dir, &config)
    unless data_dir
      data_dir = File.join(RUBLOG_DIR, "doc")
    end
    @data_dir = File.expand_path(data_dir).chomp("/")

    # default options
    @max_entries_per_page = 5
    @dont_summarize_count = 1
    @style = "standard"

    @top_title = "RubLog"
    @rss_description = "RubLog"
    @mtime_getter = FileEntries::DEFAULT_MTIME_GETTER
    @print_style_name = "print"

    # Now pick up any options set using the block associated with the
    # constructor

    if config
      instance_eval(&config)
    end
  end

   
   def process_request(request, response)
     this_rublog_request = ThisRublogRequest.new(self, request)
     View.display(this_rublog_request, response)
   end
end
