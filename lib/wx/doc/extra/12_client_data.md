<!--
# @markup markdown
# @title 12. Client/User data with wxRuby
-->

# 12. Client/User data with wxRuby

## Introduction

The wxWidgets library has widespread support for attaching arbitrary client (or user) data to GUI elements like
windows (all event handlers actually), window items, sizer items etc.
To cater to various C++ use cases in most instances this support covers both specific wxWidgets defined types (like
wxClientData and wxObject instances) and untyped data pointers (represented as `void *`) with subtle but essential
differences.

wxRuby implements a fully compatible version of this support.    

## Everything is an Object

As Ruby does not do untyped data (everything is an Object), and having two different options is confusing anyway, 
wxRuby provides only a single option and more or less unifies the interface across the entire library.
In Ruby anywhere the original wxWidgets library supports some type of client (or user) data attachment wxRuby will 
support the attachment of any arbitrary Ruby `Object` by either the method `#set_client_object` (where C++ supports 
`SetClientData` and `SetClientObject`) or `#set_user_data` (where C++ supports `SetUserData`). Data retrieval
is supported by complementary `#get_client_object` or `#get_user_data` methods in all cases.
Wherever C++ supports `SetClientObject` wxRuby also provides the method aliases `#set_client_data` and `#get_client_data`.

Another difference with C++ is that for typed client data in wxWidgets developers could leverage object destruction as 
callback trigger (through the implementation of virtual destructors) to handle any required 'unlinking' logic. This
obviously does not apply to untyped data (one of the 'subtle' differences).
As Ruby does not provide any usable object destruction hooks this does not work there.
Ruby however has 'Duck-typing' which is what wxRuby uses to provide support for a unlinking callback 'hook' for attached
client data.

> Any attached Ruby Object implementing (responding to) the method `#client_data_unlinked` will have that method called after the 
> attached object has been detached from the element it was attached to (either because of data replacement or element 
> deletion).

Regard the following example.

```ruby
    frame = Wx::Frame.new(nil, Wx::ID_ANY)
    
    # attach a hash with user data  
    frame.set_client_data({ text: 'A string', float: 3.14 })
    
    # ... do something with frame
    
    # replace the user data
    frame.set_client_data([1,2,3,4])

    # ... do something else with frame
```

In this case standard Ruby object are attached. After attachment the object can be retrieved using a call to `get_client_data`
anywhere access to the frame instance is available.

Using a specially derived (or adapted) object a developer can handle specific logic after the object has been unlinked 
like in this example:

```ruby
    # define a user data class
    class MyUserData
      def initialize(payload)
        @payload = payload
      end
      attr_reader :payload
      
      def client_data_unlinked
        # handle some logic
      end
    end

    # ...

    # attach data to some window
    win.set_client_data(MyUserData.new(some_payload_data)) 

    # ...
    
    # reset user data for some reason (will call MyUserData#client_data_unlinked after replacement)
    win.set_client_data(nil)
```

# CommandEvent data

wxRuby also fully supports the propagation of attached client data to Wx::CommandEvent objects (see
{Wx::CommandEvent#get_client_object} and {Wx::CommandEvent#set_client_object}).
As mentioned above wxRuby provides the method aliases `#set_client_data` and `#get_client_data` here also. 
