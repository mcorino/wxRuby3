# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class HyperlinkCtrl < Window

      def setup
        super
        if Config.instance.wx_version_check('3.3.0') <= 0
          # XML docs (< 3.3) incorrectly declare these pure virtual
          spec.ignore 'wxHyperlinkCtrl::GetVisited', 'wxHyperlinkCtrl::SetVisited', ignore_doc: false
          # replace by correct declarations
          spec.extend_interface 'wxHyperlinkCtrl',
                                'virtual bool wxHyperlinkCtrl::GetVisited() const',
                                'virtual void wxHyperlinkCtrl::SetVisited(bool visited = true)'
        end

        def process(gendoc: false)
          defmod = super
          # For WXOSX wxGenericHyperlinkCtrl is functionally identical to wxHyperlinkCtrl
          # so we will declare a constant for that in pure Ruby.
          # In case we are generating documentation create the class def anyway so we get full docs for MacOS as well.
          unless Config.instance.features_set?('WXOSX') && !gendoc
            spec.include 'wx/generic/hyperlink.h'
            def_hlink = defmod.find_item('wxHyperlinkCtrl')
            # create a definition for 'wxGenericHyperlinkCtrl' which is not documented
            def_genhlink = def_hlink.dup
            def_genhlink.name = 'wxGenericHyperlinkCtrl'
            def_genhlink.items = def_genhlink.items.collect { |itm| itm.dup }
            def_genhlink.items.each do |itm|
              if itm.is_a?(Extractor::MethodDef)
                itm.overloads = itm.overloads.collect { |ovl| ovl.dup }
                itm.all.each do |ovl|
                  ovl.name = 'wxGenericHyperlinkCtrl' if ovl.is_ctor
                  ovl.class_name = 'wxGenericHyperlinkCtrl'
                  ovl.update_attributes(klass: def_genhlink)
                end
              end
            end
            defmod.items << def_genhlink
            if Config.instance.wx_version_check('3.3.0') <= 0
              # the interface extensions to fix the incorrectly pure virtual declared methods are missing
              spec.extend_interface 'wxGenericHyperlinkCtrl',
                                    'virtual bool wxGenericHyperlinkCtrl::GetVisited() const',
                                    'virtual void wxGenericHyperlinkCtrl::SetVisited(bool visited = true)'
            end
            # as we already called super before adding wxGenericHyperlinkCtrl the no_proxy settings from the
            # base Window director are missing; just copy all those set for wxStaticBitmap
            list = spec.no_proxies.select { |name| name.start_with?('wxHyperlinkCtrl::') }
            spec.no_proxy(*list.collect { |name| name.sub(/\AwxHyperlinkCtrl::/, 'wxGenericHyperlinkCtrl::')})
          end
          defmod
        end
      end
    end # class HyperlinkCtrl

  end # class Director

end # module WXRuby3
