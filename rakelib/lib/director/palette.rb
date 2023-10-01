# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Palette < Director

      def setup
        super
        spec.disable_proxies
        spec.gc_as_untracked 'wxPalette'
        spec.ignore 'wxPalette::GetRGB(int,unsigned char *,unsigned char *,unsigned char *) const', ignore_doc: false
        spec.extend_interface 'wxPalette', 'bool GetRGB(int pixel,unsigned char *red_out,unsigned char *green_out,unsigned char *blue_out) const'
        # for GetRGB
        spec.map 'unsigned char *red_out', 'unsigned char *green_out', 'unsigned char *blue_out', as: 'Integer' do
          map_in ignore: true, temp: 'unsigned char cv', code: '$1 = &cv;'
          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, UINT2NUM(cv$argnum));'
        end
        # for ctor and Create
        spec.map 'int n, const unsigned char *red' => 'Array<Integer>' do
          map_in temp: 'std::unique_ptr<unsigned char[]> arr, int _global_len', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              _global_len = $1 = RARRAY_LEN($input);
              arr = std::make_unique<unsigned char[]>($1);
              $2 = arr.get ();
              for (int i=0; i<$1 ;++i)
              {
                $2[i] = NUM2UINT(rb_ary_entry($input, i));
              }
            }
            else
            {
              rb_raise(rb_eArgError, "Expected an array of integers for %d", $argnum-1);
            }
          __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_ARRAY);'
        end
        spec.map 'const unsigned char *green', 'const unsigned char *blue', as: 'Array<Integer>' do
          map_in temp: 'std::unique_ptr<unsigned char[]> arr', code: <<~__CODE
            if (TYPE($input) == T_ARRAY && _global_len == RARRAY_LEN($input))
            {
              int len = RARRAY_LEN($input);
              arr = std::make_unique<unsigned char[]>(len);
              $1 = arr.get ();
              for (int i=0; i<len ;++i)
              {
                $1[i] = NUM2UINT(rb_ary_entry($input, i));
              }
            }
            else
            {
              if (TYPE($input) == T_ARRAY)
                rb_raise(rb_eArgError, "Expected an array of integers of size %d for %d", _global_len, $argnum-1);
              else
                rb_raise(rb_eArgError, "Expected an array of integers for %d", $argnum-1);
            }
          __CODE
          map_typecheck precedence: 'POINTER', code: '$1 = (TYPE($input) == T_ARRAY);'
        end
        if Config.instance.wx_port == :wxQT
          # mismatched implementation which does nothing anyway
          spec.ignore 'wxPalette::wxPalette(int, const unsigned char *, const unsigned char *, const unsigned char *)'
          spec.ignore 'wxPalette::Create(int, const unsigned char *, const unsigned char *, const unsigned char *)'
        end
      end
    end # class Palette

  end # class Director

end # module WXRuby3
