# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class EditableListBox < Window

      def setup
        super
        # methods missing from docs
        spec.extend_interface 'wxEditableListBox',
                              'wxListCtrl* GetListCtrl()',
                              'wxBitmapButton* GetDelButton()',
                              'wxBitmapButton* GetNewButton()',
                              'wxBitmapButton* GetUpButton()',
                              'wxBitmapButton* GetDownButton()',
                              'wxBitmapButton* GetEditButton()'
        # redefine this
        spec.ignore 'wxEditableListBox::GetStrings', ignore_doc: false
        spec.add_extend_code 'wxEditableListBox', <<~__HEREDOC
          VALUE GetStrings()
          {
            VALUE rb_list = rb_ary_new(); 
            wxArrayString list;
            $self->GetStrings(list);
            for (unsigned int i=0; i<list.GetCount() ;++i)
            {
              rb_ary_push(rb_list, WXSTR_TO_RSTR(list.Item(i)));
            }
            return rb_list;
          }
          __HEREDOC
        # map for doc gen
        spec.map 'wxArrayString& strings' => 'Array<String>', swig: false do
          map_in ignore: true, code: ''
          map_argout code: ''
        end
        # make sure GetStrings uses the right typemap
        spec.map_apply 'wxArrayString&' => 'const wxArrayString& strings'
      end
    end # class EditableListBox

  end # class Director

end # module WXRuby3
