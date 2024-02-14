# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 extension configuration file for gems
###

require 'optparse'

OPTIONS = {
}

opts = OptionParser.new
opts.banner = "wxRuby3 extension build script\n\nUsage: gem install wxruby3 -- -h|--help OR gem install wxruby3 [-- options]\n\n"
opts.separator ''
opts.on('--[no-]prebuilt',
        "Specifies to either require ('--prebuilt') or avoid ('--no-prebuilt') installing prebuilt binary packages.",
        "If not specified installing a prebuilt package will be attempted reverting to source install if none found.")  {|v| OPTIONS[:prebuilt] = !!v }
opts.on('--package=URL',
        "Specifies the http(s) url or absolute path to the prebuilt binary package to install.",
        "Implies '--prebuilt'.")  {|v| OPTIONS[:package] = v }
opts.on('-h', '--help',
        'Show this message.') do |v|
  puts opts
  puts
  exit(0)
end
opts.parse!(args)

task_args = ''
unless OPTIONS[:prebuilt].nil?
  task_args << (OPTIONS[:prebuilt] ? '--prebuilt' : '--no-prebuilt')
end
if OPTIONS[:package]
  task_args << ', ' unless task_args.empty?
  task_args << '--package, ' << OPTIONS[:package]
end

# generate new rakefile with appropriate default task (calls actual task in rakelib)
File.open('../Rakefile', 'w') do |f|
  f.puts <<EOF__
###
# wxRuby3 rake file
# Copyright (c) M.J.N. Corino, The Netherlands
###

unless File.file?(File.join('lib', 'wx', 'wxruby_core.so'))
  task :default do
    Rake::Task['wxruby:gem:install'].invoke(#{task_args})
  end
end
EOF__
end
