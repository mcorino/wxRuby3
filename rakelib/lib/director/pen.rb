###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Pen < Director

      def setup
        super
        spec.items << 'wxPenInfo'
        spec.gc_as_temporary 'wxPenInfo'
        spec.disable_proxies
        spec.add_header_code <<~__HEREDOC
          // special free func is needed to clean up Dashes array if it has been
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
          __HEREDOC
        spec.add_swig_code '%feature("freefunc") wxPen "GC_free_wxPen";'
        # dealt with below - these require special handling becaause of the use
        # of wxDash array, which cannot be freed until the pen is disposed of
        # or until a new dash pattern is specified.
        spec.ignore(%w[wxPen::GetDashes wxPen::SetDashes], ignore_doc: false)
        spec.add_extend_code 'wxPen', <<~__HEREDOC
          // Returns a ruby array with the dash lengths
          VALUE get_dashes() {
            VALUE rb_dashes = rb_ary_new();
            wxDash* dashes;
            int dash_count = $self->GetDashes(&dashes);
            for ( int i = 0; i < dash_count; i++ )
              {
                rb_ary_push(rb_dashes, INT2NUM( dashes[i] ) );
              }
            return rb_dashes;
          }
        
          // Sets the dashes to have the lengths defined in the ruby array of ints
          void set_dashes(VALUE rb_dashes) {
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
        spec.map 'wxPenInfo &' => 'Wx::PenInfo' do
          map_out code: '$result = self; wxUnusedVar($1);'
        end
        # these are defined and loaded in RubyStockObjects.i
        spec.ignore %w[
          wxRED_PEN wxBLUE_PEN wxCYAN_PEN wxGREEN_PEN wxYELLOW_PEN wxBLACK_PEN wxWHITE_PEN
          wxTRANSPARENT_PEN wxBLACK_DASHED_PEN wxGREY_PEN wxMEDIUM_GREY_PEN wxLIGHT_GREY_PEN wxThePenList]
      end
    end # class Pen

  end # class Director

end # module WXRuby3
