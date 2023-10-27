# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Animation < Director

      include Typemap::IOStreams

      def setup
        super
        spec.items << 'wxAnimationDecoder'
        spec.ignore 'wxAnimation::IsCompatibleWith' # no wxClassInfo in wxRuby
        spec.gc_as_refcounted 'wxAnimationDecoder'
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxAnimationDecoder', 'wxRubyAnimationDecoder')
        spec.regard 'wxAnimationDecoder::DoCanRead'
        spec.override_inheritance_chain('wxAnimationDecoder', [])
        spec.new_object 'wxAnimationDecoder::Clone'
        spec.suppress_warning(473, 'wxAnimationDecoder::Clone')
        spec.extend_interface('wxAnimationDecoder', 'virtual ~wxAnimationDecoder ();')
        spec.add_header_code <<~__HEREDOC
          class wxRubyAnimationDecoder : public wxAnimationDecoder
          {
          public:
            wxRubyAnimationDecoder () {}
            virtual ~wxRubyAnimationDecoder () { }
            virtual wxAnimationDecoder *Clone () const { return 0; }
            virtual wxAnimationType GetType () const { return wxANIMATION_TYPE_INVALID; }
            virtual bool ConvertToImage (unsigned int /*frame*/, wxImage * /*image*/) const { return false; }
            virtual wxSize GetFrameSize(unsigned int /*frame*/) const { return wxSize(0,0); }
            virtual wxPoint GetFramePosition(unsigned int /*frame*/) const { return wxPoint(0,0); }
            virtual wxAnimationDisposal GetDisposalMethod(unsigned int /*frame*/) const { return wxANIM_UNSPECIFIED; }
            virtual long GetDelay(unsigned int /*frame*/) const { return 0; }
            virtual wxColour GetTransparentColour(unsigned int /*frame*/) const { return wxNullColour; }
          protected:
            virtual bool DoCanRead (wxInputStream &/*stream*/) const { return false; }
          };
          __HEREDOC
        spec.map 'wxImage *' => 'Wx::Image' do
          map_in ignore: true, temp: 'wxImage tmpImg', code: '$1 = &tmpImg;'
          map_argout code: <<~__CODE
            if (TYPE($result) == T_ARRAY)
            {
              $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj($1, SWIGTYPE_p_wxImage, 0));
            }
            else
            {
              $result = SWIG_NewPointerObj($1, SWIGTYPE_p_wxImage, 0);
            }
          __CODE
          map_directorargout code: <<~__CODE
            void* ptr = 0;
            int res$argnum = SWIG_ConvertPtr($result, &ptr, SWIGTYPE_p_wxImage,  0 );
            if (!SWIG_IsOK(res$argnum)) {
              Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError, "Expected Wx::Image result");
            }
            *$1 = *reinterpret_cast<wxImage*> (ptr);
          __CODE
        end
        spec.map 'wxAnimationDecoderList &' => 'Array<Wx::AnimationDecoder>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            wxAnimationDecoderList::compatibility_iterator node = $1->GetFirst();
            while (node)
            {
              wxAnimationDecoder *wx_ad = node->GetData();
              VALUE rb_ad = SWIG_NewPointerObj(wx_ad, SWIGTYPE_p_wxAnimationDecoder, 0);
              rb_ary_push($result, rb_ad);
              node = node->GetNext();
            }
          __CODE
        end
      end

    end # class Animation

  end # class Director

end # module WXRuby3
