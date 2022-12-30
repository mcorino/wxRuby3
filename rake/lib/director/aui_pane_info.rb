###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class AuiPaneInfo < Director

      def setup
        spec.disable_proxies
        spec.gc_as_temporary
        spec.regard %w[
          wxAuiPaneInfo::name
          wxAuiPaneInfo::caption
          wxAuiPaneInfo::icon
          wxAuiPaneInfo::window
          wxAuiPaneInfo::frame
          wxAuiPaneInfo::state
          wxAuiPaneInfo::dock_direction
          wxAuiPaneInfo::dock_layer
          wxAuiPaneInfo::dock_row
          wxAuiPaneInfo::dock_pos
          wxAuiPaneInfo::best_size
          wxAuiPaneInfo::min_size
          wxAuiPaneInfo::max_size
          wxAuiPaneInfo::floating_pos
          wxAuiPaneInfo::floating_size
          wxAuiPaneInfo::dock_proportion
          wxAuiPaneInfo::rect
                    ]
        spec.ignore %w[
          wxAuiPaneInfo::Name
          wxAuiPaneInfo::Caption
          wxAuiPaneInfo::Icon
          wxAuiPaneInfo::Window
          wxAuiPaneInfo::State
          wxAuiPaneInfo::Direction
          wxAuiPaneInfo::Layer
          wxAuiPaneInfo::Row
          wxAuiPaneInfo::Position
          wxAuiPaneInfo::BestSize
          wxAuiPaneInfo::MinSize
          wxAuiPaneInfo::MaxSize
          wxAuiPaneInfo::FloatingPosition
          wxAuiPaneInfo::FloatingSize
          ]
        spec.rename_for_ruby(
          'direction' => 'wxAuiPaneInfo::dock_direction',
          'layer' => 'wxAuiPaneInfo::dock_layer',
          'row' => 'wxAuiPaneInfo::dock_row',
          'position' => 'wxAuiPaneInfo::dock_pos',
          'floating_position' => 'wxAuiPaneInfo::floating_pos',
          'proportion' => 'wxAuiPaneInfo::dock_proportion',
          'floatable=' => 'wxAuiPaneInfo::Floatable',
          'bottom_dockable=' => 'wxAuiPaneInfo::BottomDockable',
          'caption_visible=' => 'wxAuiPaneInfo::CaptionVisible',
          'close_button=' => 'wxAuiPaneInfo::CloseButton',
          'destroy_on_close=' => 'wxAuiPaneInfo::DestroyOnClose',
          'dock_fixed=' => 'wxAuiPaneInfo::DockFixed',
          'minimize_button=' => 'wxAuiPaneInfo::MinimizeButton',
          'maximize_button=' => 'wxAuiPaneInfo::MaximizeButton',
          'left_dockable=' => 'wxAuiPaneInfo::LeftDockable',
          'gripper_top=' => 'wxAuiPaneInfo::GripperTop',
          'gripper=' => 'wxAuiPaneInfo::Gripper',
          'movable=' => 'wxAuiPaneInfo::Movable',
          'pane_border=' => 'wxAuiPaneInfo::PaneBorder',
          'pin_button=' => 'wxAuiPaneInfo::PinButton',
          'resizable=' => 'wxAuiPaneInfo::Resizable',
          'right_dockable=' => 'wxAuiPaneInfo::RightDockable',
          'show=' => 'wxAuiPaneInfo::Show',
          'top_dockable=' => 'wxAuiPaneInfo::TopDockable'
        )
        super
      end
    end # class AuiPaneInfo

  end # class Director

end # module WXRuby3
