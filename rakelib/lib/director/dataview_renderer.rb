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
          'wxDataViewIconTextRenderer' << 'wxDataViewIconText' << 'wxDataViewCheckIconText' <<
          'wxDataViewProgressRenderer' <<
          'wxDataViewTextRenderer' <<
          'wxDataViewToggleRenderer'
        spec.gc_as_object 'wxDataViewValueAdjuster'
        spec.gc_as_untracked 'wxDataViewIconText', 'wxDataViewCheckIconText'
        spec.disown 'wxDataViewValueAdjuster *transformer'
        spec.ignore_unless 'USE_ACCESSIBILITY', 'wxDataViewRenderer::GetAccessibleDescription'
        spec.regard 'wxDataViewRenderer::GetView'
        spec.suppress_warning(473, 'wxDataViewRenderer::CreateEditorCtrl')
        spec.add_header_code <<~__CODE
          static void __wxruby_wxDataViewIconText2Variant(wxVariant& var, wxObject* obj)
          {
            wxDataViewIconText* wx_dvit = dynamic_cast<wxDataViewIconText*>(obj);
            if (wx_dvit) var << *wx_dvit;
          }

          static void __wxruby_wxDataViewCheckIconText2Variant(wxVariant& var, wxObject* obj)
          {
            wxDataViewCheckIconText* wx_dvcit = dynamic_cast<wxDataViewCheckIconText*>(obj);
            if (wx_dvcit) var << *wx_dvcit;
          }

          typedef void (* TWxObject2VariantConverterFunc)(wxVariant&, wxObject *);
          typedef std::map<wxString, TWxObject2VariantConverterFunc> TWxObject2VariantConverterMap;
          WXRUBY_EXPORT void wxRuby_RegisterWxObject2VariantConverter(wxString type, TWxObject2VariantConverterFunc cnv);
          __CODE
        spec.add_init_code <<~__HEREDOC
          wxRuby_RegisterWxObject2VariantConverter(wxDataViewIconText::ms_classInfo.GetClassName(), __wxruby_wxDataViewIconText2Variant);
          wxRuby_RegisterWxObject2VariantConverter(wxDataViewCheckIconText::ms_classInfo.GetClassName(), __wxruby_wxDataViewCheckIconText2Variant);
          __HEREDOC
        spec.add_extend_code 'wxDataViewIconText', <<~__CODE
          static wxVariant to_variant(const wxDataViewIconText& wx_dvit)
          {
            wxVariant var;
            var << wx_dvit;
            return var;
          }          
          static void from_variant(const wxVariant& var, wxDataViewIconText& wx_dvit)
          {
            wx_dvit << var;
          }          
          __CODE
        spec.add_extend_code 'wxDataViewCheckIconText', <<~__CODE
          static wxVariant to_variant(const wxDataViewCheckIconText& wx_dvcit)
          {
            wxVariant var;
            var << wx_dvcit;
            return var;
          }          
          static void from_variant(const wxVariant& var, wxDataViewCheckIconText& wx_dvcit)
          {
            wx_dvcit << var;
          }          
          __CODE
        spec.do_not_generate :typedefs, :variables, :defines, :functions, :enums
      end

    end

  end

end
