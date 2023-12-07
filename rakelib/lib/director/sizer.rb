# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Sizer < Director

      def setup
        # Any nested sizers passed to Add() in are owned by C++, not GC'd by Ruby
        case spec.module_name
        when 'wxSizer'
          spec.items << 'wxSizerFlags'
          spec.gc_as_untracked('wxSizerFlags')
          if Config.instance.wx_version < '3.3.0'
            # missing from docs
            spec.extend_interface 'wxSizerFlags',
                                  'wxSizerFlags& HorzBorder()'
          end
          spec.make_abstract('wxSizer')
          spec.ignore %w[wxSizer::IsShown wxSizer::SetVirtualSizeHints]
          # cannot use these with wxRuby
          spec.ignore 'wxSizer::Add(wxSizerItem *)',
                      'wxSizer::Insert(size_t, wxSizerItem *)',
                      'wxSizer::Prepend(wxSizerItem *)'
          spec.ignore 'wxSizer::Remove(wxWindow *)' # long time deprecated
          # need to remove userData arg which we do not support in wxRuby (not really useful and a pita)
          spec.ignore 'wxSizer::Add(wxWindow *, int, int, int, wxObject *)',
                      'wxSizer::Add(int, int, int, int, int, wxObject *)',
                      'wxSizer::Insert(size_t, wxWindow *, int, int, int, wxObject *)',
                      'wxSizer::Insert(size_t, int, int, int, int, int, wxObject *)',
                      'wxSizer::Prepend(wxWindow *, int, int, int, wxObject *)',
                      'wxSizer::Prepend(int, int, int, int, int, wxObject *)'
          # re-add without userData
          spec.extend_interface 'wxSizer',
                                'wxSizerItem * Add(wxWindow *window, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem * Add(int width, int height, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem * Insert(size_t index, wxWindow *window, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem * Insert(size_t index, int width, int height, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem * Prepend(wxWindow *window, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem * Prepend(int width, int height, int proportion=0, int flag=0, int border=0)'
          # for doc gen
          spec.map 'wxObject *userData' => '', swig: false do
            map_in ignore: true, code: ''
          end
          # need to adjust sizer arg name to apply disown specs (also remove userData arg)
          spec.ignore 'wxSizer::Add(wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Add(wxSizer *, int, int, int, wxObject *)',
                      'wxSizer::Insert(size_t, wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Insert(size_t, wxSizer *, int, int, int, wxObject *)',
                      'wxSizer::Prepend(wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Prepend(wxSizer *, int, int, int, wxObject *)',
                      ignore_doc: false
          spec.extend_interface 'wxSizer',
                                'wxSizerItem* Add(wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Add(wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem* Insert(size_t index, wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Insert(size_t index, wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0)',
                                'wxSizerItem* Prepend(wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Prepend(wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0)'
          spec.disown 'wxSizer* sizer_disown'
          # needs custom impl to transfer ownership of detached items
          spec.ignore 'wxSizer::Detach(wxSizer*)',
                      'wxSizer::Detach(int)', ignore_doc: false
          spec.add_extend_code 'wxSizer', <<~__HEREDOC
            bool Detach(wxSizer* szr)
            {
              if ($self->Detach(szr))
              {
                VALUE rb_szr = SWIG_RubyInstanceFor(szr);
                if (rb_szr && !NIL_P(rb_szr))
                {
                  // transfer ownership to Ruby
                  RDATA(rb_szr)->dfree = GcSizerFreeFunc;            
                }
                return true;
              }
              return false;
            }

            bool Detach(int itm_nr)
            {
              wxSizerItem* itm = $self->GetItem(itm_nr);
              if (itm)
              {
                VALUE rb_szr = Qnil;
                if (itm->IsSizer())
                {
                  rb_szr = SWIG_RubyInstanceFor(itm->GetSizer());
                }
                if ($self->Detach(itm_nr))
                {
                  if (rb_szr && !NIL_P(rb_szr))
                  {
                    // transfer ownership to Ruby
                    RDATA(rb_szr)->dfree = GcSizerFreeFunc;            
                  }
                  return true;
                }
              }
              return false;
            }

            VALUE each_child()
            {
              const wxSizerItemList& child_list = self->GetChildren();
              VALUE rc = Qnil;
              wxSizerItemList::compatibility_iterator node = child_list.GetFirst();
              while (node)
              {
                wxSizerItem *wx_si = node->GetData();
                VALUE rb_si = SWIG_NewPointerObj(wx_si, SWIGTYPE_p_wxSizerItem, 0);
                rc = rb_yield(rb_si);
                node = node->GetNext();
              }
              return rc;
            }
            __HEREDOC
          # Typemap for GetChildren - convert to array of Sizer items
          spec.map 'wxSizerItemList&' => 'Array<Wx::SizerItem>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              wxSizerItemList::compatibility_iterator node = $1->GetFirst();
              while (node)
              {
                wxSizerItem *wx_si = node->GetData();
                VALUE rb_si = SWIG_NewPointerObj(wx_si, SWIGTYPE_p_wxSizerItem, 0);
                rb_ary_push($result, rb_si);
                node = node->GetNext();
              }
              __CODE
          end
          spec.map 'wxSizerFlags&' => 'Wx::SizerFlags' do
            map_out code: '$result = self; wxUnusedVar($1);'
          end
          # get rid of unwanted SWIG warning
          spec.suppress_warning(517, 'wxSizer')
        when 'wxGridBagSizer'
          spec.items << 'wxGBSpan' << 'wxGBPosition'
          spec.gc_as_untracked 'wxGBSpan', 'wxGBPosition'
          # cannot use this with wxRuby
          spec.ignore 'wxGridBagSizer::Add(wxGBSizerItem *)'
          # need to adjust sizer arg name to apply disown specs and need to remove userData arg
          spec.ignore 'wxGridBagSizer::Add(wxSizer *, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      'wxGridBagSizer::Add(wxWindow *, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      'wxGridBagSizer::Add(int, int, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      ignore_doc: false
          spec.extend_interface 'wxGridBagSizer',
                                'wxSizerItem * Add(wxSizer *sizer_disown, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0)',
                                'wxSizerItem * Add(wxWindow *window, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0)',
                                'wxSizerItem * Add(int width, int height, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0)'
          spec.disown 'wxSizer* sizer_disown'
          # for doc gen
          spec.map 'wxObject *userData' => '', swig: false do
            map_in ignore: true, code: ''
          end
        end
        # no real use for allowing these to be overloaded but a whole lot of grieve
        # if we do allow it
        spec.no_proxy(%W[
            #{spec.module_name}::Detach
            #{spec.module_name}::Replace
            #{spec.module_name}::Remove
            #{spec.module_name}::Clear
            #{spec.module_name}::Layout
          ])
        spec.no_proxy "#{spec.module_name}::AddSpacer"
        super
      end
    end # class Object

  end # class Director

end # module WXRuby3
