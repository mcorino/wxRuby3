# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # A generic (non-native) static bitmap control to display bitmap.
  #
  # Unlike the native control implemented by {Wx::StaticBitmap}, which on some platforms is only meant for display of
  # the small icons in the dialog boxes, you may use this implementation to display larger images portably.
  # Notice that for the best results, the size of the control should be the same as the size of the image displayed in
  # it, as happens by default if it's not resized explicitly. Otherwise, behaviour depends on the platform: under MSW,
  # the bitmap is drawn centred inside the control, while elsewhere it is drawn at the origin of the control. You can
  # use {Wx::GenericStaticBitmap#set_scale_mode} to control how the image is scaled inside the control.
  #
  # @see Wx::Bitmap
  # @see Wx::StaticBitmap
  class GenericStaticBitmap < Control

  end

end
