require 'modulr/error'
module Modulr
  class JSModule
    include Comparable
    
    JS_ESCAPE_MAP = {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'"
    }
    
    def self.parser
      @dependency_finder ||= Parser.new
    end
    
    def self.find_dependencies(js_module)
      begin
        expressions = parser.get_require_expressions(js_module.src)
      rescue ParserError
        raise JavaScriptSyntaxError, js_module
      end
      expressions.map do |exp|
        if exp[:identifier]
          new(exp[:identifier], js_module.root, js_module.path, exp[:line])
        else
          raise DynamicModuleIdentifierError.new(exp[:src_code], js_module.path, exp[:line])
        end
      end
    end
    
    attr_reader :identifier, :root, :terms, :file, :line
    
    def initialize(identifier, root, file=nil, line=nil)
      @identifier = identifier
      @root = root
      @file = file
      @line = line
      @terms = identifier.split('/').reject { |term| term == '' }
      raise ModuleIdentifierError.new(self) unless identifier_valid?
    end
    
    def <=> (other_module)
      id <=> other_module.id
    end

    def inspect
      "#<#{self.class.name} \"#{identifier}\">"
    end

    def identifier_valid?
      @valid ||= terms.all? { |t| t =~ /^([-_\w]+|\.\.?)$/ }
    end
    
    def id
      return @id if @id
      if top_level?
        @id = identifier
      else
        @id = File.expand_path(partial_path, directory)
        @id.sub!("#{File.expand_path(root)}/", '')
      end
    end

    def relative?
      @relative ||= terms.first =~ /^\.\.?$/
    end

    def top_level?
      !relative?
    end

    def path
      @path ||= File.expand_path(partial_path, directory) + '.js'
    end
    
    def src
      return @src if @src
      if File.exist?(path)
        @src = File.read(path)
      else
        raise LoadModuleError.new(self)
      end
    end
    
    def escaped_src
      @escaped_src ||= src.gsub(/(\\|<\/|\r\n|[\n\r"'])/) {
        JS_ESCAPE_MAP[$1]
      }
    end
    
    def factory
      "function(require, exports, module) {\n#{src}\n}"
    end
    
    def dependencies
      @dependencies ||= self.class.find_dependencies(self)
    end
    
    def dependency_array
      '[' << dependencies.map { |d| "'#{d.id}'" }.join(', ') << ']'
    end
    
    def ensure(buffer = '')
      fn = "function() {\n#{src}\n}"
      buffer << "\nrequire.ensure(#{dependency_array}, #{fn});\n"
    end

    protected
      def partial_path
        File.join(*terms)
      end
      
      def directory
        relative? ? File.dirname(file) : root
      end
  end
  
  class ModuleIdentifierError < ModulrError
    attr_reader :js_module
    def initialize(js_module)
      @js_module = js_module
      super("Invalid module identifier '#{js_module.identifier}' in #{js_module.file} at line #{js_module.line}.")
    end
  end

  class LoadModuleError < ModulrError
    attr_reader :js_module
    def initialize(js_module)
      @js_module = js_module
      super("Cannot load module '#{js_module.identifier}' in #{js_module.file} at line #{js_module.line}.\nMissing file #{js_module.path}.")
    end
  end
  
  class DynamicModuleIdentifierError < ModulrError
    attr_reader :src, :file, :line
    def initialize(src, file, line)
      @src = src
      @file = file
      @line = line
      super("Cannot do a static analysis of dynamic module identifier '#{src}' in #{file} at line #{line}.")
    end
  end
  
  class JavaScriptSyntaxError < ModulrError
    attr_reader :js_module
    def initialize(js_module)
      @js_module = js_module
      super("JavaScript Syntax Error in #{js_module.file}.")
    end
  end
end