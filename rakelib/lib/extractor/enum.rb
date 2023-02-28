###
# wxRuby3 wxWidgets interface extractor
# Copyright (c) M.J.N. Corino, The Netherlands
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
        if element
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
          extract(element)
        end
        @scope = ''
        @no_type = false
        update_attributes(**kwargs)
        EnumDef.register(self) unless is_anonymous
      end

      attr_accessor :is_anonymous, :protection, :scope

      def extract(element)
        super
        @is_anonymous = name.start_with?('@') || name.empty?
        element.xpath('enumvalue').each do |node|
          value = EnumValueDef.new(node)
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

    end # class EnumValueDef

  end # module Extractor

end # module WXRuby3
