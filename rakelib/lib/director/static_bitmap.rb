# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class StaticBitmap < Window

      def setup
        spec.add_swig_code <<~__HEREDOC
          %constant char * wxStaticBitmapNameStr = wxStaticBitmapNameStr;
          __HEREDOC
        super
      end

      def process(gendoc: false)
        defmod = super
        spec.include 'wx/generic/statbmpg.h'
        def_statbmp = defmod.find_item('wxStaticBitmap')
        # create a definition for 'wxGenericStaticBitmap' which is not documented
        def_genstatbmp = def_statbmp.dup
        def_genstatbmp.name = 'wxGenericStaticBitmap'
        def_genstatbmp.brief_doc = nil
        def_genstatbmp.detailed_doc = nil
        def_genstatbmp.items = def_genstatbmp.items.collect { |itm| itm.dup }
        def_genstatbmp.items.each do |itm|
          if itm.is_a?(Extractor::MethodDef)
            itm.overloads = itm.overloads.collect { |ovl| ovl.dup }
            itm.all.each do |ovl|
              ovl.name = 'wxGenericStaticBitmap' if ovl.is_ctor
              ovl.class_name = 'wxGenericStaticBitmap'
              ovl.update_attributes(klass: def_genstatbmp)
            end
          end
        end
        def_genstatbmp.items.delete_if { |itm| itm.is_a?(Extractor::EnumDef) && itm.name == 'ScaleMode' }
        spec.add_swig_code %Q{typedef wxStaticBitmap::ScaleMode ScaleMode; }
        spec.add_header_code %Q{typedef wxStaticBitmap::ScaleMode ScaleMode; }
        defmod.items << def_genstatbmp
        # as we already called super before adding wxGenericStaticBitmap the no_proxy settings from the
        # base Window director are missing; just copy all those set for wxStaticBitmap
        list = spec.no_proxies.select { |name| name.start_with?('wxStaticBitmap::') }
        spec.no_proxy(*list.collect { |name| name.sub(/\AwxStaticBitmap::/, 'wxGenericStaticBitmap::')})
        defmod
      end

    end # class StaticBitmap

  end # class Director

end # module WXRuby3
