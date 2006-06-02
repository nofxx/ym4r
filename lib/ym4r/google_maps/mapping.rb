module Ym4r
  module GoogleMaps
    module MappingObject
      attr_reader :variable
      
      #creates javascript code for missing methods
      def method_missing(name,*args)
        args.collect! do |arg|
          javascriptify_variable(arg)
        end
        "#{to_javascript}.#{javascriptify_method(name.to_s)}(#{args.join(",")});\n"
      end

      def javascriptify_variable(arg)
        if arg.is_a?(MappingObject)
          arg.to_javascript
        elsif arg.is_a?(String)
          "\"#{escape_javascript(arg)}\""
        else
          arg.to_s
        end
      end
      
      #lifted from rails
      def escape_javascript(javascript)
        javascript.gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
      end
      
      #transform a ruby-type method name (like qsd_fghj) to a Yahoo! Map style one (like qsdFghj)
      def javascriptify_method(method_name)
        method_name.gsub(/_(\w)/){|s| $1.upcase}
      end
      
      #Declare Mapping Object (Map, Tool, Marker,...) of name variable
      def declare(variable)
        @variable = variable
        "var #{variable} = #{create};\n"
      end
      
      def assign_to(variable)
        @variable = variable
        "#{variable} = #{create};\n"
      end
      
      #Returns a Javascript script representing the object
      def to_javascript
        unless @variable.nil?
          @variable
        else
          create
        end
      end
      
      #Creates a Mapping Object in Javascript
      #To be implemented by subclasses if needed
      def create
      end
    end


    class Variable
      include MappingObject
        
      def initialize(variable)
        @variable = variable
      end
    end
  end
end

