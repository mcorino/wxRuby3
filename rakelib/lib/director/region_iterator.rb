###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class RegionIterator < Director

      def setup
        super
        spec.gc_never
        spec.disable_proxies
        spec.make_abstract 'wxRegionIterator'
        # not useful in wxRuby
        spec.ignore 'wxRegionIterator::Reset(const wxRegion &)',
                    'wxRegionIterator::operator bool'
        # add iteration control methods
        spec.add_extend_code 'wxRegionIterator', <<~__HEREDOC
          VALUE has_more()
          {
            return ((bool)*$self) ? Qtrue : Qfalse;
          }

          void next()
          {
            (*$self)++;
          }
          __HEREDOC
        # add custom factory method
        spec.add_extend_code 'wxRegionIterator', <<~__HEREDOC
          static void for_region(const wxRegion& region) 
          {
            wxRegionIterator region_it(region);
            if (rb_block_given_p())
            {
              wxRegionIterator *p_region_it = &region_it;
              VALUE rb_region_it = SWIG_NewPointerObj(SWIG_as_voidptr(p_region_it), SWIGTYPE_p_wxRegionIterator, 0);
              rb_yield(rb_region_it);
            }
          }
          __HEREDOC
        spec.do_not_generate :functions, :variables, :defines, :enums
      end
    end # class RegionIterator

  end # class Director

end # module WXRuby3
