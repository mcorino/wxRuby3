
require 'wx'
fail "ERROR: Expected #{ARGV[0]} but is #{Wx::WXWIDGETS_VERSION}" unless Wx::WXWIDGETS_VERSION == ARGV[0]
