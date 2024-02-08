# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake file
###

require_relative './gem'

namespace :wxruby do

  namespace :gem do

    task :srcgem => ['bin:build', WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION)]

    if WXRuby3.is_bootstrapped?
      task :binpkg => ['wxruby:build', 'bin:build', WXRuby3::Gem.bin_pkg_file(WXRuby3::WXRUBY_VERSION)]
    end

    # this task only exists for installed source gems (where package tasks have been removed)
    unless File.file?(File.join(__dir__, 'package.rake'))

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
file WXRuby3::Gem.gem_file('wxruby3', WXRuby3::WXRUBY_VERSION) => WXRuby3::Gem.manifest do
  gemspec = WXRuby3::Gem.define_spec('wxruby3', WXRuby3::WXRUBY_VERSION) do |gem|
    gem.summary = %Q{wxWidgets extension for Ruby}
    gem.description = %Q{wxRuby3 is a Ruby library providing an extension for the wxWidgets C++ UI framework}
    gem.email = 'mcorino@m2c-software.nl'
    gem.homepage = "https://github.com/mcorino/wxRuby3"
    gem.authors = ['Martin Corino']
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

      The wxRuby3 Gem has been successfully installed.
      Before being able to use wxRuby3 you need to run the post-install setup process
      by executing the command 'wxruby setup'.

      Run 'wxruby setup -h' to see information on the available commandline options.

      __MSG
  end
  WXRuby3::Gem.build_gem(gemspec)
end

desc 'Build wxRuby 3 gem'
task :gem => 'wxruby:gem:srcgem'

if WXRuby3.is_bootstrapped?

  # binary package file
  file WXRuby3::Gem.bin_pkg_file(WXRuby3::WXRUBY_VERSION) => WXRuby3::Gem.bin_pkg_manifest do |t|
    WXRuby3::Install.install_wxwin_shlibs
    begin
      # create bin package
      WXRuby3::Gem.build_bin_pkg(t.name, WXRuby3::Gem.bin_pkg_manifest)
    ensure
      # cleanup
      WXRuby3::Install.remove_wxwin_shlibs
    end
  end

  desc 'Build wxRuby 3 binary release package'
  task :binpkg => 'wxruby:gem:binpkg'

end
