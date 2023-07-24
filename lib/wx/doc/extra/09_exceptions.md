<!--
# @markup markdown
# @title 9. wxRuby Exception Handling
-->

# 9. wxRuby Exception Handling

The wxRuby library should (!) be completely exception safe, i.e. Ruby code raising an exception should not leak into
the wrapped wxWidgets C++ code and cause unexpected exception handling or (worse) segmentation faults and should be 
handled in ways expected of Ruby applications.

As the wxWidgets library does not use exceptions for it's public API any raised exceptions should come either from the
wxRuby wrapper code (signalling mostly typical Ruby-ish error situations like ArgumentError, TypeError and such) or from
your own Ruby application code.

Any exceptions raised from wxRuby wrapper code signal coding errors that need to be rectified.

As far as handling application code exceptions is concerned the same advice applies as for wxWidgets itself; do **NOT**
let exceptions escape your event handlers meaning that if you can reasonably expect application code to raise exceptions
you should make sure to catch any such exceptions within the context of the event handler like:

```ruby
class MyForm < Wx::Frame
  
  def initialize(title)
    super(nil, title: title)
    
    # initialize frame elements
    # ...
    
    # setup event handlers
    evt_menu MY_MENU_ID, :on_my_menu_item
    
    # ...
  end
  
  def on_my_menu_item(evt)
    begin
      # execute some application code
      # ...
    rescue SomeException => ex 
      # handle exception
    end
  end
  
  #...
  
end
```

In wxRuby event handler code is executed in an exception safe way which will capture any leaking exceptions. As wxRuby 
however has no idea why this exception was raised and how to handle it, the result will be an exit of the main event loop
of the running `Wx::App` instance and re-raising the exception to be handled by Ruby like any unhandled application 
exception.
