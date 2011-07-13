require 'cgi'
require 'Template'
require 'FileEntries'
require 'Request'
require 'rublog_template_common.rb'
require 'Response'
require 'BaseConvertor'

RSS_TEMPLATE = 
%{IF:rss_encoding
<?xml version="1.0" encoding="%rss_encoding%" ?>
ENDIF:rss_encoding
IFNOT:rss_encoding
<?xml version="1.0" ?>
ENDIF:rss_encoding
<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN"
                     "http://my.netscape.com/publish/formats/rss-0.91.dtd"> 
<rss version="0.91">
<channel>
  <title>%top_title%</title>
  <link>%toplevel_link%</link>
  <description>%toplevel_description%</description>
  <language>en-us</language>
IF:rss_image_url
  <image>
    <title>%rss_image_title%</title>
    <link>%rss_image_link%</link>
    <url>%rss_image_url%</url>
  </image>
ENDIF:rss_image_url
START:entries
  <item>
    <title>%title%</title>
    <link>%url%</link>
IFNOT:synopsis
    <description>%description%</description>
ENDIF:synopsis
IF:synopsis
    <description>%description% &lt;a href="%url%"&gt;[more]&lt;/a&gt;</description>
ENDIF:synopsis
  </item>
END:entries
</channel>
</rss>
}

######################################################################

class View
  attr_accessor :template
  
  def View.display(this_request, response=CGIResponse.new)
    style_list = [ this_request.style, "standard"]
    style_list.each do |style|
      begin
        require "styles/#{style}"
        display_with_template(this_request, PAGE_TEMPLATE, response)
        return
      rescue LoadError
      end
    end
    raise "Can't find standard style"
  end

  def View.display_with_template(this_request, template_text, response)
    viewer = if this_request.is_rss_request
       RssView.new(this_request, response)
     else 
       HtmlView.new(this_request, response, template_text)
     end
    
    viewer.render
  end

  def initialize(this_request, response, template)
    @template = template
    @response = response
    @this_request = this_request
  end

  # Extended Views should define render
  def render
    raise "Missing 'render' method in viewer"
  end

  def setup_initial_values
    @values = {
     'top_title'    => @this_request.top_title,
     'rss_image_title' => @this_request.rss_image_title,
     'rss_image_link'  => @this_request.rss_image_link,
     'rss_image_url'   => @this_request.rss_image_url,
     'rss_encoding'    => @this_request.rss_encoding,
     'rss_ref'      => @this_request.rss_ref,
     'position'     => @this_request.position,
     'home_page'    => @this_request.url_of_script,
     'fulltext_rss_url'      => @this_request.fulltext_rss_url,
     'synopsis_rss_url'      => @this_request.synopsis_rss_url,
     'date'         => Time.now.strftime("%d-%b-%y %H:%M"),
     'comment_email_address' => @this_request.comment_email_address,
    }

 
    info_url = @this_request.info_url
    if info_url 
      if info_url =~ %r{^/|^\w+:/}  # absolute path or url?
 	@values['info_url'] = info_url
      else
 	@values['info_url'] = File.join(@this_request.url_of_script, info_url)
      end
    end
    
    @values['copyright'] =
          @this_request.copyright if @this_request.copyright
    @values['external_stylesheet'] = 
          @this_request.external_stylesheet if @this_request.external_stylesheet

    # Allow a style to know if there are multiple entries on this page
    if (@this_request.displayed_entries.entries.length > 1)
      @values['multiple_entries'] = @this_request.displayed_entries.entries
    end
  end

   # and write out the data
   def write_template
   	template = Template.new(@template)
    template.write_html_on(@response, @values)
   end
end

######################################################################

