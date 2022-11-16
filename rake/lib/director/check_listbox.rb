#--------------------------------------------------------------------
# @file    check_listbox.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class CheckListBox < Window

      def setup
        super
        spec.ignore_bases('wxCheckListBox' => %w[wxListBox])
        spec.override_base('wxCheckListBox', 'wxListBox')
        spec.ignore('wxCheckListBox::Create(wxWindow *,wxWindowID, const wxPoint &,const wxSize &,int,const wxString[],long,const wxValidator &,const wxString &)')
        spec.swig_import('swig/classes/include/wxObject.h',
                         'swig/classes/include/wxEvtHandler.h',
                         'swig/classes/include/wxWindow.h',
                         'swig/classes/include/wxControl.h',
                         'swig/classes/include/wxControlWithItems.h',
                         'swig/classes/include/wxListBox.h')
        spec.swig_include('swig/shared/arrayint_selections.i')
      end

    end # class ListBox

  end # class Director

end # module WXRuby3
