require 'tempfile'
require 'parsedate'

# = Introduction
#
# TaggedPublisher allows a blogger to control publication dates.
# Entries stored in CVS are ignored unless they have a version that's
# been tagged with a PUBLISHED tag.  If an entry has been so tagged,
# the timestamp will be that of the PUBLISHED version (although the
# most recent committed content will be used).  Thus, you can commit
# your drafts and they won't show up on the site ... and you can fix
# typos and make small changes after publication without changing the
# timestamp.  (As a courtesy to readers, it's best to avoid making
# substantial changes after a day or two have gone by.  Better to make
# a new entry in that case.) 
#
# = Usage
#
# Put these lines in your rublog.cgi:
#
#   require 'extras/TaggedPublisher'
#   publisher = TaggedPublisher.new("/tmp/mtime_cache")
#
# Then, in the Rublog initialization block:
#
#   set_mtime_getter publisher.mtime_getter
#
# When you're ready to publish an entry, do this:
# 
#   $ cvs commit -m "publication" new_entry.rdoc
#   $ cvs tag -cfF PUBLISHED new_entry.rdoc
#
# Author:: Glenn Vanderburg
# Version:: 1.0
# License:: Ruby license

class TaggedPublisher

  class MtimeCache < Hash
    attr_accessor :modified

    def initialize
      @modified = false
    end

    def store(key, value)
      @modified = true
      super
    end

    def []=(key, value)
      @modified = true
      super
    end
  end

  ##
  # Initialize an instance, storing the timestamp cache in +file+.
  # 
  # In some circumstances you may wish to display entries even if they 
  # don't contain a PUBLISHED tag.  The optional second parameter 
  # allows that.

  def initialize (file, display_untagged = false)
    @file = file
    @display_untagged = display_untagged
    @cache = nil

    begin
      # It's possible for this file to be read, then blog entry
      # modified, and then the cache file be written, so that the
      # entry appears to be older than the cache (when actually it's
      # younger than the information in the cache).  We subtract thirty
      # seconds from the cache mod time to protect against this.  If
      # we end up inspecting a modified entry more than once, so be
      # it.
      @timestamp = File.mtime(@file) - 30
      File.open(@file, "r") do |f| 
	@cache = Marshal.load(f)
      end
    rescue
      # cache file doesn't exist or we couldn't read it.  Start fresh,
      # last modified at the epoch.
      @timestamp = Time.at(0);
      @cache = MtimeCache.new;
    end

    at_exit {
      maybe_dump_cache
    }

  end

  def mtime_getter
    proc {|filename, stat|
      if filename =~ /,v$/
	get_mtime(filename, stat)
      else
	stat.mtime 
      end
    }
  end

  protected

  def get_mtime (filename, stat)
    mt = find_publication_time(filename, stat)

    return mt ? mt : handle_untagged(filename, stat)
  end

  def find_publication_time (filename, stat)
    if stat.mtime > @timestamp
      IO.popen("rlog '#{filename}'") { |f|
	version = find_publication_version(f)
	return nil unless version

	version_timestamp = find_version_timestamp(f, version)
	return nil unless version_timestamp

	@cache[filename] = version_timestamp
      }
    end

    return @cache[filename]
  end

  def handle_untagged (filename, stat)
    if @display_untagged
      return stat.mtime
    else
      throw :ignore
    end
  end

  def find_publication_version (f)
    while line = f.gets
      if line =~ /PUBLISHED: ([\d.]+)/
	return $1
      end
    end
    
    nil
  end

  def find_version_timestamp (f, version)
    while line = f.gets
      if line =~ /^revision #{version}[ \t]*$/
	dateline = f.gets
	dateline =~ /^date: ([^;]+);/
	# date format will be: 2004/02/29 12:57:42
	version_timestamp = Time.utc(*(ParseDate::parsedate($1)[0..-3]))
	version_timestamp.localtime
	return version_timestamp
      end
    end

    nil
  end

  def maybe_dump_cache
    if @cache.modified
      @cache.modified = false
      tmpfile = Tempfile.new("mtime_cache")
      tmppath = tmpfile.path
      tmpio = tmpfile.open
      Marshal.dump(@cache, tmpio)
      tmpio.close
      system("mv '#{tmppath}' '#{@file}'")
    end
  end
end
