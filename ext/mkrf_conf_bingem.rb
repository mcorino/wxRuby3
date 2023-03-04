###
# wxRuby3 extension configuration file for binary gem
# Copyright (c) M.J.N. Corino, The Netherlands
###

# generate Rakefile with appropriate default task (all actual task in rakelib)
File.open('../Rakefile', 'w') do |f|
  f.puts <<EOF__
###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

task :default do
  Rake::Task['wxruby:startup:config'].invoke
end
EOF__
end
