# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake gem support
###

require_relative './lib/config'
require_relative './install'

module WXRuby3

  module Post

    def self.create_startup(code)
      File.open('lib/wx/startup.rb', 'w+') do |f|
        f.puts <<~__CODE
          # Wx startup for wxRuby3
          # Copyright (c) M.J.N. Corino, The Netherlands

          #{code}
          __CODE
      end
    end

    def self.setup_add_dll_directory(dll_directory)
      <<~__CODE
        begin
          require 'ruby_installer'
          if RubyInstaller::Runtime.respond_to?(:add_dll_directory)
            RubyInstaller::Runtime.add_dll_directory('#{dll_directory}')
          else
            RubyInstaller::Build.add_dll_directory('#{dll_directory}')
          end
        rescue LoadError
        end
        __CODE
    end

    def self.setup_adjust_wx_prefix
      <<~__CODE
        ENV['WXPREFIX'] = File.realpath(File.join(__dir__, '..', '..', 'ext'))
        __CODE
    end

  end

end
