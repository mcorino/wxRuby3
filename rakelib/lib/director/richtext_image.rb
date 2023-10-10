# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_object'

module WXRuby3

  class Director

    class RichTextImage < RichTextObject

      include Typemap::RichText
      include Typemap::IOStreams

      def setup
        super
        spec.items << 'wxRichTextImageBlock'
        spec.no_proxy 'wxRichTextImageBlock'
        spec.ignore 'wxRichTextImageBlock::ReadBlock',
                    'wxRichTextImageBlock::WriteBlock'
        # for SetData & GetData
        spec.map 'unsigned char *' => 'String' do

          map_in temp: 'std::unique_ptr<unsigned char[]> buf', code: <<~__CODE
            if (TYPE($input) == T_STRING)
            {
              int data_len = RSTRING_LEN($input);
              buf = std::make_unique<unsigned char[]> (data_len);
              memcpy(buf.get(), StringValuePtr($input), data_len);
              $1 = buf.release();
            }
            else
            {
              rb_raise(rb_eArgError, "Expected a String for %d", $argnum-1);
            }
          __CODE

          map_out code: <<~__CODE
            size_t data_len = arg1->GetDataSize();
            $result = rb_str_new( (const char*)$1, data_len);
          __CODE
        end
        spec.map_apply 'bool * OUTPUT' => 'bool & changed'
        spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
      end

    end

  end

end
