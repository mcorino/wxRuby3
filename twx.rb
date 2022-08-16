
$:.insert(0, File.join(File.dirname(__FILE__), 'lib'))

# require './lib/wx'
#
# # This is the minimum code to start a WxRuby app - create a Frame, and
# # show it.
# Wx::App.run do
#   frame = Wx::Frame.new(nil, :title => "Minimal wxRuby App")
#   frame.background_colour = Wx::BLUE
#   icon_file = File.join( File.dirname(__FILE__)+"/../wxruby/art", "wxruby.png")
#   frame.icon = Wx::Icon.new(icon_file)
#   frame.create_status_bar(2)
#   frame.show
#   frame.on_evt_close do
#     Wx::about_box(:name => frame.title,
#                   :version     => Wx::WXRUBY_VERSION,
#                   :description => "This is the minimal sample",
#                   :developers  => ['The wxRuby Development Team'] )
#     frame.close()
#   end
# end

#require_relative './samples/minimal/nothing'
#require_relative './samples/minimal/minimal'
require_relative './samples/event/event'