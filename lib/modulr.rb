module Modulr
  LIB_DIR = File.dirname(__FILE__)
  PARSER_DIR = File.join(LIB_DIR, '..', 'vendor', 'rkelly', 'lib')
  $:.unshift(LIB_DIR)
  $:.unshift(PARSER_DIR)
  
  require 'modulr/js_module'
  require 'modulr/parser'
  require 'modulr/collector'
  require 'modulr/sync_collector'
  require 'modulr/global_export_collector'
  require 'modulr/minifier'
  require 'modulr/dependency_graph'
  require 'open-uri'
  require 'modulr/version'
  
  PATH_TO_MODULR_JS = File.join(LIB_DIR, '..', 'assets', 'modulr.js')
  PATH_TO_MODULR_SYNC_JS = File.join(LIB_DIR, '..', 'assets', 'modulr.sync.js')
  
  def self.ize(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    input_files = args
    
    if options[:global]
      collector = GlobalExportCollector.new(options)
    elsif options[:sync]
      collector = SyncCollector.new(options)
    else
      collector = Collector.new(options)
    end
    
    collector.parse_files(*input_files)
    minify(collector.to_js, options[:minify])
  end
  
  def self.graph(file, options = {})
    dir = File.dirname(file)
    mod_name = File.basename(file, '.js')
    mod = JSModule.new(mod_name, dir, file)
    output = options.delete(:output)
    output = "#{dir}/#{mod_name}.png" unless output
    uri = DependencyGraph.new(mod).to_yuml(options)
    File.open(output, 'w').write(open(uri).read)
  end
  
  protected
    def self.minify(output, options)
      if options
        Minifier.minify(output, options == true ? {} : options)
      else
        output
      end
    end
end