# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class DataViewCtrl < Window

      include Typemap::DataViewItem

      def setup
        super
        spec.items << 'wxDataViewListCtrl' << 'wxDataViewTreeCtrl'
        spec.add_header_code <<~__HEREDOC
            WXRUBY_TRACE_GUARD(WxRubyTraceMarkDVCtrl, "GC_MARK_DVCTRL")
            WXRUBY_EXPORT void GC_mark_wxDataViewCtrl(void* ptr)
            {
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVCtrl, 2)
                WXRUBY_TRACE("> GC_mark_wxDataViewCtrl : " << ptr)
              WXRUBY_TRACE_END
  
              if (GC_IsWindowDeleted(ptr)) return;          

              GC_mark_wxWindow(ptr);            
              
              wxDataViewCtrl* wx_dvc = reinterpret_cast<wxDataViewCtrl*> (ptr);

              // Mark associated model
              wxDataViewModel* wx_dvmdl = wx_dvc->GetModel();
              rb_gc_mark(SWIG_RubyInstanceFor(wx_dvmdl));

              // Mark added columns
              for (unsigned int n=0; n < wx_dvc->GetColumnCount() ; n++)
              {
                wxDataViewColumn* wx_dvcol = wx_dvc->GetColumn(n);
                rb_gc_mark(SWIG_RubyInstanceFor(wx_dvcol));
              }                                            
            
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVCtrl, 2)
                WXRUBY_TRACE("< GC_mark_wxDataViewCtrl : " << ptr)
              WXRUBY_TRACE_END
            }
            __HEREDOC
        spec.add_swig_code '%markfunc wxDataViewCtrl "GC_mark_wxDataViewCtrl";'
        spec.add_swig_code '%markfunc wxDataViewListCtrl "GC_mark_wxDataViewCtrl";'
        spec.add_swig_code '%markfunc wxDataViewTreeCtrl "GC_mark_wxDataViewCtrl";'
        # mixin WithImages (this relation is missing from wxWidgets doc)
        spec.include_mixin 'wxDataViewTreeCtrl', 'Wx::WithImages'
        # ignore methods inherited from wxWithImages
        spec.ignore 'wxDataViewTreeCtrl::SetImageList', 'wxDataViewTreeCtrl::GetImageList', ignore_doc: false
        spec.suppress_warning(473, 'wxDataViewCtrl::GetSortingColumn')
        # not useful in Ruby
        spec.no_proxy 'wxDataViewCtrl::GetColumnCount', 'wxDataViewCtrl::GetColumn'
        # make arg names more specific for disowning rule
        spec.rename_method_arg %w[wxDataViewCtrl::AppendColumn wxDataViewCtrl::PrependColumn wxDataViewCtrl::InsertColumn] => { 'col' => 'new_col' }
        spec.rename_method_arg %w[wxDataViewListCtrl::AppendColumn wxDataViewListCtrl::PrependColumn wxDataViewListCtrl::InsertColumn] => { 'column' => 'new_col' }
        spec.disown 'wxDataViewColumn *new_col'
        # make arg name more specific for type map
        spec.rename_method_arg 'wxDataViewCtrl::GetSelections' => { 'sel' => 'sel_out' }
        # for GetSelections
        spec.map 'wxDataViewItemArray& sel_out' => '::Array<::Integer>,nil' do

          map_in ignore: true, temp: 'wxDataViewItemArray tmp_arr', code: '$1 = &tmp_arr;'
          map_out ignore: 'unsigned int'
          map_argout code: <<~__CODE
            if (result > 0)
            {
              $result = rb_ary_new();
              for (size_t n=0; n <tmp_arr$argnum.GetCount() ;n++)
              {
                wxDataViewItem wx_itm = tmp_arr$argnum.Item(n);
                rb_ary_push($result, wx_itm.IsOk() ? ULL2NUM(wxUIntPtr(wx_itm.GetID())) : Qnil);
              }
            }
            else
            {
              $result = Qnil;
            }
            __CODE

          # ignore input for now
          map_directorin code: ''

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_ARRAY)
              {
                unsigned int n = RARRAY_LEN(result);
                for (unsigned int i = 0; i < n; i++)
                {
                  VALUE val = rb_ary_entry(result, i);
                  sel_out.Add(RTEST(val) ? wxDataViewItem((void*)wxUIntPtr(NUM2ULL(val))) : wxDataViewItem());
                }
                c_result = n;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                           "get_children should return nil or an array of objects (data item ids)");
              }
            }
            else
              c_result = 0;
          __CODE

        end
        # for GetSortingColumns
        spec.map 'wxVector<wxDataViewColumn*>' => 'Array<Wx::DVW::DataViewColumn>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (wxDataViewColumn* col : $1)
            {
              VALUE rb_col = SWIG_NewPointerObj(col, SWIGTYPE_p_wxDataViewColumn, 0);       
              rb_ary_push($result, rb_col);     
            }
            __CODE

          map_directorout code: <<~__CODE
            if (RTEST($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i; i < RARRAY_LEN($input) ;i++)
                {
                  void* ptr;
                  VALUE rb_col = rb_ary_entry($input, i); 
                  int res = SWIG_ConvertPtr(rb_col, &ptr,SWIGTYPE_p_wxDataViewColumn,  0);
                  if (!SWIG_IsOK(res)) {
                    Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", SWIG_ErrorType(SWIG_ArgError(res)), "expected output value of Array<Wx::DVW::DataViewColumn>");
                  }
                  $result.push_back(reinterpret_cast<wxDataViewColumn*> (ptr));
                }
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, "expected output value of Array<Wx::DVW::DataViewColumn>");
              }
            }            
            __CODE
        end
        # for EnableDropTargets
        spec.map 'const wxVector<wxDataFormat> &formats' => 'Array<Wx::DataFormat>' do
          map_in temp: 'wxVector<wxDataFormat> tmpVec', code: <<~__CODE
            if (RTEST($input))
            {
              if (TYPE($input) == T_ARRAY)
              {
                for (int i; i < RARRAY_LEN($input) ;i++)
                {
                  void* ptr;
                  VALUE rb_fmt = rb_ary_entry($input, i); 
                  int res = SWIG_ConvertPtr(rb_fmt, &ptr,SWIGTYPE_p_wxDataFormat,  0);
                  if (!SWIG_IsOK(res)) {
                    const char* msg;
                    VALUE rb_msg;
                    rb_msg = rb_inspect(rb_fmt);
                    msg = StringValuePtr(rb_msg);
                    rb_raise(rb_eTypeError, "$symname : expected Array<Wx::DataFormat> for $argnum but got %s in element %d",
                             msg, i);
                  }
                  tmpVec.push_back(*reinterpret_cast<wxDataFormat*> (ptr));
                }
              }
              else
              {
                const char* msg;
                VALUE rb_msg;
                rb_msg = rb_inspect($input);
                msg = StringValuePtr(rb_msg);
                rb_raise(rb_eTypeError, "$symname : expected Array<Wx::DataFormat> for $argnum but got %s",
                         msg);
              }
            }
            $1 = &tmpVec;
            __CODE
        end
        # for HitTest
        spec.map 'wxDataViewItem& item, wxDataViewColumn *&col' => '::Array(::Integer, Wx::DVW::DataViewColumn), nil' do
          map_in ignore: true, temp: 'wxDataViewItem tmpItm, wxDataViewColumn *tmpCol = nullptr', code: <<~__CODE
              $1 = &tmpItm; $2 = &tmpCol;              
              __CODE
          map_argout code: <<~__CODE
              if (tmpItm$argnum.IsOk())
              {
                $result = rb_ary_new();
                rb_ary_push($result, ULL2NUM(wxUIntPtr(tmpItm$argnum.GetID())));
                VALUE rb_col = SWIG_NewPointerObj(tmpCol$argnum, SWIGTYPE_p_wxDataViewColumn, 0);       
                rb_ary_push($result, rb_col);     
              }
              else
              {
                $result = Qnil;
              }
              __CODE

          # ignore input for now
          map_directorin code: ''
          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_ARRAY && RARRAY_LEN(result) == 2)
              {
                VALUE rb_itm = rb_ary_entry(result, 0);
                item = RTEST(rb_itm) ? wxDataViewItem((void*)wxUIntPtr(NUM2ULL(rb_itm))) : wxDataViewItem();
                
                void* ptr;
                VALUE rb_col = rb_ary_entry(result, 1); 
                int res = SWIG_ConvertPtr(rb_col, &ptr,SWIGTYPE_p_wxDataViewColumn,  0);
                if (!SWIG_IsOK(res)) {
                  Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", SWIG_ErrorType(SWIG_ArgError(res)), 
                                                             "expected Wx::DVW::DataViewColumn as second return value");
                }
                col = reinterpret_cast<wxDataViewColumn*> (ptr);
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                           "expected return of nil or an array size 2 with an ::Object and a Wx::DVW::DataViewColumn");
              }
            }
            else
            {
              item.Unset();
              col = nullptr;
            }
          __CODE
        end
        # for variant vectors
        spec.map 'const wxVector<wxVariant> &' => 'Array<Wx::Variant,String,Integer,Float,Time,Wx::Font,Wx::Colour,Array<Wx::Variant>,Array<String>,Object,nil>' do
          map_in temp: 'wxVector<wxVariant> tmp', code: <<~__CODE
              if (($input == Qnil) || (TYPE($input) != T_ARRAY))
              {
                rb_raise(rb_eArgError, "Expected an Array of Wx::Variant or other objects for %d", $argnum-1);
              }
              else
              {
                for (int i = 0; i < RARRAY_LEN($input); ++i)
                {
                  VALUE var = rb_ary_entry($input, i);
                  tmp.push_back(wxRuby_ConvertRbValue2Variant(var));
                }
                $1 = &tmp;
              }
              __CODE
        end
      end

    end

  end

end
