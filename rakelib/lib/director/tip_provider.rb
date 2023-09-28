# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class TipProvider < Director

      def setup
        spec.gc_as_object
        spec.make_abstract 'wxTipProvider'
        spec.add_header_code <<~__HEREDOC
          // Custom subclass implementation. 
          // Provides access to currentTip member.
          class wxRubyTipProvider : public wxTipProvider
          {
          public:
            wxRubyTipProvider(size_t currentTip=0) : wxTipProvider(currentTip) {}
            void SetCurrentTip(size_t currentTip) { m_currentTip = currentTip; }
          };
          __HEREDOC
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxTipProvider', 'wxRubyTipProvider')
        # add setter to class wrapper
        spec.add_extend_code 'wxTipProvider', <<~__HEREDOC
          void SetCurrentTip(size_t currentTip)
          {
            wxRubyTipProvider* rtp = dynamic_cast<wxRubyTipProvider*> (self);
            if (rtp) rtp->SetCurrentTip(currentTip);
          }
          __HEREDOC
        spec.add_swig_code '%alias wxTipProvider::SetCurrentTip "current_tip=";'
        # make Ruby object responsible for returned C++ tip provider
        spec.new_object 'wxCreateFileTipProvider'
        super
      end
    end # class TipProvider

  end # class Director

end # module WXRuby3
