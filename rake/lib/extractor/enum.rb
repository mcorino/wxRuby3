###
# wxRuby3 wxWidgets interface extractor
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  module Extractor

    # A named or anonymous enumeration.
    class EnumDef < BaseDef
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
        update_attributes(**kwargs)
      end

      attr_accessor :is_anonymous, :protection

      def extract(element)
        super
        @is_anonymous = name.start_with?('@')
        element.xpath('enumvalue').each do |node|
          value = EnumValueDef.new(node)
          items << value
        end
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
