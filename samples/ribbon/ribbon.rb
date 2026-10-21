# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby Ribbon sample
###

require 'wx'

module Ribbon

  class MyFrame < Wx::Frame

    module ID
      %i[
        CIRCLE
        CROSS
        TRIANGLE
        SQUARE
        POLYGON
        SELECTION_EXPAND_H
        SELECTION_EXPAND_V
        SELECTION_CONTRACT
        BUTTON_XX
        BUTTON_XY
        PRIMARY_COLOUR
        SECONDARY_COLOUR
        DEFAULT_PROVIDER
        AUI_PROVIDER
        MSW_PROVIDER
        MAIN_TOOLBAR
        POSITION_TOP
        POSITION_TOP_ICONS
        POSITION_TOP_BOTH
        POSITION_LEFT
        POSITION_LEFT_LABELS
        POSITION_LEFT_BOTH
        TOGGLE_PANELS
        ENABLE
        DISABLE
        DISABLED
        UI_ENABLE_UPDATED
        CHECK
        UI_CHECK_UPDATED
        CHANGE_TEXT1
        CHANGE_TEXT2
        UI_CHANGE_TEXT_UPDATED
        REMOVE_PAGE
        HIDE_PAGES
        SHOW_PAGES
        PLUS_MINUS
        CHANGE_LABEL
        SMALL_BUTTON_1
        SMALL_BUTTON_2
        SMALL_BUTTON_3
        SMALL_BUTTON_4
        SMALL_BUTTON_5
        SMALL_BUTTON_6
        BACKSTAGE_INFO
        BACKSTAGE_NEW
        BACKSTAGE_OPEN
        BACKSTAGE_SAVE
        BACKSTAGE_SAVE_AS
        BACKSTAGE_EXIT
        BACKSTAGE_DISCARD
        BACKSTAGE_PROTECT
        BACKSTAGE_TEMPLATE_BLANK
        BACKSTAGE_TEMPLATE_RIBBON
        BACKSTAGE_TEMPLATE_COLOURS
        BACKSTAGE_RECENT_LIST
        BACKSTAGE_FOLDER_LIST
      ].each_with_index { |sym, ix| self.const_set(sym, Wx::ID_HIGHEST+1+ix) }
    end

    # embedded SVG icons
    RibbonSvg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>" \
      "<rect x='2' y='4' width='28' height='8' rx='2' fill='#4488CC'/>" \
      "<rect x='2' y='12' width='28' height='16' rx='1' fill='#E0E8F0' stroke='#4488CC'" \
      " stroke-width='0.5'/>" \
      "<rect x='4' y='14' width='8' height='4' rx='1' fill='#4488CC' opacity='0.6'/>" \
      "<rect x='14' y='14' width='8' height='4' rx='1' fill='#4488CC' opacity='0.6'/>" \
      "<rect x='4' y='20' width='6' height='4' rx='1' fill='#4488CC' opacity='0.4'/>" \
      "<rect x='12' y='20' width='6' height='4' rx='1' fill='#4488CC' opacity='0.4'/>" \
      "<rect x='20' y='20' width='6' height='4' rx='1' fill='#4488CC' opacity='0.4'/>" \
      "</svg>"

    EyeSvg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>" \
      "<path d='M16 8C8 8 2 16 2 16s6 8 14 8 14-8 14-8-6-8-14-8z' fill='none' stroke='#555'" \
      " stroke-width='2'/>" \
      "<circle cx='16' cy='16' r='5' fill='#4488CC'/>" \
      "<circle cx='16' cy='16' r='2' fill='#222'/>" \
      "</svg>"

    EmptySvg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>" \
      "<rect x='6' y='2' width='20' height='28' rx='2' fill='#F8F8F8' stroke='#999'" \
      " stroke-width='1'/>" \
      "<path d='M10 8h12M10 13h12M10 18h8' stroke='#DDD' stroke-width='1'/>" \
      "</svg>"

    ColoursSvg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>" \
      "<circle cx='12' cy='10' r='6' fill='#FF4444' opacity='0.8'/>" \
      "<circle cx='20' cy='10' r='6' fill='#44CC44' opacity='0.8'/>" \
      "<circle cx='16' cy='18' r='6' fill='#4444FF' opacity='0.8'/>" \
      "</svg>"

    PdfSvg = %q{<svg xmlns="http://www.w3.org/2000/svg" width="75.320129mm" height="92.604164mm" viewBox="0 0 75.320129 92.604164">
      <g transform="translate(53.548057 -183.975276) scale(1.4843)">
      <path fill="#ff2116" d="M-29.632812 123.94727c-3.551967 0-6.44336 2.89347-6.44336 6.44531v49.49804c0 3.55185 2.891393 6.44532 6.44336 6.44532H8.2167969c3.5519661 0 6.4433591-2.89335 6.4433591-6.44532v-40.70117s.101353-1.19181-.416015-2.35156c-.484969-1.08711-1.275391-1.84375-1.275391-1.84375a1.0584391 1.0584391 0 0 0-.0059-.008l-9.3906254-9.21094a1.0584391 1.0584391 0 0 0-.015625-.0156s-.8017392-.76344-1.9902344-1.27344c-1.39939552-.6005-2.8417968-.53711-2.8417968-.53711l.021484-.002z" color="#000" font-family="sans-serif" overflow="visible" paint-order="markers fill stroke" style="line-height:normal;font-variant-ligatures:normal;font-variant-position:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-alternates:normal;font-feature-settings:normal;text-indent:0;text-align:start;text-decoration-line:none;text-decoration-style:solid;text-decoration-color:#000000;text-transform:none;text-orientation:mixed;white-space:normal;shape-padding:0;isolation:auto;mix-blend-mode:normal;solid-color:#000000;solid-opacity:1"/>
      <path fill="#f5f5f5" d="M-29.632812 126.06445h28.3789058a1.0584391 1.0584391 0 0 0 .021484 0s1.13480448.011 1.96484378.36719c.79889772.34282 1.36536982.86176 1.36914062.86524.0000125.00001.00391.004.00391.004l9.3671868 9.18945s.564354.59582.837891 1.20899c.220779.49491.234375 1.40039.234375 1.40039a1.0584391 1.0584391 0 0 0-.002.0449v40.74609c0 2.41592-1.910258 4.32813-4.3261717 4.32813H-29.632812c-2.415914 0-4.326172-1.91209-4.326172-4.32813v-49.49804c0-2.41603 1.910258-4.32813 4.326172-4.32813z" color="#000" font-family="sans-serif" overflow="visible" paint-order="markers fill stroke" style="line-height:normal;font-variant-ligatures:normal;font-variant-position:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-alternates:normal;font-feature-settings:normal;text-indent:0;text-align:start;text-decoration-line:none;text-decoration-style:solid;text-decoration-color:#000000;text-transform:none;text-orientation:mixed;white-space:normal;shape-padding:0;isolation:auto;mix-blend-mode:normal;solid-color:#000000;solid-opacity:1"/>
      <path fill="#ff2116" d="M-23.40766 161.09299c-1.45669-1.45669.11934-3.45839 4.39648-5.58397l2.69124-1.33743 1.04845-2.29399c.57665-1.26169 1.43729-3.32036 1.91254-4.5748l.8641-2.28082-.59546-1.68793c-.73217-2.07547-.99326-5.19438-.52872-6.31588.62923-1.51909 2.69029-1.36323 3.50626.26515.63727 1.27176.57212 3.57488-.18329 6.47946l-.6193 2.38125.5455.92604c.30003.50932 1.1764 1.71867 1.9475 2.68743l1.44924 1.80272 1.8033728-.23533c5.72900399-.74758 7.6912472.523 7.6912472 2.34476 0 2.29921-4.4984914 2.48899-8.2760865-.16423-.8499666-.59698-1.4336605-1.19001-1.4336605-1.19001s-2.3665326.48178-3.531704.79583c-1.202707.32417-1.80274.52719-3.564509 1.12186 0 0-.61814.89767-1.02094 1.55026-1.49858 2.4279-3.24833 4.43998-4.49793 5.1723-1.3991.81993-2.86584.87582-3.60433.13733zm2.28605-.81668c.81883-.50607 2.47616-2.46625 3.62341-4.28553l.46449-.73658-2.11497 1.06339c-3.26655 1.64239-4.76093 3.19033-3.98386 4.12664.43653.52598.95874.48237 2.01093-.16792zm21.21809-5.95578c.80089-.56097.68463-1.69142-.22082-2.1472-.70466-.35471-1.2726074-.42759-3.1031574-.40057-1.1249.0767-2.9337647.3034-3.2403347.37237 0 0 .993716.68678 1.434896.93922.58731.33544 2.0145161.95811 3.0565161 1.27706 1.02785.31461 1.6224.28144 2.0729-.0409zm-8.53152-3.54594c-.4847-.50952-1.30889-1.57296-1.83152-2.3632-.68353-.89643-1.02629-1.52887-1.02629-1.52887s-.4996 1.60694-.90948 2.57394l-1.27876 3.16076-.37075.71695s1.971043-.64627 2.97389-.90822c1.0621668-.27744 3.21787-.70134 3.21787-.70134zm-2.74938-11.02573c.12363-1.0375.1761-2.07346-.15724-2.59587-.9246-1.01077-2.04057-.16787-1.85154 2.23517.0636.8084.26443 2.19033.53292 3.04209l.48817 1.54863.34358-1.16638c.18897-.64151.47882-2.02015.64411-3.06364z"/>
      <path fill="#2c2c2c" d="M-20.930423 167.83862h2.364986q1.133514 0 1.840213.2169.706698.20991 1.189489.9446.482795.72769.482795 1.75625 0 .94459-.391832 1.6233-.391833.67871-1.056548.97958-.65772.30087-2.02913.30087h-.818651v3.72941h-1.581322zm1.581322 1.22447v3.33058h.783664q1.049552 0 1.44838-.39184.405826-.39183.405826-1.27345 0-.65772-.265887-1.06355-.265884-.41282-.587747-.50378-.314866-.098-1.000572-.098zm5.50664-1.22447h2.148082q1.560333 0 2.4909318.55276.9375993.55276 1.4133973 1.6443.482791 1.09153.482791 2.42096 0 1.3994-.4338151 2.49793-.4268149 1.09153-1.3154348 1.76324-.8816233.67172-2.5189212.67172h-2.267031zm1.581326 1.26645v7.018h.657715q1.378411 0 2.001144-.9516.6227329-.95858.6227329-2.5539 0-3.5125-2.6238769-3.5125zm6.4722254-1.26645h5.30372941v1.26645H-4.2075842v2.85478h2.9807225v1.26646h-2.9807225v4.16322h-1.5813254z" font-family="Franklin Gothic Medium Cond" letter-spacing="0" style="line-height:125%;-inkscape-font-specification:'Franklin Gothic Medium Cond'" word-spacing="4.26000023"/>
      </g>
      </svg>}

    OdsSvg = %q{<svg fill="#000000" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 550.801 550.801" xml:space="preserve"><g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <g>
        <path d="M488.426,197.021H475.2v-63.825c0-0.398-0.063-0.799-0.116-1.203c-0.021-2.533-0.827-5.022-2.562-6.995L366.325,3.694 c-0.032-0.031-0.063-0.042-0.085-0.074c-0.633-0.709-1.371-1.297-2.151-1.803c-0.231-0.158-0.464-0.288-0.706-0.422 c-0.676-0.369-1.393-0.675-2.131-0.896c-0.2-0.056-0.38-0.138-0.58-0.19C359.87,0.119,359.037,0,358.193,0H97.2 c-11.918,0-21.6,9.695-21.6,21.601v175.413H62.377c-17.049,0-30.873,13.818-30.873,30.873v160.545 c0,17.043,13.824,30.87,30.873,30.87h13.224V529.2c0,11.907,9.682,21.601,21.6,21.601h356.4c11.907,0,21.6-9.693,21.6-21.601 V419.302h13.226c17.044,0,30.871-13.827,30.871-30.87v-160.54C519.297,210.832,505.47,197.021,488.426,197.021z M97.2,21.601 h250.193v110.513c0,5.967,4.841,10.8,10.8,10.8h95.407v54.108H97.2V21.601z M358.773,297.496c0,27.791-10.125,46.955-24.131,58.81 c-15.304,12.72-38.555,18.736-67.002,18.736c-17.004,0-29.072-1.07-37.26-2.146V230.283c12.058-1.938,27.789-3.029,44.376-3.029 c27.58,0,45.457,4.946,59.453,15.504C349.292,253.975,358.773,271.838,358.773,297.496z M69.225,302.01 c0-43.516,27.789-76.04,70.659-76.04c44.587,0,68.929,33.394,68.929,73.451c0,47.614-28.861,76.486-71.307,76.486 C94.427,375.907,69.225,343.364,69.225,302.01z M453.601,523.347H97.2V419.302h356.4V523.347z M415.885,375.706 c-16.58,0-32.964-4.329-41.144-8.854l6.666-27.143c8.849,4.535,22.412,9.049,36.407,9.049c15.088,0,23.066-6.238,23.066-15.72 c0-9.055-6.897-14.223-24.353-20.461c-24.121-8.4-39.856-21.758-39.856-42.873c0-24.777,20.682-43.73,54.938-43.73 c16.368,0,28.435,3.438,37.051,7.317l-7.319,26.491c-5.822-2.795-16.158-6.885-30.386-6.885c-14.217,0-21.114,6.465-21.114,14.02 c0,9.252,8.2,13.345,26.947,20.453c25.629,9.471,37.688,22.834,37.688,43.306C474.478,355.003,455.741,375.706,415.885,375.706z"></path>
        <path d="M278.198,252.474c-7.322,0-12.063,0.63-14.866,1.284v94.996c2.803,0.654,7.333,0.654,11.42,0.654 c29.736,0.221,49.122-16.158,49.122-50.847C324.096,268.408,306.424,252.474,278.198,252.474z"></path>
        <path d="M174.135,300.513c0-26.067-12.49-48.481-35.121-48.481c-22.188,0-35.111,21.112-35.111,49.336 c0,28.439,13.36,48.468,35.327,48.468C161.418,349.835,174.135,328.726,174.135,300.513z"></path> </g>
      </g>
      </svg>}

    TxtSvg = %q{<svg fill="#000000" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 548.291 548.291" xml:space="preserve"><g id="SVGRepo_bgCarrier" stroke-width="0"></g>
      <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <g>
      <path d="M486.201,196.124h-13.166V132.59c0-0.396-0.062-0.795-0.115-1.196c-0.021-2.523-0.825-5-2.552-6.963L364.657,3.677 c-0.033-0.031-0.064-0.042-0.085-0.075c-0.63-0.704-1.364-1.29-2.143-1.796c-0.229-0.154-0.461-0.283-0.702-0.418 c-0.672-0.366-1.387-0.671-2.121-0.892c-0.2-0.055-0.379-0.134-0.577-0.188C358.23,0.118,357.401,0,356.562,0H96.757 C84.894,0,75.256,9.649,75.256,21.502v174.616H62.09c-16.968,0-30.729,13.753-30.729,30.73v159.812 c0,16.961,13.761,30.731,30.729,30.731h13.166V526.79c0,11.854,9.638,21.501,21.501,21.501h354.776 c11.853,0,21.501-9.647,21.501-21.501V417.392h13.166c16.966,0,30.729-13.764,30.729-30.731V226.854 C516.93,209.872,503.167,196.124,486.201,196.124z M96.757,21.502h249.054v110.006c0,5.943,4.817,10.751,10.751,10.751h94.972 v53.864H96.757V21.502z M202.814,225.042h41.68l14.063,29.3c4.756,9.756,8.336,17.622,12.147,26.676h0.48 c3.798-10.242,6.9-17.392,10.95-26.676l13.587-29.3h41.449l-45.261,78.363l47.638,82.185h-41.927l-14.525-29.06 c-5.956-11.197-9.771-19.528-14.299-28.825h-0.478c-3.334,9.297-7.381,17.628-12.381,28.825l-13.336,29.06h-41.455l46.455-81.224 L202.814,225.042z M66.08,255.532v-30.489h123.382v30.489h-43.828v130.049h-36.434V255.532H66.08z M451.534,520.962H96.757v-103.57 h354.776V520.962z M471.764,255.532h-43.831v130.049h-36.442V255.532h-43.119v-30.489h123.393V255.532z"></path>
      </g> </g>
      </svg>}

    def initialize
      super(nil, Wx::ID_ANY, "wxRibbon Sample Application", size: [800, 600], style: Wx::DEFAULT_FRAME_STYLE)

      self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))

      @panel = Wx::Panel.new(self)

      @colour_data = Wx::ColourData.new
      @ribbon = Wx::RBN::RibbonBar.new(@panel, Wx::ID_ANY,
                                       style: Wx::RBN::RIBBON_BAR_FLOW_HORIZONTAL |
                                         Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS |
                                         Wx::RBN::RIBBON_BAR_SHOW_PANEL_EXT_BUTTONS |
                                         Wx::RBN::RIBBON_BAR_SHOW_TOGGLE_BUTTON |
                                         Wx::RBN::RIBBON_BAR_SHOW_HELP_BUTTON)

      # Reusable bitmap bundles for the generic ribbon and empty-page icons.
      @ribbon_small = make_svg_bundle(RibbonSvg, [16, 16])
      @ribbon_large = make_svg_bundle(RibbonSvg, [32, 32])
      @empty_small = make_svg_bundle(EmptySvg, [16, 16])

      # The File tab shows the backstage.
      file = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, 'File')
      @ribbon.set_backstage_page(file)
      @ribbon.set_page_key_tip(file, 'F')

      home = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Examples", bitmap_(:ribbon_xpm))
      toolbar_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Toolbar",
                                               style: Wx::RBN::RIBBON_PANEL_NO_AUTO_MINIMISE |
                                                 Wx::RBN::RIBBON_PANEL_EXT_BUTTON)
      toolbar = Wx::RBN::RibbonToolBar.new(toolbar_panel, ID::MAIN_TOOLBAR)
      toolbar.add_toggle_tool(Wx::ID_JUSTIFY_LEFT, bitmap_(:align_left_xpm))
      toolbar.add_toggle_tool(Wx::ID_JUSTIFY_CENTER , bitmap_(:align_center_xpm))
      toolbar.add_toggle_tool(Wx::ID_JUSTIFY_RIGHT, bitmap_(:align_right_xpm))
      toolbar.add_separator
      toolbar.add_hybrid_tool(Wx::ID_NEW, Wx::ArtProvider.get_bitmap(Wx::ART_NEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
      toolbar.add_tool(Wx::ID_OPEN, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_OPEN, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Open something")
      toolbar.add_tool(Wx::ID_SAVE, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_SAVE, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Save something")
      toolbar.add_tool(Wx::ID_SAVEAS, Wx::ArtProvider.get_bitmap(Wx::ART_FILE_SAVE_AS, Wx::ART_OTHER, Wx::Size.new(16, 15)), "Save something as ...")
      toolbar.enable_tool(Wx::ID_OPEN, false)
      toolbar.enable_tool(Wx::ID_SAVE, false)
      toolbar.enable_tool(Wx::ID_SAVEAS, false)
      toolbar.add_separator
      toolbar.add_dropdown_tool(Wx::ID_UNDO, Wx::ArtProvider.get_bitmap(Wx::ART_UNDO, Wx::ART_OTHER, Wx::Size.new(16, 15)))
      toolbar.add_dropdown_tool(Wx::ID_REDO, Wx::ArtProvider.get_bitmap(Wx::ART_REDO, Wx::ART_OTHER, Wx::Size.new(16, 15)))
      toolbar.add_separator
      toolbar.add_tool(Wx::ID_ANY, Wx::ArtProvider.get_bitmap(Wx::ART_REPORT_VIEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
      toolbar.add_tool(Wx::ID_ANY, Wx::ArtProvider.get_bitmap(Wx::ART_LIST_VIEW, Wx::ART_OTHER, Wx::Size.new(16, 15)))
      toolbar.add_separator
      toolbar.add_hybrid_tool(ID::POSITION_LEFT, bitmap_(:position_left_xpm),
                             "Align ribbonbar vertically\non the left\nfor demonstration purposes")
      toolbar.add_hybrid_tool(ID::POSITION_TOP, bitmap_(:position_top_xpm),
                             "Align the ribbonbar horizontally\nat the top\nfor demonstration purposes")
      toolbar.add_separator
      prt_tool = toolbar.add_hybrid_tool(Wx::ID_PRINT, Wx::ArtProvider.get_bitmap(Wx::ART_PRINT, Wx::ART_OTHER, Wx::Size.new(16, 15)),
                                         "This is the Print button tooltip\ndemonstrating a tooltip")
      toolbar.set_rows(2, 3)

      if toolbar.tool_count != (toolbar.tool_pos(prt_tool)+1)
        Wx.log_error('Wx::RibbonToolBar::get_tool_count or Wx::RibbonToolBar::get_tool_pos is broken')
      elsif Wx::ID_PRINT != toolbar.tool_by_pos(toolbar.tool_pos(prt_tool))
        Wx.log_error('Wx::RibbonToolBar::get_tool_by_pos is broken')
      end

      selection_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Selection", bitmap_(:selection_panel_xpm))
      selection = Wx::RBN::RibbonButtonBar.new(selection_panel)
      selection.add_button(ID::SELECTION_EXPAND_V, "Expand Vertically", bitmap_(:expand_selection_v_xpm),
                           "This is a tooltip for Expand Vertically\ndemonstrating a tooltip")
      selection.add_button(ID::SELECTION_EXPAND_H, "Expand Horizontally", bitmap_(:expand_selection_h_xpm), '')
      selection.add_button(ID::SELECTION_CONTRACT, "Contract", bitmap_(:auto_crop_selection_xpm), bitmap_(:auto_crop_selection_small_xpm))

      shapes_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Shapes", bitmap_(:circle_small_xpm))
      shapes = Wx::RBN::RibbonButtonBar.new(shapes_panel)
      shapes.add_button(ID::CIRCLE, "Circle", bitmap_(:circle_xpm), bitmap_(:circle_small_xpm),
                        Wx::NULL_BITMAP, Wx::NULL_BITMAP, Wx::RBN::RIBBON_BUTTON_NORMAL,
                        "This is a tooltip for the circle button\ndemonstrating another tooltip")
      shapes.add_button(ID::CROSS, "Cross", bitmap_(:cross_xpm), '')
      shapes.add_hybrid_button(ID::TRIANGLE, "Triangle", bitmap_(:triangle_xpm))
      shapes.add_button(ID::SQUARE, "Square", bitmap_(:square_xpm), '')
      shapes.add_dropdown_button(ID::POLYGON, "Other Polygon", bitmap_(:hexagon_xpm), '')

      sizer_panel = Wx::RBN::RibbonPanel.new(home, Wx::ID_ANY, "Panel with Sizer",
                                             style:  Wx::RBN::RIBBON_PANEL_DEFAULT_STYLE)

      as = ["Item 1 using a box sizer now", "Item 2 using a box sizer now"]
      sizer_panelcombo = Wx::ComboBox.new(sizer_panel, Wx::ID_ANY,
                                          choices: as, style: Wx::CB_READONLY)

      sizer_panelcombo2 = Wx::ComboBox.new(sizer_panel, Wx::ID_ANY,
                                           choices: as, style: Wx::CB_READONLY)

      sizer_panelcombo.select(0)
      sizer_panelcombo2.select(1)
      sizer_panelcombo.set_min_size(Wx::Size.new(150, -1))
      sizer_panelcombo2.set_min_size(Wx::Size.new(150, -1))

      bar = Wx::RBN::RibbonButtonBar.new(sizer_panel, Wx::ID_ANY)
      bar.add_button(ID::BUTTON_XX, "xx", bitmap_(:ribbon_xpm))
      bar.add_button(ID::BUTTON_XY, "xy", bitmap_(:ribbon_xpm))
      # This prevents ribbon buttons in panels with sizer from collapsing.
      bar.set_button_min_size_class(ID::BUTTON_XX, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_LARGE)
      bar.set_button_min_size_class(ID::BUTTON_XY, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_LARGE)

      sizer_panelsizer_h = Wx::BoxSizer.new(Wx::HORIZONTAL)
      sizer_panelsizer_v = Wx::BoxSizer.new(Wx::VERTICAL)
      sizer_panelsizer_v.add_stretch_spacer(1)
      sizer_panelsizer_v.add(sizer_panelcombo, 0, Wx::ALL|Wx::EXPAND, 2)
      sizer_panelsizer_v.add(sizer_panelcombo2, 0, Wx::ALL|Wx::EXPAND, 2)
      sizer_panelsizer_v.add_stretch_spacer(1)
      sizer_panelsizer_h.add(bar, 0, Wx::EXPAND)
      sizer_panelsizer_h.add(sizer_panelsizer_v, 0)
      sizer_panel.set_sizer(sizer_panelsizer_h)

      @label_font = Wx::Font.new(Wx::FontInfo.new(8).light)

      scheme = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Appearance", bitmap_(:eye_xpm))
      @default_primary = Wx::Colour.new
      @default_secondary = Wx::Colour.new
      @default_tertiary = Wx::Colour.new
      @ribbon.get_art_provider.get_colour_scheme(@default_primary, @default_secondary, @default_tertiary)
      provider_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                        "Art", style: Wx::RBN::RIBBON_PANEL_NO_AUTO_MINIMISE)
      provider_bar = Wx::RBN::RibbonButtonBar.new(provider_panel, Wx::ID_ANY)
      provider_bar.add_button(ID::DEFAULT_PROVIDER, "Default Provider",
                              Wx::ArtProvider.get_bitmap(Wx::ART_QUESTION, Wx::ART_OTHER, Wx::Size.new(32, 32)))
      provider_bar.add_button(ID::AUI_PROVIDER, "AUI Provider", bitmap_(:aui_style_xpm))
      provider_bar.add_button(ID::MSW_PROVIDER, "MSW Provider", bitmap_(:msw_style_xpm))
      primary_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                       "Primary Colour", bitmap_(:colours_xpm))
      @primary_gallery = populate_colours_panel(primary_panel,
                                               @default_primary, ID::PRIMARY_COLOUR)
      secondary_panel = Wx::RBN::RibbonPanel.new(scheme, Wx::ID_ANY,
                                                         "Secondary Colour", bitmap_(:colours_xpm))
      @secondary_gallery = populate_colours_panel(secondary_panel,
                                                 @default_secondary, ID::SECONDARY_COLOUR)

      page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "UI Updated", bitmap_(:ribbon_xpm))
      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Enable/Disable", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::DISABLED, "Disabled", bitmap_(:ribbon_xpm))
      bar.add_button(ID::ENABLE,   "Enable", bitmap_(:ribbon_xpm))
      bar.add_button(ID::DISABLE,  "Disable", bitmap_(:ribbon_xpm))
      bar.add_button(ID::UI_ENABLE_UPDATED, "Enable UI updated", bitmap_(:ribbon_xpm))
      bar.enable_button(ID::DISABLED, false)
      @bEnabled = true

      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Toggle", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::CHECK, "Toggle", bitmap_(:ribbon_xpm))
      bar.add_toggle_button(ID::UI_CHECK_UPDATED, "Toggled UI updated", bitmap_(:ribbon_xpm))
      @bChecked = true

      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Change text", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::CHANGE_TEXT1, "One", bitmap_(:ribbon_xpm))
      bar.add_button(ID::CHANGE_TEXT2, "Two", bitmap_(:ribbon_xpm))
      bar.add_button(ID::UI_CHANGE_TEXT_UPDATED, "Zero", bitmap_(:ribbon_xpm))

      # Also set the general disabled text colour:
      artProvider = @ribbon.get_art_provider
      tColour = artProvider.get_color(Wx::RBN::RIBBON_ART_BUTTON_BAR_LABEL_COLOUR)
      artProvider.set_color(Wx::RBN::RIBBON_ART_BUTTON_BAR_LABEL_DISABLED_COLOUR, tColour.make_disabled)

      Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Empty Page", bitmap_(:empty_xpm))

      page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Another Page", bitmap_(:empty_xpm))
      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Page manipulation", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::REMOVE_PAGE, "Remove", Wx::ArtProvider.get_bitmap(Wx::ART_DELETE, Wx::ART_OTHER, Wx::Size.new(24, 24)))
      bar.add_button(ID::HIDE_PAGES, "Hide Pages", bitmap_(:ribbon_xpm))
      bar.add_button(ID::SHOW_PAGES, "Show Pages", bitmap_(:ribbon_xpm))

      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Button bar manipulation", bitmap_(:ribbon_xpm))
      button_bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      button_bar.add_button(ID::PLUS_MINUS, "+/-",
                            Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, Wx::Size.new(24, 24)))
      @plus_minus_state = false
      button_bar.add_button(ID::CHANGE_LABEL, "short", bitmap_(:ribbon_xpm))
      button_bar.set_button_text_min_width(ID::CHANGE_LABEL, "some long text")
      @change_label_state = false

      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Always medium buttons", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::SMALL_BUTTON_1, "Button 1", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_1, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_2, "Button 2", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_2, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_3, "Button 3", bitmap_(:ribbon_xpm))
      bar.add_button(ID::SMALL_BUTTON_4, "Button 4", bitmap_(:ribbon_xpm))
      bar.add_button(ID::SMALL_BUTTON_5, "Button 5", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_5, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_6, "Button 6", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_6, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)

      Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Highlight Page", bitmap_(:empty_xpm))
      @ribbon.add_page_highlight(@ribbon.get_page_count-1)


      page = Wx::RBN::RibbonPage.new(@ribbon, Wx::ID_ANY, "Advanced", bitmap_(:empty_xpm))
      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Button bar manipulation", bitmap_(:ribbon_xpm))
      button_bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      button_bar.add_button(ID::PLUS_MINUS, "+/-",
                            Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, Wx::Size.new(24, 24)))
      @plus_minus_state = false
      button_bar.add_button(ID::CHANGE_LABEL, "short", bitmap_(:ribbon_xpm))
      button_bar.set_button_text_min_width(ID::CHANGE_LABEL, "some long text")
      @change_label_state = false

      button_panel = Wx::RBN::RibbonPanel.new(page, Wx::ID_ANY, "Always medium buttons", bitmap_(:ribbon_xpm))
      bar = Wx::RBN::RibbonButtonBar.new(button_panel, Wx::ID_ANY)
      bar.add_button(ID::SMALL_BUTTON_1, "Button 1", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_1, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_2, "Button 2", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_2, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_3, "Button 3", bitmap_(:ribbon_xpm))
      bar.add_button(ID::SMALL_BUTTON_4, "Button 4", bitmap_(:ribbon_xpm))
      bar.add_button(ID::SMALL_BUTTON_5, "Button 5", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_5, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)
      bar.add_button(ID::SMALL_BUTTON_6, "Button 6", bitmap_(:ribbon_xpm))
      bar.set_button_max_size_class(ID::SMALL_BUTTON_6, Wx::RBN::RIBBON_BUTTONBAR_BUTTON_MEDIUM)

      @ribbon.realize

      @logwindow = Wx::TextCtrl.new(@panel, Wx::ID_ANY, style: Wx::TE_MULTILINE | Wx::TE_READONLY |
                                     Wx::TE_LEFT | Wx::TE_BESTWRAP | Wx::BORDER_NONE)

      @togglePanels = Wx::ToggleButton.new(@panel, ID::TOGGLE_PANELS, "&Toggle panels")
      @togglePanels.set_value(true)

      s = Wx::BoxSizer.new(Wx::VERTICAL)

      s.add(@ribbon, 0, Wx::EXPAND)
      s.add(@logwindow, 1, Wx::EXPAND)

      # The backstage takes the place of the log window while the File tab is selected.
      create_backstage
      @backstage.hide
      s.add(@backstage, Wx::SizerFlags.new(1).expand)

      s.add(@togglePanels, Wx::SizerFlags.new.border)

      @panel.set_sizer(s)

      frameSizer = Wx::VBoxSizer.new
      frameSizer.add(@panel, Wx::SizerFlags.new(1).expand)
      set_sizer(frameSizer)

      @ribbon.set_backstage(@backstage, @logwindow)

      evt_ribbonbuttonbar_clicked(ID::ENABLE, :on_enable)
      evt_ribbonbuttonbar_clicked(ID::DISABLE, :on_disable)
      evt_ribbonbuttonbar_clicked(ID::DISABLED, :on_disabled)
      evt_ribbonbuttonbar_clicked(ID::UI_ENABLE_UPDATED, :on_enable_updated)
      evt_update_ui(ID::UI_ENABLE_UPDATED, :on_enable_update_ui)
      evt_ribbonbuttonbar_clicked(ID::CHECK, :on_check)
      evt_update_ui(ID::UI_CHECK_UPDATED, :on_check_update_ui)
      evt_ribbonbuttonbar_clicked(ID::CHANGE_TEXT1, :on_change_text1)
      evt_ribbonbuttonbar_clicked(ID::CHANGE_TEXT2, :on_change_text2)
      evt_update_ui(ID::UI_CHANGE_TEXT_UPDATED, :on_change_text_update_ui)
      evt_ribbonbuttonbar_clicked(ID::DEFAULT_PROVIDER, :on_default_provider)
      evt_ribbonbuttonbar_clicked(ID::AUI_PROVIDER, :on_aui_provider)
      evt_ribbonbuttonbar_clicked(ID::MSW_PROVIDER, :on_msw_provider)
      evt_ribbonbuttonbar_clicked(ID::SELECTION_EXPAND_H, :on_selection_expand_h_button)
      evt_ribbonbuttonbar_clicked(ID::SELECTION_EXPAND_V, :on_selection_expand_v_button)
      evt_ribbonbuttonbar_clicked(ID::SELECTION_CONTRACT, :on_selection_contract_button)
      evt_ribbonbuttonbar_clicked(ID::CIRCLE, :on_circle_button)
      evt_ribbonbuttonbar_clicked(ID::CROSS, :on_cross_button)
      evt_ribbonbuttonbar_clicked(ID::TRIANGLE, :on_triangle_button)
      evt_ribbonbuttonbar_clicked(ID::SQUARE, :on_square_button)
      evt_ribbonbuttonbar_dropdown_clicked(ID::TRIANGLE, :on_triangle_dropdown)
      evt_ribbonbuttonbar_dropdown_clicked(ID::POLYGON, :on_polygon_dropdown)
      evt_ribbongallery_hover_changed(ID::PRIMARY_COLOUR, :on_hovered_colour_change)
      evt_ribbongallery_hover_changed(ID::SECONDARY_COLOUR, :on_hovered_colour_change)
      evt_ribbongallery_selected(ID::PRIMARY_COLOUR, :on_primary_colour_select)
      evt_ribbongallery_selected(ID::SECONDARY_COLOUR, :on_secondary_colour_select)
      evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_LEFT, :on_justify)
      evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_CENTER, :on_justify)
      evt_ribbontoolbar_clicked(Wx::ID_JUSTIFY_RIGHT, :on_justify)
      evt_update_ui(Wx::ID_JUSTIFY_LEFT, :on_justify_update_ui)
      evt_update_ui(Wx::ID_JUSTIFY_CENTER, :on_justify_update_ui)
      evt_update_ui(Wx::ID_JUSTIFY_RIGHT, :on_justify_update_ui)
      evt_ribbontoolbar_clicked(Wx::ID_NEW, :on_new)
      evt_ribbontoolbar_dropdown_clicked(Wx::ID_NEW, :on_new_dropdown)
      evt_ribbontoolbar_clicked(Wx::ID_PRINT, :on_print)
      evt_ribbontoolbar_dropdown_clicked(Wx::ID_PRINT, :on_print_dropdown)
      evt_ribbontoolbar_dropdown_clicked(Wx::ID_REDO, :on_redo_dropdown)
      evt_ribbontoolbar_dropdown_clicked(Wx::ID_UNDO, :on_undo_dropdown)
      evt_ribbontoolbar_clicked(ID::POSITION_LEFT, :on_position_left)
      evt_ribbontoolbar_dropdown_clicked(ID::POSITION_LEFT, :on_position_left_dropdown)
      evt_ribbontoolbar_clicked(ID::POSITION_TOP, :on_position_top)
      evt_ribbontoolbar_dropdown_clicked(ID::POSITION_TOP, :on_position_top_dropdown)
      evt_button(ID::PRIMARY_COLOUR, :on_colour_gallery_button)
      evt_button(ID::SECONDARY_COLOUR, :on_colour_gallery_button)
      evt_menu(ID::POSITION_LEFT, :on_position_left_icons)
      evt_menu(ID::POSITION_LEFT_LABELS, :on_position_left_labels)
      evt_menu(ID::POSITION_LEFT_BOTH, :on_position_left_both)
      evt_menu(ID::POSITION_TOP, :on_position_top_labels)
      evt_menu(ID::POSITION_TOP_ICONS, :on_position_top_icons)
      evt_menu(ID::POSITION_TOP_BOTH, :on_position_top_both)
      evt_togglebutton(ID::TOGGLE_PANELS, :on_toggle_panels)
      evt_ribbonpanel_extbutton_activated(Wx::ID_ANY, :on_ext_button)
      evt_ribbonbuttonbar_clicked(ID::REMOVE_PAGE, :on_remove_page)
      evt_ribbonbuttonbar_clicked(ID::HIDE_PAGES, :on_hide_pages)
      evt_ribbonbuttonbar_clicked(ID::SHOW_PAGES, :on_show_pages)
      evt_ribbonbuttonbar_clicked(ID::PLUS_MINUS, :on_plus_minus)
      evt_ribbonbuttonbar_clicked(ID::CHANGE_LABEL, :on_change_label)
      evt_ribbonbar_toggled(Wx::ID_ANY, :on_ribbon_bar_toggled)
      evt_ribbonbar_help_click(Wx::ID_ANY, :on_ribbon_bar_help_clicked)
      evt_size(:on_size_event)
    end

    # utility function to find an icon relative to this ruby script
    def bitmap_(bitmap_name)
      Wx::Bitmap.new(File.join(File.dirname(__FILE__), bitmap_name.to_s.sub(/_([A-Za-z]+)\Z/, '.\1')))
    end

    # Helper to create a bitmap bundle from embedded SVG data. When wxHAS_SVG is
    # available, the SVG is rasterized at any requested size for DPI-aware display.
    # Falls back to wxArtProvider to guarantee the returned bundle is never empty,
    # which prevents wxASSERT failures in AddTool/AddButton.
    def make_svg_bundle(svg_data, size, fallback = Wx::ART_QUESTION)
      if Wx.has_feature?(:USE_SVG)
        bundle = Wx::BitmapBundle::from_svg(svg_data, size)
        return bundle if bundle.ok?
      else
        # noop
      end # USE_SVG
      Wx::ArtProvider::get_bitmap_bundle(fallback, Wx::ART_OTHER, size)
    end

    def create_backstage
      @backstage = Wx::RBN::Backstage.new(@panel)

      @backstage.add_button(ID::BACKSTAGE_INFO, "Info")
      @backstage.add_button(ID::BACKSTAGE_NEW, "New")
      @backstage.add_button(ID::BACKSTAGE_OPEN, "Open")
      @backstage.add_button(ID::BACKSTAGE_SAVE, "Save")
      @backstage.add_button(ID::BACKSTAGE_SAVE_AS, "Save As")
      @backstage.add_separator
      @backstage.add_flexible_space
      @backstage.add_button(ID::BACKSTAGE_EXIT, "Exit")

      # Save and Exit have no page, so they are just actions.
      margin = from_dip(30)

      page = @backstage.add_page(ID::BACKSTAGE_INFO)
      sizer = Wx::VBoxSizer.new
      sizer.add(Wx::RBN::BackstageHeading.new(page, Wx::ID_ANY, 'Information'),
                Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))

      callout = Wx::BackstageCallout.new(page, Wx::ID_ANY,
          'Checked Out Document',
          "No one else can edit this document or view your changes\n" +
          'until it is checked in.')
      callout.set_action(Wx::RBN::BackstageButton.new(callout, ID::BACKSTAGE_DISCARD,
                                                      'Discard Check Out', Wx::BitmapBundle.new,
                                                      Wx::RBN::BackstageButtonStyle::Wide))
      sizer.add(callout, Wx::SizerFlags.new.expand.border(Wx::LEFT | Wx::RIGHT | Wx::TOP, margin))

      protect = Wx::RBN::BackstageButton.new(page, ID::BACKSTAGE_PROTECT,
                                             'Protect Document', Wx::BitmapBundle.new,
                                             Wx::RBN::BackstageButtonStyle::Wide,
                                             'Control what types of changes people can make')
      protect.show_drop_down_arrow
      sizer.add(protect, Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))
      page.set_sizer(sizer)

      page = @backstage.add_page(ID::BACKSTAGE_NEW)
      sizer = Wx::VBoxSizer.new
      sizer.add(Wx::RBN::BackstageHeading.new(page, Wx::ID_ANY, 'New'),
                    Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))
      sizer.add(Wx::RBN::BackstageHeading.new(page, Wx::ID_ANY, 'Featured',
                                          Wx::RBN::BackstageHeadingStyle::Section),
                Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))

      # Wx::REMOVE_LEADING_SPACES keeps the last card on a row from being stretched
      cards = Wx::WrapSizer.new(Wx::HORIZONTAL, Wx::REMOVE_LEADING_SPACES)
      cardFlags = Wx::SizerFlags.new.border(Wx::RIGHT | Wx::TOP, from_dip(16))
      [
          { id: ID::BACKSTAGE_TEMPLATE_BLANK, label: "Blank Document", svg: EmptySvg },
          { id: ID::BACKSTAGE_TEMPLATE_RIBBON, label: "Ribbon Layout", svg: RibbonSvg },
          { id: ID::BACKSTAGE_TEMPLATE_COLOURS, label: "Colour Study", svg: ColoursSvg }
      ].each do |tmpl|
        cards.add(Wx::RBN::BackstageButton.new(page, tmpl[:id], tmpl[:label],
                                               make_svg_bundle(tmpl[:svg], [64, 64]),
                                               Wx::RBN::BackstageButtonStyle::Card),
                  cardFlags)
      end
      sizer.add(cards, Wx::SizerFlags.new(1).expand.border(Wx::LEFT | Wx::RIGHT, margin))
      page.set_sizer(sizer)

      page = @backstage.add_page(ID::BACKSTAGE_OPEN)
      sizer = Wx::VBoxSizer.new
      sizer.add(Wx::RBN::BackstageHeading.new(page, Wx::ID_ANY, 'Open'),
                Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))

      # The list sorts by modified date and groups the files into sections
      # ("Today", "Yesterday", ...). The files here don't need to exist.
      recent = Wx::RBN::BackstageMRUList.new(page, ID::BACKSTAGE_RECENT_LIST)
      recent.set_empty_text("You haven't opened any files recently.")
      now = Time::now
      recent.add_file("/Documents/Marketing Proposal.pdf", now - (12 * 60))
      recent.add_file("/Documents/Invoices/March.txt", now - (5 * 60 * 60))
      recent.add_file("/Documents/Notes.txt", now - (24 * 60 * 60))
      recent.add_file("/Documents/Reports/Q1.ods", now - (4 * 24 * 60 * 60))
      recent.add_file("/Documents/Old/Archive.txt", now - (40 * 24 * 60 * 60))
      recent.set_min_size(from_dip([560, 340].to_size))
      recent.set_icon_provider do |path|
        case File.extname(path)
        when '.pdf'
          make_svg_bundle(PdfSvg, [16, 16])
        when '.ods'
          make_svg_bundle(OdsSvg, [16, 16])
        else
          make_svg_bundle(TxtSvg, [16, 16])
        end
      end
      sizer.add(recent, Wx::SizerFlags.new(1).expand.border(Wx::ALL, margin))
      page.set_sizer(sizer)

      page = @backstage.add_page(ID::BACKSTAGE_SAVE_AS)
      sizer = Wx::VBoxSizer.new
      sizer.add(Wx::RBN::BackstageHeading.new(page, Wx::ID_ANY, 'Save As'),
                Wx::SizerFlags.new.border(Wx::LEFT | Wx::TOP, margin))

      folders = Wx::RBN::BackstageItemList.new(page, ID::BACKSTAGE_FOLDER_LIST)
      folders.add_header('Current Folder')
      folderSeparator = " » "
      folders.add_item('Marketing', 'Documents' + folderSeparator + 'Marketing', '',
                       Wx::BitmapBundle.new, '/Documents/Marketing')
      folders.add_header('Recent')
      folders.add_item('Reports', 'Documents' + folderSeparator + 'Reports', '',
                       Wx::BitmapBundle.new, '/Documents/Reports')
      folders.add_item('Downloads', '', '',
                       Wx::BitmapBundle.new, '/Downloads')
      folders.set_min_size(from_dip([380, 340].to_size))
      sizer.add(folders, Wx::SizerFlags.new(1).expand.border(Wx::ALL, margin))
      page.set_sizer(sizer)

      evt_backstage_clicked Wx::ID_ANY, :on_backstage_clicked
      evt_backstage_item_clicked Wx::ID_ANY, :on_backstage_item_clicked
      connect(ID::BACKSTAGE_DISCARD, ID::BACKSTAGE_TEMPLATE_COLOURS, Wx::EVT_BUTTON, self.method(:on_backstage_button))

    end

    def on_backstage_clicked(evt)
      # A button with a page shows it after this returns, unless evt.Veto() is called.
      case evt.id
      when ID::BACKSTAGE_SAVE
        Wx::message_box("The \"#{evt.string}\" button was clicked.",
                        'Backstage Button', Wx::OK | Wx::ICON_INFORMATION, self)

      when ID::BACKSTAGE_EXIT
        close(true)
      end
    end

    def on_backstage_item_clicked(evt)
      # GetId() is the ID of the list, GetInt() is the index of the item, and
      # GetString() is its user string (here it's the path).
      Wx::message_box("Item #%d of list %d was clicked:\n%s" % [evt.int, evt.id, evt.string],
                      evt.id == ID::BACKSTAGE_RECENT_LIST ? 'Open Recent File'
                        : 'Save To Folder',
                      Wx::OK | Wx::ICON_INFORMATION, self)
    end

    def on_backstage_button(evt)
      if evt.id == ID::BACKSTAGE_PROTECT
        menu = Wx::Menu.new
        choices = ["Mark as Final", "Encrypt with Password", "Restrict Access"]
        choices.each do |choice|
          item = menu.append(Wx::ID_ANY, choice)
          menu.evt_menu(item) { Wx::message_box("\"#{choice}\" was chosen.", 'Protect Document', Wx::OK | Wx::ICON_INFORMATION) }
        end
        evt.event_object.popup_menu(menu, 0, evt.event_object.size.height) if evt.event_object.is_a?(Wx::Window)
        return
      end

      Wx::message_box("The button \"%s\" (ID %d) was clicked." % [evt.string, evt.id],
                      'Backstage Page Button', Wx::OK | Wx::ICON_INFORMATION, self)
    end

    def on_enable_update_ui(evt)
      evt.enable(@bEnabled)
    end

    def on_check_update_ui(evt)
      evt.check(@bChecked)
    end

    def on_change_text_update_ui(evt)
      unless @new_text.nil? || @new_text.empty?
        evt.set_text(@new_text)
        @new_text = ''
      end
    end

    def on_check(evt)
      @bChecked = !@bChecked
    end

    def on_enable(evt)
      @bEnabled = true
    end

    def on_disable(evt)
      @bEnabled = false
    end

    def on_disabled(evt)
      add_text("ERROR: Disabled button activated (not supposed to happen)")
    end

    def on_enable_updated(evt)
      add_text("Button activated")
    end

    def on_change_text1(evt)
      @new_text = "One"
    end

    def on_change_text2(evt)
      @new_text = "Two"
    end

    def on_circle_button(evt)
      add_text("Circle button clicked.")
    end

    def on_cross_button(evt)
      add_text("Cross button clicked.")
    end

    def on_triangle_button(evt)
      add_text("Triangle button clicked.")
    end

    def on_triangle_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "Equilateral")
      menu.append(Wx::ID_ANY, "Isosceles")
      menu.append(Wx::ID_ANY, "Scalene")

      evt.popup_menu(menu)
    end

    def on_square_button(evt)
      add_text("Square button clicked.")
    end

    def on_polygon_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "Pentagon (5 sided)")
      menu.append(Wx::ID_ANY, "Hexagon (6 sided)")
      menu.append(Wx::ID_ANY, "Heptagon (7 sided)")
      menu.append(Wx::ID_ANY, "Octogon (8 sided)")
      menu.append(Wx::ID_ANY, "Nonagon (9 sided)")
      menu.append(Wx::ID_ANY, "Decagon (10 sided)")

      evt.popup_menu(menu)
    end

    def on_selection_expand_v_button(evt)
      add_text("Expand selection horizontally button clicked.")
    end

    def on_selection_expand_h_button(evt)
      add_text("Expand selection vertically button clicked.")
    end

    def on_selection_contract_button(evt)
      add_text("Contract selection button clicked.")
    end

    def on_hovered_colour_change(evt)
      # Set the background of the gallery to the hovered colour, or back to the
      # default if there is no longer a hovered item.

      gallery = evt.gallery
      provider = gallery.get_art_provider

      if evt.gallery_item != 0
        if provider == @ribbon.art_provider
          provider = provider.clone
          gallery.set_art_provider(provider)
        end
        _, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
        provider.set_colour(Wx::RIBBON_ART_GALLERY_HOVER_BACKGROUND_COLOUR,
                            colour)
      else
        if provider != @ribbon.get_art_provider
          gallery.set_art_provider(@ribbon.get_art_provider)
        end
      end
    end

    def on_primary_colour_select(evt)
      name, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
      add_text("Colour \"" + name + "\" selected as primary.")
      secondary = Wx::Colour.new
      tertiary = Wx::Colour.new
      @ribbon.get_art_provider.get_colour_scheme(nil, secondary, tertiary)
      @ribbon.get_art_provider.set_colour_scheme(colour, secondary, tertiary)
      reset_gallery_art_providers
      @ribbon.refresh
    end

    def on_secondary_colour_select(evt)
      name, colour = get_gallery_colour(evt.get_gallery, evt.get_gallery_item)
      add_text("Colour \"" + name + "\" selected as secondary.")
      primary = Wx::Colour.new
      tertiary = Wx::Colour.new
      @ribbon.art_provider.get_colour_scheme(primary, nil, tertiary)
      @ribbon.art_provider.set_colour_scheme(primary, colour, tertiary)
      reset_gallery_art_providers
      @ribbon.refresh
    end

    def on_colour_gallery_button(evt)
      gallery = evt.get_event_object
      return unless gallery

      @ribbon.dismiss_expanded_panel
      if gallery.get_selection
        _, c = get_gallery_colour(gallery, gallery.get_selection)
        @colour_data.colour = c
      end
      Wx.ColourDialog(self, @colour_data) do |dlg|
        if dlg.show_modal == Wx::ID_OK
          @colour_data = dlg.colour_data
          clr = @colour_data.colour

          # Try to find colour in gallery
          item = nil
          gallery.count.times do |i|
            item = gallery.item(i)
            _, c = get_gallery_colour(gallery, item)
            break if c == clr
            item = nil
          end

          # Colour not in gallery - add it
          unless item
            Wx::MemoryDC.draw_on do |dc|
              item = add_colour_to_gallery(gallery,
                                           clr.get_as_string(Wx::C2S_HTML_SYNTAX), dc, clr)
            end
            gallery.realise
          end

          # Set selection
          gallery.ensure_visible(item)
          gallery.set_selection(item)

          # Send an event to respond to the selection change
          dummy = Wx::RBN::RibbonGalleryEvent.new(Wx::RBN::EVT_RIBBONGALLERY_SELECTED, gallery.id)
          dummy.set_event_object(gallery)
          dummy.set_gallery(gallery)
          dummy.set_gallery_item(item)
          process_window_event(dummy)
        end
      end
    end

    def on_default_provider(evt)
      @ribbon.dismiss_expanded_panel
      set_art_provider(Wx::RibbonDefaultArtProvider.new)
    end

    def on_aui_provider(evt)
      @ribbon.dismiss_expanded_panel
      set_art_provider(Wx::RBN::RibbonAUIArtProvider.new)
    end

    def on_msw_provider(evt)
      @ribbon.dismiss_expanded_panel
      set_art_provider(Wx::RBN::RibbonMSWArtProvider.new)
    end

    def on_justify(evt)
      style = @logwindow.get_window_style & ~(Wx::TE_LEFT | Wx::TE_CENTER | Wx::TE_RIGHT)
      case evt.id
      when Wx::ID_JUSTIFY_LEFT
        @logwindow.set_window_style(style | Wx::TE_LEFT)
      when Wx::ID_JUSTIFY_CENTER
        @logwindow.set_window_style(style | Wx::TE_CENTER)
      when Wx::ID_JUSTIFY_RIGHT
        @logwindow.set_window_style(style | Wx::TE_RIGHT)
      end
    end

    def on_justify_update_ui(evt)
      case evt.id
      when Wx::ID_JUSTIFY_LEFT
        evt.check(!@logwindow.has_flag(Wx::TE_CENTER | Wx::TE_RIGHT))
      when Wx::ID_JUSTIFY_CENTER
        evt.check(@logwindow.has_flag(Wx::TE_CENTER))
      when Wx::ID_JUSTIFY_RIGHT
        evt.check(@logwindow.has_flag(Wx::TE_RIGHT))
      end
    end

    def on_new(evt)
      add_text("New button clicked.")
    end

    def on_new_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "New Document")
      menu.append(Wx::ID_ANY, "New Template")
      menu.append(Wx::ID_ANY, "New Mail")

      evt.popup_menu(menu)
    end

    def on_print(evt)
      add_text("Print button clicked.")
    end

    def on_print_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "Print")
      menu.append(Wx::ID_ANY, "Preview")
      menu.append(Wx::ID_ANY, "Options")

      evt.popup_menu(menu)
    end

    def on_redo_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "Redo E")
      menu.append(Wx::ID_ANY, "Redo F")
      menu.append(Wx::ID_ANY, "Redo G")

      evt.popup_menu(menu)
    end

    def on_undo_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(Wx::ID_ANY, "Undo C")
      menu.append(Wx::ID_ANY, "Undo B")
      menu.append(Wx::ID_ANY, "Undo A")

      evt.popup_menu(menu)
    end

    def on_position_top(evt)
      on_position_top_labels(evt)
    end

    def on_position_top_labels(evt)
      set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE)
    end

    def on_position_top_icons(evt)
      set_bar_style((Wx::RBN::RIBBON_BAR_DEFAULT_STYLE & (~Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS)) | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS)
    end

    def on_position_top_both(evt)
      set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS)
    end

    def on_position_top_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(ID::POSITION_TOP, "Top with Labels")
      menu.append(ID::POSITION_TOP_ICONS, "Top with Icons")
      menu.append(ID::POSITION_TOP_BOTH, "Top with Both")
      evt.popup_menu(menu)
    end

    def on_position_left(evt)
      on_position_left_icons(evt)
    end

    def on_position_left_labels(evt)
      set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
    end

    def on_position_left_icons(evt)
      set_bar_style((Wx::RBN::RIBBON_BAR_DEFAULT_STYLE & (~Wx::RBN::RIBBON_BAR_SHOW_PAGE_LABELS)) |
                    Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS | Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
    end

    def on_position_left_both(evt)
      set_bar_style(Wx::RBN::RIBBON_BAR_DEFAULT_STYLE | Wx::RBN::RIBBON_BAR_SHOW_PAGE_ICONS |
                    Wx::RBN::RIBBON_BAR_FLOW_VERTICAL)
    end

    def on_position_left_dropdown(evt)
      menu = Wx::Menu.new
      menu.append(ID::POSITION_LEFT, "Left with Icons")
      menu.append(ID::POSITION_LEFT_LABELS, "Left with Labels")
      menu.append(ID::POSITION_LEFT_BOTH, "Left with Both")
      evt.popup_menu(menu)
    end

    def on_remove_page(evt)
      n = @ribbon.get_page_count
      if n > 0
        @ribbon.delete_page(n-1)
        @ribbon.realize
      end
    end

    def on_hide_pages(evt)
      @ribbon.hide_page(1)
      @ribbon.hide_page(2)
      @ribbon.hide_page(3)
      @ribbon.realize
    end

    def on_show_pages(evt)
      @ribbon.show_page(1)
      @ribbon.show_page(2)
      @ribbon.show_page(3)
      @ribbon.realize
    end

    def on_plus_minus(evt)
      if @plus_minus_state
        evt.bar.set_button_icon(ID::PLUS_MINUS,
                                Wx::ArtProvider.get_bitmap(Wx::ART_PLUS, Wx::ART_OTHER, [24, 24]))
        @plus_minus_state = false
      else
        evt.bar.set_button_icon(ID::PLUS_MINUS,
                                Wx::ArtProvider.get_bitmap(Wx::ART_MINUS, Wx::ART_OTHER, [24, 24]))
        @plus_minus_state = true
      end
    end

    def on_change_label(evt)
      if @change_label_state
        evt.bar.set_button_text(ID::CHANGE_LABEL, "short")
        @change_label_state = false
      else
        evt.bar.set_button_text(ID::CHANGE_LABEL, "some long text")
        @change_label_state = true
      end
    end

    def on_toggle_panels(evt)
      @ribbon.show_panels(@togglePanels.value)
    end

    def on_ribbon_bar_toggled(evt)
      add_text("Ribbon bar %s." %
                (@ribbon.are_panels_shown ? "expanded" : "collapsed"))
    end

    def on_ribbon_bar_help_clicked(evt)
      add_text("Ribbon bar help clicked")
    end

    def on_size_event(evt)
      if evt.size.width < 200
        @ribbon.hide()
      else
        @ribbon.show
      end
      evt.skip
    end

    def on_ext_button(evt)
      Wx.message_box("Extension button clicked")
    end

    protected

    def populate_colours_panel(panel, defclr, gallery_id)
      gallery = panel.find_window_by_id(gallery_id)
      if gallery
        gallery.clear
      else
        gallery = Wx::RBN::RibbonGallery.new(panel, gallery_id)
      end
      Wx::MemoryDC.draw_on do |dc|
        def_item = add_colour_to_gallery(gallery, "Default", dc, defclr)
        gallery.set_selection(def_item)
        add_colour_to_gallery(gallery, "BLUE", dc)
        add_colour_to_gallery(gallery, "BLUE VIOLET", dc)
        add_colour_to_gallery(gallery, "BROWN", dc)
        add_colour_to_gallery(gallery, "CADET BLUE", dc)
        add_colour_to_gallery(gallery, "CORAL", dc)
        add_colour_to_gallery(gallery, "CYAN", dc)
        add_colour_to_gallery(gallery, "DARK GREEN", dc)
        add_colour_to_gallery(gallery, "DARK ORCHID", dc)
        add_colour_to_gallery(gallery, "FIREBRICK", dc)
        add_colour_to_gallery(gallery, "GOLD", dc)
        add_colour_to_gallery(gallery, "GOLDENROD", dc)
        add_colour_to_gallery(gallery, "GREEN", dc)
        add_colour_to_gallery(gallery, "INDIAN RED", dc)
        add_colour_to_gallery(gallery, "KHAKI", dc)
        add_colour_to_gallery(gallery, "LIGHT BLUE", dc)
        add_colour_to_gallery(gallery, "LIME GREEN", dc)
        add_colour_to_gallery(gallery, "MAGENTA", dc)
        add_colour_to_gallery(gallery, "MAROON", dc)
        add_colour_to_gallery(gallery, "NAVY", dc)
        add_colour_to_gallery(gallery, "ORANGE", dc)
        add_colour_to_gallery(gallery, "ORCHID", dc)
        add_colour_to_gallery(gallery, "PINK", dc)
        add_colour_to_gallery(gallery, "PLUM", dc)
        add_colour_to_gallery(gallery, "PURPLE", dc)
        add_colour_to_gallery(gallery, "RED", dc)
        add_colour_to_gallery(gallery, "SALMON", dc)
        add_colour_to_gallery(gallery, "SEA GREEN", dc)
        add_colour_to_gallery(gallery, "SIENNA", dc)
        add_colour_to_gallery(gallery, "SKY BLUE", dc)
        add_colour_to_gallery(gallery, "TAN", dc)
        add_colour_to_gallery(gallery, "THISTLE", dc)
        add_colour_to_gallery(gallery, "TURQUOISE", dc)
        add_colour_to_gallery(gallery, "VIOLET", dc)
        add_colour_to_gallery(gallery, "VIOLET RED", dc)
        add_colour_to_gallery(gallery, "WHEAT", dc)
        add_colour_to_gallery(gallery, "WHITE", dc)
        add_colour_to_gallery(gallery, "YELLOW", dc)
      end

      gallery
    end

    def add_text(msg)
      @logwindow.append_text(msg)
      @logwindow.append_text("\n")
      @ribbon.dismiss_expanded_panel
    end

    def add_colour_to_gallery(gallery, colour, dc, value = nil)
      item = nil

      c = nil
      c = Wx::Colour.new(colour) if colour != "Default"

      c = value unless c && c.ok?

      if c.ok?
        iWidth = 64
        iHeight = 40

        bitmap = Wx::Bitmap.new(iWidth, iHeight)
        dc.select_object(bitmap)
        dc.set_font(@label_font)
        b = Wx::Brush.new (c)
        dc.set_pen(Wx::BLACK_PEN)
        dc.set_brush(b)
        dc.draw_rectangle(0, 0, iWidth, iHeight)

        colour = colour[0] + colour[1,colour.size].downcase
        size = dc.get_text_extent(colour)
        foreground = Wx::Colour.new(~c.red, ~c.green, ~c.blue)
        if ((foreground.red - c.red).abs +
            (foreground.blue - c.blue).abs +
            (foreground.green - c.green).abs) < 64
          # Foreground too similar to background - use a different
          # strategy to find a contrasting colour
          foreground = Wx::Colour.new((c.red + 64) % 256, 255 - c.green, (c.blue + 192) % 256)
        end
        dc.set_text_foreground(foreground)
        dc.draw_text(colour, (iWidth - size[0] + 1).div(2), (iHeight - size[1]).div(2))
        dc.select_object_as_source(Wx::NULL_BITMAP)

        item = gallery.append(bitmap, Wx::ID_ANY)
        gallery.set_item_client_object(item, [colour, c])
      end
      item
    end

    def get_gallery_colour(gallery, item)
      gallery.get_item_client_object(item)
    end

    def reset_gallery_art_providers
      if @primary_gallery.get_art_provider != @ribbon.get_art_provider
        @primary_gallery.set_art_provider(@ribbon.get_art_provider)
      end
      if @secondary_gallery.art_provider != @ribbon.art_provider
        @secondary_gallery.art_provider= @ribbon.art_provider
      end
    end

    def set_art_provider(prov)
      @ribbon.freeze
      @ribbon.set_art_provider(prov)

      prov.get_colour_scheme(@default_primary, @default_secondary, @default_tertiary)
      populate_colours_panel(@primary_gallery.get_parent, @default_primary, ID::PRIMARY_COLOUR)
      populate_colours_panel(@secondary_gallery.parent, @default_secondary, ID::SECONDARY_COLOUR)

      @ribbon.realize
      @ribbon.thaw
      get_sizer.layout
    end

    def set_bar_style(style)
      @ribbon.freeze
      @ribbon.set_window_style_flag(style)
      pTopSize = get_sizer
      pToolbar = find_window_by_id(ID::MAIN_TOOLBAR)
      if (style & Wx::RBN::RIBBON_BAR_FLOW_VERTICAL) == Wx::RBN::RIBBON_BAR_FLOW_VERTICAL
        @ribbon.set_tab_ctrl_margins(10, 10)
        pTopSize.set_orientation(Wx::HORIZONTAL)
        pToolbar.set_rows(3, 5) if pToolbar
      else
        @ribbon.set_tab_ctrl_margins(50, 20)
        pTopSize.set_orientation(Wx::VERTICAL)
        pToolbar.set_rows(2, 3) if pToolbar
      end
      @ribbon.realise
      layout
      @ribbon.thaw
    end

  end

end

module RibbonSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'Ribbon wxRuby example.',
      description: 'wxRuby example displaying frame window showcasing Ribbon framework.' }
  end

  def self.activate
    frame = Ribbon::MyFrame.new
    frame.show(true)
    frame
  end

  if $0 == __FILE__
    Wx::App.run do
      self.gc_stress
      RibbonSample.activate
    end
  end

end
