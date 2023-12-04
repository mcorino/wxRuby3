# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class TextEntry < Director

      def setup
        super
        spec.items << 'wxTextCompleter' << 'wxTextCompleterSimple'
        spec.gc_as_untracked 'wxTextCompleter', 'wxTextCompleterSimple'
        spec.gc_as_untracked 'wxTextEntry' # actually no GC control necessary as this is a mixin only
        # turn wxTextEntry into a mixin module
        spec.make_mixin 'wxTextEntry'
        # !!NOTE!!
        # This is not very nice but it is the easiest way to work around the problem that
        # what we actually want as native type is wxTextEntryBase (because of some bad implementation decisions in wxw)
        # and what is documented is wxTextEntry.
        spec.add_header_code '#define wxTextEntry wxTextEntryBase'
        spec.disown 'wxTextCompleter *completer' # managed by wxWidgets after passing in
        spec.map_apply 'long * OUTPUT' => 'long *' # for GetSelection
        # missing non-pure virtual overrides in docs for wxTextCompleterSimple
        spec.extend_interface 'wxTextCompleterSimple',
                              'virtual bool Start(const wxString &prefix)',
                              'virtual wxString GetNext()'
        # for wxTextCompleterSimple::GetCompletions
        spec.map 'wxArrayString &res' => 'Array<String>' do

          map_in ignore: true, temp: 'wxArrayString tmp', code: '$1 = &tmp;'

          map_argout code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push($result,WXSTR_TO_RSTR( $1->Item(i) ) );
            }
          __CODE

          map_directorargout code: <<~__CODE
            if (result != Qnil && TYPE(result) == T_ARRAY)
            {
              for (int i = 0, n = RARRAY_LEN(result); i < n ;i++)
              {
                VALUE rb_comp = rb_ary_entry(result, i);
                wxString comp = RSTR_TO_WXSTR(rb_comp);
                $1.Add(comp);
              }
            }
          __CODE
        end
      end
    end # class TextEntry

  end # class Director

end # module WXRuby3
