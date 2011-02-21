module Modulr
  class MinifierError < ModulrError
  end
  
  class Minifier    
    def self.minify(input, options = {})
      new(options).minify(input)
    end
    
    def initialize(options = {})
      @options = options
    end
    
    def minify(input)
      require "yui/compressor"
      compressor = YUI::JavaScriptCompressor.new(@options)
      compressor.compress(input)
    end
  end
end
