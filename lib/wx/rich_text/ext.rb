# Constant extension loader for Wx::RichText
# Copyright (c) M.J.N. Corino, The Netherlands

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '*.rb')) do | fpath |
  require_relative './ext/' + File.basename(fpath)
end
