# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class StyledTextCtrl < Window

      def setup
        super
        spec.override_inheritance_chain('wxStyledTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        # mixin TextEntry
        spec.include_mixin 'wxStyledTextCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.map 'int *', 'long *', as: 'Integer' do
          map_in ignore: true, temp: '$*1_ltype a', code: '$1 = &a;'
          map_argout code: <<~__CODE
            if (NIL_P($result)) $result = INT2NUM(*$1);
            else 
            {
              if (TYPE($result) != T_ARRAY)
              {
                VALUE rc = rb_ary_new();
                rb_ary_push(rc, $result);
                $result = rc;
              }
              rb_ary_push($result, INT2NUM(*$1));
            }
            __CODE
        end
        spec.map 'long *, long *', 'wxTextCoord *col, wxTextCoord *row', as: 'Array(Integer, Integer)' do
          map_in ignore: true, temp: '$*1_ltype a, $*2_ltype b', code: '$1 = &a; $2 = &b;'
          map_argout code: <<~__CODE
            if (TYPE($result) != T_ARRAY)
            {
              VALUE rc = rb_ary_new();
              if (!NIL_P($result)) rb_ary_push(rc, $result);
              $result = rc;
            }
            rb_ary_push($result, INT2NUM(*$1));
            rb_ary_push($result, INT2NUM(*$2));
          __CODE
        end
        spec.map 'wxIntPtr' => 'Integer' do
          map_in code: '$1 = NUM2ULL($input);'
          map_out code: '$result = ULL2NUM($1);'
        end
        # not useful in wxRuby
        spec.ignore 'wxStyledTextCtrl::HitTest(const wxPoint &, long *) const',
                    'wxStyledTextCtrl::GetDirectFunction',
                    'wxStyledTextCtrl::GetDirectPointer',
                    'wxStyledTextCtrl::CreateLoader',
                    'wxStyledTextCtrl::AddTextRaw',
                    'wxStyledTextCtrl::InsertTextRaw',
                    'wxStyledTextCtrl::GetCurLineRaw',
                    'wxStyledTextCtrl::GetLineRaw',
                    'wxStyledTextCtrl::GetSelectedTextRaw',
                    'wxStyledTextCtrl::GetTargetTextRaw',
                    'wxStyledTextCtrl::GetTextRangeRaw',
                    'wxStyledTextCtrl::SetTextRaw',
                    'wxStyledTextCtrl::GetTextRaw',
                    'wxStyledTextCtrl::AppendTextRaw',
                    'wxStyledTextCtrl::ReplaceSelectionRaw',
                    'wxStyledTextCtrl::ReplaceTargetRaw',
                    'wxStyledTextCtrl::ReplaceTargetRERaw',
                    'wxStyledTextCtrl::SetStyleBytes',
                    'wxStyledTextCtrl::AddStyledText',
                    'wxStyledTextCtrl::GetStyledText',
                    'wxStyledTextCtrl::RegisterImage(int, const char *const *)',
                    'wxStyledTextCtrl::RegisterRGBAImage(int, const unsigned char *)',
                    'wxStyledTextCtrl::MarkerDefineRGBAImage(int, const unsigned char *)',
                    'wxStyledTextCtrl::MarkerDefinePixmap(int, const char *const *)'
        # TODO : these need investigating to see if they might be useful
        spec.ignore 'wxStyledTextCtrl::GetDocPointer',
                    'wxStyledTextCtrl::SetDocPointer',
                    'wxStyledTextCtrl::CreateDocument',
                    'wxStyledTextCtrl::AddRefDocument',
                    'wxStyledTextCtrl::ReleaseDocument',
                    'wxStyledTextCtrl::PrivateLexerCall'
        # TODO : these will need some sort of stream solution to be useful
        spec.ignore 'wxStyledTextCtrl::GetCharacterPointer',
                    'wxStyledTextCtrl::GetRangePointer'
        spec.add_extend_code 'wxStyledTextCtrl', <<~__HEREDOC
          VALUE each_line()
          {
            VALUE rc = Qnil;
            int n = $self->GetNumberOfLines();
            for (int i=0; i<n ;++i)
            {
              VALUE rb_ln = WXSTR_TO_RSTR($self->GetLineText(i));
              rc = rb_yield_values(2, rb_ln, INT2NUM(i));
            }
            return rc;
          }
          __HEREDOC
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class StyledTextCtrl

  end # class Director

end # module WXRuby3
