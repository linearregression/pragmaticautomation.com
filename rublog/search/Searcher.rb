require 'search/Dictionary'
require 'search/Vector'

require "RubLog"

require "convertors/RDoc"
require "convertors/Text"
require "convertors/Html"

SearchResult = Struct.new(:name, :score)

class SearchResults
  attr_reader :warnings
  attr_reader :results

  def initialize
    @warnings = []
    @results  = []
  end

  def add_warning(txt)
    @warnings << txt
  end

  def add_result(name, score)
    @results << SearchResult.new(name, score)
  end

  def contains_matches
    !@results.empty?
  end
end


class Searcher

  def initialize(dict, document_vectors, cache_file)
    @dict = dict
    @document_vectors = document_vectors
    @cache_file = cache_file
  end

  # Return SearchResults based on trying to find the array of
  # +words+ in our document vectors
  #
  # A word beginning '+' _must_ appear in the target documents
  # A word beginning '-' <i>must not</i> appear
  # other words are scored. The documents with the highest
  # scores are returned first

  def find_words(words)
    searchResults = SearchResults.new

    general = Vector.new
    must_match = Vector.new
    must_not_match = Vector.new
    
    Searcher.extract_words_for_searcher(words.join(' ')) do |word|
      case word[0]
      when ?+
        word = word[1,99]
        vector = must_match
      when ?-
    	word = word[1,99]
        vector = must_not_match
      else
    	vector = general
      end
      
      index = @dict.find(word.downcase)
      if index
        vector.add_word_index(index)
      else
    	searchResults.add_warning "'#{word}' does not occur in the documents"
      end
    end

#    if (general.num_bits + must_match.num_bits).zero? 
#      searchResults.add_warning "No valid search terms given"
#    else
      res = []
      @document_vectors.each do |entry, dvec|
        score = dvec.score_against(must_match, must_not_match, general)
        res << [ entry, score ] if score > 0
      end
      
      res.sort {|a,b| b[1] <=> a[1] }.each {|name, score|
        searchResults.add_result(name, score)
      }
      
      searchResults.add_warning "No matches" unless searchResults.contains_matches
#    end
    searchResults
  end
      
      
  # Serialization support. At some point we'll need to add incremenntal indexing. 
  # For now, however, the following seems to work fairly effectively
  # on 1000 entry blogs, so I'll defer the change until later.

#  def Searcher.load(rublog, cache_filename)
  def Searcher.load(blog, cache_file)
    dict = document_vectors = nil
    modified = false
    loaded   = false
    begin
      File.open(cache_file, "r") do |f| 
		if f.mtime > blog.all_entries.latest_mtime
		  dict = Marshal.load(f)
		  document_vectors = Marshal.load(f)
		  loaded = true
		end
      end
    rescue
      ;
    end

    unless loaded
      dict = Dictionary.new
      document_vectors = {}
      create_indices(blog, dict, document_vectors)
      modified = true
    end
    
    s = Searcher.new(dict, document_vectors, cache_file)
    s.dump if modified
    s
  end

  def dump
    File.open(@cache_file, "w") do |fileInstance|
      Marshal.dump(@dict, fileInstance)
      Marshal.dump(@document_vectors, fileInstance)
    end
  end

  def Searcher.extract_words_for_searcher(text)
    text.scan(/[-+]?\w[\-\w]{2,}/) do |word|
      yield word
    end
  end

  # Create a new dictionary and document vectors from
  # a blog archive

  def Searcher.create_indices(rublog, dict, document_vectors)
#    entries = FileEntries.new(rublog, Time.at(0), Time.now).entries
    entries = rublog.all_entries.entries

    word_count = doc_count = 0
  
    entries.each do |entry|
      doc_count += 1
      vector = Vector.new
      extract_words_for_searcher(entry.as_plain_text.downcase) do |word|
        word_index = dict.add_word(word)
        if word_index
          vector.add_word_index(word_index) 
          word_count += 1
        end
      end
      document_vectors[entry.name_part] = vector
    end
    
    $stderr.puts "#{dict.size} unique words out of #{word_count} " +
      "in #{doc_count} documents"
    
  end
  
end



=begin
document_vectors.each do |entry1, vector1|
  puts "\n\n#{entry1}"
  res = []
  document_vectors.each do |entry2, vector2|
    cosine = vector1.dot(vector2)
    res << [ entry2, cosine ]
  end
  res.sort {|a,b| b[1] <=> a[1] }.each {|name, cos|
    puts "#{name}: #{cos}" if cos > 0.1
  }
end
=end


