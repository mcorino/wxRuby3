###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonToolBar < Window

      def setup
        super
        if Config.instance.wx_version <= '3.2.2.1'
          # In older versions a bug exists in wxRibbonToolBar::GetToolByPos and wxRibbonToolBar::DeleteToolByPos
          # so we use a wxRuby custom derived class
          spec.add_header_code <<~__HEREDOC
            class wxRibbonToolBarToolBase
            {
            public:
                wxString help_string;
                wxBitmap bitmap;
                wxBitmap bitmap_disabled;
                wxRect dropdown;
                wxPoint position;
                wxSize size;
                wxObject* client_data;
                int id;
                wxRibbonButtonKind kind;
                long state;
            };
            
            WX_DEFINE_ARRAY_PTR(wxRibbonToolBarToolBase*, wxArrayRibbonToolBarToolBase);
            
            class wxRibbonToolBarToolGroup
            {
            public:
                // To identify the group as a wxRibbonToolBarToolBase*
                wxRibbonToolBarToolBase dummy_tool;
            
                wxArrayRibbonToolBarToolBase tools;
                wxPoint position;
                wxSize size;
            };

            class WXRUBY_EXPORT wxRubyRibbonToolBar : public wxRibbonToolBar
            {
            public:
              wxRubyRibbonToolBar() : wxRibbonToolBar() {}
          
              wxRubyRibbonToolBar(wxWindow* parent,
                                  wxWindowID id = wxID_ANY,
                                  const wxPoint& pos = wxDefaultPosition,
                                  const wxSize& size = wxDefaultSize,
                                  long style = 0)
                : wxRibbonToolBar(parent, id, pos, size, style)
              {}
              virtual ~wxRubyRibbonToolBar() {}

              virtual bool DeleteToolByPos(size_t pos)
              {
                size_t group_count = m_groups.GetCount();
                size_t g, t;
                for(g = 0; g < group_count; ++g)
                {
                    wxRibbonToolBarToolGroup* group = m_groups.Item(g);
                    size_t tool_count = group->tools.GetCount();
                    if(pos<tool_count)
                    {
                        // Remove tool
                        wxRibbonToolBarToolBase* tool = group->tools.Item(pos);
                        group->tools.RemoveAt(pos);
                        delete tool;
                        return true;
                    }
                    else if(pos==tool_count)
                    {
                        // Remove separator
                        if(g < group_count - 1)
                        {
                            wxRibbonToolBarToolGroup* next_group = m_groups.Item(g+1);
                            for(t = 0; t < next_group->tools.GetCount(); ++t)
                                group->tools.Add(next_group->tools[t]);
                            m_groups.RemoveAt(g+1);
                            delete next_group;
                        }
                        return true;
                    }
                    pos -= tool_count+1;
                }
                return false;
              }
              virtual wxRibbonToolBarToolBase* GetToolByPos(size_t pos) const
              {
                size_t group_count = m_groups.GetCount();
                size_t g;
                for(g = 0; g < group_count; ++g)
                {
                    wxRibbonToolBarToolGroup* group = m_groups.Item(g);
                    size_t tool_count = group->tools.GetCount();
                    if(pos<tool_count)
                    {
                        return group->tools[pos];
                    }
                    else if(pos==tool_count)
                    {
                        return NULL;
                    }
                    pos -= tool_count+1;
                }
                return NULL;
              }
            };
            __HEREDOC
          spec.use_class_implementation('wxRibbonToolBar', 'wxRubyRibbonToolBar')
        end
        # exclude these; far better done in pure Ruby
        spec.ignore 'wxRibbonToolBar::SetToolClientData',
                    'wxRibbonToolBar::GetToolClientData', ignore_doc: false
        spec.map 'wxObject*' => 'Object', swig: false do
          map_in
          map_out
        end
        # not needed because of type mapping
        spec.ignore 'wxRibbonToolBar::GetToolId',
                    'wxRibbonToolBar::FindById'
        # replace incorrectly documented method
        spec.ignore 'wxRibbonToolBar::AddToggleTool', ignore_doc: false
        spec.extend_interface 'wxRibbonToolBar',
                              'virtual wxRibbonToolBarToolBase*	AddToggleTool (int tool_id, const wxBitmap &bitmap, const wxString &help_string=wxEmptyString)'
        # map opaque wxRibbonToolBarToolBase* to the integer tool ID
        spec.map 'wxRibbonToolBarToolBase*' => 'Integer' do
          map_out code: '$result = ($1) ? INT2NUM((arg1)->GetToolId($1)) : Qnil;'
          map_directorout code: '$result = NIL_P($1) ? 0 : this->FindById(NUM2INT($1));'
          map_in code: '$1 = NIL_P($input) ? 0 : (arg1)->FindById(NUM2INT($input));'
          map_directorin code: '$input = ($1) ? INT2NUM(this->GetToolId($1)) : Qnil;'
          map_typecheck precedence: 'INTEGER', code: '$1 = (TYPE($input) == T_FIXNUM);'
        end
      end
    end # class RibbonToolBar

  end # class Director

end # module WXRuby3
