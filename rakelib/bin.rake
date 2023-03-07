###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'rake/clean'

require_relative './bin'

directory 'bin'

file File.join('bin', 'wxruby') => 'bin' do |t|
  File.open(t.name, 'w') { |f| f.puts WXRuby3::Bin.wxruby }
  File.chmod(0755, t.name)
end

namespace :wxruby do

  namespace :bin do

    task :build => %w[wxruby:bin:check wxruby:bin:files]

    task :check do
      WXRuby3::Bin.binaries.each do |bin|
        if File.exist?(File.join('bin', bin))
          content = IO.read(File.join('bin', bin))
          rm_f(File.join('bin', bin)) unless content == WXRuby3::Bin.__send__(bin.gsub('.','_').to_sym)
        end
      end
    end

    task :files => [File.join('bin', 'wxruby')]
  end
end

CLOBBER.include File.join('bin', 'wxruby')

if WXRuby3.config.windows?

  file File.join('bin', 'wxruby.bat') => ['bin'] do |t|
    File.open(t.name, 'w') { |f| f.puts WXRuby3::Bin.wxruby_bat }
  end
  Rake::Task['wxruby:bin:files'].enhance [File.join('bin', 'wxruby.bat')]

  CLOBBER.include File.join('bin', 'wxruby.bat')

end
