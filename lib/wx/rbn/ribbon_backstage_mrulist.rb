# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module RBN

    class BackstageMRUList

      # manage IconProvider for GC
      wx_set_icon_provider = instance_method :set_icon_provider
      wx_redefine_method :set_icon_provider do |prov = nil, &block|
        @icon_provider = nil # clear any previously set
        prov = if block and not prov
                 block
               elsif prov and not block
                 case prov
                 when Proc then prov
                 when Method then prov
                 else Kernel.raise ArgumentError,
                                   "set_icon_provider expects a Proc, Method, block or lambda excepting a single argument"
                 end
               end
        # check arity == 1
        if prov.arity != 1
          Kernel.raise ArgumentError,
                       "icon provider should accept a single argument"
        end
        wx_set_icon_provider.bind(self).call(prov)
        @icon_provider = prov # keep non-wx-managed provider safe
      end
      alias :icon_provider= :set_icon_provider

    end

  end

end
