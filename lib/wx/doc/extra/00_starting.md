<!--
# @markup markdown
# @title 0. Overview of wxRuby
-->

# 0. Overview of wxRuby

## What is wxRuby?

wxRuby3 is a cross-platform GUI library for Ruby, based on the popular [wxWidgets](https://wxwidgets.org)
cross platform GUI toolkit for C++. It uses native widgets wherever possible, providing
the correct look, feel and behaviour to GUI applications on Windows, OS
X and Linux/GTK. wxRuby aims to provide a comprehensive solution to
developing professional-standard desktop applications in Ruby.

Like Ruby and wxWidgets, wxRuby is Open Source, which means that it is free for anyone to use and the source code 
is available for anyone to look at and use in any way they like. Also, anyone can contribute (tested) fixes, additions 
and enhancements to the project.

Like wxWidgets wxRuby is a cross platform toolkit. This means that the same program will run on multiple platforms 
without modification. Currently Supported platforms are Microsoft Windows and Linux or other 
unix-like systems with GTK2 or GTK3 libraries. As wxWidgets also has stable releases for Mac OSX and Linux QT platforms
it should not be to hard to support these. Contributions to achieve this are appreciated.

Since the programming language is Ruby, wxRuby programs are simple and easy to write and understand. To accomplish the
full Ruby experience wxRuby has not ported the wxWidgets API 1 on 1 to Ruby but has made an effort to make the wxRuby
API typically Ruby-ish. This means all method signatures (names, arguments) have been transformed to conform to common
Ruby naming rules as well as other Ruby programming practices. Also does wxRuby introduce iterators in favor of getters
returning arrays or lists.
Check out the samples and the documentation for details.

## What is wxRuby3?

The wxRuby3 project is a new, rebooted, implementation of wxRuby (as compared to wxRuby2 and earlier versions) with the
clear intent to make this implementation better maintainable and extensible.

To this end wxRuby3 adopted much of the approach of the wxPython Phoenix project in that the wxRuby API is generated 
from the wxWidgets XML interface definitions. Unlike the Phoenix project however, wxRuby does not use a home-grown
interface code generator but rather still relies on SWIG for that (with Ruby tooling to configure and post-process).
The wxRuby generation process more or less conforms to: 

1. build wxWidgets interface XML
2. parse interface XML
3. generate SWIG interface definitions
4. generate Ruby extension code with SWIG
5. post-process Ruby extension code

As the wxRuby tooling is already parsing the full wxWidgets interface specs (from which wxWidgets generates it's own 
reference documentation) it also uses the parsed information to generate matching reference documentation for the 
wxRuby API. This documentation is not (yet) perfect but should go a long way in helping people using wxRuby to build
GUI applications.

The wxRuby3 API is largely compatible with the earlier wxRuby incarnations but not 100% mostly due to more 
modularization and more explicit typing of (especially) enums. Also wxRuby3 exclusively targets a lot more modern 
versions of wxWidgets (>= 3.2) and Ruby (>= 2.5) so there are some shifts from that as well. All in all though,
people that once took a stab at looking at wxRuby(2) should not have much problems getting up to speed again. 

## Quick start

To create an application with wxRuby you need to require the wxRuby libraries:

```ruby
require 'wx'
```

Next would be the application code and a main entry point. With wxRuby (as with wxWidgets) the entry
point is mostly just a simple call to start the applications event loop (as we're talking about event 
based GUI applications here). 
In wxRuby the Wx::App class provides some typically Ruby-style magic to make this as easy as possible.

Using this the simplest Hello World application could be:

```ruby
require 'wx'
Wx::App.run { puts 'Hello world!' }
```

As you can there is no obligation to create an instance of the Wx::App class in wxRuby for
(admittedly extremely) simple applications. Calling the #run class method with a block will suffice.<br>
The class method will create an instance of the generic Wx::App class under the hood and use the 
provided block as the #on_init callback. As the code inside the block returns a false-type value (#puts 
returns `nil`) the application will terminate immediately after writing "Hello world!" to standard
output (actually not even starting the event loop at all).

Of course this is not truly a GUI application so let's elaborate a little to make the GUI element
more real.

```ruby
require 'wx'
Wx::App.run { Wx::Frame.new(nil, title: 'Hello World!').show }
```

Executing this will create a generic Frame instance in the on_init callback of the application
and show the frame. As #show returns a true-type when successful the event loop will actually be
started and keep the application running until the frame is closed. 

## The application class

For more complex applications the approach demonstrated above will quickly become insufficient. In those cases
creating a specialized derived App class is the better option.
This provides the possibility (as with all Ruby classes) to override the constructor (#initialize) for
custom initialization, attribute definitions and create customized #on_init and/or #on_exit methods like
this:

```ruby
require 'wx'

class MyApp < Wx::App
  def initialize
    super
    @frame = nil
  end
  attr_reader :frame
  
  def on_init
    @frame = Wx::Frame.new(nil, title: 'Hello World!')
    @frame.show
  end
  
  def on_exit
    puts 'Exiting.'
  end
end
```

When creating #on_init/#on_exit methods it is important to understand that those would not be overrides (as is the case
with wxWidgets itself). The base Wx::App class actually does not define these methods so it's also not needed (even not possible)
to call `super` in the implementation. The wxRuby application class implementation will call the wxWidget OnInit base implementation
itself and after successful completion check for the existence of an #on_init method (which could also be 'automagicallly'
created from a block passed to #run) and call that if available or terminate the application if not. For the
exit sequence to executions are similar but reversed (first a possible #on_exit method and than the wxWidgets base OnExit).

What remains though is that for a derived application class it is still not necessary to explicitly create a class instance.
Simply calling the #run class method will suffice.

```ruby
MyApp.run
```

The current application instance (as long as the application is active) can always be retrieved by
calling `Wx.get_app`.

## wxRuby modules

The toplevel module of the wxRuby library is the `Wx` module and when using `require 'wx'` to load the wxRuby library
**all** constants and classes are loaded and can be accessed from that scope like `Wx::Frame` or `Wx::RichTextCtrl` 
like previous versions of wxRuby supported.

With the current wxRuby library however a more modular approach has been used similar to wxWidgets itself which
distributes implementations over various sub-modules. These sub-modules can be loaded separately to provide more control.
The core module still provides the toplevel `Wx` namespace and all classes and constants declared in that namespace.
All other modules add to that (and **all** require the core module).

See [here](01_packages.md) for more details on wxRuby sub-modules.
