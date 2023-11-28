# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GenericDirCtrl < Window

      include Typemap::TreeItemId

      def setup
        super
        spec.no_proxy 'wxGenericDirCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # already with DirFilterListCtrl
      end

      def process(gendoc: false)
        defmod = super
        # fix documentation errors for generic dirctrl events
        def_item = defmod.find_item('wxGenericDirCtrl')
        if def_item
          def_item.event_types.each do |evt_spec|
            case evt_spec.first
            when 'EVT_DIRCTRL_SELECTIONCHANGED', 'EVT_DIRCTRL_FILEACTIVATED'
              if evt_spec[3].nil?
                evt_spec[3] = 'wxTreeEvent' # missing from docs
              end
            end
          end
        end
        defmod
      end

    end # class GenericDirCtrl

  end # class Director

end # module WXRuby3
