###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class AuiPaneInfo < Director

      def setup
        spec.disable_proxies
        spec.gc_as_untracked
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
        spec.make_readonly %w[
          wxAuiPaneInfo::name
          wxAuiPaneInfo::caption
          wxAuiPaneInfo::rect
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
          ]
        spec.ignore 'wxAuiPaneInfo::BestSize(int,int)',
                    'wxAuiPaneInfo::MinSize(int,int)',
                    'wxAuiPaneInfo::MaxSize(int,int)',
                    'wxAuiPaneInfo::FloatingPosition(int,int)',
                    'wxAuiPaneInfo::FloatingSize(int,int)'
        spec.rename_for_ruby(
          'direction' => 'wxAuiPaneInfo::dock_direction',
          'set_direction' => 'wxAuiPaneInfo::Direction',
          'layer' => 'wxAuiPaneInfo::dock_layer',
          'set_layer' => 'wxAuiPaneInfo::Layer',
          'row' => 'wxAuiPaneInfo::dock_row',
          'set_row' => 'wxAuiPaneInfo::Row',
          'position' => 'wxAuiPaneInfo::dock_pos',
          'set_position' => 'wxAuiPaneInfo::Position',
          'floating_position' => 'wxAuiPaneInfo::floating_pos',
          'proportion' => 'wxAuiPaneInfo::dock_proportion',
          'set_name' => 'wxAuiPaneInfo::Name',
          'set_caption' => 'wxAuiPaneInfo::Caption',
          'set_floatable' => 'wxAuiPaneInfo::Floatable',
          'set_bottom_dockable' => 'wxAuiPaneInfo::BottomDockable',
          'set_caption_visible' => 'wxAuiPaneInfo::CaptionVisible',
          'set_close_button' => 'wxAuiPaneInfo::CloseButton',
          'set_destroy_on_close' => 'wxAuiPaneInfo::DestroyOnClose',
          'set_dock_fixed' => 'wxAuiPaneInfo::DockFixed',
          'set_minimize_button' => 'wxAuiPaneInfo::MinimizeButton',
          'set_maximize_button' => 'wxAuiPaneInfo::MaximizeButton',
          'set_dockable' => 'wxAuiPaneInfo::Dockable',
          'set_left_dockable' => 'wxAuiPaneInfo::LeftDockable',
          'set_gripper_top' => 'wxAuiPaneInfo::GripperTop',
          'set_gripper' => 'wxAuiPaneInfo::Gripper',
          'set_movable' => 'wxAuiPaneInfo::Movable',
          'set_pane_border' => 'wxAuiPaneInfo::PaneBorder',
          'set_pin_button' => 'wxAuiPaneInfo::PinButton',
          'set_resizable' => 'wxAuiPaneInfo::Resizable',
          'set_right_dockable' => 'wxAuiPaneInfo::RightDockable',
          'set_top_dockable' => 'wxAuiPaneInfo::TopDockable',
          'set_window'=> 'wxAuiPaneInfo::Window',
          'set_icon' => 'wxAuiPaneInfo::Icon',
          'set_best_size' => 'wxAuiPaneInfo::BestSize',
          'set_min_size' => 'wxAuiPaneInfo::MinSize',
          'set_max_size' => 'wxAuiPaneInfo::MaxSize',
          'set_floating_position' => 'wxAuiPaneInfo::FloatingPosition',
          'set_floating_size' => 'wxAuiPaneInfo::FloatingSize'
        )
        super
      end
    end # class AuiPaneInfo

  end # class Director

end # module WXRuby3
