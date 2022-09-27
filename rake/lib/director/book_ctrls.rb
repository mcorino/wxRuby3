#--------------------------------------------------------------------
# @file    book_ctrls.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class BookCtrls < Director

      def setup
        super
        spec.add_swig_begin_code <<~__HEREDOC
          // Protect panels etc added as Toolbook pages from being GC'd by Ruby;
          // avoids double-free segfaults on exit on GTK
          %apply SWIGTYPE *DISOWN { wxWindow* page };
          
          // Avoid premature deletion of ImageList providing icons for notebook
          // tabs; wxRuby takes ownership when the ImageList is assigned,
          // wxWidgets will delete the ImageList with the Toolbook.
          %apply SWIGTYPE *DISOWN { wxImageList* };
          __HEREDOC
        case spec.module_name
        when 'wxBookCtrlBase'
          spec.fold_bases('wxBookCtrlBase' => 'wxWithImages')
          spec.ignore_bases('wxBookCtrlBase' => 'wxWithImages')
          spec.ignore('wxWithImages::@57', 'wxWithImages::SetImageList')
          spec.rename('SetImageList' => 'wxBookCtrlBase::AssignImageList')
          spec.no_proxy('wxBookCtrlBase')
        when 'wxNotebook'
          setup_book_ctrl_class(spec.module_name)
        end
      end
      
      def setup_book_ctrl_class(clsnm)
        spec.ignore_bases('wxBookCtrlBase' => 'wxWithImages')
        # This version in Wx doesn't automatically delete
        spec.ignore "#{clsnm}::SetImageList"
        # Use the version that deletes the ImageList when the Toolbook is destroyed
        spec.rename('SetImageList' => "#{clsnm}::AssignImageList")
        # Users should handle page changes with events, not virtual methods
        spec.ignore("#{clsnm}::OnSelChange")
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
          ])
      end
    end # class Object

  end # class Director

end # module WXRuby3
