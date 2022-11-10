#--------------------------------------------------------------------
# @file    tree_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class TreeEvent < Event

      def setup
        super
        spec.ignore_bases('wxTreeEvent' => %w[wxNotifyEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h') # provide base definitions
        spec.override_base('wxTreeEvent', 'wxNotifyEvent') # re-establish correct base
        # wxTreeItemId fixes - these typemaps convert them to ruby Integers
        # spec.swig_include '../shared/treeitemid_typemaps.i'
        # add to items but ignore extracted class def
        spec.items << 'wxTreeItemId'
        spec.ignore 'wxTreeItemId'
        spec.ignore('operator!=', 'operator==')
        # Add simplified interface definition for wxTreeItemId to trigger minimal wrapper generation
        spec.add_swig_code <<~__HEREDOC
          class wxTreeItemId
          {
          public:
            wxTreeItemId ();
            wxTreeItemId (void *pItem);

            // we only want a type and this wrapped
            bool IsOk () const;      
          };

          // extend with comparison operator
          // we do not want exceptions on failed conversions here
          %extend wxTreeItemId {
            VALUE __eq__(VALUE other)
            {
              void* item_ptr;
              wxTreeItemId* item_id;
              int res2 = SWIG_ConvertPtr(other, &item_ptr, SWIGTYPE_p_wxTreeItemId,  0 );
              if (!SWIG_IsOK(res2)) {
                return Qfalse; 
              }
              item_id = reinterpret_cast< wxTreeItemId * >(item_ptr);
              return self->GetID() == item_id->GetID() ? Qtrue : Qfalse;
            }
          }
          __HEREDOC
        # no tracking or special GC handling
        spec.gc_as_temporary('wxTreeItemId')

        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class TreeEvent

  end # class Director

end # module WXRuby3
