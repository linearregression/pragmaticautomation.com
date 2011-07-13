TOP_DIR =  File.join(File.dirname($0),"..")

$: << TOP_DIR

require 'test/TestDevelSetup'
require 'test/ArticleSynopsisAcceptanceTest'
#require 'test/TC_Sham'
require 'test/Tester'
require 'test/TestConvertors'
require 'test/TestFileEntries'
require 'test/TestHtmlView'
require 'test/TestTemplate'
require 'test/TestRequest'
require 'search/test/TestSearcher'
require 'search/test/TestDictionary'
require 'search/test/TestVector'
