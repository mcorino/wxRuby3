# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake gem support
###

require 'set'
require 'rubygems'
require 'rubygems/package'
begin
  require 'rubygems/builder'
rescue LoadError
end

require_relative './lib/config'
require_relative './install'

module WXRuby3

  module Gem

    def self.manifest(gemtype = :src)
      # create MANIFEST list with included files
      manifest = Rake::FileList.new
      manifest.include %w[bin/*] # *nix executables in bin/
      manifest.exclude %w[bin/*.bat] unless WXRuby3.config.windows?
      manifest.include %w[assets/**/* lib/**/* samples/**/* tests/**/*]
      if gemtype == :bin
        if WXRuby3.config.get_config('with-wxwin')
          manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
        end
        manifest.include 'ext/mkrf_conf_bingem.rb'
        manifest.include %w[rakelib/prepost.* rakelib/install.rb rakelib/lib/config.rb rakelib/lib/config/**/* rakelib/lib/ext/**/* rakelib/yard/**/*]
        manifest.include WXRuby3::BUILD_CFG
      else
        manifest.exclude "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include 'ext/wxruby3/wxruby.ico', 'ext/wxruby3/swig/**/*', 'ext/wxruby3/include/**/*'
        manifest.exclude 'ext/wxruby3/swig/classes/**/*'
        manifest.include 'rakelib/**/*'
        manifest.exclude %w[rakelib/run.* rakelib/help.* rakelib/package.* rakelib/memcheck.* rakelib/memcheck/**/*]
        manifest.include 'rakefile'
      end
      manifest.include %w{LICENSE README.md CREDITS.md INSTALL.md .yardopts}
      manifest
    end

    def self.bin_pkg_manifest
      # create MANIFEST list with included files
      manifest = Rake::FileList.new
      manifest.include "lib/*.#{WXRuby3.config.dll_mask}"
      if WXRuby3.config.get_config('with-wxwin')
        manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
      end
      manifest
    end

    def self.define_spec(name, version, gemtype = :src, &block)
      gemspec = ::Gem::Specification.new(make_gem_name(name, gemtype), version)
      if gemtype == :bin
        platform = ::Gem::Platform.local.to_s
        gemspec.platform = platform
      end
      gemspec.required_rubygems_version = ::Gem::Requirement.new(">= 0") if gemspec.respond_to? :required_rubygems_version=
      block.call(gemspec) if block_given?
      gemspec
    end

    def self.make_gem_name(name, gemtype)
      if gemtype == :bin &&  WXRuby3.config.platform == :linux
        distro = Config::Platform::PkgManager.distro
        "#{name}-#{distro[:distro]}-#{distro[:release] || '0'}"
      else
        name
      end
    end

    def self.gem_name(name, version, gemtype = :src)
      define_spec(name, version, gemtype).full_name
    end

    def self.gem_file(name, version, gemtype = :src)
      File.join('pkg', "#{WXRuby3::Gem.gem_name(name, version, gemtype)}.gem")
    end

    def self.build_gem(gemspec)
      if defined?(::Gem::Package) && ::Gem::Package.respond_to?(:build)
        gem_file_name = ::Gem::Package.build(gemspec)
      else
        gem_file_name = ::Gem::Builder.new(gemspec).build
      end

      FileUtils.mkdir_p('pkg')

      FileUtils.mv(gem_file_name, 'pkg')
    end

    def self.make_bin_name
      if WXRuby3.config.platform == :linux
        distro = Config::Platform::PkgManager.distro
        "wxruby3_#{distro[:distro]}_#{distro[:release] || '0'}"
      else
        "wxruby3_#{WXRuby3.config.platform}"
      end
    end

    def self.bin_pkg_name(version)
      gemspec = ::Gem::Specification.new(make_bin_name, version)
      gemspec.platform = ::Gem::Platform.local.to_s
      gemspec.full_name
    end

    def self.bin_pkg_ext
      WXRuby3.config.windows? ? 'zip' : 'tar.gz'
    end

    def self.bin_pkg_file(version)
      File.join('pkg', "#{WXRuby3::Gem.bin_pkg_name(version)}.#{bin_pkg_ext}")
    end

    def self.build_bin_pkg(fname, manifest)
      if WXRuby3.config.windows?
        WXRuby3.config.execute("powershell Compress-Archive -Path #{manifest.join(',')} -DestinationPath #{fname} -Force")
      else
        WXRuby3.config.execute("tar -czf #{fname} #{manifest.to_s}")
      end
    end

  end

end
