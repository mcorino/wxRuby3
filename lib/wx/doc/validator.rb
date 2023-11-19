# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class Validator < EvtHandler

    # @overload initialize()
    #   Constructor.
    #   @return [Wx::Validator]
    # @overload initialize(other)
    #   Copy constructor.
    #   @param [Wx::Validator] other
    #   @return [Wx::Validator]
    def initialize(*arg) end

    # Method called when transferring data from window.
    # Should retrieve and return the data from the associated window (#get_window).
    # By default returns nil.
    # Overload for customized functionality.
    # @return [Object] retrieved data from window
    def do_transfer_from_window; end
    protected :do_transfer_from_window

    # Method called when transferring data to window.
    # Should transfer the given data to the associated window and return true if successful.
    # By default does nothing and just returns true.
    # Overload for customized functionality.
    # @param [Object] data
    # @return [Boolean]
    def do_transfer_to_window(data) end
    protected :do_transfer_to_window

    # Mixin module providing data binding options for validators.
    module Binding

      # Installs a callback handler to capture the data retrieved from the associated window.
      # The callback handler can be specified as a (name of a) method, a Proc or a block.
      #
      # @example This can be used to implement data binding like:
      #   class MyValidator < Wx::Validator
      #     def initialize(data_store)
      #       @data_store = data_store
      #       self.on_transfer_from_window :store_data
      #       self.on_transfer_to_window :load_data
      #     end
      #     protected
      #     def store_data(data)
      #       @data_store.save_the_data(data)
      #     end
      #     def load_data
      #       @data_store.get_the_data
      #     end
      #   end
      #   val = MyValidator.new(a_data_store)
      #   win.set_validator(val)
      #
      # @param [String,Symbol,Method,Proc] meth (name of) method or event handling proc; to be supplied when no block is given
      # @yieldparam [Object] data the data retrieved from the window
      def on_transfer_from_window(meth=nil, &block) end

      # Installs a callback handler to provide the data to transfer to the associated window.
      # The callback handler can be specified as a (name of a) method, a Proc or a block.
      #
      # @example This can be used to implement data binding like:
      #   class MyValidator < Wx::Validator
      #     def initialize(data_store)
      #       @data_store = data_store
      #       self.on_transfer_from_window :store_data
      #       self.on_transfer_to_window :load_data
      #     end
      #     protected
      #     def store_data(data)
      #       @data_store.save_the_data(data)
      #     end
      #     def load_data
      #       @data_store.get_the_data
      #     end
      #   end
      #   val = MyValidator.new(a_data_store)
      #   win.set_validator(val)
      #
      # @param [String,Symbol,Method,Proc] meth (name of) method or event handling proc; to be supplied when no block is given
      # @yieldreturn [Object] the data to transfer to the window
      def on_transfer_to_window(meth=nil, &block) end

      # Method called with data transferred from window.
      # By default will call the on_transfer_from_window handler if defined.
      # Returns true if successful or none defined.
      # @param [Object] data
      # @return [Boolean]
      def do_on_transfer_from_window(data) end
      protected :do_on_transfer_from_window

      # Method called to get data to transfer to window.
      # By default will call the on_transfer_to_window handler if defined.
      # Returns the handler's result if successful.
      # Otherwise returns nil.
      # @return [Object]
      def do_on_transfer_to_window; end
      protected :do_on_transfer_to_window

    end

    include Binding

  end

end
