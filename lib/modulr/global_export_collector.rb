module Modulr
  class GlobalExportCollector < SyncCollector
    
    private
      def global_var_name
        @options[:global]
      end
      
      def use_module_id_as_var_name?
        @options[:global] == true
      end
      
      def globals
        if use_module_id_as_var_name?
          top_level_modules.map { |m| define_global_var(m.id) }.join
        else
          define_global_var(global_var_name)
        end
      end
    
      def define_global_var(var_name)
        if var_name.include?('.')
          props = var_name.split('.')
          str = props.shift
          results = "var #{str};"
          props.each do |prop|
            results << "\n#{str} = #{str} || {};"
            str << ".#{prop}"
          end
          "#{results}\n#{str};\n"
        else
          "var #{var_name};\n"
        end
      end
    
      def requires
        if use_module_id_as_var_name?
          top_level_modules.map { |m| "\n  #{m.id} = require('#{m.id}');" }.join
        elsif top_level_modules.size == 1
          # Export to named global
          "\n  #{global_var_name} = require('#{top_level_modules.first.id}');"
        else
          # Export to props of named global
          top_level_modules.inject("\n#{global_var_name} = {};") do |str, m|
            str << "\n  #{global_var_name}.#{m.id} = require('#{m.id}');"
          end
        end
      end
    
  end
end