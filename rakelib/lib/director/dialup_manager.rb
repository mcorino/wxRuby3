# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Defs director
###

module WXRuby3

  class Director

    class DialUpManager < Director

      def setup
        super
        spec.gc_as_untracked
        spec.make_abstract 'wxDialUpManager'
        spec.disable_proxies
        spec.ignore 'wxDialUpManager::GetISPNames', ignore_doc: false
        spec.add_extend_code 'wxDialUpManager', <<~__HEREDOC
          VALUE get_isp_names() const
          {
            VALUE rb_isps = rb_ary_new();
            wxArrayString isps;
            size_t n_isps = $self->GetISPNames(isps);
            for (size_t i=0; i<n_isps ;++i)
            {
              rb_ary_push(rb_isps, WXSTR_TO_RSTR(isps.Item(i)));
            }
            return rb_isps;
          }
          __HEREDOC
        spec.map 'wxArrayString& names', swig: false do
          map_in ignore: true, code: ''
          map_out ignore: 'size_t'
          map_argout as: 'Array<String>'
        end
      end

    end

  end

end
