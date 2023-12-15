# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './validator'

module WXRuby3

  class Director

    class TextValidator < Validator

      def setup
        super
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyTextValidator : public wxTextValidator, public wxRubyValidatorBinding
          {
          public:
            WXRubyTextValidator(long style=wxFILTER_NONE) 
              : wxTextValidator(style, &m_valueCache) 
            {
            }
            WXRubyTextValidator(const WXRubyTextValidator& other) 
              : wxTextValidator(other.GetStyle(), &m_valueCache)
              , wxRubyValidatorBinding(other)
            {
            }
            virtual ~WXRubyTextValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }

            virtual wxObject* Clone() const override
            {
              WXRubyTextValidator* clone = new WXRubyTextValidator(*this);
              clone->m_valueCache = this->m_valueCache;
              return clone;
            }

            virtual void SetWindow(wxWindow *win) override
            {
              this->wxTextValidator::SetWindow(win);
              VALUE self = this->get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            virtual bool TransferFromWindow () override 
            {
              // call super 
              if (this->wxTextValidator::TransferFromWindow())
              {
                // ok, data is retrieved from window and cached
                // now allow any defined binding handler to pass on the data
                return this->DoOnTransferFromWindow(WXSTR_TO_RSTR(m_valueCache));
              } 
              return false;
            }
            virtual bool TransferToWindow () override 
            { 
              // collect data from any defined binding handler
              VALUE data = this->DoOnTransferToWindow();
              // if Qnil returned there is no data returned from handler so we just keep what's in the store
              if (!NIL_P(data))
              {
                m_valueCache = RSTR_TO_WXSTR(data);
              }
              // now allow standard functionality to transfer to window 
              return this->wxTextValidator::TransferToWindow();
            }

            const wxString& GetValue () const
            {
              return m_valueCache;
            }

            void SetValue (const wxString& val)
            {
              m_valueCache = val;
            }

          private:
            static VALUE c_TextValidator; 

            virtual VALUE get_self() override
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
                // if this is a C++ created clone (wxWidgets clones validators that are set) it's not tracked yet
                if (NIL_P(this->self_))
                {
                  if (NIL_P(c_TextValidator))
                  {
                    c_TextValidator = rb_const_get(mWxCore, rb_intern("TextValidator"));
                  }
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(c_TextValidator);
                  this->self_ = SWIG_NewPointerObj(this, swig_type, 0); // wrap but don't make Ruby own it
                }
              }
              return this->self_; 
            }

            wxString m_valueCache;               
          };

          VALUE WXRubyTextValidator::c_TextValidator = Qnil;

          static void GC_mark_wxTextValidator(void* ptr)
          {
            if (ptr)
            {
              wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
              WXRubyTextValidator* rbvp = dynamic_cast<WXRubyTextValidator*> (vp);
              // This might be a pointer to a non-customized validator (or clone thereof) created internally 
              // by wxWidgets C++ code 
              if (rbvp) rbvp->GC_Mark();
            }
          } 

          __HEREDOC
        spec.add_swig_code '%markfunc wxTextValidator "GC_mark_wxTextValidator";'
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation 'wxTextValidator', 'WXRubyTextValidator'
        # ignore this ctor
        spec.ignore 'wxTextValidator::wxTextValidator(long, wxString*)'
        # add alternative
        spec.extend_interface 'wxTextValidator', 'wxTextValidator(long style=wxFILTER_NONE)'
        # add wxRuby extensions
        spec.add_extend_code 'wxTextValidator', <<~__HEREDOC
          VALUE GetValue()
          {
            WXRubyTextValidator* rb_self = dynamic_cast<WXRubyTextValidator*> ($self);
            if (rb_self)
              return WXSTR_TO_RSTR(rb_self->GetValue());
            else
              return Qnil;
          }

          void SetValue(const wxString& val)
          {
            WXRubyTextValidator* rb_self = dynamic_cast<WXRubyTextValidator*> ($self);
            if (rb_self)
              rb_self->SetValue(val);
          }
          __HEREDOC
        # ignore non-virtual standard handler (not useful in Ruby)
        spec.ignore 'wxTextValidator::OnChar'
        spec.new_object 'wxTextValidator::Clone'
        # handle clone mapping
        spec.map 'wxObject *' => 'Wx::TextValidator' do
          map_out code: <<~__CODE
            $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxTextValidator, SWIG_POINTER_OWN);
            __CODE
        end
        spec.suppress_warning(473, 'wxTextValidator::Clone')
        # not provided in Ruby
        spec.ignore %w[wxTextValidator::TransferFromWindow wxTextValidator::TransferToWindow]
      end
    end # class TextValidator

  end # class Director

end # module WXRuby3
