<!--
# @markup markdown
# @title 7. wxRuby Colour and Font
-->

# 6. wxRuby Colour and Font

## Introduction

The wxWidgets API makes use of typical C++ features to support automatic conversion of certain types providing
user friendly options for argument specifications. This way for example a developer does not need to explicitly
declare a colour object construction where a colour instance value is expected but rather can specify a simple string
constant like:

```C++
wxPen pen;
pen.SetColour("CYAN"); // instead of pen.SetColour(wxColour("CYAN"));
```

For the wxRuby API similar support has been achieved for various much used argument types.  

## Colour

Wherever a {Wx::Colour} object is expected as an argument wxRuby supports the specification of `String` or `Symbol`
values as a developer friendly alternative. This way the following code is equivalent:

```ruby
pen = Wx::Pen.new
pen.set_colour(Wx::Colour.new("CYAN"))

pen = Wx::Pen.new
pen.set_colour("CYAN")

pen = Wx::Pen.new
pen.set_colour(:CYAN)
```

## Font

Wherever a {Wx::Font} object is expected as an argument wxRuby supports the specification of a {Wx::FontInfo} object.
This way the following code is equivalent:

```ruby
title = Wx::StaticText.new(self, -1, "Title")
title.set_font(Wx::Font.new(18, Wx::FontFamily::FONTFAMILY_SWISS, Wx::FontStyle::FONTSTYLE_NORMAL, Wx::FontWeight::FONTWEIGHT_BOLD))

title = Wx::StaticText.new(self, -1, "Title")
title.set_font(Wx::FontInfo.new(18)
                 .family(Wx::FontFamily::FONTFAMILY_SWISS)
                 .style(Wx::FontStyle::FONTSTYLE_NORMAL)
                 .bold())
```
