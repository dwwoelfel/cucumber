module Cucumber
  module RbSupport
    # A Ruby Transform holds a Regexp and a Proc, and is created
    # by calling <tt>Transform in the <tt>support</tt> ruby files.
    # See also RbDsl.
    #
    # Example:
    #
    #   Transform /^(\d+) cucumbers$/ do |cucumbers_string|
    #     cucumbers_string.to_i
    #   end
    #
    class RbTransform
      class MissingProc < StandardError
        def message
          "Transforms must always have a proc with at least one argument"
        end
      end

      attr_reader :proc, :regexp
      
      def initialize(rb_language, pattern, proc)
        raise MissingProc if proc.nil? || proc.arity < 1
        @rb_language, @regexp, @proc = rb_language, Regexp.new(pattern), proc        
      end

      def invoke(arg)
        if arg.kind_of?(String) && matched = regexp.match(arg)
          args = Array(matched.captures.empty? ? arg : matched.captures)
          @rb_language.current_world.cucumber_instance_exec(true, regexp.inspect, *args, &@proc)
        end        
      end
    end
  end
end