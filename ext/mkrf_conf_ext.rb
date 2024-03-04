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
  when /^prebuilt=(none|only|head)$/
    OPTIONS[:prebuilt] = $1.to_sym
  when /^package=(.+)$/
    OPTIONS[:package] = $1
  when 'help'
    puts <<~__INFO_TXT
      wxRuby3 extension build script

      Usage: gem install wxruby3 -- help OR gem install wxruby3 [-- options [...]]

        options:

        prebuilt=OPT    Specifies to either require (OPT == 'only' | 'head') or avoid (OPT == 'none') installing prebuilt 
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

task_args = []
unless OPTIONS[:prebuilt].nil?
  case OPTIONS[:prebuilt]
  when :only
    task_args << "'--prebuilt'"
  when :none
    task_args << "'--no-prebuilt'"
  when :head
    task_args << "'--prebuilt'" << "'head'"
  end
end
if OPTIONS[:package]
  pkg = RUBY_PLATFORM =~ /mingw/ ? OPTIONS[:package].gsub('\\', '/') : OPTIONS[:package] # make sure the path is URI compatible
  task_args << "'--package'" << "'#{pkg}'"
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
    Rake::Task['wxruby:gem:install'].invoke(#{task_args.join(', ')})
  end
end
EOF__
end
