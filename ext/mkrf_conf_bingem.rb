# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 extension configuration file for binary gem
###

# generate Rakefile with appropriate default task (all actual task in rakelib)
File.open('../Rakefile', 'w') do |f|
  f.puts <<EOF__
###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

task :default do
  Rake::Task['wxruby:post:bingem'].invoke
end
EOF__
end
