# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  class SecretStore

    # Wipes the secret data.
    def self.wipe(secret)
      if ::String === secret
        secret.bytesize.times { |i| secret.setbyte(i, 0) }
      end
    end

  end

end
