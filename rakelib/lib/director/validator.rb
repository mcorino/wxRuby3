# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class Validator < EvtHandler

      def setup
        super
        if spec.module_name == 'wxValidator'
          # make Ruby director and wrappers use custom implementation
          spec.use_class_implementation('wxValidator', 'wxRubyValidator')
          # provide custom wxRuby derivative of validator
          spec.add_header_code <<~__HEREDOC
            #include "wxruby-Validator.h"
  
            WxRuby_ID wxRubyValidator::do_transfer_from_window_id("do_transfer_from_window");
            WxRuby_ID wxRubyValidator::do_transfer_to_window_id("do_transfer_to_window");
            WxRuby_ID wxRubyValidator::clone_id("clone");

            wxRubyValidator::wxRubyValidator () 
              : wxValidator ()
              , wxRubyValidatorBinding () 
            {}
            wxRubyValidator::wxRubyValidator (const wxRubyValidator& v)
              : wxValidator (v)
              , wxRubyValidatorBinding (v)
            {}
            wxRubyValidator::~wxRubyValidator ()
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }

            wxObject* wxRubyValidator::Clone() const
            {
              VALUE self = const_cast<wxRubyValidator*> (this)->get_self();
              VALUE rc = wxRuby_Funcall(self, clone_id(), 0);
              void *ptr;
              int res = SWIG_ConvertPtr(rc, &ptr, SWIGTYPE_p_wxValidator,  0);
              if (!SWIG_IsOK(res)) 
              {
                Swig::DirectorTypeMismatchException::raise(self, "clone", SWIG_ErrorType(SWIG_ArgError(res)), "in output value of type '""Wx::Validator *""'");
              }
              return reinterpret_cast< wxValidator * >(ptr);
            }

            void wxRubyValidator::SetWindow(wxWindow *win)
            {
              this->wxValidator::SetWindow(win);
              VALUE self = this->get_self();
              // make sure Ruby does not own this validator instance anymore
              RDATA(self)->dfree = SWIG_RubyRemoveTracking;
            } 

            bool wxRubyValidator::TransferFromWindow() 
            { 
              return this->DoOnTransferFromWindow(this->DoTransferFromWindow());
            }
            bool wxRubyValidator::TransferToWindow() 
            { 
              return this->DoTransferToWindow(this->DoOnTransferToWindow());
            }
  
            VALUE wxRubyValidator::DoTransferFromWindow()
            {
              VALUE rc = wxRuby_Funcall(this->get_self(), do_transfer_from_window_id(), 0);
              return rc; 
            } 
            bool wxRubyValidator::DoTransferToWindow(VALUE data)
            {
              VALUE rc = wxRuby_Funcall(this->get_self(), do_transfer_to_window_id(), 1, data);
              return (rc == Qtrue); 
            } 

            VALUE wxRubyValidator::get_self()
            {
              if (NIL_P(this->self_))
              {
                this->self_ = SWIG_RubyInstanceFor(this);
              }
              return this->self_;
            }

            WxRuby_ID wxRubyValidatorBinding::do_on_transfer_from_window_id("do_on_transfer_from_window");
            WxRuby_ID wxRubyValidatorBinding::do_on_transfer_to_window_id("do_on_transfer_to_window");
            WxRuby_ID wxRubyValidatorBinding::call_id("call");

            bool wxRubyValidatorBinding::DoOnTransferFromWindow(VALUE data)
            {
              VALUE rc = wxRuby_Funcall(this->get_self(), do_on_transfer_from_window_id(), 1, data);
              return (rc == Qtrue); 
            } 
            VALUE wxRubyValidatorBinding::DoOnTransferToWindow()
            {
              VALUE rc = wxRuby_Funcall(this->get_self(), do_on_transfer_to_window_id(), 0);
              return rc; 
            } 

            bool wxRubyValidatorBinding::OnTransferFromWindow(VALUE data)
            {
              if (!NIL_P(this->on_transfer_from_win_proc_))
              {
                wxRuby_Funcall(this->on_transfer_from_win_proc_, call_id(), 1, data);
              }
              return true; 
            } 
            VALUE wxRubyValidatorBinding::OnTransferToWindow()
            {
              if (!NIL_P(this->on_transfer_to_win_proc_))
              {
                VALUE rc = wxRuby_Funcall(this->on_transfer_to_win_proc_, call_id(), 0);
                return rc;
              }
              return Qnil; 
            } 

            void wxRubyValidatorBinding::CopyBindings(const wxRubyValidatorBinding* val_bind)
            {
              if (val_bind)
              {
                this->on_transfer_from_win_proc_ = val_bind->on_transfer_from_win_proc_;
                this->on_transfer_to_win_proc_ = val_bind->on_transfer_to_win_proc_;
              }
            }
  
            static void GC_mark_wxValidator(void* ptr)
            {
              if (ptr)
              {
                wxValidator* vp = reinterpret_cast<wxValidator*> (ptr);
                wxRubyValidator* rbvp = dynamic_cast<wxRubyValidator*> (vp);
                // This might be a pointer to the global constant wxDefaultValidator or one of it's clones 
                // which are not wxRubyValidator-s 
                if (rbvp) rbvp->GC_Mark();
              }
            } 
            __HEREDOC
          spec.add_swig_code '%markfunc wxValidator "GC_mark_wxValidator";'
          # will be provided as a pure Ruby method
          spec.ignore 'wxValidator::Clone', ignore_doc: false
          # add wxRuby specifics
          spec.extend_interface 'wxValidator',
                                'wxValidator(const wxValidator& other)'
          spec.add_extend_code 'wxValidator', <<~__HEREDOC
            void OnTransferFromWindow(VALUE proc)
            {
              dynamic_cast<wxRubyValidatorBinding *>($self)->SetOnTransferFromWindow(proc);
            } 
            void OnTransferToWindow(VALUE proc)
            {
              dynamic_cast<wxRubyValidatorBinding *>($self)->SetOnTransferToWindow(proc);
            }
            bool DoOnTransferFromWindow(VALUE data)
            {
              return dynamic_cast<wxRubyValidatorBinding *>($self)->OnTransferFromWindow(data);
            }
            VALUE DoOnTransferToWindow()
            {
              return dynamic_cast<wxRubyValidatorBinding *>($self)->OnTransferToWindow();
            }
            __HEREDOC
          # not provided in Ruby
          spec.ignore %w[wxValidator::TransferFromWindow wxValidator::TransferToWindow wxValidator::SetWindow]
        else
          spec.add_header_code <<~__HEREDOC
            #include "wxruby-ValidatorBinding.h"
            __HEREDOC
        end
        # overrule common typemap for parent arg of Validate
        spec.map 'wxWindow* parent' do
          map_check code: ''
        end
      end
    end # class Validator

  end # class Director

end # module WXRuby3