class RssView < View

  def initialize(this_request, response)
    super(this_request, response, RSS_TEMPLATE)
  end


  def render
    mod = CGI::rfc1123_date(@this_request.all_entries.latest_mtime)

    if @this_request.page_is_past_requested_date
      @response.add_header("Last-modified", mod)
      @response.write_headers
      setup_initial_values
      add_content_to(@this_request.displayed_entries.entries, @this_request.start_index)
      write_template
    else
      @response.add_header("Status", CGI::HTTP_STATUS['NOT_MODIFIED'])
      @response.add_header("Last-modified", mod)
      @response.write_headers
    end
  end

  #######
  private
  #######

  def add_content_to(entries, start_index)
    entry_values = []
    @this_request.page_size.times do |i|
      e = entries[start_index+i]
      break unless e
      rss_entry = e.convert
      synopsis = false
      if @this_request.is_synopsis_rss || @this_request.always_synopsis_rss
        description =  rss_entry.synopsis 
        if description
          1 while description.chomp!
          synopsis = true
        else
          description = rss_entry.body
        end
      else
        description = rss_entry.body
      end
      
      entry_values << {
        'title'    => rss_entry.title.chomp,
        'url'      => @this_request.make_url(e.url),
        'description' => CGI.escapeHTML(description),
	'synopsis'    => synopsis,
      }
    end
    @values['entries'] = entry_values
    @values['toplevel_link'] = @this_request.url_of_script
    @values['toplevel_description'] = @this_request.rss_description
  end
end

######################################################################

class HtmlView < View

  def render
    mod = CGI::rfc1123_date(@this_request.all_entries.latest_mtime)
    if @this_request.page_is_past_requested_date
      @response.add_header("Content-type", "text/html")
      @response.add_header("Last-modified", mod)
      @response.write_headers
      setup_initial_values
      add_content_to(@this_request.displayed_entries.entries, @this_request.start_index)
      write_template
    else
      @response.add_header("Status", CGI::HTTP_STATUS['NOT_MODIFIED'])
      @response.add_header("Last-modified", mod)
      @response.write_headers
    end
  end

  def url(entry)
    if @this_request.use_dynamic_urls 
      ENV['SCRIPT_NAME'] + '/=' + entry.root_name 
    else 
      entry.url
    end
  end


  private

  def add_content_to(entries, start_index)
    entry_values = []
    @this_request.page_size.times do |i|
      e = entries[start_index+i]
      break unless e
      html_entry = e.convert

      fields = {
		'title'        => html_entry.title,
		'body'         => html_entry.body,
		'url'          => url(e),
		'full_url'     => full_url(e),
		'url_name'     => e.base_name,
		'print_url'    => print_url(e),
		'timeline_url' => timeline_url(e),
		'date'         => e.formatted_date,
		'time'         => e.formatted_time,
      }

#      show_synopsis_this_time = @this_request.allow_synopsis && entries.length > 1
      show_synopsis_this_time = @this_request.allow_synopsis && e.allow_synopsis
      if show_synopsis_this_time && html_entry.synopsis
      	fields['synopsis'] = html_entry.synopsis
      end

      index = e.index_page
      if index
        fields['index_url'] = url(index)
        fields['index_name'] = index.dir_name
      end
      if i.zero?
        fields['first_entry'] = true
      end
      entry_values << fields
    end

    @values['entries'] = entry_values
    if start_index > 0
      prev_start = [0, start_index - @this_request.page_size].max
      @values['prev']  = continuation_url(entries[prev_start])
    end
    @values['next']  = continuation_url(entries[start_index + @this_request.page_size])

    @values['sidebar'] = Sidebar.generate_all(@this_request)
  end

  # generate a request that is like the current one, but starting
  # at the given page
  def continuation_url(entry)
    return nil unless entry
    url = @this_request.url_of_script
    url << "/" unless (url[-1] == ?/ || @this_request.path[0] == ?/)
    url << @this_request.path
    url << "/" unless url[-1] == ?/
    url << "+" << entry.base_name
    url << "?count=#{@this_request.page_size}"
    url << "&#{@this_request.date_range_to_s}"
    url
  end

  # The timeline URL for an entry is simply _all_ entries, starting
  # from this one
  def timeline_url(entry)
    url = @this_request.url_of_script
    url << "/" unless url[-1] == ?/
    url << "+" << entry.base_name
  end

  # The URL for a printable version of an entry 
  def print_url(entry)
    File.join(entry.url, "style", @this_request.print_style_name)
  end

  # The full URL of this script
  def full_url(entry)
    @this_request.make_url(url(entry))
  end


end


