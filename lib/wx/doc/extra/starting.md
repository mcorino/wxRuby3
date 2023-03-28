<!--
# @markup markdown
# @title Starting with wxRuby
-->

# Starting with wxRuby

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
**all** constants and classes are loaded and can be accessed from that scope like `Wx::Frame` like previous versions of wxRuby provided.

With the current wxRuby library however a more modular approach has been used similar to wxWidgets itself which
distributes implementations over various sub-modules. These sub-modules can be loaded separately to provide more control.
The core module still provides the toplevel `Wx` namespace and all classes and constants declared in that namespace.
All other modules add to that (and **all** require the core module).

This way only part of the wxRuby library can be loaded like:

```ruby
require 'wx/core' # load wxRuby core Wx module
require 'wx/grid' # load wxRuby Wx::GRID module - provides Grid control
require 'wx/rtc'  # load wxRuby Wx::RTC module - provides RichText control 
```

However, when loading the library like this scoping rules change by default. Specifically the constants and classes
from the loaded sub-modules will **not** be accessible from the `Wx` scope anymore (like `Wx::Grid`) but must instead be
explicitly scoped from the sub-module (like `Wx::GRID::Grid`).

It is possible to revert the 'global scope' resolution behaviour by setting the toplevel constant `WX_GLOBAL_CONSTANTS` to
`true` before the require statements like:

```ruby
WX_GLOBAL_CONSTANTS=true
require 'wx/core' # load wxRuby core Wx module
require 'wx/grid' # load wxRuby Wx::GRID module - provides Grid control
require 'wx/rtc'  # load wxRuby Wx::RTC module - provides RichText control 
```

See [here](packages.md) for more details on wxRuby sub-modules.
