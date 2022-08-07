
require 'rake'
require_relative './rake/lib/director'

WXRuby3::Extractor.xml_dir = '/home/martin/develop/wxwRuby/wxWidgets/docs/doxygen/out/xml/'
WXRuby3::Extractor.verbose = true
WXRuby3::Director.run
