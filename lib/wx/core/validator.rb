# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::Validator

  # Default implementation of clone, may need to be over-ridden if
  # custom subclasses should state variables that need to be copied
  # NOTE: There is no way to copy the bindings here so do NOT
  def clone
    begin
      self.class.new(self)
    rescue
      p $!
      raise
    end
  end

  # overload for customized functionality
  def do_transfer_from_window
    nil # by default just return nil
  end
  protected :do_transfer_from_window

  # overload for customized functionality
  def do_transfer_to_window(_data)
    true # by default just return true
  end
  protected :do_transfer_to_window

  protected :do_on_transfer_from_window
  protected :do_on_transfer_to_window

  module Binding
    def self.included(base)
      wx_on_transfer_from_window = base.instance_method :on_transfer_from_window
      base.wx_redefine_method :on_transfer_from_window do |meth = nil, &block|
        proc = if block and not meth
                 block
               elsif meth and not block
                 h_meth = case meth
                          when Symbol, String then self.method(meth)
                          when Proc then meth
                          when Method then meth
                          end
                 # check arity == 1
                 if h_meth.arity != 1
                   Kernel.raise ArgumentError,
                                "on_transfer_from_window handler should accept a single argument"
                 end
                 h_meth
               end
        wx_on_transfer_from_window.bind(self).call(proc)
      end

      wx_on_transfer_to_window = base.instance_method :on_transfer_to_window
      base.wx_redefine_method :on_transfer_to_window do |meth = nil, &block|
        proc = if block and not meth
                 block
               elsif meth and not block
                 h_meth = case meth
                          when Symbol, String then self.method(meth)
                          when Proc then meth
                          when Method then meth
                          end
                 # check arity == 0
                 if h_meth.arity != 0
                   Kernel.raise ArgumentError,
                                "on_transfer_to_window handler should not accept any argument"
                 end
                 h_meth
               end
        wx_on_transfer_to_window.bind(self).call(proc)
      end
    end
  end

  include Binding

end
