# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class TipWindow < Window

      def setup
        super
        spec.disable_proxies
        spec.ignore 'wxTipWindow::SetTipWindowPtr'
        spec.ignore 'wxTipWindow::wxTipWindow'
        if Config.instance.wx_version_check('3.3.2') >= 0
          spec.ignore 'wxTipWindow::Create'
          # need to re-implement this
          spec.ignore 'wxTipWindow::New', ignore_doc: false
          # Rubified version
          spec.add_extend_code 'wxTipWindow', <<~__HEREDOC
            static VALUE New(wxWindow* parent, const wxString& text, wxCoord maxLength = 100, wxRect* rectBounds = nullptr)
            {
                wxTipWindow::Ref tipRef = wxTipWindow::New(parent, text, maxLength, rectBounds);   

                return SWIG_NewPointerObj((new wxTipWindow::Ref(std::move(tipRef))), SWIGTYPE_p_wxTipWindow__Ref, SWIG_POINTER_OWN |  0 );
            }
            __HEREDOC
          # add Ruby-style methods
          spec.add_extend_code 'wxTipWindow::Ref', <<~__HEREDOC
            VALUE is_ok()
            {
                return *$self ? Qtrue : Qfalse;
            }
 
            wxTipWindow* get_tip_window()
            {
                return $self->Ref::operator->();
            }
            __HEREDOC
          # and aliases
          spec.add_swig_code '%alias wxTipWindow::Ref::is_ok "ok?";'
          spec.add_swig_code '%alias wxTipWindow::Ref::get_tip_window "tip_window";'
          spec.rename_for_ruby 'TipWindow_Ref' => 'wxTipWindow::Ref'
          spec.rename_for_ruby 'new_tip' => 'wxTipWindow::New'
        else
          spec.make_abstract 'wxTipWindow'
          # provide custom wxRuby reference class
          spec.add_header_code <<~__HEREDOC
            class WXTipWindow_Ref
            {
              public:
                WXTipWindow_Ref() {}
                WXTipWindow_Ref& operator=(WXTipWindow_Ref&& o)
                {
                    if (_ptr != o._ptr)
                    {
                        if (_ptr)
                        {
                            _ptr->SetTipWindowPtr(nullptr);
                        }
                
                        _ptr = o._ptr;
                        if (_ptr)
                        {
                            o._ptr = nullptr;
                            _ptr->SetTipWindowPtr(&_ptr);
                        }
                    }
                    return *this;
                }

                bool is_ok()
                {
                    return _ptr ? true : false;
                }
     
                wxTipWindow* get_tip_window()
                {
                    return _ptr;
                }

                wxTipWindow* _ptr = {};  
            };
            __HEREDOC
          spec.add_swig_code <<~__HEREDOC
            %alias WXTipWindow_Ref::is_ok "ok?";
            %alias WXTipWindow_Ref::get_tip_window "tip_window";

            class WXTipWindow_Ref
            {
              private:
                WXTipWindow_Ref();

              public:
                bool is_ok();
     
                wxTipWindow* get_tip_window();
            };
            __HEREDOC
          # add constructor method
          spec.add_extend_code 'wxTipWindow', <<~__HEREDOC
            static VALUE New_Tip(wxWindow* parent, const wxString& text, wxCoord maxLength = 100, wxRect* rectBounds = nullptr)
            {
                std::unique_ptr<WXTipWindow_Ref> retval(new WXTipWindow_Ref);
                std::unique_ptr<wxTipWindow> temp(new wxTipWindow(parent, text, maxLength, &retval->_ptr, rectBounds));
                retval->_ptr = temp.release();
            
                return SWIG_NewPointerObj(retval.release(), SWIGTYPE_p_WXTipWindow_Ref, SWIG_POINTER_OWN |  0 );
            }
            __HEREDOC
        end
      end

      def doc_generator
        TipWindowDocGenerator.new(self)
      end

    end

    class TipWindowDocGenerator < DocGenerator

      def gen_class_doc_members(fdoc, clsdef, cls_members, alias_methods)
        super
        fdoc.doc.puts 'Constructs a new TipWindow object which is immediately shown.'
        fdoc.doc.puts 'Returns a {Wx::TipWindow::Ref}.'
        fdoc.doc.puts '@param parent [Wx::Window] parent window (not nil).'
        fdoc.doc.puts '@param text [String] The text to show, may contain the new line characters.'
        fdoc.doc.puts '@param maxLength [Integer] The length of each line, in pixels. Set to a very large value to avoid wrapping lines.'
        fdoc.doc.puts '@param rectBounds [Wx::Rect] If given, passed to {Wx::TipWindow#set_bounding_rect}, please see its documentation for the description of this parameter.'
        fdoc.doc.puts '@return [Wx::TipWindow::Ref] weak tip window reference'
        fdoc.puts 'def self.new_tip(parent, text, maxLength = 100, rectBounds = nil) end'
      end

    end

  end

end
