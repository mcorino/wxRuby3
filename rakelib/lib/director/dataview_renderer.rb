# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DataViewRenderer < Director

      include Typemap::DataViewItem

      def setup
        super
        spec.items << 'wxDataViewValueAdjuster' <<
          'wxDataViewBitmapRenderer' <<
          'wxDataViewCheckIconTextRenderer' <<
          'wxDataViewChoiceRenderer' <<
          'wxDataViewChoiceByIndexRenderer' <<
          'wxDataViewDateRenderer' <<
          'wxDataViewIconTextRenderer' <<
          'wxDataViewProgressRenderer' <<
          'wxDataViewTextRenderer' <<
          'wxDataViewToggleRenderer'
        spec.gc_as_object 'wxDataViewValueAdjuster'
        spec.disown 'wxDataViewValueAdjuster *transformer'
        spec.ignore_unless 'USE_ACCESSIBILITY', 'wxDataViewRenderer::GetAccessibleDescription'
        spec.regard 'wxDataViewRenderer::GetView'
        spec.suppress_warning(473, 'wxDataViewRenderer::CreateEditorCtrl')
        spec.do_not_generate :typedefs, :variables, :defines, :functions, :enums
      end

    end

  end

end
