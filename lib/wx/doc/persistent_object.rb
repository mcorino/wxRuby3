# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class PersistentObject < ::Object

    # Save the specified value using the given name.
    # @param [String] name The name of the value in the configuration file.
    # @param [::Object] value The value to save, currently must be a type supported by wxConfig.
    # @return [Boolean] true if the value was saved or false if an error occurred.
    def save_value(name, value); end
    protected :save_value

    # Restore a value saved by {#save_value}.
    # @param [String] name The name of the value in the configuration file.
    # @return [Object,nil] The value if successfully read, nil otherwise
    def restore_value(name); end
    protected :restore_value

  end

end
