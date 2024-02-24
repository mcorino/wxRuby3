# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class SecretStore < Director

      def setup
        super
        spec.items << 'wxSecretValue'
        spec.gc_as_untracked # don't even track SecretStore and SecretValue objects
        # there is no possibility of SecretStore derivatives
        # not least because wxRuby only ever allows a single global SecretStore
        spec.disable_proxies
        spec.make_abstract 'wxSecretStore'

        spec.include 'ruby/encoding.h'

        spec.ignore 'wxSecretValue::GetAsString',
                    'wxSecretValue::GetSize',
                    'wxSecretValue::GetData',
                    'wxSecretValue::Wipe',
                    'wxSecretValue::WipeString'
        # customize ctor
        spec.ignore 'wxSecretValue::wxSecretValue(const wxString&)', ignore_doc: false
        spec.regard 'wxSecretValue::wxSecretValue(size_t, const void *)', regard_doc: false
        spec.map 'size_t size, const void *data' do
          map_in from: {type: 'String', index: 1}, temp: 'wxScopedCharBuffer tmp', code: <<~__CODE
            if (RTEST($input) && TYPE($input) == T_STRING)
            {
              $1 = RSTRING_LEN($input);
              $2 = (void*)StringValuePtr($input);
            }
            else
            {
              rb_raise(rb_eArgError, "Expected String for #0");
            }
            __CODE

          map_typecheck precedence: 'pointer', code: '$1 = (TYPE($input) == T_STRING);'
        end

        # customize GetData
        spec.map 'const void*' => 'String', swig: false do
          map_out code: ''
        end
        spec.add_extend_code 'wxSecretValue', <<~__HEREDOC
          VALUE get_data() 
          {
            size_t sz = $self->GetSize();
            const void* data = $self->GetData();
            return rb_enc_str_new(static_cast<const char*>(data), sz, rb_ascii8bit_encoding());
          }

          VALUE get_as_string() 
          {
            size_t sz = $self->GetSize();
            const void* data = $self->GetData();
            return rb_utf8_str_new(static_cast<const char*>(data), sz);
          }
          __HEREDOC

        # customize GetDefault
        spec.ignore 'wxSecretStore::GetDefault', ignore_doc: false
        spec.add_extend_code 'wxSecretStore', <<~__HEREDOC
          static VALUE get_default() 
          {
            wxSecretStore* result = new wxSecretStore(wxSecretStore::GetDefault());
            return SWIG_NewPointerObj(result, SWIGTYPE_p_wxSecretStore, SWIG_POINTER_OWN);
          }
          __HEREDOC
        spec.map 'wxString *errmsg' => 'String' do
          map_in ignore: true, temp: 'wxString tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            if ($result == Qfalse)
            {
              $result = SWIG_Ruby_AppendOutput($result, WXSTR_TO_RSTR(tmp$argnum));
            }
            __CODE
        end
        spec.map 'wxString& username' => 'String' do
          map_in ignore: true, temp: 'wxString tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            if ($result == Qtrue)
            {
              $result = SWIG_Ruby_AppendOutput($result, WXSTR_TO_RSTR(tmp$argnum));
            }
            __CODE
        end
        # the type matching of the username argument is tricky here since there only is the const difference
        # have to explicitly overrule here for Save() incl. explicitly negating the argout mapping
        spec.map 'const wxString& username' => 'String' do
          map_in temp: 'wxString tmp', code: 'tmp = RSTR_TO_WXSTR($input); $1 = &tmp;'
          map_argout by_ref: true
        end
      end

    end # class SecretStore

  end # class Director

end # module WXRuby3
