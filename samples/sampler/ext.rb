# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 sampler application core extensions
###

class ::String

  def modulize!
    self.gsub!(/[^a-zA-Z0-9_]/, '_')
    self.sub!(/^[a-z\d]*/) { $&.capitalize }
    self.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    self
  end

  def modulize
    self.dup.modulize!
  end
end
