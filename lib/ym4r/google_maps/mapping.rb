module Ym4r
  module GoogleMaps
    #The module where all the Ruby-to-JavaScript conversion takes place. It is included by all the classes in the YM4R library.
    module MappingObject
      #The name of the variable in JavaScript space.
      attr_reader :variable
      
      #Creates javascript code for missing methods
      def method_missing(name,*args)
        args.collect! do |arg|
          javascriptify_variable(arg)
        end
        "#{to_javascript}.#{javascriptify_method(name.to_s)}(#{args.join(",")});\n"
      end

      #Transforms a Ruby object into a JavaScript string
      def javascriptify_variable(arg)
        if arg.is_a?(MappingObject)
          arg.to_javascript
        elsif arg.is_a?(String)
          "\"#{escape_javascript(arg)}\""
        else
          arg.to_s
        end
      end
      
      #Escape string to be used in JavaScript. Lifted from rails.
      def escape_javascript(javascript)
        javascript.gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
      end
      
      #Transform a ruby-type method name (like add_overlay) to a JavaScript-style one (like addOverlay).
      def javascriptify_method(method_name)
        method_name.gsub(/_(\w)/){|s| $1.upcase}
      end
      
      #Declares a Mapping Object bound to a JavaScript variable of name +variable+.
      def declare(variable)
        @variable = variable
        "var #{variable} = #{create};\n"
      end
      
      #Binds a Mapping object to a previously declared JavaScript variable of name +variable+.
      def assign_to(variable)
        @variable = variable
        "#{variable} = #{create};\n"
      end
      
      #Returns a Javascript code representing the object
      def to_javascript
        unless @variable.nil?
          @variable
        else
          create
        end
      end
      
      #Creates a Mapping Object in JavaScript.
      #To be implemented by subclasses if needed
      def create
      end
    end

    #Used to bind a ruby variable to an already existing JavaScript one.
    class Variable
      include MappingObject
      def initialize(variable)
        @variable = variable
      end
    end
  end
end

