# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class ToolBar < Window

      def setup
        spec.items << 'wxToolBarToolBase'
        super
        # This class is an 'opaque handle' so these methods don't actually
        # work to change the state; therefore hide them.
        spec.ignore %w[
          wxToolBarToolBase::Enable
          wxToolBarToolBase::Toggle
          wxToolBarToolBase::SetToggle
          wxToolBarToolBase::SetShortHelp
          wxToolBarToolBase::SetLongHelp
          wxToolBarToolBase::SetNormalBitmap
          wxToolBarToolBase::SetDisabledBitmap
          wxToolBarToolBase::SetLabel
          wxToolBarToolBase::SetClientData
          wxToolBarToolBase::Detach
          wxToolBarToolBase::Attach
          ]
        spec.no_proxy 'wxToolBarToolBase'
        # more sensible name to use
        spec.rename_for_ruby('ToolBarTool' => 'wxToolBarToolBase')
        spec.map 'wxToolBarBase *' => 'Wx::ToolBar' do
          map_in code: <<~__CODE
            void *argp = 0;
            int res = SWIG_ConvertPtr($input, &argp, SWIGTYPE_p_wxToolBar, 0);
            if (!SWIG_IsOK(res)) {
              SWIG_exception_fail(SWIG_ArgError(res), Ruby_Format_TypeError( "", "Wx::ToolBar", "$symname", 1, $input)); 
            }
            $1 = reinterpret_cast< wxToolBarBase * >(argp);
            __CODE
          map_typecheck code: <<~__CODE
            void *vptr = 0;
            int res = SWIG_ConvertPtr($input, &vptr, SWIGTYPE_p_wxToolBar, 0);
            $1 = SWIG_CheckState(res);
            __CODE
          map_out code: '$result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxToolBar, 0);'
        end
        # Ensure that the C++ wxToolBar(Base) implementation of UpdateWindowUI
        # is called internally, so that UpdateUIEvents are also sent to each
        # button within the toolbar. This means update_window_ui can't be
        # overridden for this class in Ruby, but unlikely a real problem.
        spec.no_proxy 'wxToolBar::UpdateWindowUI'
        # problematic (and probably not very useful to overload)
        spec.no_proxy %w[
          wxToolBar::AddControl
          wxToolBar::AddSeparator
          wxToolBar::FindControl
          wxToolBar::FindToolForPosition
          wxToolBar::GetToolClientData
          wxToolBar::InsertControl
          wxToolBar::InsertSeparator
          wxToolBar::RemoveTool
          wxToolBar::CreateTool
          ]
        # These don't work as you would think...
        spec.ignore [
          'wxToolBar::AddTool(wxToolBarToolBase *)',
          'wxToolBar::InsertTool(size_t,wxToolBarToolBase *)'
          ]
        if Config.instance.features_set?('WXOSX')
          spec.extend_interface('wxToolBar',
                                'virtual bool Destroy() override')
        end
      end
    end # class Object

  end # class Director

end # module WXRuby3
