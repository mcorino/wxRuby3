<!--
# @markup markdown
# @title 13. Validators and data binding
-->

# 13. Validators and data binding

## Introduction

wxRuby fully supports validator classes offering input validation and/or data binding and/or event filtering. 

## Validation

The base Wx::Validator class defines the method {Wx::Validator#validate} which is called when validation of the
value or content of the associated window is required.

The implementation of this method should (somehow) retrieve the value of the associated window and validate that
value, returning `true` if valid or `false` otherwise. The default implementation always returns `false`.

An example would be:

```ruby
# define custom validator
class MyTextValidator < Wx::Validator

  def validate(_parent)
    txt = get_window.value
    # validate that the control text starts with a capital if not empty
    txt.empty? || (?A..?Z).include?(txt[0])
  end

end

# ...

# assign custom validator to text control
text = Wx::TextCtrl.new(parent, MY_TEXT_ID)
text.set_validator(MyTextValidator.new)
```

The derived, specialized, validator classes {Wx::TextValidator}, {Wx::IntegerValidator}, {Wx::IntegerValidator} and 
{Wx::FloatValidator} all have implementations that can be configured through specific options and do not 
normally require an override to be defined.

Examples of using the standard validators would be:

```ruby
text = Wx::TextCtrl.new(parent, MY_TEXT_ID)

# accept only hexadecimal characters
text.set_validator(Wx::TextValidator.new(Wx::TextValidatorStyle::FILTER_XDIGITS))

# or only numbers between -20 and 20
text.set_validator(Wx::IntegerValidator.new(-20, 20))
```

## Event filtering

All validator classes are event handlers and can have event handling routines defined (see 
[Event Handling](05_event-handling.md)).
When processing events the core implementation will allow any validator associated with a window to handle an event
before the associated window itself thereby allowing it to filter events (see {Wx::EvtHandler#process_event} for more 
details).

The standard specialized validators use this functionality to filter entry of allowable characters (by handling 
Wx::EVT_CHAR events).

## Data binding

Data binding concerns the transfer of a validator's associated window's value to or from a user definable storage (a 
variable, memory cache entry, persistent storage ...).

To integrate with the core C++ implementation but allow for Ruby specific differences the scheme implemented for this
differs somewhat (in naming and functionality) from the original wxWidgets interface.

The responsibilities of the standard wxRuby interface for handling validator data binding is distributed over 2 base 
methods and a mixin module.  

- The protected {Wx::Validator#do_transfer_from_window} and {Wx::Validator#do_transfer_to_window} methods are 
  responsible for collecting and transferring data from/to the associated window (possibly applying conversions).<br>
  <br>
  These methods have default implementations in all of the derived validator classes and should not be overridden for
  specializations of these as they will be ignored.<br>
  Overriding these methods is necessary to implement data binding for any user defined specialization of the base 
  {Wx::Validator} class.<br>
  <br>
- The methods the {Wx::Validator::Binding} mixin module provide the means to store data after collection from or retrieve data 
  before transfer to the associated window.<br>
  <br>
  The methods {Wx::Validator::Binding#on_transfer_from_window} and {Wx::Validator::Binding#on_transfer_to_window} provide
  the means to specify user defined handlers for storing the data transferred from the associated window or retrieving the
  data to transfer to the associated window. Like with event handling the handlers can be specified using a `String` or
  `Symbol`, a `Proc` or a `Method`.<br>
  <br>
  The methods {Wx::Validator::Binding#do_on_transfer_from_window} and {Wx::Validator::Binding#do_on_transfer_to_window} by
  default call the binding handlers if defined.
  These methods can be overridden to create derived validator classes with dedicated data binding functionality like 
  with {Wx::GenericValidator}.

An example of a custom validator providing data binding would be:

```ruby
class MyTextValidator < Wx::Validator

  def do_transfer_from_window
    get_window.get_value
  end

  def do_transfer_to_window(val)
    get_window.set_value(val)
    true
  end
  
end

# ...

# use custom validator
@data = nil # attribute to store data
text.set_validator(MyTextValidator.new)
text.get_validator.on_transfer_to_window { @data }
text.get_validator.on_transfer_from_window { |v| @data = v }
```

### Wx::GenericValidator

The {Wx::GenericValidator} class provides an extendable standard implementation for data binding in combination with a 
large collection of controls (see class documentation).
The implementation provides a standard accessor {Wx::GenericValidator#value} to get access to the data value collected
from the associated window or transfer to the associated window.

To add support for any control unsupported by the standard implementation the method {Wx::GenericValidator.define_handler}
is provided (see documentation for an example).
