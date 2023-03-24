###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class BookCtrls < Window

      def setup
        super
        # Protect panels etc added as Toolbook pages from being GC'd by Ruby;
        # avoids double-free segfaults on exit on GTK
        spec.map_apply 'SWIGTYPE *DISOWN' => 'wxWindow* page'
        # but not for const args (query methods)
        spec.map_apply 'SWIGTYPE *' => 'const wxWindow* page'

        case spec.module_name
        when 'wxBookCtrlBase'
          spec.make_abstract 'wxBookCtrlBase'
          spec.items.replace %w[wxBookCtrlBase bookctrl.h]
          spec.ignore 'wxBookCtrl' # useless define in bookctrl.h doc
          spec.override_inheritance_chain('wxBookCtrlBase', %w[wxControl wxWindow wxEvtHandler wxObject])
          spec.no_proxy('wxBookCtrlBase')
          # argout for HitTest
          spec.map_apply 'long *OUTPUT' => 'long *flags'
          # mixin WithImages
          spec.include_mixin 'wxBookCtrlBase', 'Wx::WithImages'
        when 'wxNotebook'
          spec.ignore("wxNotebook::OnSelChange")
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxNotebook', 'virtual void OnInternalIdle()')
          setup_book_ctrl_class(spec.module_name)
        when 'wxToolbook'
          setup_book_ctrl_class(spec.module_name)
          spec.force_proxy(spec.module_name)
        end
      end
      
      def setup_book_ctrl_class(clsnm)
        spec.override_inheritance_chain(clsnm, %w[wxBookCtrlBase wxControl wxWindow wxEvtHandler wxObject])
        # This version in Wx doesn't automatically delete
        # spec.ignore "#{clsnm}::SetImageList"
        # Use the version that deletes the ImageList when the Toolbook is destroyed
        # spec.rename_for_ruby('SetImageList' => "#{clsnm}::AssignImageList")
        # These are virtual in C++ but don't need directors as fully
        # implemented in the individual child classes
        spec.no_proxy(%W[
          #{clsnm}::AddPage
          #{clsnm}::AssignImageList
          #{clsnm}::AdvanceSelection
          #{clsnm}::ChangeSelection
          #{clsnm}::DeleteAllPages
          #{clsnm}::GetPageCount
          #{clsnm}::GetPageImage
          #{clsnm}::GetPageText
          #{clsnm}::GetSelection
          #{clsnm}::GetSelection
          #{clsnm}::HitTest
          #{clsnm}::InsertPage
          #{clsnm}::SetPageImage
          #{clsnm}::SetPageText
          #{clsnm}::SetSelection
          #{clsnm}::DeletePage
          #{clsnm}::RemovePage
          #{clsnm}::SetPageSize
          ])
      end
    end # class Object

  end # class Director

end # module WXRuby3
