# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 extension configuration file for gems
###

OPTIONS = {
}

until ARGV.empty?
  switch = ARGV.shift
  case switch
  when /^prebuilt=(none|only)$/
    OPTIONS[:prebuilt] = $1 == 'only'
  when /^package=(.+)$/
    OPTIONS[:package] = $1
  when 'help'
    puts <<~__INFO_TXT
      wxRuby3 extension build script

      Usage: gem install wxruby3 -- help OR gem install wxruby3 [-- options [...]]

        options:

        prebuilt=OPT    Specifies to either require (OPT == 'only') or avoid (OPT == 'none') installing prebuilt 
                        binary packages. If not specified installing a prebuilt package will be attempted reverting 
                        to source install if none found.

        package=URL     Specifies the http(s) url or absolute path to the prebuilt binary package to install.
                        Implies 'prebuilt=only'.

        help            Show this message.
      __INFO_TXT
    puts
    exit(1)
  else
    $stderr.puts "ERROR: Invalid option [#{switch}] for wxRuby3 extension build script."
    exit(1)
  end
end

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
