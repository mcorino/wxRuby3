# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # Function used to create the correct persistent adapter for the given object.
  #
  # This is a compatibility function that simply redirects the call to the object itself. Any object class
  # supporting persistence should implement the #create_persistent_object method to return a Wx::PersistentObject
  # instance for the object it is called for.
  # This method raises a NoImplementError if the object class does not support persistence.
  # @see Defining Custom Persistent Windows
  # @param obj [Object]
  # @return [Wx::PersistentObject]
  def self.create_persistent_object(obj) end

  # A shorter synonym for {Wx::PersistenceManager#register_and_restore}.
  #
  # This function simply calls {Wx::PersistenceManager#register_and_restore} but using it results in slightly shorter
  # code as it calls {Wx::PersistenceManager.get} internally. As an additional convenience, this function can also set the window name.
  #
  # Returns true if the settings were restored or false otherwise (this will always be the case when the program runs
  # for the first time, for example).
  # @param obj [Wx::Window]  window to register with persistence manager and to try to restore the settings for.
  # @param name [String]  If specified non-empty, window name is changed to the provided value before registering it.
  # @return [Boolean]
  def self.persistent_register_and_restore(obj, name=nil) end

  # class alias
  PersistentWindow = PersistentWindowBase

end
