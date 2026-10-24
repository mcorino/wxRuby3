# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class FileHistory < Director

      include Typemap::ConfigBase

      def setup
        super
        spec.gc_as_untracked 'wxFileHistory'
        spec.ignore 'wxFileHistory::GetMenus',
                    ignore_doc: false
        spec.map 'const wxList&' => 'Array<Wx::Menu>', swig: false do
          map_out
        end
        spec.add_extend_code 'wxFileHistory', <<~__CODE
          VALUE get_menus()
          {
            VALUE ary = rb_ary_new();
            const wxList& lst = $self->GetMenus();
            for (wxList::compatibility_iterator node = lst.GetFirst();
                    node; node = node->GetNext())
            {
              wxMenu *menu = (wxMenu *) node->GetData();
              rb_ary_push(ary, wxRuby_WrapWxMenuInRuby(menu));
            }
            return ary;
          }
          __CODE
      end
    end # class FileHistory

  end # class Director

end # module WXRuby3
