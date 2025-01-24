# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class TextCtrl < Window

      def setup
        super
        # mixin TextEntry
        spec.include_mixin 'wxTextCtrl', { 'Wx::TextEntry' => 'wxTextEntryBase' }
        spec.override_inheritance_chain('wxTextCtrl', %w[wxControl wxWindow wxEvtHandler wxObject])
        spec.ignore 'wxTextCtrl::HitTest(const wxPoint &,long *)'
        if Config.instance.wx_port == :wxgtk && Config.instance.wx_version >= '3.3.0'
          spec.ignore 'wxTextCtrl::GTKGetTextBuffer',
                      'wxTextCtrl::GTKGetEditable'
        end
        if Config.instance.wx_version >= '3.3.0'
          spec.items << 'wxTextSearch' << 'wxTextSearchResult'
          spec.regard 'wxTextSearch::m_searchValue',
                      'wxTextSearch::m_startingPosition',
                      'wxTextSearch::m_matchCase',
                      'wxTextSearch::m_wholeWord',
                      'wxTextSearch::m_direction',
                      'wxTextSearchResult::m_start',
                      'wxTextSearchResult::m_end'
          spec.make_readonly 'wxTextSearch::m_searchValue',
                             'wxTextSearch::m_startingPosition',
                             'wxTextSearch::m_matchCase',
                             'wxTextSearch::m_wholeWord',
                             'wxTextSearch::m_direction',
                             'wxTextSearchResult::m_start',
                             'wxTextSearchResult::m_end'
          spec.rename_for_ruby 'get_search_value' => 'wxTextSearch::m_searchValue',
                               'get_starting_position' => 'wxTextSearch::m_startingPosition',
                               'match_case?' => 'wxTextSearch::m_matchCase',
                               'whole_word?' => 'wxTextSearch::m_wholeWord',
                               'get_direction' => 'wxTextSearch::m_direction',
                               'start' => 'wxTextSearchResult::m_start',
                               'end' => 'wxTextSearchResult::m_end'
        end
        if Config.instance.wx_port == :wxqt
          # not implemented
          spec.ignore 'wxTextCtrl::OnDropFiles'
        end
        # Ignore these; wxTextProofOptions documentation is absolute crap and as the class is trivial
        # we will not wrap it but create a simplified interface when USE_SPELLCHECK is enabled which
        # we will complement in pure Ruby to provide Wx::TextProofOptions class
        spec.ignore('wxTextCtrl::EnableProofCheck', 'wxTextCtrl::GetProofCheckOptions')
        if Config.instance.features_set?('USE_SPELLCHECK')
          spec.add_extend_code 'wxTextCtrl', <<~__HEREDOC
            VALUE DoEnableProofCheck(bool spelling, bool grammar, const wxString& language)
            {
              bool rc = $self->EnableProofCheck (wxTextProofOptions::Disable().SpellCheck(spelling).GrammarCheck(grammar).Language(language));
              return rc ? Qtrue : Qfalse;
            }

            VALUE DoGetProofCheckOptions()
            {
              wxTextProofOptions opts = $self->GetProofCheckOptions();
              VALUE rc = rb_ary_new();
              rb_ary_push(rc, opts.IsSpellCheckEnabled() ? Qtrue : Qfalse);
              rb_ary_push(rc, opts.IsGrammarCheckEnabled() ? Qtrue : Qfalse);
              rb_ary_push(rc, WXSTR_TO_RSTR(opts.GetLang()));
              return rc;
            }
          __HEREDOC
        end
        spec.no_proxy %w[wxTextCtrl::EmulateKeyPress wxTextCtrl::GetDefaultStyle]
        spec.map_apply 'long * OUTPUT' => 'long *'
        spec.map_apply 'long * OUTPUT' => [ 'wxTextCoord *col', 'wxTextCoord *row' ]
        # for PositionToXY
        spec.map 'long pos, long *x, long *y' do
          map_in from: {name: 'pos', type: 'Integer'}, temp: 'long tmpX, long tmpY', code: <<~__CODE
            $1 = (long)NUM2INT($input);
            $2 = &tmpX;
            $3 = &tmpY;
            __CODE

          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'

          map_argout as: 'Array(Integer, Integer), nil', code: <<~__CODE
            $result = Qnil;
            if (result)
            {
              $result = rb_ary_new ();
              rb_ary_push ($result,INT2NUM(tmpX$argnum));
              rb_ary_push ($result,INT2NUM(tmpY$argnum));
            }
          __CODE

          map_directorin code: '$input = INT2NUM($1);'

          map_directorargout code: <<~__CODE
            c_result = false;
            if (result != Qnil && TYPE(result) == T_ARRAY)
            {
              *x = (long)NUM2INT(rb_ary_entry(result, 0));
              *y = (long)NUM2INT(rb_ary_entry(result, 1));
            }
          __CODE
        end
        spec.ignore 'wxTextCtrl::operator<<'
        # Allow << to work with a TextCtrl
        # We'll make sure to return 'self' in Ruby override
        spec.add_extend_code 'wxTextCtrl', <<~__HEREDOC
          void __lshift__(VALUE value)
          {
            if(TYPE(value)==T_STRING)
              *self << wxString(StringValuePtr(value), wxConvUTF8);
            else if(TYPE(value)==T_FIXNUM)
              *self << NUM2INT(value);
            else if(TYPE(value)==T_FLOAT)
              *self << (double)(RFLOAT_VALUE(value));
          }

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
        spec.swig_import 'swig/classes/include/wxTextAttr.h'
      end
    end # class TextCtrl

  end # class Director

end # module WXRuby3
