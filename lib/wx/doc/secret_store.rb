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
