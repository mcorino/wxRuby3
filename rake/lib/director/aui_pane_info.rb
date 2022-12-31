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
        spec.make_readonly %w[
          wxAuiPaneInfo::rect
          wxAuiPaneInfo::icon
          wxAuiPaneInfo::window
          wxAuiPaneInfo::frame
          wxAuiPaneInfo::state
          wxAuiPaneInfo::best_size
          wxAuiPaneInfo::min_size
          wxAuiPaneInfo::max_size
          wxAuiPaneInfo::floating_pos
          wxAuiPaneInfo::floating_size
          ]
        spec.ignore %w[
          wxAuiPaneInfo::Name
          wxAuiPaneInfo::Caption
          wxAuiPaneInfo::Direction
          wxAuiPaneInfo::Layer
          wxAuiPaneInfo::Row
          wxAuiPaneInfo::Position
          ]
        spec.ignore 'wxAuiPaneInfo::BestSize(int,int)',
                    'wxAuiPaneInfo::MinSize(int,int)',
                    'wxAuiPaneInfo::MaxSize(int,int)',
                    'wxAuiPaneInfo::FloatingPosition(int,int)',
                    'wxAuiPaneInfo::FloatingSize(int,int)'
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
          'top_dockable=' => 'wxAuiPaneInfo::TopDockable',
          'window=' => 'wxAuiPaneInfo::Window',
          'icon=' => 'wxAuiPaneInfo::Icon',
          'best_size=' => 'wxAuiPaneInfo::BestSize',
          'min_size=' => 'wxAuiPaneInfo::MinSize',
          'max_size=' => 'wxAuiPaneInfo::MaxSize',
          'floating_position=' => 'wxAuiPaneInfo::FloatingPosition',
          'floating_size=' => 'wxAuiPaneInfo::FloatingSize'
        )
        super
      end
    end # class AuiPaneInfo

  end # class Director

end # module WXRuby3
