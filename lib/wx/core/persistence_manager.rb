# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  # Function used to create the correct persistent adapter for the given object.
  def self.create_persistent_object(obj)
    obj.create_persistent_object
  end

  # A shorter synonym for {Wx::PersistenceManager#register_and_restore}.
  def self.persistent_register_and_restore(obj, name=nil)
    obj.name = name if name && !name.empty?
    PersistenceManager.get.register_and_restore(obj)
  end

  class PersistenceManager

    class << self

      # Cache the global instance to keep it safe from GC

      wx_get = instance_method :get
      wx_redefine_method :get do
        @the_manager ||= wx_get.bind(self).call
      end

      wx_set = instance_method :set
      wx_redefine_method :set do |pman|
        wx_set.bind(self).call(pman)
        @the_manager = pman
      end

    end

  end

end
