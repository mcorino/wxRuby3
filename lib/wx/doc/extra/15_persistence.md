<!--
# @markup markdown
# @title 15. Persistence support
-->

# 15. Persistence support

## Introduction

wxRuby3 fully supports the wxWidgets persistence framework.

This framework provides the means to persist window (and other object) states which can than be restored when
re-creating these objects.

The persistence framework depends on the configuration framework (see [here](14_config.md)).

The persistence framework includes the following components:

* {Wx::PersistenceManager} which all persistent objects register themselves with. This class handles actual saving 
  and restoring of persistent data.
* Persistent object adapters for persistent objects. These adapters provide a bridge between the associated class – 
which has no special persistence support – and {Wx::PersistenceManager}. All Persistent object adapters need to derive 
from {Wx::PersistentObject} (like {Wx::PersistentWindowBase} and it's derivatives).
* The {Wx.create_persistent_object} and {Wx.persistent_register_and_restore} methods (mainly convenience methods for 
wxWidgets compatibility).

## Persistence manager

By default a global singleton manager instance is available through {Wx::PersistenceManager.get} which will be used
by all available persistent object adapters for saving/restoring state values.

An alternate (possibly customized) manager instance can be installed through {Wx::PersistenceManager.set}.

## Persistent object adapters

All persistent object adapters must be derived from {Wx::PersistentObject}. This class provides common methods for
saving and restoring state values connecting to the persistence manager for actual writing and reading.

All windows/objects to be persisted need to be registered with the persistence manager. Creating the correct persistent
object adapter instance for an object to persist is abstracted away in wxWidgets by using template methods allowing
to simply only provide the object to persist instead of having to explicitly instantiate an adapter instance and provide
both to the persistence manager (which is however still possible).

wxRuby3 replaces this convenience interface (incompatible with Ruby) by a Ruby-fied approach which relies on Rubies 
trusted *duck typing*.<br>
In wxRuby3 any class supported by a specific persistent object adapter class should implement the method 
`#create_persistent_object` which should return a unique adapter instance for the object instance to be persisted 
like this:

```ruby
class MyPersistentObject < Wx::PersistentObject

  # Save the object properties.
  # The implementation of this method should use {Wx::PersistentObject#save_value}.
  # @return [void]
  def save
    # ...
  end

  # Restore the object properties.
  # The implementation of this method should use {Wx::PersistentObject#restore_value}.
  # @return [Boolean]
  def restore
    # ...
  end

  # Returns the string uniquely identifying the objects supported by this adapter.
  # This method has default implementations in any of the built-in derived adapter classes.
  # @return [String]
  def get_kind
    'MyObject'
  end

  # Returns the string uniquely identifying the object we're associated with among all the other objects of the same type.
  # This method has a default implementation in Wx::PersistentWindowBase returning the window name.
  # @return [String]
  def get_name
    'object_1'
  end

end

class MyObject
  
  # ...
  
  def create_persistent_object
    MyPersistentObject.new(self)
  end
  
  # ...
  
end
```

## Persistent windows

A number of classes provide built-in support for persistence of a number of windows or controls:

* {Wx::PersistentTLW} supports top level windows (including {Wx::Frame} and {Wx::Dialog}).
* {Wx::PersistentBookCtrl} supports the book controls {Wx::Notebook}, {Wx::Listbook}, {Wx::Toolbook} and {Wx::Choicebook}.
* {Wx::PersistentTreeBookCtrl} supports {Wx::Treebook}

All persistent window adapters are derived from {Wx::PersistentWindowBase}. This class makes sure that any window 
registered for persisting gets automatically saved when the window is destroyed. Intermittently explicit saving still
remains possible of course.

User defined persistent window adapters can be derived from this class or any of the built-in derivatives to support
otherwise unsupported or custom windows/controls like this:

```ruby
class PersistentButton < Wx::PersistentWindowBase

  def get_kind
    'Button'
  end
    
  def save
    save_value('w', get.size.width)
    save_value('h', get.size.height)
    save_value('label', get.label)
    save_value('my_custom_value', get.my_custom_value)
  end
    
  def restore
    get.size = [Integer(restore_value('w')), Integer(restore_value('h'))]
    get.label = restore_value('label')
    get.my_custom_value = Float(restore_value('my_custom_value'))
    true
  end

end

class MyButton < Wx::Button

  def initialize(parent=nil, name)
    super(parent, label: '', name: name)
    @my_custom_value = ''
  end

  attr_accessor :my_custom_value

  def create_persistent_object
    PersistentButton.new(self)
  end

end
```
