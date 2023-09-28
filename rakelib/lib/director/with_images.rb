# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class WithImages < Director

      def setup
        super
        spec.gc_as_untracked 'wxWithImages' # actually no GC control necessary as this is a mixin only
        # turn wxWithImages into a mixin module
        spec.make_mixin 'wxWithImages'
        # Avoid premature deletion of ImageList providing icons for notebook
        # tabs; wxRuby takes ownership when the ImageList is assigned,
        # wxWidgets will delete the ImageList with the Toolbook.
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxImageList*'
        spec.ignore('wxWithImages::@.NO_IMAGE', 'wxWithImages::SetImageList')
        spec.rename_for_ruby('SetImageList' => 'wxWithImages::AssignImageList')
        spec.ignore 'wxWithImages::SetImages', ignore_doc: false
        spec.add_swig_code 'typedef wxBitmapBundle* WxBitmapBundleArray;'
        spec.add_header_code 'typedef wxVector<wxBitmapBundle> WxBitmapBundleArray;'
        spec.extend_interface 'wxWithImages', 'void SetImages(const WxBitmapBundleArray& images);'
        # type mapping for wrapper implementation
        spec.map 'const WxBitmapBundleArray& images' => 'Array<Wx::Image>' do
          map_in temp: 'wxVector<wxBitmapBundle> tmp', code: <<~__CODE
            if ($input != Qnil)
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i=0; i<RARRAY_LEN($input) ;++i)
                {
                  void* ptr;
                  VALUE rb_image = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(rb_image, &ptr, SWIGTYPE_p_wxBitmapBundle, 0);
                  if (!SWIG_IsOK(res)) 
                  {
                    VALUE msg = rb_inspect(rb_image);
                    rb_raise(rb_eTypeError, "Expected Wx::ImageBundle at index %d but got %s", i, StringValuePtr(msg));
                  }
                  tmp.push_back(*static_cast<wxBitmapBundle*>(ptr));
                }
              }
              else
              {
                VALUE msg = rb_inspect($input);
                rb_raise(rb_eArgError, "Expected Array of Wx::ImageBundle for $argnum but got %s", StringValuePtr(msg));
              }
            }
            $1 = &tmp;
            __CODE
        end
        # doc type map
        spec.map 'const wxVector<wxBitmapBundle> &images' => 'Array<Wx::Image>', swig: false do
          map_in
        end
      end
    end # class WithImages

  end # class Director

end # module WXRuby3
