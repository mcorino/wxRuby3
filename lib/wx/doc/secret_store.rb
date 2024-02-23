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

    # Returns a copy of the secret data.
    # Be aware this is binary data and may contain embedded NUL characters.
    # For more security {Wx::SecretStore.wipe} should be used to wipe the secret data after use.
    # @return [String] secret data
    def get_data; end

  end

end
