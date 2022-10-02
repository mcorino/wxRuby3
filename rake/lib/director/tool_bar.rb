#--------------------------------------------------------------------
# @file    tool_bar.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

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
        spec.rename('ToolBarTool' => 'wxToolBarToolBase')
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
      end
    end # class Object

  end # class Director

end # module WXRuby3
