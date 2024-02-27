# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  class SecretStore

    # Wipes the secret data.
    # @param [String] secret string containing secret data
    # @return [void]
    def self.wipe(secret); end

  end

  class SecretValue

    # @overload initialize()
    #   Creates an empty secret value (not the same as an empty password).
    #   @return [Wx::SecretValue]
    # @overload initialize(secret)
    #   Creates a secret value from the given string.
    #   The secret argument may contain NUL bytes.
    #   Any UTF-8 encoded (or encodable; wxRuby will attempt re-encoding as UTF-8 for any string not encoded UTF-8 or ASCII-8BIT) string will be stored as UTF-8 encoded string.
    #   In these cases use {#get_as_string} if needing to compare the original string to a restored string.
    #   Otherwise the string will be stored as ASCII-8BIT encoded string.
    #   In these cases use {#get_data} if needing to compare the original string to a restored string.
    #   See {#==} for comparing secret values opaquely.
    #   @param secret [String]
    #   @return [Wx::SecretValue]
    # @overload initialize(other)
    #   Creates a copy of an existing secret.
    #   @param other [Wx::SecretValue]
    #   @return [Wx::SecretValue]
    def initialize(*args) end

    # Returns a copy of the secret data as an ASCII-8BIT encoded String.
    # Be aware this could be binary data and may contain embedded NUL characters.
    # For more security {Wx::SecretStore.wipe} should be used to wipe the secret data after use.
    # @return [String] secret data
    def get_data; end

    # Returns a copy of the secret data as an UTF-8 encoded String.
    # Make sure to use this method only if sure that the secret originally stored was indeed
    # UTF-8 data as otherwise the returned string will not match the stored data.
    # For more security {Wx::SecretStore.wipe} should be used to wipe the secret data after use.
    # @return [String] secret data
    def get_as_string; end

  end

end
