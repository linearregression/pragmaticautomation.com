
# Handle special hyperlinking requirments for RDoc formatted
# entries. Requires RDoc

class HyperLinkHtml < SM::ToHtml

  # +all_entries+ is a reference to all the blog's entries in order to handle
  # hyperlinking

  def initialize(entry_name, all_entries)
    @all_entries = all_entries
    @entry_name  = entry_name
    super()
  end

  # We have a WikiWord, which we assume is a link to another entry in the 
  # same directory. If we don't find it there, optionally look for it
  # globally

  def handle_special_LOCALLINK(special)
    find_wiki_word(special.text, special.text)
  end

  # We have a WikiWord captured in the form [[word word...]].
  # We capitalize internal words, then treat it as a normal hyperlink

  def handle_special_WIKISENTENCE(special)
    phrase = special.text.
      sub(/^\[\[/, '').
      sub(/\]\]$/, '')

    wikiword = phrase.gsub(/\s+(\w)/) { $1.upcase }
    find_wiki_word(wikiword, phrase)
  end


  # We have a file path, which we assume is a link to another page in the blog
  def handle_special_ANYLINK(special)
    url = @all_entries.find_any_entry_named(special.text)
    cross_reference(special.text, url)
  end
  
  # We're invoked with a potential external hyperlink.
  # [mailto:]   just gets inserted.
  # [http:]     links are checked to see if they
  #             reference an image. If so, that image gets inserted
  #             using an <img> tag. Otherwise a conventional <a href>
  #             is used.
  
  def handle_special_HYPERLINK(special)
    url = special.text
    if url =~ /([A-Za-z]+):(.*)/
      type = $1
      path = $2
    else
      type = "http"
      path = url
      url  = "http://#{url}"
    end
    
    if type == "http" &&  url =~ /\.(gif|png|jpg|jpeg|bmp)$/
      if path[0] == ?~
        %{<img src="#{ $LOCAL_IMAGE_PATH }#{ path[1..-1] }">}
      else
        "<img src=\"#{url}\">"
      end
    else
      "<a href=\"#{url}\">#{url.sub(%r{^\w+:/*}, '')}</a>"
    end
  end

  # Here's a hypedlink where the label is different to the URL
  #  <label>[url]
  #
  
  def handle_special_TIDYLINK(special)
    text = special.text
    unless text =~ /\{(.*?)\}\[(.*?)\]/ or text =~ /(\S+)\[(.*?)\]/ 
      return text
    end
    label = $1
    url   = $2
    
    unless url =~ /\w+?:/
      url = "http://#{url}"
    end
    
    "<a href=\"#{url}\">#{label}</a>"
  end

  
  private


  def cross_reference(phrase, url)
    if url
      %{<a href="#{url.url}">#{phrase}</a>}
    else
      phrase
    end
  end

  # Find a wiki word. If we find an appropriate file in the same
  # directory as the original, stop looking. Otherwise,
  # find all files that match. If there's more than one,
  # generate a name link

  def find_wiki_word(word, original)

    url = @all_entries.find_local_entry(@entry_name, word)
    if url.nil?
      urls = @all_entries.find_entries_with_root_name(word)
      url = case urls.size
            when 0 then nil
            when 1 then urls[0]
            else
              # !!SMELL!!
              res = File.join(ENV['SCRIPT_NAME'], "=" + word)
              def res.url() self; end
              res
            end
    end
    cross_reference(original, url)
  end
        

end

