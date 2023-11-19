# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './validator'

module WXRuby3

  class Director

    class NumericPropertyValidator < Validator

      def setup
        super
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyNumericPropertyValidator : public wxNumericPropertyValidator, public wxRubyValidatorBinding
          {
          public:
            WXRubyNumericPropertyValidator(NumericType numericType, int base=10) 
              : wxNumericPropertyValidator(numericType, base) 
            {
              m_stringValue = &m_valueCache;
            }
            WXRubyNumericPropertyValidator(const WXRubyNumericPropertyValidator& other) 
              : wxNumericPropertyValidator(other)
              , wxRubyValidatorBinding(other) 
            {
              m_stringValue = &m_valueCache;
            }
            virtual ~WXRubyNumericPropertyValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               

            virtual wxObject* Clone() const override
            {
              WXRubyNumericPropertyValidator *clone = new WXRubyNumericPropertyValidator(*this);
              clone->m_valueCache = this->m_valueCache;
              return clone;
            }

            virtual void SetWindow(wxWindow *win) override
            {
              this->wxNumericPropertyValidator::SetWindow(win);
              VALUE self = get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            virtual bool TransferFromWindow () override 
            {
              // call super 
              if (this->wxNumericPropertyValidator::TransferFromWindow())
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
              if (NIL_P(data))
              {
                m_valueCache.clear();
              }
              else
              {
                m_valueCache = RSTR_TO_WXSTR(data);
              }
              // now allow standard functionality to transfer to window 
              return this->wxNumericPropertyValidator::TransferToWindow();
            }

          private:
            static VALUE c_NumericPropertyValidator; 

            virtual VALUE get_self() override
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
                // if this is a C++ created clone (wxWidgets clones validators that are set) it's not tracked yet
                if (NIL_P(this->self_))
                {
                  if (NIL_P(c_NumericPropertyValidator))
                  {
                    c_NumericPropertyValidator = rb_eval_string("Wx::PG::NumericPropertyValidator");
                  }
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(c_NumericPropertyValidator);
                  this->self_ = SWIG_NewPointerObj(this, swig_type, 0); // wrap but don't make Ruby own it
                }
              }
              return this->self_; 
            }

            wxString m_valueCache;               
          };

          VALUE WXRubyNumericPropertyValidator::c_NumericPropertyValidator = Qnil;

          WXRUBY_EXPORT void GC_mark_wxNumericPropertyValidator(void* ptr)
          {
            if (ptr)
            {
              wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
              WXRubyNumericPropertyValidator* rbvp = dynamic_cast<WXRubyNumericPropertyValidator*> (vp);
              // This might be a pointer to a non-customized validator (or clone thereof) created internally 
              // by wxWidgets C++ code 
              if (rbvp) rbvp->GC_Mark();
            }
          } 
          __HEREDOC
        spec.add_swig_code '%markfunc wxValidator "GC_mark_wxValidator";'
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation 'wxNumericPropertyValidator', 'WXRubyNumericPropertyValidator'
        spec.new_object 'wxNumericPropertyValidator::Clone'
        # handle clone mapping
        spec.map 'wxObject *' => 'Wx::PG::NumericPropertyValidator' do
          map_out code: <<~__CODE
            $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxTextValidator, SWIG_POINTER_OWN);
            __CODE
        end
        spec.suppress_warning(473, 'wxNumericPropertyValidator::Clone')
        spec.extend_interface 'wxNumericPropertyValidator',
                              'wxNumericPropertyValidator(const wxNumericPropertyValidator &other)'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end

    end # class NumericPropertyValidator

  end # class Director

end # module WXRuby3
