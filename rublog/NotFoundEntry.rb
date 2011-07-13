require 'FileEntry'

class NotFoundEntry < FileEntry

  HTML_BODY = "The entry you requested could not be found."

  def initialize(all_entries)
    @all_entries = all_entries
  end

  def mtime
    Time.now
  end
  
  def file_name
    "Not found..."
  end

  def base_name
    file_name
  end

  def converter
    raise "Unset converter"
  end

  def convert
    HTMLEntry.new("Not found...",
                  HTML_BODY,
                  HTML_BODY,
                  self)
  end

  def as_plain_text
    TEXT_NOT_FOUND
  end

  def url
    "wibble_url"
  end
end
