<!--
# @markup markdown
# @title 4. wxRuby Enum values
-->

# 4. wxRuby Enum values

The wxWidget library liberally mixes integer constants and enum values for things like IDs, style flags
and option flags and such without much consistency.<br>
In previous wxRuby versions these were all mapped to integer constants which had 2 distinct disadvantages.

- **loss of scoping**<br>
Integer constants for enum values would all be declared in the enclosing scope for the enum declaration loosing
the naming scope which originally existed in C++ (excepting anonymous enums).

- **loss of type-safety**<br>
Constants for enum values with identical integer values are indistinguishable from each other.

The wxRuby3 project attempts to provide a solution to that by introducing the `Wx::Enum` class which
is used as a base class for mapping all (named) wxWidget enums to Ruby.
The reference documentation for the `Wx::Enum` class can be found [here](https://mcorino.github.io/wxRuby3/Wx/Enum.html).

Any named wxWidget enum is mapped to a similarly named (Rubified C++ name) derived Enum class with each enum value 
defined as a constant of the enum class referencing an instance of the enum class with the corresponding
integer value like for example the 'wxSystemFont' enum which is defined in wxRuby as:

```ruby
module Wx
  class SystemFont < Wx::Enum
  
    # Original equipment manufacturer dependent fixed-pitch font.
    # 
    SYS_OEM_FIXED_FONT = Wx::SystemFont.new(10)
    
    # Windows fixed-pitch (monospaced) font.
    # 
    SYS_ANSI_FIXED_FONT = Wx::SystemFont.new(11)
    
    # Windows variable-pitch (proportional) font.
    # 
    SYS_ANSI_VAR_FONT = Wx::SystemFont.new(12)
    
    # System font.
    # 
    SYS_SYSTEM_FONT = Wx::SystemFont.new(13)
    
    # Device-dependent font.
    # 
    SYS_DEVICE_DEFAULT_FONT = Wx::SystemFont.new(14)
    
    # Default font for user interface objects such as menus and dialog boxes.
    # 
    SYS_DEFAULT_GUI_FONT = Wx::SystemFont.new(17)
    
  end # SystemFont
end
```

or the 'wxBorder' enum which is defined in wxRuby as:

```ruby
module Wx
  # Border flags for {Wx::Window}.
  class Border < Wx::Enum

    # This is different from {Wx::Border::BORDER_NONE} as by default the controls do have a border.
    # 
    BORDER_DEFAULT = Wx::Border.new(0)

    # 
    # 
    BORDER_NONE = Wx::Border.new(2097152)

    # 
    # 
    BORDER_STATIC = Wx::Border.new(16777216)

    # 
    # 
    BORDER_SIMPLE = Wx::Border.new(33554432)

    # 
    # 
    BORDER_RAISED = Wx::Border.new(67108864)

    # 
    # 
    BORDER_SUNKEN = Wx::Border.new(134217728)

    # 
    # 
    BORDER_DOUBLE = Wx::Border.new(268435456)

    # 
    # 
    BORDER_THEME = Wx::Border.new(268435456)

    # 
    # 
    BORDER_MASK = Wx::Border.new(522190848)

  end # Border
end
```

Enum instances are interchangeable with integer constants in wxRuby with respect to arithmetic or logical
operations. This make it possible to use enum values to construct integer bitflag arguments like:

```ruby
Wx::TextCtrl.new(pane, Wx::ID_ANY, sample_desc.description, style: Wx::TE_MULTILINE|Wx::TE_READONLY|Wx::BORDER_NONE)
```

where `Wx::ID_ANY` is a `Wx::StandardID` enum instance passed to provide an integer argument value, `Wx::TE_MULTILINE` 
and `Wx::TE_READONLY` are simple integer constants and `Wx::BORDER_NONE` is a `Wx::Border` enum instance.

In other cases however enum values can provide just the right kind of type safety where explicit enum values are 
expected like for example with:

```ruby
Wx::Font.new(36, Wx::FONTFAMILY_SWISS, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL)
```

where the `Wx::Font` constructor definition is:

> initialize(pointSize, family, style, weight, underline = false, faceName = `Wx::EMPTY_STRING`, encoding = `Wx::FONTENCODING_DEFAULT`) ⇒ `Wx::Font`

with the following parameter specification:

> - pointSize (`Integer`)
> - family (`Wx::FontFamily`)
> - style (`Wx::FontStyle`)
> - weight (`Wx::FontWeight`)
> - underline (`true`, `false`) (defaults to: `false`)
> - faceName (`String`) (defaults to: `Wx::EMPTY_STRING`)
> - encoding (`Wx::FontEncoding`) (defaults to: `Wx::FONTENCODING_DEFAULT`)

In this case the constructor explicitly expects specific enum value types for *family*, *style* and *weigth* and
providing the integer literal value `74` instead of `Wx::FONTFAMILY_SWISS` (or any other constant representing the same 
integer value) will not work (raises an exception) although the integer values for the two are equal.

As you have probably noticed it is not required to use the full naming for an enum instance constant (like 
`Wx::FontFamily::FONTFAMILY_SWISS`). All enum value constants are accessible from the naming scope where the enum class
to which they belong has been declared.
