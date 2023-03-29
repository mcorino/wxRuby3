<!--
# @markup markdown
# @title 7. wxRuby Extensions
-->

# 7. wxRuby Extensions

## Keyword Constructors

The **Keyword Constructors** extension allows the use of Ruby hash-style
keyword arguments in constructors of common WxWidgets Windows, Frame,
Dialog and Control classes.

### Introduction

Building a GUI in WxWidgets involves lots of calls to +new+, but
these methods often have long parameter lists. Often the default
values for many of these parameters are correct. For example, if
you're using a sizer-based layout, you usually don't want to specify a
size for widgets, but you still have to type

    Wx::TreeCtrl.new( parent, -1, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::NO_BUTTONS )

just to create a standard TreeCtrl with the 'no buttons' style. If you
want to specify the 'NO BUTTONS' style, you can't avoid all the typing
of DEFAULT_POSITION etc.

### Basic Keyword Constructors

With keyword_constructors, you could write the above as

    TreeCtrl.new(parent, :style => Wx::NO_BUTTONS)

And it will assume you want the default id (-1), and the default size
and position. If you want to specify an explicit size, you can do so:

    TreeCtrl.new(parent, :size => Wx::Size.new(100, 300))

For brevity, this module also allows you to specify positions and
sizes using a a two-element array:

    TreeCtrl.new(parent, :size => [100, 300])

Similarly with position:

    TreeCtrl.new(parent, :pos => Wx::Point.new(5, 25))
    
    TreeCtrl.new(parent, :pos => [5, 25])

You can have multiple keyword arguments:

    TreeCtrl.new(parent, :pos => [5, 25], :size => [100, 300] )

### No ID required

As with position and size, you usually don't want to deal with
assigning unique ids to every widget and frame you create - it's a C++
hangover that often seems clunky in Ruby. The **Event Connectors**
extension allows you to set up event handling without having to use
ids, and if no `:id` argument is supplied to a constructor, the default
(-1) will be passed.

There are occasions when a specific ID does need to be used - for
example, to tell WxWidgets that a button is a 'stock' item, so that it
can be displayed using platform-standard text and icon. To do this,
simply pass an :id argument to the constructor - here, the system's
standard 'preview' button

    Wx::Button.new(parent, :id => Wx::ID_PREVIEW)

### Class-specific arguments

The arguments `:size`, `:pos` and `:style` are common to many WxWidgets
window classes. The `new` methods of these classes also have
parameters that are specific to those classes; for example, the text
label on a button, or the initial value of a text control.

    Wx::Button.new(parent, :label => 'press me')
    Wx::TextCtrl.new(parent, :value => 'type some text here')

The keyword names of these arguments can be found by looking at the
WxRuby documentation, in the relevant class's +new+ method. You can
also get a string description of the class's +new+ method parameters
within Ruby by doing:

    puts Wx::TextCtrl.describe_constructor()

This will print a list of the argument names expected by the class's
+new+ method, and the correct type for them.

### Mixing positional and keyword arguments

To support existing code, and to avoid forcing the use of more verbose
keyword-style arguments where they're not desired, you can mix
positional and keyword arguments, omitting or including `id`s as
desired.

    Wx::Button.new(parent, 'press me', :style => Wx::BU_RIGHT)

### Handling complex defaults or version differences

To support complex (context dependent) defaults and/or auto conversion
of arguments for backwards compatibility the keyword constructors
extension allows the definition of lambdas or procs to be associated
with a parameter specification.
