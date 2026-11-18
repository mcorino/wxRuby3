# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class DataViewEvent < Event

      include Typemap::DataViewItem

      def setup
        super
        spec.override_inheritance_chain('wxDataViewEvent',
                                        {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
        spec.ignore 'wxDataViewEvent::GetDataBuffer', ignore_doc: false
        spec.add_extend_code 'wxDataViewEvent', <<~__HEREDOC
          VALUE GetDataBuffer()
          {
            const char* data = (const char*)$self->GetDataBuffer();
            if (data)
              return rb_utf8_str_new(data, $self->GetDataSize());
            else
              return Qnil;
          }          
          __HEREDOC
        spec.map 'void*' => '::String', swig: false
        # only for wxWidgets internal use
        spec.ignore 'wxDataViewEvent::SetDataBuffer', 'wxDataViewEvent::SetDataSize'
        if Config.instance.wx_version_check('3.3.4') <= 0
          spec.ignore 'wxDataViewEvent::SetDataViewColumn', 'wxDataViewEvent::SetModel', 'wxDataViewEvent::SetItem'
        end
        spec.do_not_generate :typedefs, :variables, :defines, :functions, :enums
      end
    end # class DataViewEvent

  end # class Director

end # module WXRuby3
