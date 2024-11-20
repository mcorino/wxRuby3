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

  class SecretValue

    # Redefine the initialize method to auto-convert UTF-16/-32 strings to UTF-8 if possible.
    wx_init = self.instance_method(:initialize)
    wx_redefine_method(:initialize) do | *args |
      if args.size == 1 && ::String === args.first
        unless args.first.encoding == ::Encoding::UTF_8 || args.first.encoding == ::Encoding::ASCII_8BIT
          # convert in place unless frozen
          if !args.first.frozen?
            args.first.encode!(::Encoding::UTF_8) rescue nil
          else # create converted copy
            (args = [args.first.encode(::Encoding::UTF_8)]) rescue nil
          end
        end
      end
      wx_init.bind(self).call(*args)
    end

  end

end
