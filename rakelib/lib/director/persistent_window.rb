# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PersistentWindow < Director

      def setup
        spec.items << 'wxPersistentTLW' << 'wxPersistentBookCtrl' << 'wxPersistentTreeBookCtrl'
        if Config.instance.wx_version_check('3.2.4') > 0
          # only after 3.2.4 properly available
          spec.items << 'wxPersistentComboBox'
        end
        if Config.instance.wx_version_check('3.3.0') > 0
          # only after 3.3.0 available
          spec.items << 'wxPersistentCheckBox' << 'wxPersistentRadioButton'
        end
        super
        spec.gc_as_marked
        spec.use_template_as_class('wxPersistentWindow', 'wxPersistentWindowBase')
        spec.override_inheritance_chain('wxPersistentWindow', %w[wxPersistentObject])
        spec.ignore 'wxPersistentWindow::wxPersistentWindow',
                    'wxPersistentWindow::Get',
                    ignore_doc: false
        # make ctor protected because of pure virt methods
        spec.extend_interface 'wxPersistentWindow',
                              'wxPersistentWindowBase(wxWindow *win)',
                              visibility: 'protected'
        spec.add_header_code 'typedef wxWindow WindowType;'
        spec.add_swig_code 'typedef wxWindow WindowType;'
        spec.map 'WindowType *' => 'Wx::Window', swig: false do
          map_in code: ''
          map_out code: ''
        end
        spec.add_extend_code 'wxPersistentWindowBase', <<~__HEREDOC
          wxWindow * GetObject()
          {
            return reinterpret_cast<wxWindow*> ($self->GetObject());
          }
        __HEREDOC
        # wxPersistentTLW
        spec.override_inheritance_chain('wxPersistentTLW', [{ 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
        # add method override missing from docs
        spec.extend_interface 'wxPersistentTLW',
                              'virtual wxString GetKind() const override'
        # wxPersistentBookCtrl
        spec.override_inheritance_chain('wxPersistentBookCtrl', [{ 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
        # add method override missing from docs
        spec.extend_interface 'wxPersistentBookCtrl',
                              'virtual wxString GetKind() const override'
        # wxPersistentTreeBookCtrl
        spec.override_inheritance_chain('wxPersistentTreeBookCtrl', ['wxPersistentBookCtrl', { 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
        # add method override missing from docs
        spec.extend_interface 'wxPersistentTreeBookCtrl',
                              'virtual wxString GetKind() const override'
        spec.do_not_generate :functions, :defines, :typedefs, :variables, :enums
        if Config.instance.wx_version_check('3.0.0') >= 0
          # wxPersistentComboBox
          spec.override_inheritance_chain('wxPersistentComboBox', [{ 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
          # add method override missing from docs
          spec.extend_interface 'wxPersistentComboBox',
                                'virtual wxString GetKind() const override'
        end
        if Config.instance.wx_version_check('3.3.0') > 0
          # wxPersistentCheckBox
          spec.override_inheritance_chain('wxPersistentCheckBox', [{ 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
          # add method override missing from docs
          spec.extend_interface 'wxPersistentCheckBox',
                                'virtual wxString GetKind() const override'
          # wxPersistentRadioButton
          spec.override_inheritance_chain('wxPersistentRadioButton', [{ 'wxPersistentWindowBase' => 'wxPersistentWindow' }, 'wxPersistentObject'])
          # add method override missing from docs
          spec.extend_interface 'wxPersistentRadioButton',
                                'virtual wxString GetKind() const override'
        end
      end

    end

  end

end
