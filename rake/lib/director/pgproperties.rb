###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './pgproperty'

module WXRuby3

  class Director

    class PGProperties < PGProperty

      include Typemap::DateTime

      def setup
        spec.items.replace %w[
          wxBoolProperty wxDateProperty wxFlagsProperty wxStringProperty wxPropertyCategory
          wxEditorDialogProperty wxArrayStringProperty wxDirProperty wxFileProperty
          wxImageFileProperty wxFontProperty wxLongStringProperty wxMultiChoiceProperty
          wxNumericProperty wxIntProperty wxFloatProperty wxUIntProperty
          wxEnumProperty wxCursorProperty wxEditEnumProperty wxSystemColourProperty wxColourProperty wxColourPropertyValue
          ]
        super
        spec.ignore 'wxEnumProperty::wxEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, int)',
                    'wxEnumProperty::wxEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, wxPGChoices *, int)'
        spec.ignore 'wxEditEnumProperty::wxEditEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, const wxString&)',
                    'wxEditEnumProperty::wxEditEnumProperty(const wxString &, const wxString &, const wxChar *const *, const long *, wxPGChoices *, const wxString&)'
        spec.regard 'wxEnumProperty::GetIndex',
                    'wxEnumProperty::SetIndex',
                    'wxEnumProperty::ValueFromString_',
                    'wxEnumProperty::ValueFromInt_'
        spec.gc_as_temporary 'wxColourPropertyValue'
        spec.regard 'wxColourPropertyValue::m_type',
                    'wxColourPropertyValue::m_colour'
        spec.rename_for_ruby 'type'=> 'wxColourPropertyValue::m_type',
                             'colour' => 'wxColourPropertyValue::m_colour'
        spec.regard 'wxNumericProperty::wxNumericProperty' # TODO - provide access to protected member vars? (see wxPGArrayEditorDialog)
        spec.regard 'wxEditorDialogProperty::wxEditorDialogProperty',
                    'wxEditorDialogProperty::DisplayEditorDialog',
                    'wxArrayStringProperty::DisplayEditorDialog',
                    'wxDirProperty::DisplayEditorDialog',
                    'wxFileProperty::DisplayEditorDialog',
                    'wxImageFileProperty::DisplayEditorDialog',
                    'wxLongStringProperty::DisplayEditorDialog',
                    'wxMultiChoiceProperty::DisplayEditorDialog',
                    'wxFontProperty::DisplayEditorDialog'
        spec.new_object 'wxArrayStringProperty::CreateEditorDialog'
        spec.suppress_warning(473, 'wxArrayStringProperty::CreateEditorDialog')
        # not needed in wxRuby
        spec.ignore 'wxFlagsProperty::wxFlagsProperty(const wxString &, const wxString &, const wxChar *const *, const long *, long)'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end
    end # class PGProperties

  end # class Director

end # module WXRuby3
