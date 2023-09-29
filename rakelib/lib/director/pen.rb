# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Pen < Director

      def setup
        super
        spec.items << 'wxPenInfo'
        spec.gc_as_untracked 'wxPenInfo'
        spec.gc_as_untracked 'wxPen'
        spec.disable_proxies
        spec.add_header_code <<~__HEREDOC
          // special free funcs are needed to clean up Dashes array if it has been
          // set; wxWidgets does not do this automatically so will leak if not
          // dealt with.
          void GC_free_wxPen(wxPen *pen) 
          {
            SWIG_RubyRemoveTracking(pen);
            if (pen && pen->IsOk ())
            {
              wxDash *dashes;
              int dash_count = pen->GetDashes(&dashes);
              if ( dash_count )
                delete dashes;
            }
            delete pen;
          }
          void GC_free_wxPenInfo(wxPenInfo *pen_info) 
          {
            SWIG_RubyRemoveTracking(pen_info);
            if (pen_info)
            {
              wxDash *dashes;
              int dash_count = pen_info->GetDashes(&dashes);
              if ( dash_count )
                delete dashes;
            }
            delete pen_info;
          }
          __HEREDOC
        spec.add_swig_code '%feature("freefunc") wxPen "GC_free_wxPen";'
        spec.add_swig_code '%feature("freefunc") wxPenInfo "GC_free_wxPenInfo";'
        # all but the default ctor require a running App
        spec.require_app 'wxPen::wxPen(const wxPenInfo &info)',
                         'wxPen::wxPen(const wxColour &colour, int width, wxPenStyle style)',
                         'wxPen::wxPen(const wxBitmap &stipple, int width)',
                         'wxPen::wxPen(const wxPen &pen)'
        # ignore because of memory management issue
        spec.ignore 'wxPen::wxPen(const wxPenInfo &)'
        # add our own
        spec.add_extend_code 'wxPen', <<~__HEREDOC
          wxPen(const wxPenInfo &info)
          {
            if (!wxRuby_IsAppRunning()) 
              rb_raise(rb_eRuntimeError, "Contract violation: require: (wxRuby_IsAppRunning())");

            wxPen* new_pen = new wxPen(info.GetColour(), info.GetWidth(), info.GetStyle());
            new_pen->SetJoin(info.GetJoin());
            new_pen->SetCap(info.GetCap());
            // copy the dashes
            wxDash* new_dashes = new wxDash[info.GetDashCount()];
            for (int i = 0; i < info.GetDashCount(); i++)
            {
              new_dashes[i] = info.GetDash()[i];
            }
            new_pen->SetDashes(info.GetDashCount(), new_dashes);
            return new_pen;
          }
          __HEREDOC
        # dealt with below - these require special handling becaause of the use
        # of wxDash array, which cannot be freed until the pen(info) is disposed of
        # or until a new dash pattern is specified.
        spec.ignore(%w[wxPen::GetDashes wxPen::SetDashes wxPenInfo::GetDashes wxPenInfo::Dashes], ignore_doc: false)
        spec.ignore 'wxPenInfo::GetDash'
        spec.add_extend_code 'wxPen', <<~__HEREDOC
          // Returns a ruby array with the dash lengths
          VALUE get_dashes() 
          {
            VALUE rb_dashes = rb_ary_new();
            wxDash* dashes;
            int dash_count = $self->GetDashes(&dashes);
            for ( int i = 0; i < dash_count; i++ )
            {
              rb_ary_push(rb_dashes, INT2NUM(dashes[i]));
            }
            return rb_dashes;
          }
        
          // Sets the dashes to have the lengths defined in the ruby array of ints
          void set_dashes(VALUE rb_dashes) 
          {
            // Check right parameter type
            if ( TYPE(rb_dashes) != T_ARRAY )
              rb_raise(rb_eTypeError, 
                       "Wrong argument type for set_dashes, should be Array");
        
            // Get old value in case it needs to be deallocated to avoid leaking
            wxDash* old_dashes;
            int old_dashes_count = $self->GetDashes(&old_dashes);
        
            // Create a C++ wxDash array to hold the new dashes, and populate
            int new_dash_count = RARRAY_LEN(rb_dashes);
            wxDash* new_dashes = new wxDash[ new_dash_count ];
            for ( int i = 0; i < new_dash_count; i++ )
            {
              new_dashes[i] = NUM2INT(rb_ary_entry(rb_dashes, i));
            }
            $self->SetDashes(new_dash_count, new_dashes);
        
            // Clean up the old if it existed
            if ( old_dashes_count )
              delete old_dashes;
          }
          __HEREDOC
        spec.add_extend_code 'wxPenInfo', <<~__HEREDOC
          // Returns a ruby array with the dash lengths
          VALUE get_dashes() 
          {
            VALUE rb_dashes = rb_ary_new();
            wxDash* dashes;
            int dash_count = $self->GetDashes(&dashes);
            for ( int i = 0; i < dash_count; i++ )
            {
              rb_ary_push(rb_dashes, INT2NUM(dashes[i]));
            }
            return rb_dashes;
          }
        
          // Sets the dashes to have the lengths defined in the ruby array of ints
          void dashes(VALUE rb_dashes) 
          {
            // Check right parameter type
            if ( TYPE(rb_dashes) != T_ARRAY )
              rb_raise(rb_eTypeError, 
                       "Wrong argument type for set_dashes, should be Array");
        
            // Get old value in case it needs to be deallocated to avoid leaking
            wxDash* old_dashes;
            int old_dashes_count = $self->GetDashes(&old_dashes);
        
            // Create a C++ wxDash array to hold the new dashes, and populate
            int new_dash_count = RARRAY_LEN(rb_dashes);
            wxDash* new_dashes = new wxDash[ new_dash_count ];
            for ( int i = 0; i < new_dash_count; i++ )
            {
              new_dashes[i] = NUM2INT(rb_ary_entry(rb_dashes, i));
            }
            $self->Dashes(new_dash_count, new_dashes);
        
            // Clean up the old if it existed
            if ( old_dashes_count )
              delete old_dashes;
          }
        __HEREDOC
        spec.map 'wxPenInfo &' => 'Wx::PenInfo' do
          map_out code: '$result = self; wxUnusedVar($1);'
        end
        # for SetColour
        spec.map_apply 'const wxColour&' => ['wxColour&']
        # these are defined and loaded in RubyStockObjects.i
        spec.ignore %w[
          wxRED_PEN wxBLUE_PEN wxCYAN_PEN wxGREEN_PEN wxYELLOW_PEN wxBLACK_PEN wxWHITE_PEN
          wxTRANSPARENT_PEN wxBLACK_DASHED_PEN wxGREY_PEN wxMEDIUM_GREY_PEN wxLIGHT_GREY_PEN]
        # do not expose this
        spec.ignore 'wxThePenList'
        # provide it's functionality as a class method of Pen instead
        spec.add_extend_code 'wxPen', <<~__HEREDOC
          static wxPen* find_or_create_pen(const wxColour &colour, int width=1, wxPenStyle style=wxPENSTYLE_SOLID)
          {
            return wxThePenList->FindOrCreatePen(colour, width, style);
          }
          __HEREDOC
      end
    end # class Pen

  end # class Director

end # module WXRuby3
