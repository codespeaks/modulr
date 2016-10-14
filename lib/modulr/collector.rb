module Modulr
  class Collector
    attr_reader :modules, :top_level_modules
    
    def initialize(options = {})
      @options       = options
      @root          = options[:root]
      @lazy_eval     = options[:lazy_eval]
      @custom_loader = options[:custom_loader]
      @modules       = []
      @top_level_modules = []
    end
    
    def to_js(buffer = '')
      buffer << globals
      buffer << "\n(function() {"
      buffer << lib unless @custom_loader
      buffer << transport
      reorder_top_level_modules
      buffer << requires
      buffer << "})();\n"
    end
    
    def parse_file(path)
      parse_files(path)
    end
    
    def parse_files(*paths)
      reset
      paths.each do |path|
        add_module_from_path(path)
      end
    end
    
    private
    
      def reset
        modules.clear
        top_level_modules.clear
      end
      
      def main_module?
        !!main_module
      end

      def main_module
        if mm_id = @options[:main_module]
          @top_level_modules.find { |m| m.id == mm_id }
        end
      end

      def reorder_top_level_modules
        if mm = main_module
          index = top_level_modules.index(mm)
          top_level_modules[index] = top_level_modules[0]
          top_level_modules[0] = mm
        end
      end
      
      def module_from_path(path)
        identifier = File.basename(path, '.js')
        root = @root || File.dirname(path)
        JSModule.new(identifier, root, path)
      end
      
      def add_module_from_path(path)
        js_module = module_from_path(path)
        top_level_modules << js_module
        collect_dependencies(js_module)
        js_module
      end

      def lib
        src = File.read(PATH_TO_MODULR_JS)
        "#{src}\nvar require = modulr.require, module = require.main;\n"
      end
    
      def requires
        top_level_modules.map { |m| m.ensure }.join("\n")
      end
    
      def globals
        ''
      end
    
      def transport
        pairs = modules.map do |m|
          if lazy_eval_module?(m)
            value = m.escaped_src
          else
            value = m.factory
          end
          "\n'#{m.id}': #{value}"        
        end
        "require.define({#{pairs.join(', ')}\n});"
      end
    
      def collect_dependencies(js_module)
        js_module.dependencies.each do |dependency|
          unless modules.include?(dependency)
            modules << dependency
            collect_dependencies(dependency)
          end
        end
      end
      
      def lazy_eval_module?(js_module)
        return false unless @lazy_eval
        return true if @lazy_eval === true
        return true if @lazy_eval.include?(js_module.identifier)
        return true if @lazy_eval.include?(js_module.id)
        false
      end
  end
end