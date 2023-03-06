###
# wxRuby3 rake gem support
# Copyright (c) M.J.N. Corino, The Netherlands
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

  end

end
