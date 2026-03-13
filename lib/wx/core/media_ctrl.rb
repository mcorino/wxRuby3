# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx


  class MediaCtrl < Wx::Control

  if Wx::PLATFORM == 'WXMSW'
  
  wx_load = instance_method :load
  wx_redefine_method :load do |*args|
	uri_or_path = args.shift
	if args.empty? && uri_or_path.is_a?(::URI) && uri_or_path.scheme == 'file'
	  if uri_or_path.host.empty?
		wx_load.bind(self).call("#{uri_or_path.path}")
	  else
		wx_load.bind(self).call("#{uri_or_path.host}:#{uri_or_path.path}")
	  end
	else
	  wx_load.bind(self).call(uri_or_path, *args)
	end
  end

  end

  end

end
