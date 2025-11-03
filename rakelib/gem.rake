# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './gem'

namespace :wxruby do

  namespace :gem do

    task :srcgemspec => ['bin:build', WXRuby3::Gem.gemspec_file]

    task :srcgem => ['bin:build', WXRuby3::Gem.gem_file]

    # this task only exists for installed (source) gems (where run tasks have been removed)
    unless File.file?(File.join(__dir__, 'run.rake'))

      task :setup => 'config:bootstrap' do |_t, args|
        begin
          $stdout.print "Building wxRuby3 extensions..." if WXRuby3.config.run_silent?
          WXRuby3.config.set_silent_run_incremental
          Rake::Task['wxruby:build'].invoke
          WXRuby3.config.set_silent_run_batched
          $stdout.puts 'done!' if WXRuby3.config.run_silent?
          Rake::Task['wxruby:post:srcgem'].invoke
          # all is well -> cleanup
          if args.extras.include?(':keep_log')
            $stdout.puts "Log: #{WXRuby3.config.silent_log_name}"
          else
            rm_f(WXRuby3.config.silent_log_name, verbose: WXRuby3.config.verbose?)
          end
        rescue Exception => ex
          $stderr.puts <<~__ERR_TXT
            #{ex.message}#{WXRuby3.config.verbose? ? "\n#{ex.backtrace.join("\n")}" : ''}

            For error details check #{WXRuby3.config.silent_log_name}
            __ERR_TXT
          exit(1)
        end
        $stdout.puts <<~__MSG
      
          wxRuby3 has been successfully installed including the 'wxruby' utility.
      
          You can run the regression tests to verify the installation by executing:
      
          $ ./wxruby test
      
          The wxRuby3 sample explorer can be run by executing:
      
          $ ./wxruby sampler
      
          Have fun using wxRuby3.
          __MSG
      end
    end

  end

end

file WXRuby3::Gem.gemspec_file => WXRuby3::Gem.manifest do |t|
  code = <<~__GEMSPEC
    Gem::Specification.new('wxruby3', '#{WXRuby3::WXRUBY_VERSION}') do |gem|
      gem.summary = %Q{wxWidgets extension for Ruby}
      gem.description = %Q{wxRuby3 is a Ruby library providing an extension for the wxWidgets C++ UI framework}
      gem.email = 'mcorino@m2c-software.nl'
      gem.homepage = "https://github.com/mcorino/wxRuby3"
      gem.authors = ['Martin Corino']
      gem.extensions = ['ext/mkrf_conf_ext.rb']
      gem.files = [#{WXRuby3::Gem.manifest.collect {|f| "'#{f}'" }.join(',')}]
      gem.require_paths = %w{lib}
      gem.bindir = 'bin'
      gem.executables = [#{WXRuby3::Bin.binaries.collect { |b| "'#{b}'" }.join(',')}]
      gem.required_ruby_version = '>= 2.5'
      gem.licenses = ['MIT']
      gem.add_dependency 'nokogiri', '~> 1.12'
      gem.add_dependency 'rake'
      gem.add_dependency 'power_assert', '~> 2.0'
      gem.add_dependency 'minitest', '~> 5.15'
      gem.add_dependency 'test-unit', '~> 3.5'
      gem.add_dependency 'plat4m', '~> 1.1'
      gem.rdoc_options <<
        '--exclude=\\.dll' <<
        '--exclude=\\.so' <<
        '--exclude=lib/wx.rb' <<
        '--exclude=lib/wx/*.rb' <<
        "'--exclude=lib/wx/(aui|core|grid|html|pg|prt|rbn|rtc|stc|wxruby)/.*'"
      gem.metadata = {
        "bug_tracker_uri"   => "https://github.com/mcorino/wxRuby3/issues",
        "homepage_uri"      => "https://github.com/mcorino/wxRuby3/wiki",
        "source_code_uri"   => "https://github.com/mcorino/wxRuby3",
        "documentation_uri" => "https://mcorino.github.io/wxRuby3",
        "github_repo"       => "https://github.com/mcorino/wxRuby3"
      }
      gem.post_install_message = <<~__MSG
  
        The wxRuby3 Gem has been successfully installed including the 'wxruby' utility.
  
        In case no suitable binary release package was available for your platform you  
        will need to run the post-install setup process by executing:
  
        $ wxruby setup
  
        To check whether wxRuby3 is ready to run or not you can at any time execute the 
        following command:
  
        $ wxruby check
  
        Run 'wxruby check -h' for more information.
  
        When the wxRuby3 setup has been fully completed you can start using wxRuby3.
   
        You can run the regression tests to verify the installation by executing:
  
        $ wxruby test
  
        The wxRuby3 sample explorer can be run by executing:
  
        $ wxruby sampler
  
        Have fun using wxRuby3.
  
        Run 'wxruby -h' to see information on the available commands.
  
        __MSG
      gem.required_rubygems_version = '>= 0' if gem.respond_to? :required_rubygems_version=
    end
    __GEMSPEC
  File.open(t.name, 'w') { |f| f.puts code }
end


CLOBBER.include WXRuby3::Gem.gemspec_file

desc 'Build wxRuby 3 gemspec'
task :gemspec => 'wxruby:gem:srcgemspec'

directory 'pkg'

# source gem file
file WXRuby3::Gem.gem_file => ['wxruby:gem:srcgemspec', 'pkg'] do
  WXRuby3.config.sh "gem build #{WXRuby3::Gem.gemspec_file} -o #{WXRuby3::Gem.gem_file}"
end

desc 'Build wxRuby 3 gem'
task :gem => 'wxruby:gem:srcgem'

# these tasks do not exist for installed (source) gems (where run tasks have been removed)
if File.file?(File.join(__dir__, 'run.rake'))

  if WXRuby3.is_bootstrapped?

    namespace :wxruby do

      namespace :gem do
        task :binpkg => ['wxruby:build', 'wxruby:doc', 'bin:build', WXRuby3::Gem.bin_pkg_file]
      end

    end

    # binary package file
    file WXRuby3::Gem.bin_pkg_file => [*WXRuby3::Gem.bin_pkg_manifest, 'pkg'] do |t|
      WXRuby3::Install.install_wxwin_shlibs
      begin
        # create bin package
        WXRuby3::Gem.build_bin_pkg
      ensure
        # cleanup
        WXRuby3::Install.remove_wxwin_shlibs
      end
    end

    desc 'Build wxRuby 3 binary release package'
    task :binpkg => 'wxruby:gem:binpkg'

  end

else # in case of installed source gem the following tasks exist

  namespace :wxruby do

    namespace :gem do
      kwargs = {}
      no_prebuilt = false
      task :install do |_, args|
        argv = args.extras
        until argv.empty?
          switch = argv.shift
          case switch
          when '--prebuilt'
            kwargs[:prebuilt_only] = true
          when '--no-prebuilt'
            no_prebuilt = true unless kwargs[:package]
          when '--package'
            fail "Missing value for '--package' argument for wxruby:gem:install." if argv.empty?
            kwargs[:package] = argv.shift
            no_prebuilt = false
          else
            fail "Invalid argument #{switch} for wxruby:gem:install."
          end
        end
        unless no_prebuilt # do not even try to find&install a binary package
          if WXRuby3::Gem.install_gem(**kwargs)
            # binaries have been installed -> finish install
            Rake::Task['wxruby:post:binpkg'].invoke
          end
        end
      end

    end

  end

end
