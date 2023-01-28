###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './dialog'

module WXRuby3

  class Director

    class PGArrayEditorDialog < Dialog

      def setup
        spec.items << 'wxPGArrayStringEditorDialog'
        super
        # SWIG does not handle protected member variables so we declare a
        # custom derived class which provides public access and insert that
        # as the actual instantiated class and than extend the wrapped interface with
        # public accessors
        spec.add_header_code <<~__HEREDOC
          class WXRB_PGArrayEditorDialog : public wxPGArrayEditorDialog
          {
          public:
            wxEditableListBox * get_m_elb () { return m_elb; }
            wxWindow * get_m_elbSubPanel () { return m_elbSubPanel; }
            wxWindow * get_m_lastFocused () { return m_lastFocused; }
            int get_m_itemPendingAtIndex () { return m_itemPendingAtIndex; }
            bool get_m_modified () { return m_modified; }
            bool get_m_hasCustomNewAction () { return m_hasCustomNewAction; }
            void set_m_elb (wxEditableListBox * elb) { m_elb = elb; }
            void set_m_elbSubPanel (wxWindow * esp) { m_elbSubPanel = esp; }
            void set_m_lastFocused (wxWindow * lfw) { m_lastFocused = lfw; }
            void set_m_itemPendingAtIndex (int i) { m_itemPendingAtIndex = i; }
            void set_m_modified (bool f) { m_modified = f; }
            void set_m_hasCustomNewAction (bool f) { m_hasCustomNewAction = f; }
          };
          __HEREDOC
        spec.use_class_implementation 'wxPGArrayEditorDialog', 'WXRB_PGArrayEditorDialog'
        spec.regard 'wxPGArrayEditorDialog::ArrayGet',
                    'wxPGArrayEditorDialog::ArrayGetCount',
                    'wxPGArrayEditorDialog::ArrayInsert',
                    'wxPGArrayEditorDialog::ArraySet',
                    'wxPGArrayEditorDialog::ArrayRemoveAt',
                    'wxPGArrayEditorDialog::ArraySwap',
                    'wxPGArrayEditorDialog::OnCustomNewAction'
        # add public extensions which we will make protected in Ruby code part of library
        spec.add_extend_code 'wxPGArrayEditorDialog', <<~__HEREDOC
          wxEditableListBox* get_elb ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_elb();
          }
          wxWindow* get_elb_sub_panel ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_elbSubPanel();
          }
          wxWindow* get_last_focused ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_lastFocused();
          }
          int get_item_pending_at_index ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_itemPendingAtIndex();
          }
          bool get_modified ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_modified();
          }
          bool get_has_custom_new_action ()
          {
            return ((WXRB_PGArrayEditorDialog*)self)->get_m_hasCustomNewAction();
          }
          void set_elb (wxEditableListBox* elb)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_elb(elb);
          }
          void set_elb_sub_panel (wxWindow* w)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_elbSubPanel(w);
          }
          void set_last_focused (wxWindow* w)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_lastFocused(w);
          }
          void set_item_pending_at_index (int i)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_itemPendingAtIndex(i);
          }
          void set_modified (bool f)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_modified(f);
          }
          void set_has_custom_new_action (bool f)
          {
            ((WXRB_PGArrayEditorDialog*)self)->set_m_hasCustomNewAction(f);
          }
          __HEREDOC
        spec.suppress_warning(473, 'wxPGArrayEditorDialog::GetTextCtrlValidator')
      end
    end # class PGArrayEditorDialog

  end # class Director

end # module WXRuby3
