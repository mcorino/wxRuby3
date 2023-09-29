# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface extractor
###

module WXRuby3

  module Extractor

    # A named or anonymous enumeration.
    class EnumDef < BaseDef

      class << self
        def enums(hash = nil)
          @enums = hash if hash
          @enums ||= ::Hash.new
        end

        def register(enum)
          enums[enum.name] = enum.scope || '' # assumes all wxWidgets enums (even scoped) are uniquely named
        end

        def enum?(name)
          enums.has_key?(name)
        end

        def enum_scope(name)
          enums[name]
        end
      end

      def initialize(element = nil, **kwargs)
        super()
        @strong = false
        @protection = 'public'
        extract(element) if element
        @scope = ''
        @no_type = false
        update_attributes(**kwargs)
        EnumDef.register(self) unless is_anonymous
      end

      attr_accessor :is_anonymous, :protection, :scope, :strong

      def extract(element)
        super
        prot = element['prot']
        if prot
          @protection = prot
          unless %w[public protected].include?(@protection)
            raise ExtractorError.new("Invalid protection [#{@protection}")
          end
          # TODO: Should protected items be ignored by default or should we
          #       leave that up to the tweaker code or the generators?
          ignore if @protection == 'protected'
        end
        @is_anonymous = name.start_with?('@') || name.empty?
        @strong = (element['strong'] == 'yes') unless @is_anonymous
        element.xpath('enumvalue').each do |node|
          value = EnumValueDef.new(node, enum: self)
          items << value
        end
      end

      def is_type
        !@is_anonymous
      end
    end # class EnumDef

    # An item in an enumeration.
    class EnumValueDef < BaseDef
      def initialize(element = nil, **kwargs)
        super()
        @value = nil
        update_attributes(**kwargs)
        extract(element) if element
      end

      def extract(element)
        super
        @value = BaseDef.flatten_node(element.at_xpath('initializer'))
      end

      attr_reader :value

      def fqn
        enum.strong ? "#{enum.name}::#{name}" : name
      end

    end # class EnumValueDef

  end # module Extractor

end # module WXRuby3
