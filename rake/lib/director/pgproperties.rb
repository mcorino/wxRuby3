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
                    'wxLongStringProperty::DisplayEditorDialog',
                    'wxMultiChoiceProperty::DisplayEditorDialog',
                    'wxFontProperty::DisplayEditorDialog'
        spec.new_object 'wxArrayStringProperty::CreateEditorDialog'
        spec.suppress_warning(473, 'wxArrayStringProperty::CreateEditorDialog')
        # for wxArrayStringProperty::OnCustomStringEdit
        spec.map 'wxWindow *parent, wxString &value' do
          map_in from: {type: 'Wx::Window', index: 0},
                 temp: 'wxString tmp',
                 code: <<~__CODE
            void* argp$argnum = NULL;
            if ( TYPE($input) == T_DATA )
            {
              if (SWIG_IsOK(SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, $argnum-1)) && argp$argnum)
              {
                $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
              }
              else
              {
                rb_raise(rb_eTypeError, "Expected Wx::Window instance.");
              }
            }
            $2 = &tmp;
            __CODE
          # ignore C defined return value entirely (also affects directorout)
          map_out ignore: 'bool'
          map_argout as: {type: 'String', index: 1}, code: '$result = WXSTR_TO_RSTR(tmp$argnum);'
          # convert the window and ignore the string ref for now
          map_directorin code: '$input = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxWindow, 0);'
          map_directorargout code: <<~__CODE
            if (RTEST($result))
            {
              if (TYPE($result) == T_STRING)
              {
                value = RSTR_TO_WXSTR($result);
                c_result = true;
              }
              else
              {
                Swig::DirectorTypeMismatchException::raise(rb_eTypeError, 
                                                           "on_custom_string_edit should return a string, or nil");
              }
            }
            else
              c_result = false;
          __CODE
        end
        # not needed in wxRuby
        spec.ignore 'wxFlagsProperty::wxFlagsProperty(const wxString &, const wxString &, const wxChar *const *, const long *, long)'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end
    end # class PGProperties

  end # class Director

end # module WXRuby3
