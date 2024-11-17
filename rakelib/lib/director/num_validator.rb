# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './validator'

module WXRuby3

  class Director

    class NumValidator < Validator

      def setup
        spec.items.replace ['valnum.h'] # enum from XML but only manually defined custom wxRuby classes
        super
        spec.initialize_at_end = true # no inheritance/XML info to analyze
        spec.ignore 'wxMakeIntegerValidator', 'wxMakeFloatingPointValidator'
        # need to explicitly declare this here as we do not have any XML extracted items
        # so the post processing of the EvtHandler director does not work
        spec.add_header_code <<~__HEREDOC
          static WxRuby_ID __wxrb_try_before_id("try_before");
          static WxRuby_ID __wxrb_try_after_id("try_after");
          __HEREDOC
        # provide custom wxRuby numeric validator classes
        spec.add_header_code <<~__HEREDOC
          #include <wx/valnum.h>

          #ifdef wxLongLong_t
              typedef wxLongLong_t LongestValueType;
              typedef wxULongLong_t ULongestValueType;
          #else
              typedef long LongestValueType;
              typedef unsigned long ULongestValueType;
          #endif
          class WXIntegerValidator : public wxIntegerValidator<LongestValueType>, public wxRubyValidatorBinding
          {
          public:
            WXIntegerValidator(const WXIntegerValidator& v) 
              : wxIntegerValidator(v)
              , wxRubyValidatorBinding(v)
            {
              // this is horrible but why they needed to explicitly declare this as a const member is beyond me
              *reinterpret_cast<LongestValueType**> ((void*)&m_value) = &m_valueCache;
            }
            WXIntegerValidator(long style=wxNUM_VAL_DEFAULT) 
              : wxIntegerValidator(&m_valueCache, style) 
            {}
            WXIntegerValidator(LongestValueType min, LongestValueType max, long style=wxFILTER_NONE) 
              : wxIntegerValidator(&m_valueCache, min, max, style) 
            {}
            virtual ~WXIntegerValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }

            virtual wxObject* Clone() const override
            {
              WXIntegerValidator* clone = new WXIntegerValidator(*this);
              clone->m_valueCache = this->m_valueCache;
              return clone;
            }

            virtual void SetWindow(wxWindow *win) override
            {
              this->wxIntegerValidator::SetWindow(win);
              VALUE self = get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            virtual bool TransferFromWindow () override 
            {
              // call super 
              if (this->wxIntegerValidator::TransferFromWindow())
              {
                // ok, data is retrieved from window and cached
                // now allow any defined binding handler to pass on the data
                return this->DoOnTransferFromWindow(LL2NUM(m_valueCache));
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
                m_valueCache = NUM2LL(data);
              }
              // now allow standard functionality to transfer to window 
              return this->wxIntegerValidator::TransferToWindow();
            }

            LongestValueType GetValue () const
            {
              return m_valueCache;
            }

            void SetValue (LongestValueType val)
            {
              m_valueCache = val;
            }

          protected:
            static VALUE c_IntegerValidator; 

            virtual VALUE get_self() override
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
                // if this is a C++ created clone (wxWidgets clones validators that are set) it's not tracked yet
                if (NIL_P(this->self_))
                {
                if (NIL_P(c_IntegerValidator))
                {
                  c_IntegerValidator = rb_const_get(mWxCore, rb_intern("IntegerValidator"));
                }
                swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(c_IntegerValidator);
                  this->self_ = SWIG_NewPointerObj(this, swig_type, 0); // wrap but don't make Ruby own it
                }
              }
              return this->self_; 
            }
  
            LongestValueType m_valueCache {};         
          };

          VALUE WXIntegerValidator::c_IntegerValidator = Qnil;

          static void GC_mark_wxIntegerValidator(void* ptr)
          {
            if (ptr)
            {
              wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
              WXIntegerValidator* rbvp = dynamic_cast<WXIntegerValidator*> (vp);
              // This might be a pointer to a non-customized validator (or clone thereof) created internally 
              // by wxWidgets C++ code 
              if (rbvp) rbvp->GC_Mark();
            }
          } 

          class WXUnsignedValidator : public wxIntegerValidator<ULongestValueType>, public wxRubyValidatorBinding
          {
          public:
            WXUnsignedValidator(const WXUnsignedValidator& v) 
              : wxIntegerValidator(v)
              , wxRubyValidatorBinding(v)
            {
              // this is horrible but why they needed to explicitly declare this as a const member is beyond me
              *reinterpret_cast<ULongestValueType**> ((void*)&m_value) = &m_valueCache;
            }
            WXUnsignedValidator(long style=wxFILTER_NONE) 
              : wxIntegerValidator(&m_valueCache, style) 
            {}
            WXUnsignedValidator(LongestValueType min, LongestValueType max, long style=wxFILTER_NONE) 
              : wxIntegerValidator(&m_valueCache, min, max, style) 
            {}
            virtual ~WXUnsignedValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               

            virtual wxObject* Clone() const override
            {
              WXUnsignedValidator* clone = new WXUnsignedValidator(*this);
              clone->m_valueCache = this->m_valueCache;
              return clone;
            }

            virtual void SetWindow(wxWindow *win) override
            {
              this->wxIntegerValidator::SetWindow(win);
              VALUE self = get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            virtual bool TransferFromWindow () override 
            {
              // call super 
              if (this->wxIntegerValidator::TransferFromWindow())
              {
                // ok, data is retrieved from window and cached
                // now allow any defined binding handler to pass on the data
                return this->DoOnTransferFromWindow(ULL2NUM(m_valueCache));
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
                m_valueCache = NUM2ULL(data);
              }
              // now allow standard functionality to transfer to window 
              return this->wxIntegerValidator::TransferToWindow();
            }

            ULongestValueType GetValue () const
            {
              return m_valueCache;
            }

            void SetValue (ULongestValueType val)
            {
              m_valueCache = val;
            }

          protected:
            static VALUE c_UnsignedValidator; 

            virtual VALUE get_self() override
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
                // if this is a C++ created clone (wxWidgets clones validators that are set) it's not tracked yet
                if (NIL_P(this->self_))
                {
                  if (NIL_P(c_UnsignedValidator))
                  {
                    c_UnsignedValidator = rb_const_get(mWxCore, rb_intern("UnsignedValidator"));
                  }
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(c_UnsignedValidator);
                  this->self_ = SWIG_NewPointerObj(this, swig_type, 0); // wrap but don't make Ruby own it
                }
              }
              return this->self_; 
            }

            ULongestValueType m_valueCache {};         
          };

          VALUE WXUnsignedValidator::c_UnsignedValidator = Qnil;

          static void GC_mark_wxUnsignedValidator(void* ptr)
          {
            if (ptr)
            {
              wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
              WXUnsignedValidator* rbvp = dynamic_cast<WXUnsignedValidator*> (vp);
              // This might be a pointer to a non-customized validator (or clone thereof) created internally 
              // by wxWidgets C++ code 
              if (rbvp) rbvp->GC_Mark();
            }
          } 

          class WXFloatValidator : public wxFloatingPointValidator<double>, public wxRubyValidatorBinding
          {
          public:
            WXFloatValidator(const WXFloatValidator& v) 
              : wxFloatingPointValidator(v)
              , wxRubyValidatorBinding(v)
            {
              // this is horrible but why they needed to explicitly declare this as a const member is beyond me
              *reinterpret_cast<double**> ((void*)&m_value) = &m_valueCache;
            }
            WXFloatValidator(long style=wxFILTER_NONE) 
              : wxFloatingPointValidator(&m_valueCache, style) 
            {}
            WXFloatValidator(int precision, long style=wxFILTER_NONE) 
              : wxFloatingPointValidator(precision, &m_valueCache, style) 
            {}
            virtual ~WXFloatValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               

            virtual wxObject* Clone() const override
            {
              return new WXFloatValidator(*this);
            }

            virtual void SetWindow(wxWindow *win) override
            {
              this->wxFloatingPointValidator::SetWindow(win);
              VALUE self = get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            virtual bool TransferFromWindow () override 
            {
              // call super 
              if (this->wxFloatingPointValidator::TransferFromWindow())
              {
                // ok, data is retrieved from window and cached
                // now allow any defined binding handler to pass on the data
                return this->DoOnTransferFromWindow(DBL2NUM(m_valueCache));
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
                m_valueCache = NUM2DBL(data);
              }
              // now allow standard functionality to transfer to window 
              return this->wxFloatingPointValidator::TransferToWindow();
            }

            double GetValue () const
            {
              return m_valueCache;
            }

            void SetValue (double val)
            {
              m_valueCache = val;
            }

          protected:
            static VALUE c_FloatValidator; 

            virtual VALUE get_self() override
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
                // if this is a C++ created clone (wxWidgets clones validators that are set) it's not tracked yet
                if (NIL_P(this->self_))
                {
                  if (NIL_P(c_FloatValidator))
                  {
                    c_FloatValidator = rb_const_get(mWxCore, rb_intern("FloatValidator"));
                  }
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(c_FloatValidator);
                  this->self_ = SWIG_NewPointerObj(this, swig_type, 0); // wrap but don't make Ruby own it
                }
              }
              return this->self_; 
            }

            double m_valueCache {};         
          };

          VALUE WXFloatValidator::c_FloatValidator = Qnil;

          static void GC_mark_wxFloatValidator(void* ptr)
          {
            if (ptr)
            {
              wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
              WXFloatValidator* rbvp = dynamic_cast<WXFloatValidator*> (vp);
              // This might be a pointer to a non-customized validator (or clone thereof) created internally 
              // by wxWidgets C++ code 
              if (rbvp) rbvp->GC_Mark();
            }
          } 
        __HEREDOC
        spec.add_swig_code 'GC_MANAGE_AS_OBJECT(WXIntegerValidator);',
                           '%markfunc WXIntegerValidator "GC_mark_wxIntegerValidator";',
                           'GC_MANAGE_AS_OBJECT(WXUnsignedValidator);',
                           '%markfunc WXUnsignedValidator "GC_mark_wxUnsignedValidator";',
                           'GC_MANAGE_AS_OBJECT(WXFloatValidator);',
                           '%markfunc WXFloatValidator "GC_mark_wxFloatValidator";'
        spec.new_object 'WXIntegerValidator::Clone',
                        'WXUnsignedValidator::Clone',
                        'WXFloatValidator::Clone'
        %w[WXIntegerValidator WXUnsignedValidator WXFloatValidator].each do |klass|
          spec.no_proxy "#{klass}::ProcessEvent"
          spec.no_proxy "#{klass}::QueueEvent"
          spec.no_proxy "#{klass}::AddPendingEvent"
        end
        spec.suppress_warning(473,
                              'WXIntegerValidator::Clone',
                              'WXUnsignedValidator::Clone',
                              'WXFloatValidator::Clone')
        spec.map_apply 'long long * OUTPUT' => ['wxLongLong_t& min', 'wxLongLong_t& max']
        spec.map_apply 'unsigned long long * OUTPUT' => ['wxULongLong_t& min', 'wxULongLong_t& max']
        spec.map_apply 'double * OUTPUT' => ['double& min', 'double& max']
        spec.swig_import 'swig/classes/include/wxObject.h'
        spec.swig_import 'swig/classes/include/wxEvtHandler.h'
        spec.swig_import 'swig/classes/include/wxValidator.h'
        # hardcoded interface declarations
        spec.add_interface_code <<~__HEREDOC
          // Bit masks used for numeric validator styles.
          enum wxNumValidatorStyle;
          %constant int NumValidatorStyle_wxNUM_VAL_DEFAULT             = 0x0;
          %constant int NumValidatorStyle_wxNUM_VAL_THOUSANDS_SEPARATOR = 0x1;
          %constant int NumValidatorStyle_wxNUM_VAL_ZERO_AS_BLANK       = 0x2;
          %constant int NumValidatorStyle_wxNUM_VAL_NO_TRAILING_ZEROES  = 0x4;

          %alias WXIntegerValidator::GetMin "min";
          %alias WXIntegerValidator::SetMin "min=";
          %alias WXIntegerValidator::GetMax "max";
          %alias WXIntegerValidator::SetMax "max=";
          %alias WXIntegerValidator::SetStyle "style=";
          %alias WXIntegerValidator::GetValue "value";
          %alias WXIntegerValidator::SetValue "value=";

          class WXIntegerValidator : public wxValidator
          {
          public:
            WXIntegerValidator(const WXIntegerValidator& v); 
            WXIntegerValidator(long style=wxNUM_VAL_DEFAULT); 
            WXIntegerValidator(wxLongLong_t min, wxLongLong_t max, long style=wxFILTER_NONE); 
            virtual ~WXIntegerValidator(); 

            virtual WXIntegerValidator* Clone() const;

            void SetMin(wxLongLong_t min);
            wxLongLong_t GetMin() const;
            void SetMax(wxLongLong_t max);
            wxLongLong_t GetMax() const;
            void SetRange(wxLongLong_t min, wxLongLong_t max);
            void GetRange(wxLongLong_t& min, wxLongLong_t& max) const;
            void SetStyle(int style);

            // wxRuby extensions
            wxLongLong_t GetValue () const;
            void SetValue (wxLongLong_t val);
          };

          %alias WXUnsignedValidator::GetMin "min";
          %alias WXUnsignedValidator::SetMin "min=";
          %alias WXUnsignedValidator::GetMax "max";
          %alias WXUnsignedValidator::SetMax "max=";
          %alias WXUnsignedValidator::SetStyle "style=";
          %alias WXUnsignedValidator::GetValue "value";
          %alias WXUnsignedValidator::SetValue "value=";
          
          class WXUnsignedValidator : public wxValidator
          {
          public:
            WXUnsignedValidator(const WXUnsignedValidator& v); 
            WXUnsignedValidator(long style=wxNUM_VAL_DEFAULT); 
            WXUnsignedValidator(wxULongLong_t min, wxULongLong_t max, long style=wxFILTER_NONE); 
            virtual ~WXUnsignedValidator(); 

            virtual WXUnsignedValidator* Clone() const;

            void SetMin(wxULongLong_t min);
            wxULongLong_t GetMin() const;
            void SetMax(wxULongLong_t max);
            wxULongLong_t GetMax() const;
            void SetRange(wxULongLong_t min, wxULongLong_t max);
            void GetRange(wxULongLong_t& min, wxULongLong_t& max) const;
            void SetStyle(int style);

            // wxRuby extensions
            wxULongLong_t GetValue () const;
            void SetValue (wxULongLong_t val);
          };          

          %alias WXFloatValidator::GetMin "min";
          %alias WXFloatValidator::SetMin "min=";
          %alias WXFloatValidator::GetMax "max";
          %alias WXFloatValidator::SetMax "max=";
          %alias WXFloatValidator::SetStyle "style=";
          %alias WXFloatValidator::GetValue "value";
          %alias WXFloatValidator::SetValue "value=";
          
          class WXFloatValidator : public wxValidator
          {
          public:
            WXFloatValidator(const WXFloatValidator& v); 
            WXFloatValidator(long style=wxNUM_VAL_DEFAULT); 
            WXFloatValidator(int precision, long style); 
            virtual ~WXFloatValidator(); 

            virtual WXFloatValidator* Clone() const;

            void SetMin(double min);
            double GetMin() const;
            void SetMax(double max);
            double GetMax() const;
            void SetRange(double min, double max);
            void GetRange(double& min, double& max) const;
            void SetStyle(int style);

            void SetPrecision(unsigned precision);
            void SetFactor(double factor);

            // wxRuby extensions
            double GetValue () const;
            void SetValue (double val);
          };          
          __HEREDOC
      end
    end # class NumValidator

  end # class Director

end # module WXRuby3
