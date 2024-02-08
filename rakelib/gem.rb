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
require 'zlib'
require 'tempfile'
require 'json'

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

    def self.bin_pkg_file(version)
      File.join('pkg', "#{WXRuby3::Gem.bin_pkg_name(version)}.pkg")
    end

    def self.build_bin_pkg(fname, manifest)
      # package registry
      registry = []
      # package temp deflate stream
      deflate_stream = Tempfile.new(File.basename(fname, '.*'), binmode: true)
      begin
        # pack binaries into temp deflate stream
        manifest.each do |path|
          pack = true
          entry = [path, File.stat(path).mode, 0]
          unless WXRuby3.config.windows?
            if File.symlink?(path)
              pack = false
              entry << File.readlink(path)
            end
          end
          if pack
            offs = deflate_stream.tell
            deflate_stream.write(Zlib::Deflate.deflate(File.read(path, binmode: true)))
            entry[2] = deflate_stream.tell - offs # packed data size
          end
          registry << entry
        end
        # convert registry to deflated json string
        registry_json_z = Zlib::Deflate.deflate(registry.to_json)
        # create final package archive
        deflate_stream.rewind
        File.open(fname, 'w', binmode: true) do |fout|
          fout.write([registry_json_z.size].pack('Q'))
          fout.write(registry_json_z)
          registry.each do |entry|
            fout.write(deflate_stream.read(entry[2])) if entry[2] > 0
          end
        end
      ensure
        deflate_stream.close(true)
      end
    end

    def self.install_bin_pkg(fname)
      File.open(fname, 'r', binmode: true) do |fin|
        # get packed registry size
        registry_size = fin.read(8).unpack('Q').shift
        # unpack registry
        registry = JSON.parse!(Zlib::Inflate.inflate(fin.read(registry_size)))
        # unpack and create binaries
        registry.each do |entry|
          path, mode, size, symlink = entry
          if symlink
            FileUtils.ln_s(symlink, path)
          else
            File.open(path, 'w', binmode: true) do |fbin|
              fbin << Zlib::Inflate.inflate(fin.read(size))
            end
            File.chmod(mode, path)
          end
        end
      end
    end

  end

end
