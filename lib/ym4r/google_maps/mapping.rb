module Ym4r
  module GoogleMaps
    #The module where all the Ruby-to-JavaScript conversion takes place. It is included by all the classes in the YM4R library.
    module MappingObject
      #The name of the variable in JavaScript space.
      attr_reader :variable
      
      #Creates javascript code for missing methods
      def method_missing(name,*args)
        args.collect! do |arg|
          MappingObject.javascriptify_variable(arg)
        end
        Variable.new("#{to_javascript}.#{MappingObject.javascriptify_method(name.to_s)}(#{args.join(",")})")
      end
            
      def [](index) #index could be an integer or string
        return Variable.new("#{to_javascript}[#{MappingObject.javascriptify_variable(index)}]")
      end

      #Transforms a Ruby object into a JavaScript string : MAppingObject, String, Array, Hash and general case (using to_s)
      def self.javascriptify_variable(arg)
        if arg.is_a?(MappingObject)
          arg.to_javascript
        elsif arg.is_a?(String)
          "\"#{escape_javascript(arg)}\""
        elsif arg.is_a?(Array)
          "[" + arg.collect{ |a| javascriptify_variable(a)}.join(",") + "]"
        elsif arg.is_a?(Hash)
          "{" + arg.to_a.collect do |v|
            "#{v[0].to_s} : #{MappingObject::javascriptify_variable(v[1])}"
          end.join(",") + "}"
        else
          arg.to_s
        end
      end
      
      #Escape string to be used in JavaScript. Lifted from rails.
      def self.escape_javascript(javascript)
        javascript.gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
      end
      
      #Transform a ruby-type method name (like add_overlay) to a JavaScript-style one (like addOverlay).
      def self.javascriptify_method(method_name)
        method_name.gsub(/_(\w)/){|s| $1.upcase}
      end
      
      #Declares a Mapping Object bound to a JavaScript variable of name +variable+.
      def declare(variable)
        @variable = variable
        "var #{variable} = #{create};"
      end
      
      #Binds a Mapping object to a previously declared JavaScript variable of name +variable+.
      def assign_to(variable)
        @variable = variable
        "#{variable} = #{create};"
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

    #Used to bind a ruby variable to an already existing JavaScript one. It doesn't have to be a variable in the sense "var variable" but it can be any valid JavaScript expression that has a value.
    class Variable
      include MappingObject
      def initialize(variable)
        @variable = variable
      end
      #Returns the javascript expression contained in the object.
      def create
        @variable
      end
      #Returns the expression inside the Variable followed by a ";"
      def to_s
        @variable + ";"
      end
    end
  end
end

