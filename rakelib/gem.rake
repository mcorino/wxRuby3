# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './gem'

namespace :wxruby do

  namespace :gem do

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
      
          The wxRuby3 sample selector can be run by executing:
      
          $ ./wxruby sampler
      
          Have fun using wxRuby3.
          __MSG
      end
    end

  end

end

# source gem file
file WXRuby3::Gem.gem_file => WXRuby3::Gem.manifest do
  gemspec = WXRuby3::Gem.define_spec do |gem|
    gem.summary = %Q{wxWidgets extension for Ruby}
    gem.description = %Q{wxRuby3 is a Ruby library providing an extension for the wxWidgets C++ UI framework}
    gem.email = 'mcorino@m2c-software.nl'
    gem.homepage = "https://github.com/mcorino/wxRuby3"
    gem.authors = ['Martin Corino']
    gem.extensions = ['ext/mkrf_conf_ext.rb']
    gem.files = WXRuby3::Gem.manifest
    gem.require_paths = %w{lib}
    gem.bindir = 'bin'
    gem.executables = WXRuby3::Bin.binaries
    gem.required_ruby_version = '>= 2.5'
    gem.licenses = ['MIT']
    gem.add_dependency 'nokogiri', '~> 1.12'
    gem.add_dependency 'rake'
    gem.add_dependency 'minitest', '~> 5.15'
    gem.add_dependency 'test-unit', '~> 3.5'
    gem.rdoc_options <<
      '--exclude=\\.dll' <<
      '--exclude=\\.so' <<
      '--exclude=lib/wx.rb' <<
      '--exclude=lib/wx/*.rb' <<
      "'--exclude=lib/wx/(aui|core|grid|html|pg|prt|rbn|rtc|stc|wxruby)/.*'"
    gem.metadata = {
      "bug_tracker_uri"   => "https://github.com/mcorino/wxRuby3/issues",
      "source_code_uri"   => "https://github.com/mcorino/wxRuby3",
      "documentation_uri" => "https://mcorino.github.io/wxRuby3",
      "homepage_uri"      => "https://github.com/mcorino/wxRuby3",
      "github_repo"       => "https://github.com/mcorino/wxRuby3"
    }
    gem.post_install_message = <<~__MSG

      The wxRuby3 Gem has been successfully installed including the 'wxruby' utility.

      In case no suitable binary release package was available for your platform you  
      will need to run the post-install setup process by executing:

      $ wxruby setup

      Otherwise (or after you have successfully run the setup procedure) you can start
      using wxRuby3.
 
      You can run the regression tests to verify the installation by executing:

      $ wxruby test

      The wxRuby3 sample selector can be run by executing:

      $ wxruby sampler

      Have fun using wxRuby3.

      Run 'wxruby -h' to see information on the available commands.

      __MSG
  end
  WXRuby3::Gem.build_gem(gemspec)
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
    file WXRuby3::Gem.bin_pkg_file => WXRuby3::Gem.bin_pkg_manifest do |t|
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
