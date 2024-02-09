# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 extension configuration file for gems
###

# generate new rakefile with appropriate default task (calls actual task in rakelib)
File.open('../Rakefile', 'w') do |f|
  f.puts <<EOF__
###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

unless File.file?(File.join('lib', 'wx', 'wxruby_core.so'))
  task :default do
    Rake::Task['wxruby:gem:install'].invoke
  end
end
EOF__
end
