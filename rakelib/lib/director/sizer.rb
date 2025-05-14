# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Sizer < Director

      include Typemap::ClientData

      def setup
        # Any nested sizers passed to Add() in are owned by C++, not GC-ed by Ruby
        case spec.module_name
        when 'wxSizer'
          spec.items << 'wxSizerFlags'
          spec.gc_as_untracked('wxSizerFlags')
          unless Config.instance.wx_version > '3.2.4'
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
          # need to adjust sizer arg name to apply disown specs
          spec.ignore 'wxSizer::Add(wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Add(wxSizer *, int, int, int, wxObject *)',
                      'wxSizer::Insert(size_t, wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Insert(size_t, wxSizer *, int, int, int, wxObject *)',
                      'wxSizer::Prepend(wxSizer *, const wxSizerFlags &)',
                      'wxSizer::Prepend(wxSizer *, int, int, int, wxObject *)',
                      ignore_doc: false
          spec.extend_interface 'wxSizer',
                                'wxSizerItem* Add(wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Add(wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0, wxObject *userData=NULL)',
                                'wxSizerItem* Insert(size_t index, wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Insert(size_t index, wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0, wxObject *userData=NULL)',
                                'wxSizerItem* Prepend(wxSizer *sizer_disown, const wxSizerFlags &flags)',
                                'wxSizerItem* Prepend(wxSizer *sizer_disown, int proportion=0, int flag=0, int border=0, wxObject *userData=NULL)'
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
          # need to adjust sizer arg name to apply disown specs
          spec.ignore 'wxGridBagSizer::Add(wxSizer *, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      'wxGridBagSizer::Add(wxWindow *, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      'wxGridBagSizer::Add(int, int, const wxGBPosition &, const wxGBSpan &, int, int, wxObject *)',
                      ignore_doc: false
          spec.extend_interface 'wxGridBagSizer',
                                'wxSizerItem * Add(wxSizer *sizer_disown, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0, wxObject *userData=NULL)',
                                'wxSizerItem * Add(wxWindow *window, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0, wxObject *userData=NULL)',
                                'wxSizerItem * Add(int width, int height, const wxGBPosition &pos, const wxGBSpan &span=wxDefaultSpan, int flag=0, int border=0, wxObject *userData=NULL)'
          spec.disown 'wxSizer* sizer_disown'
          spec.map 'const wxGBPosition&' => 'Array(Integer, Integer), Wx::GBPosition',
                   'const wxGBSpan&' => 'Array(Integer, Integer), Wx::GBSpan' do
            add_header_code '#include <memory>'
            map_in temp: 'std::unique_ptr<$1_basetype> tmp', code: <<~__CODE
            if ( TYPE($input) == T_DATA )
            {
              void* argp$argnum;
              SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 0);
              $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
            }
            else if ( TYPE($input) == T_ARRAY )
            {
              $1 = new $1_basetype( NUM2INT( rb_ary_entry($input, 0) ),
                                   NUM2INT( rb_ary_entry($input, 1) ) );
              tmp.reset($1); // auto destruct when method scope ends 
            }
            else
            {
              rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
            }
            __CODE
            map_typecheck precedence: 'POINTER', code: <<~__CODE
            void *vptr = 0;
            $1 = 0;
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2)
              $1 = 1;
            else if (TYPE($input) == T_DATA && SWIG_CheckState (SWIG_ConvertPtr ($input, &vptr, $1_descriptor, 0)))
              $1 = 1;
            __CODE
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
