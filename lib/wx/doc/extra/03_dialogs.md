<!--
# @markup markdown
# @title 3. wxRuby Dialogs
-->

# 3. wxRuby Dialogs

Dialogs are a special class of window which are never automatically destroyed in wxWidgets.
In C++ this does not cause a lot of management overhead for application programmers because of the possibility of
static declaration of dialogs instances where the statically declared object is automatically destructed as execution 
leaves the declaration scope.<br>
This kind of construct does not exist in Ruby where everything is dynamically allocated and garbage collection normally
takes care of releasing objects that have gone *'out of scope'*.

Like any non-owned, non-toplevel windows as discussed [here](02_lifecycles.md) this means dialogs should be explicitly 
destroyed in program code as appropriate like:

```ruby
dlg = Wx::MessageDialog.new(parent, 'Select Yes or No', "Confirmation", Wx::YES_NO)
if dlg.show_modal == Wx::ID_YES
  # do something
end
dlg.destroy
```

Although this is sometimes useful (for example in cases where a dialog is repeatedly used), most of the time this makes 
for somewhat bothersome programming.

Luckily wxRuby has a solution for this.

For all dialog classes (which includes Wx::Dialog and all it's derivatives, including user defined) the library defines
a module function which is identically named to the dialog class in the same scope as where the dialog class has been
first defined. This is similar to the module functions Ruby itself defines for the basic object classes like `Integer`, 
`String`, `Array`, `Hash` and such for the `Kernel` module.<br>
These dialog *functors* accept the same arguments as the dialog class's constructor with the addition of a block. The 
*functor* will call the class constructor and pass the created dialog instance as argument to the block. After returning
from the block the dialog instance will automatically be destroyed. So, using this approach we could write the previous
example like:

```ruby
Wx.MessageDialog(parent, 'Select Yes or No', "Confirmation", Wx::YES_NO) do |dlg|
  if dlg.show_modal == Wx::ID_YES
    # do something
  end
end
```

Even better, if the only purpose is to show the dialog until closed without caring for the result we can leave out the
block. In that case the *functor* will simply create the dialog instance, call `#show_modal` on it and destroy the 
instance after returning from `#show_modal` like:

```ruby
Wx.MessageDialog(parent, 'Hello world!', 'Information', Wx::OK)
```

Regular dialog constructors are still usable for situations where the dialog instance should have a
prolonged lifetime or where different modeless behavior is required. 
