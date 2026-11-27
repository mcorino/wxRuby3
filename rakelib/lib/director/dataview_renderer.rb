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
          'wxDataViewToggleRenderer' <<
          'wxDataViewCustomRenderer' << 'wxDataViewSpinRenderer'
        spec.gc_as_object 'wxDataViewValueAdjuster'
        spec.gc_as_untracked 'wxDataViewIconText', 'wxDataViewCheckIconText'
        spec.disown 'wxDataViewValueAdjuster *transformer'
        spec.ignore_unless 'USE_ACCESSIBILITY', 'wxDataViewRenderer::GetAccessibleDescription'
        spec.regard 'wxDataViewRenderer::GetView'
        spec.suppress_warning(473, 'wxDataViewRenderer::CreateEditorCtrl')
        spec.regard 'wxDataViewCustomRenderer::GetTextExtent'
        # derivative needs proxy access too
        spec.extend_interface 'wxDataViewSpinRenderer',
                              'wxSize GetTextExtent(const wxString &str) const',
                              visibility: 'protected'
        # add pure virtual base overrides missing from docs
        spec.extend_interface 'wxDataViewSpinRenderer',
                              'wxSize GetSize() const override',
                              'bool Render(wxRect cell, wxDC *dc, int state) override'
        %w[wxDataViewBitmapRenderer wxDataViewCheckIconTextRenderer wxDataViewChoiceRenderer
                                      wxDataViewChoiceByIndexRenderer wxDataViewDateRenderer wxDataViewIconTextRenderer
                                      wxDataViewProgressRenderer wxDataViewTextRenderer wxDataViewToggleRenderer
                                      wxDataViewCustomRenderer wxDataViewSpinRenderer].each do |kls|
          spec.extend_interface kls,
                                'bool GetValue(wxVariant &value_out) const override',
                                'bool SetValue(const wxVariant &value) override'
          if Config.instance.features_set?('USE_ACCESSIBILITY')
            spec.extend_interface kls, 'wxString GetAccessibleDescription() const override'
          end
          # all derivatives also need proxy access to GetView
          spec.extend_interface kls,
                                'wxDataViewCtrl *GetView() const',
                                visibility: 'protected'
        end
        %w[wxDataViewChoiceRenderer wxDataViewChoiceByIndexRenderer wxDataViewDateRenderer wxDataViewIconTextRenderer
           wxDataViewTextRenderer wxDataViewSpinRenderer].each do |kls|
          spec.extend_interface kls,
                                'bool HasEditorCtrl() const override',
                                'wxWindow *CreateEditorCtrl(wxWindow *parent, wxRect labelRect, const wxVariant &value) override',
                                'bool	GetValueFromEditorCtrl (wxWindow *editor, wxVariant &value_out) override'
        end
        # change arg name to match type map
        spec.rename_method_arg({ ['wxDataViewRenderer::GetValue',
                                  'wxDataViewRenderer::GetValueFromEditorCtrl',
                                  'wxDataViewCustomRenderer::GetValueFromEditorCtrl'] => { 'value' => 'value_out'} })
        # for GetValue
        spec.map 'wxVariant& value_out' => 'Wx::Variant,nil' do
          map_in ignore: true, temp: 'wxVariant tmp_val', code: '$1 = &tmp_val;'
          map_out ignore: 'bool'
          map_argout code: <<~__CODE
            if (result)
            {
              $result = SWIG_NewPointerObj(new wxVariant(tmp_val$argnum), SWIGTYPE_p_wxVariant, SWIG_POINTER_OWN);
            }
            else
            {
              $result = Qnil;
            }
            __CODE

          # ignore input for now
          map_directorin code: ''

          map_directorargout code: <<~__CODE
            if (RTEST(result))
            {
              value_out = wxRuby_ConvertRbValue2Variant(result);
              c_result = true;
            }
            else
              c_result = false;
          __CODE
        end
        # for DataViewCustomRenderer::ActivateCell
        spec.map 'const wxMouseEvent *' => 'Wx::MouseEvent' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_DEBUG__
            $input = wxRuby_WrapWxEventInRuby(this, const_cast<wxMouseEvent*> ($1));
            #else
            $input = wxRuby_WrapWxEventInRuby(const_cast<wxMouseEvent*> ($1));
            #endif
            __CODE

          # Thin and trusting wrapping to bypass SWIG's normal mechanisms; we
          # don't want SWIG changing ownership or typechecking these.
          map_in code: '$1 = (wxMouseEvent*)WXRUBY_WRAPPER_DATA_PTR($input);'
        end
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
