# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class SizerItem < Director

      def setup
        spec.disable_proxies
        # do not allow creating SizerItems in Ruby; this has limited benefits and
        # memory management of sizer items is a nightmare
        case spec.module_name
        when 'wxSizerItem'
          spec.gc_as_untracked 'wxSizerItem'
          spec.make_abstract 'wxSizerItem'
          # ignore constructors
          spec.ignore 'wxSizerItem::wxSizerItem'
          # not really useful in wxRuby
          spec.ignore 'wxSizerItem::SetUserData', 'wxSizerItem::GetUserData'
          spec.ignore(%w[wxSizerItem::SetSizer wxSizerItem::SetSpacer wxSizerItem::SetWindow])
          # need to adjust sizer arg name to apply disown specs
          spec.ignore 'wxSizerItem::AssignSizer(wxSizer *)', ignore_doc: false
          spec.extend_interface 'wxSizerItem',
                                'void AssignSizer(wxSizer *sizer_disown)'
          spec.disown 'wxSizer *sizer_disown'
          # needs custom impl to properly transfer ownership to Ruby
          spec.ignore 'wxSizerItem::DetachSizer', ignore_doc: false
          spec.add_extend_code 'wxSizerItem', <<~__HEREDOC
            void detach_sizer()
            {
              if ($self->IsSizer())
              {
                VALUE rb_szr = SWIG_RubyInstanceFor($self->GetSizer());
                if (rb_szr && !NIL_P(rb_szr))
                {
                  // transfer ownership to Ruby
                  RDATA(rb_szr)->dfree = GcSizerFreeFunc;            
                }
                $self->DetachSizer();
              }              
            }
            __HEREDOC
        when 'wxGBSizerItem'
          spec.gc_as_untracked 'wxGBSizerItem'
          spec.make_abstract 'wxGBSizerItem'
          # ignore constructors
          spec.ignore 'wxGBSizerItem::wxGBSizerItem',
                      'wxGBSizerItem::SetGBSizer',
                      'wxGBSizerItem::GetPos(int &, int &)',
                      'wxGBSizerItem::GetSpan(int &, int &)'
          spec.map_apply 'int &OUTPUT' => ['int &row', 'int &col']
          spec.do_not_generate :variables, :enums, :defines, :functions
        end
        super
      end
    end # class SizerItem

  end # class Director

end # module WXRuby3
