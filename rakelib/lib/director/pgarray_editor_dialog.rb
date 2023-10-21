# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
        spec.rename_for_ruby 'elb_' => 'wxPGArrayEditorDialog::m_elb',
                             'elb_sub_panel_' => 'wxPGArrayEditorDialog::m_elbSubPanel',
                             'last_focused_' => 'wxPGArrayEditorDialog::m_lastFocused',
                             'item_pending_at_index_' => 'wxPGArrayEditorDialog::m_itemPendingAtIndex',
                             'modified_' => 'wxPGArrayEditorDialog::m_modified',
                             'has_custom_new_action_' => 'wxPGArrayEditorDialog::m_hasCustomNewAction'
        spec.extend_interface 'wxPGArrayStringEditorDialog',
                              'wxEditableListBox *m_elb',
                              'wxWindow *m_elbSubPanel',
                              'wxWindow *m_lastFocused',
                              'int m_itemPendingAtIndex',
                              'bool m_modified',
                              'bool m_hasCustomNewAction',
                              visibility: 'protected'
        spec.rename_for_ruby 'elb_' => 'wxPGArrayStringEditorDialog::m_elb',
                             'elb_sub_panel_' => 'wxPGArrayStringEditorDialog::m_elbSubPanel',
                             'last_focused_' => 'wxPGArrayStringEditorDialog::m_lastFocused',
                             'item_pending_at_index_' => 'wxPGArrayStringEditorDialog::m_itemPendingAtIndex',
                             'modified_' => 'wxPGArrayStringEditorDialog::m_modified',
                             'has_custom_new_action_' => 'wxPGArrayStringEditorDialog::m_hasCustomNewAction'
        spec.suppress_warning(473, 'wxPGArrayEditorDialog::GetTextCtrlValidator')
        # make sure SWIG knows this type is an enum
        spec.add_swig_code 'enum wxPGPropertyFlags;'
      end
    end # class PGArrayEditorDialog

  end # class Director

end # module WXRuby3
