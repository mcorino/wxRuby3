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
        spec.regard 'wxPGArrayEditorDialog::ArrayGet',
                    'wxPGArrayEditorDialog::ArrayGetCount',
                    'wxPGArrayEditorDialog::ArrayInsert',
                    'wxPGArrayEditorDialog::ArraySet',
                    'wxPGArrayEditorDialog::ArrayRemoveAt',
                    'wxPGArrayEditorDialog::ArraySwap',
                    'wxPGArrayEditorDialog::OnCustomNewAction',
                    'wxPGArrayEditorDialog::m_elb',
                    'wxPGArrayEditorDialog::m_elbSubPanel',
                    'wxPGArrayEditorDialog::m_lastFocused',
                    'wxPGArrayEditorDialog::m_itemPendingAtIndex',
                    'wxPGArrayEditorDialog::m_modified',
                    'wxPGArrayEditorDialog::m_hasCustomNewAction'
        spec.rename_for_ruby 'elb' => 'wxPGArrayEditorDialog::m_elb',
                             'elb_sub_panel' => 'wxPGArrayEditorDialog::m_elbSubPanel',
                             'last_focused' => 'wxPGArrayEditorDialog::m_lastFocused',
                             'item_pending_at_index' => 'wxPGArrayEditorDialog::m_itemPendingAtIndex',
                             'modified' => 'wxPGArrayEditorDialog::m_modified',
                             'has_custom_new_action' => 'wxPGArrayEditorDialog::m_hasCustomNewAction'
        spec.extend_interface 'wxPGArrayStringEditorDialog',
                              'wxEditableListBox *m_elb',
                              'wxWindow *m_elbSubPanel',
                              'wxWindow *m_lastFocused',
                              'int m_itemPendingAtIndex',
                              'bool m_modified',
                              'bool m_hasCustomNewAction',
                              visibility: 'protected'
        spec.rename_for_ruby 'elb' => 'wxPGArrayStringEditorDialog::m_elb',
                             'elb_sub_panel' => 'wxPGArrayStringEditorDialog::m_elbSubPanel',
                             'last_focused' => 'wxPGArrayStringEditorDialog::m_lastFocused',
                             'item_pending_at_index' => 'wxPGArrayStringEditorDialog::m_itemPendingAtIndex',
                             'modified' => 'wxPGArrayStringEditorDialog::m_modified',
                             'has_custom_new_action' => 'wxPGArrayStringEditorDialog::m_hasCustomNewAction'
        spec.suppress_warning(473, 'wxPGArrayEditorDialog::GetTextCtrlValidator')
      end
    end # class PGArrayEditorDialog

  end # class Director

end # module WXRuby3
