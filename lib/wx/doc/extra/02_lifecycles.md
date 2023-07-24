<!--
# @markup markdown
# @title 2. wxRuby Life Cycles
-->

# 2. wxRuby Life Cycles

## Introduction

Managing the life cycles of native objects in Ruby extension libraries is tricky business because of the disparity 
between common C++ dynamic memory management and the GC management scheme of the Ruby language and this certainly applies
to an event based environment like the wxRuby extension for wxWidgets.
That said, the wxRuby library should provide you with a fairly worry-free API in that respect.

The wxRuby extension manages to provide water-tight GC management for just about all mapped wxWidget objects.

There are just a few, fairly specific, things to take notice of.

## Application instance

Any wxWidgets application typically creates a single application instance and the same goes for wxRuby applications.
We already saw [here](00_starting.md) how to start a wxRuby application. Important to note is that any reference to the 
(global) application instance will ever only be valid as long as the application is still active.<br>
In essence this means the reference is valid from the moment the constructor (`#initialize`) is called to the moment
any available `#on_exit` method has finished.

There are some caveats to that however. 

1. Although the application instance is valid in the constructor, the wxWidgets
framework will only be fully initialized the moment the `#on_init` method starts. This means that all kinds of methods 
requiring initialized GUI resources (like window creation) will fail if called before that moment.

2. The global application instance returned by `Wx.get_app` will only be set from the moment the `#on_init` method 
starts to the moment the `#on_exit` method finishes. Outside that timespan the method will return `nil`.

Also be careful with storing your own application instance variables. Code like

```ruby
class MyApp < Wx::App
  def initialize
    super
    # ...
  end
  def on_init
    # ...
  end
end
$app = MyApp.new
$app.run
```

is entirely valid but for the fact that you **should** remember that after the `#run` method returns the `$app` variable
does **not** reference a valid application instance anymore. Calling methods on that instance may result in unexpected 
behavior.<br>
It is actually easier and safer to rewrite this code as:

```ruby
class MyApp < Wx::App
  def initialize
    super
    # ...
  end
  def on_init
    # ...
  end
end
MyApp.run # or MyApp.new.run
```

This way there is no reference to accidentally use after `#run` returns and `Wx.get_app` will return `nil` after that 
moment.

## Framework (re-)initialization

As mentioned above the wxWidgets GUI framework resources will only be fully initialized after the `#on_init` method
starts. Likewise the framework resources will be de-initialized (deleted) after `#on_exit` method ends which means that 
your application should not attempt to access any of these resources (windows, fonts, colours etc.) after that moment.

Also, largely because of the way the wxWidgets framework is designed but also because of the way this meshes with Ruby 
GC, there is no safe way to re-initialize the framework after an application instance ends it run. This means you 
**cannot** safely attempt to start another application instance after a previous (first) one has ended. 

## Windows

