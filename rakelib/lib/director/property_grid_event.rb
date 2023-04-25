###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event'

module WXRuby3

  class Director

    include Typemap::PGProperty

    class PropertyGridEvent < Event

      def setup
        super
        if Config.instance.wx_version >= '3.3.0'
          # work around the, disputable, use of strong enums here
          spec.ignore 'wxPropertyGridEvent::SetValidationFailureBehavior', ignore_doc: false
          spec.add_extend_code 'wxPropertyGridEvent', <<~__HEREDOC
            void SetValidationFailureBehavior(int vfb_flags)
            {
              $self->SetValidationFailureBehavior(static_cast<wxPGVFBFlags> (vfb_flags));
            }
          __HEREDOC
        end
      end
    end # class PropertyGridEvent

  end # class Director

end # module WXRuby3
