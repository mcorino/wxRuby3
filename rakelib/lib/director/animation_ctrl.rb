# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AnimationCtrl < Window

      include Typemap::IOStreams

      def setup
        super
        spec.items << 'wxGenericAnimationCtrl'
        spec.include 'wx/animate.h'
        spec.include 'wx/generic/animate.h'
        if Config.instance.wx_version >= '3.3.0'
          spec.items << 'wxAnimationBundle'
          spec.ignore 'wxAnimationBundle::GetAll', ignore_doc: false
          spec.add_extend_code 'wxAnimationBundle', <<~__HEREDOC
            VALUE get_all() const
            {
              const std::vector<wxAnimation>& ani_list = $self->GetAll();
              VALUE rb_ani_list = rb_ary_new();
              for (const wxAnimation& ani : ani_list)
              {
                VALUE rb_ani = SWIG_NewPointerObj(new wxAnimation(ani), SWIGTYPE_p_wxAnimation, SWIG_POINTER_OWN);
                rb_ary_push(rb_ani_list, rb_ani);
              }
              return rb_ani_list;
            }
            __HEREDOC
          spec.map 'const std::vector<wxAnimation>&' => 'Array<Wx::Animation>', swig: false do
            map_out code: ''
          end
          # adjust documentation for #set_animation argument
          spec.map 'const wxAnimationBundle &animations', as: 'Wx::AnimationBundle,Wx::Animation', swig: false do
            map_in code: ''
          end
        end
        # replace method signature by one that provides a default argument to correctly provide
        # the two overloads the Ruby way
        spec.ignore 'wxGenericAnimationCtrl::Play'
        spec.extend_interface 'wxGenericAnimationCtrl', 'bool Play(bool looped=true)'
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class AnimationCtrl

  end # class Director

end # module WXRuby3