Window instances (and it's derivatives) are fully managed by the wxWidget framework and cannot (are not) managed by 
Ruby GC handling. This means on the one hand that a window instances life time is not controlled by any reference
a Ruby variable may hold and on the other hand that the Ruby object linked to that native window object is kept alive
(marked in GC) as long as the window instance is alive.<br>
Generally speaking window lifetimes are dependent on the (toplevel) window (or it's parent) being closed. In case of a 
toplevel window this result in automatic destruction of the window and all it's child windows (controls). There are 
however exceptions to this where explicit calling of a window's `#destroy` method is required to prevent memory leaks
(when a window is not a child window but also not a toplevel window for example or in case of dialogs; see 
[here](03_dialogs.md)). Please check out the wxWidgets documentation for more detailed information.

This has several consequences you need to be aware of.

First of, in cases where you keep a reference to any window (control) instance in a local or instance variable in Ruby 
(which is fairly common practice) you need to be aware that the reference is only valid as long as the window has not 
been destroyed. In most cases this will not be an issue as most references are kept as instance variables of parent 
windows for child windows where the instance variables will only ever be used as long the parent window is alive itself. 
In other circumstances you should take care to track the lifetime of the window that is referenced.

Secondly, as already indicated above not all window instances will be automatically destroyed. It is for example fairly 
common in more complex applications to create and show other windows as response to events triggered in the toplevel 
window. These windows will not (and should not) be automatically designated as toplevel window but they are also not 
owned (i.e. not child windows). Closing these windows will not automatically destroy them (which is a good thing as 
these are often re-shown after renewed events from the toplevel window) and will also not be automatically destroyed 
when any parent window is destroyed. This means they pose a threat for potential memory leaks.<br>
In case it concerns a fairly simple application which creates one or two of these sub-windows and needs to keep these
around for most or all of the lifetime of the application this is not really an issue as the window will be cleaned up
at application exit eventually. If however it concerns a more complex application which potentially could create a large
number of these sub windows (probably each only used for limited purposes) it would be advisable to track instances and
destroy these on a regular basis when not used (closed) possibly re-creating them as needed.

Dialogs are special cases of toplevel windows which are not automatically destroyed when closed. The wxRuby library
therefor provides special support to ease handling the destruction of these. See [here](03_dialogs.md) for more details.

## Object identities

One of the trickier things to handle correctly in the kind of native extensions like wxRuby is maintaining object 
identities i.e. keeping native instances synced with their Ruby wrapper counter parts.

Whenever a native extension is allowed to call back into Ruby space we encounter the problem that we need to map any 
native object data provided for the call to the right Ruby types and when necessary to the right Ruby instance (object
identity).

Objects that are considered POD types (*plain old data* types) like numerics, booleans, strings, arrays and hashes do
not require maintaining *object identity*. For these objects it is enough to map them to the right Ruby type before
passing them on to Ruby space.

For a lot of other objects though it is essential to not only map to the right **most derived** class type but also to
the exact Ruby instance which was originally instantiated as wrapper for the native object if any exists (in case no
Ruby instance existed yet a new instance of the correct **most derived** class should be instantiated at that point). 
The reason this is important is **1.** because the Ruby instance may have been used to identify, link to or otherwise 
reference other data and/or functionality related to that specific Ruby/native pair and **2.** the Ruby instance could 
contain data elements (instance variables) related to that specific Ruby/native pair.<br>
In the case of wxRuby Window instance for example it is common to derive custom Window classes with custom behaviour and
corresponding instance variables that drive that behaviour. When an event handler or an overloaded native method is passed
a native window object we absolutely need to be able to map that native object to the correct Ruby wrapper instance so
all information stays in sync.

For this purpose wxRuby uses *object tracking* i.e. maintaining hash tables mapping native object pointers to Ruby object 
values. Whenever a tracked object is instantiated it is registered and can from than on be resolved whenever needed to map
from native object to Ruby object.<br>
Of course this also means wxRuby has to track object destruction so mappings can be removed when a native object is 
destructed.<br>
Additionally the tracking tables are also used to mark Ruby objects during the GC marking phase so they do not get garbage
collected whenever they are not referenced in Ruby space anymore but still functioning in native space (this is for example
a common situation for many child windows created but not permanently referenced in Ruby space).

Tracking and resolving mappings from tracking tables produces a certain computing overhead but testing has shown this to be
absolutely acceptable for normal applications.

There are however quite a lot of wrapped native objects in wxRuby for which *object identity* is not essential. For these
object tracking has been disabled for their classes. This means these kind of classes/object should **not** be derived from
(if even possible and/or useful) to add functionality/information or their identity used as key to link other information.<br>
These classes include:
* classes considered POD types like Wx::Size, Wx::Point, Wx::RealPoint, Wx::Rect, Wx::GBSpan, Wx::GBPosition, Wx::BusyInfoFlags,
Wx::AboutDialogInfo
* final non-instantiatable classes like the Wx::DC (Device Context) class family, Wx::GraphicsContext, Wx::WindowsDisabler,
Wx::EventBlocker, Wx::BusyInfo
* classes with native singleton objects like Wx::Clipboard
* the reference counted GDI objects like Wx::Pen, Wx::Brush, Wx::Colour, Wx::Cursor, Wx::Bitmap, Wx::Icon and similar 
reference counted objects like Wx::Font

The reference documentation will note untracked object classes.
