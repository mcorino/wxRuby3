#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

class FontTestPanel < Wx::Panel
  def initialize(parent, log)
    super(parent, -1)
    @log = log
    btn = Wx::Button.new(self, -1, "Select Font")
    evt_button(btn.get_id) { |event| on_select_font(event) }

    @sampleText = Wx::TextCtrl.new(self, -1, "Sample Text")
    @curFont = @sampleText.get_font
    @curClr = Wx::BLACK

    fgs = Wx::FlexGridSizer.new(2, 2, 5, 5)
    fgs.add_growable_col(1)
    fgs.add_growable_row(0)

    fgs.add(btn, 0, Wx::ALIGN_CENTRE_VERTICAL)
    fgs.add(@sampleText, 10, Wx::GROW)

    fgs.add(15, 15)
    fgs.add(15, 15) # an empty row

    fgs.add(Wx::StaticText.new(self, -1, "PointSize: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @ps = Wx::StaticText.new(self, -1, "")
    font = @ps.get_font
    font.set_weight(Wx::FONTWEIGHT_BOLD)
    @ps.set_font(font)
    fgs.add(@ps, 0, Wx::ALIGN_CENTRE_VERTICAL)

    fgs.add(Wx::StaticText.new(self, -1, "Family: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @family = Wx::StaticText.new(self, -1, "")
    @family.set_font(font)
    fgs.add(@family, 0, Wx::ALIGN_CENTRE_VERTICAL)

    fgs.add(Wx::StaticText.new(self, -1, "Style: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @style = Wx::StaticText.new(self, -1, "")
    @style.set_font(font)
    fgs.add(@style, 0, Wx::ALIGN_CENTRE_VERTICAL)

    fgs.add(Wx::StaticText.new(self, -1, "Weight: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @weight = Wx::StaticText.new(self, -1, "")
    @weight.set_font(font)
    fgs.add(@weight, 0, Wx::ALIGN_CENTRE_VERTICAL)

    fgs.add(Wx::StaticText.new(self, -1, "Face: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @face = Wx::StaticText.new(self, -1, "")
    @face.set_font(font)
    fgs.add(@face, 0, Wx::ALIGN_CENTRE_VERTICAL)

    fgs.add(15, 15)
    fgs.add(15, 15) # an empty row

    fgs.add(Wx::StaticText.new(self, -1, "Wx::NativeFontInfo: "), 0, Wx::ALIGN_CENTRE_VERTICAL)
    @nfi = Wx::StaticText.new(self, -1, "")
    @nfi.set_font(font)
    fgs.add(@nfi, 0, Wx::ALIGN_CENTRE_VERTICAL)

    # give it some border space

    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    sizer.add(fgs, 0, Wx::GROW | Wx::ALL, 25)

    set_sizer(sizer)
    sizer.fit(self)
    @sizer = fgs
    update_ui
  end

  def update_ui
    @sampleText.set_font(@curFont)
    # layout is called so that if the user changes the size of the Font, the text control will be properly displayed
    # to show the whole font - just comment out this line, to see the font size change without corresponding changes
    # to the text control :-)
    # As a postscript, it is interesting to note that if I call layout at the end of this method, it causes all of the
    # labels to appear BLANK, showing nothing.  Through trial and error, I moved it here, and found that it resized the
    # text control properly and set the text of the labels too - I don't know why that is though?
    @sizer.layout
    @ps.set_label(@curFont.get_point_size.to_s)
    @family.set_label(map_font_value_to_name(@curFont.get_family))
    @style.set_label(map_font_value_to_name(@curFont.get_style, :style))
    @weight.set_label(map_font_value_to_name(@curFont.get_weight, :weight))
    @face.set_label(@curFont.get_face_name)
    @nfi.set_label(@curFont.get_native_font_info_desc.to_s)

  end

  def on_select_font(evt)
    data = Wx::FontData.new
    # data.enable_effects(true)
    data.set_colour(@curClr) # set colour
    data.set_initial_font(@curFont)

    dlg = Wx::FontDialog.new(self, data)
    if dlg.show_modal == Wx::ID_OK
      data = dlg.get_font_data
      font = data.get_chosen_font
      colour = data.get_colour
      @log.write_text("You selected: " + font.get_face_name + ", " + font.get_point_size.to_s + " points, color (" +
                        get_rgb_string(colour))
      @curFont = font
      @curClr = colour
      update_ui
    end
  end

  def map_font_value_to_name(constant, option = :family)
    case option
    when :family
      case constant
      when Wx::FONTFAMILY_DEFAULT
        return "Wx::FONTFAMILY_DEFAULT"
      when Wx::FONTFAMILY_DECORATIVE
        return "Wx::FONTFAMILY_DECORATIVE"
      when Wx::FONTFAMILY_ROMAN
        return "Wx::FONTFAMILY_ROMAN"
      when Wx::FONTFAMILY_SCRIPT
        return "Wx::FONTFAMILY_SCRIPT"
      when Wx::FONTFAMILY_SWISS
        return "Wx::FONTFAMILY_SWISS"
      when Wx::FONTFAMILY_MODERN
        return "Wx::FONTFAMILY_MODERN"
      when Wx::FONTFAMILY_TELETYPE
        return "Wx::FONTFAMILY_TELETYPE"
      else
        return "Unknown (#{constant})"
      end
    when :style
      case constant
      when Wx::FONTSTYLE_NORMAL
        return "Wx::FONTSTYLE_NORMAL"
      when Wx::FONTSTYLE_SLANT
        return "Wx::FONTSTYLE_SLANT"
      when Wx::FONTSTYLE_ITALIC
        return "Wx::FONTSTYLE_ITALIC"
      else
        return "Unknown (#{constant})"
      end
    when :weight
      case constant
      when Wx::FONTWEIGHT_INVALID
        return "Wx::FONTWEIGHT_INVALID"
      when Wx::FONTWEIGHT_THIN
        return "Wx::FONTWEIGHT_THIN"
      when Wx::FONTWEIGHT_EXTRALIGHT
        return "Wx::FONTWEIGHT_EXTRALIGHT"
      when Wx::FONTWEIGHT_MEDIUM
        return "Wx::FONTWEIGHT_MEDIUM"
      when Wx::FONTWEIGHT_NORMAL
        return "Wx::FONTWEIGHT_NORMAL"
      when Wx::FONTWEIGHT_LIGHT
        return "Wx::FONTWEIGHT_LIGHT"
      when Wx::FONTWEIGHT_BOLD
        return "Wx::FONTWEIGHT_BOLD"
      when Wx::FONTWEIGHT_SEMIBOLD
        return "Wx::FONTWEIGHT_SEMIBOLD"
      when Wx::FONTWEIGHT_EXTRABOLD
        return "Wx::FONTWEIGHT_EXTRABOLD"
      when Wx::FONTWEIGHT_HEAVY
        return "Wx::FONTWEIGHT_HEAVY"
      when Wx::FONTWEIGHT_EXTRAHEAVY
        return "Wx::FONTWEIGHT_BOLD"
      else
        return "Unknown (#{constant})"
      end
    end
  end

  def get_rgb_string(color)
    red = color.red.to_s
    green = color.green.to_s
    blue = color.blue.to_s
    return "(%s, %s, %s)" % [red, green, blue]
  end
end

module Demo
  def Demo.run(frame, nb, log)
    win = FontTestPanel.new(nb, log)
    return win

  end

  def Demo.overview
    return "This class allows you to use the system font chooser dialog."
  end
end

if __FILE__ == $0
  run_solo_lib = File.join(File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
