# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RichTextCtrl < Window

      include Typemap::RichText
      if Config.instance.features_set?('USE_DATETIME')
        include Typemap::DateTime
      end

      def setup
        super
        spec.items << 'wxRichTextContextMenuPropertiesInfo' << 'wxCommandProcessor'
        spec.include 'wx/richtext/richtextstyles.h'
        spec.gc_as_untracked 'wxRichTextContextMenuPropertiesInfo'
        spec.no_proxy 'wxCommandProcessor'
        spec.make_abstract 'wxCommandProcessor'
        # restrict CommandProcessor functionality so we do not expose wxCommand hierarchy
        spec.ignore %w[
          wxCommandProcessor::GetCommands
          wxCommandProcessor::GetCurrentCommand
          wxCommandProcessor::Submit
          wxCommandProcessor::Store
        ]
        # mixin TextEntry
        spec.include_mixin 'wxRichTextCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxRichTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        spec.include 'wx/dc.h'
        spec.ignore [
          'wxRichTextCtrl::GetSelection(long *,long *) const',
          'wxRichTextCtrl::GetSelection() const',
          'wxRichTextCtrl::SetStyle(long,long,const wxTextAttr &)',
          'wxRichTextCtrl::SetStyle(const wxRichTextRange &,const wxTextAttr &)',
          'wxRichTextCtrl::SetStyle(wxRichTextObject *,const wxRichTextAttr &,int)',
          'wxRichTextCtrl::GetStyleForRange(const wxRichTextRange &,wxTextAttr &)',
          'wxRichTextCtrl::HitTest(const wxPoint &,long *)',
          'wxRichTextCtrl::SetListStyle(const wxRichTextRange &,wxRichTextListStyleDefinition *,int,int,int)',
          ]
        # ignore the standard event handlers (doesn't seem useful to export to Ruby since non-virtual)
        # and removing cleans the interface
        spec.ignore %w[
          wxRichTextCtrl::OnDropFiles
          wxRichTextCtrl::OnCaptureLost
          wxRichTextCtrl::OnSysColourChanged
          wxRichTextCtrl::OnCut
          wxRichTextCtrl::OnCopy
          wxRichTextCtrl::OnPaste
          wxRichTextCtrl::OnUndo
          wxRichTextCtrl::OnRedo
          wxRichTextCtrl::OnSelectAll
          wxRichTextCtrl::OnProperties
          wxRichTextCtrl::OnClear
          wxRichTextCtrl::OnUpdateCut
          wxRichTextCtrl::OnUpdateCopy
          wxRichTextCtrl::OnUpdatePaste
          wxRichTextCtrl::OnUpdateUndo
          wxRichTextCtrl::OnUpdateRedo
          wxRichTextCtrl::OnUpdateSelectAll
          wxRichTextCtrl::OnUpdateProperties
          wxRichTextCtrl::OnUpdateClear
          wxRichTextCtrl::OnContextMenu
          wxRichTextCtrl::OnPaint
          wxRichTextCtrl::OnEraseBackground
          wxRichTextCtrl::OnLeftClick
          wxRichTextCtrl::OnLeftUp
          wxRichTextCtrl::OnMoveMouse
          wxRichTextCtrl::OnLeftDClick
          wxRichTextCtrl::OnMiddleClick
          wxRichTextCtrl::OnRightClick
          wxRichTextCtrl::OnChar
          wxRichTextCtrl::OnSize
          wxRichTextCtrl::OnSetFocus
          wxRichTextCtrl::OnKillFocus
          wxRichTextCtrl::OnIdle
          wxRichTextCtrl::OnScroll
          ]
        # TODO : not supported (yet)
        spec.ignore %w[
          wxRichTextCtrl::PaintBackground
          wxRichTextCtrl::PaintAboveContent
          wxRichTextCtrl::LayoutContent
          wxRichTextCtrl::DoLayoutBuffer
          wxRichTextCtrl::DoGetValue
          wxRichTextCtrl::DoSetValue
          wxRichTextCtrl::DoWriteText
          wxRichTextCtrl::EnableVerticalScrollbar
          wxRichTextCtrl::GetVerticalScrollbarEnabled
          wxRichTextCtrl::SetupScrollbars
          wxRichTextCtrl::ScrollIntoView
          wxRichTextCtrl::KeyboardNavigate
          wxRichTextCtrl::PositionToXY
          wxRichTextCtrl::XYToPosition
          ]
        # this method contains worrisome code and is unclearly documented so I doubt it's usefulness
        spec.ignore 'wxRichTextCtrl::FindContainerAtPoint'
        # do not think having these proxied is going to bring much for wxRuby and suppressing them
        # prevents code bloat
        spec.no_proxy %w[
          wxRichTextCtrl::GetDefaultStyleEx
          wxRichTextCtrl::GetBasicStyle
          wxRichTextCtrl::WriteField
          wxRichTextCtrl::WriteTextBox
          wxRichTextCtrl::WriteTable
          wxRichTextCtrl::WriteImage
          wxRichTextCtrl::FindRangeForList
          wxRichTextCtrl::ProcessMouseMovement
          wxRichTextCtrl::ProcessBackKey
          ]
        unless Config.instance.features_set?('USE_DATETIME')
          spec.ignore %w[wxRichTextCtrl::GetDragStartTime wxRichTextCtrl::SetDragStartTime]
        end
        spec.add_header_code 'extern VALUE wxRuby_RichTextObject2Ruby(const wxRichTextObject *wx_rto, int own);'
        spec.swig_import('swig/classes/include/wxTextAttr.h',
                         'swig/classes/include/wxRichTextObject.h',
                         'swig/classes/include/wxRichTextCompositeObject.h',
                         'swig/classes/include/wxRichTextParagraphLayoutBox.h',
                         'swig/classes/include/wxRichTextBuffer.h',
                         append_to_base_imports: true)
        spec.suppress_warning(402, 'wxRichTextAttr')
        # Deal with some output values from TextCtrl methods - PositionToXY
        spec.map_apply 'long * OUTPUT' => 'long *'
        # DeleteSelectedContent
        spec.map 'long *newPos' => 'Integer,nil' do
          map_in ignore: true, temp: 'long tmp', code: '$1 = &tmp;'
          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'
          map_argout code: <<~__CODE
            if (result)
            {
              $result = LONG2NUM(tmp$argnum);
            }
            else
              $result = Qnil;
            __CODE
          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              if (TYPE(result) == T_FIXNUM)
              {
                *newPos = NUM2LONG(result);
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, 
                                                           "expected an Integer, or nil on failure");
              }
            }
            else
              c_result = false;
          __CODE
        end
        spec.map_apply 'long * OUTPUT' => [ 'wxTextCoord *col', 'wxTextCoord *row' ]
        # GetViewStart
        spec.map_apply 'int * OUTPUT' => 'int *'
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxRichTextStyleSheet* styleSheet'
        # ProcessDelayedImageLoading
        spec.map_apply 'int * OUTPUT' => 'int & loadCount'
        # FindRangeForList & FindCaretPositionForCharacterPosition
        spec.map_apply 'bool * OUTPUT' => ['bool & isNumberedList', 'bool & caretLineStart']
        spec.map 'wxLongLong' => 'Integer' do
          map_in code: '$1 = NUM2LL($input);'
          map_out code: '$result = LL2NUM($1.GetValue());'
        end
        # for GetLastPosition
        spec.map_apply 'long' => 'wxTextPos'
        # for wxRichTextContextMenuPropertiesInfo::GetObjects/SetObjects
        spec.map 'const wxRichTextObjectPtrArray &' => 'Array<Wx::RTC::RichTextObject>' do

          map_in temp: 'wxRichTextObjectPtrArray tmp', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              for (int i=0; i<RARRAY_LEN($input) ;++i)
              {
                void *ptr;
                int res = SWIG_ConvertPtr(rb_ary_entry($input, i), &ptr, SWIGTYPE_p_wxRichTextObject, 0);
                if (!SWIG_IsOK(res)) 
                {
                  rb_raise(rb_eArgError, "Expected Array of Wx::RTC::RichTextObject for %d", $argnum-1); 
                }
                tmp.Add(reinterpret_cast< wxRichTextObject * >(ptr));
              }
              $1 = &tmp;
            }
            else
            {
              rb_raise(rb_eArgError, "Expected Array for %d", $argnum-1);
            }
            __CODE

          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i=0; i<$1->GetCount() ;++i)
            {
              rb_ary_push($result, wxRuby_RichTextObject2Ruby($1->Item(i), 0));
            }
            __CODE

        end
        spec.add_extend_code 'wxRichTextCtrl', <<~__HEREDOC
          VALUE each_line()
          {
            VALUE rc = Qnil;
            for (int i=0; i<$self->GetNumberOfLines() ;++i)
            {
              VALUE rb_ln = WXSTR_TO_RSTR($self->GetLineText(i));
              rc = rb_yield(rb_ln);
            }
            return rc;
          }
          __HEREDOC
      end
    end # class RichTextCtrl

  end # class Director

end # module WXRuby3
