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
require 'uri'
require 'net/https'

require_relative './lib/config'
require_relative './install'

module WXRuby3

  module Gem

    class << self

      # Gem helpers

      def manifest
        # create MANIFEST list with included files
        manifest = Rake::FileList.new
        manifest.include %w[bin/*] # *nix executables in bin/
        manifest.exclude %w[bin/*.bat] unless WXRuby3.config.windows?
        manifest.include %w[assets/**/* lib/**/* samples/**/* tests/**/*]
        manifest.exclude "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include 'ext/mkrf_conf_ext.rb', 'ext/wxruby3/wxruby.ico', 'ext/wxruby3/swig/**/*', 'ext/wxruby3/include/**/*'
        manifest.exclude 'ext/wxruby3/swig/classes/**/*'
        manifest.include 'rakelib/**/*'
        manifest.exclude %w[rakelib/run.* rakelib/help.* rakelib/package.* rakelib/memcheck.* rakelib/memcheck/**/*]
        manifest.include %w{LICENSE README.md CREDITS.md INSTALL.md .yardopts}
        manifest
      end

      def define_spec(&block)
        gemspec = ::Gem::Specification.new('wxruby3', WXRuby3::WXRUBY_VERSION)
        gemspec.required_rubygems_version = ::Gem::Requirement.new(">= 0") if gemspec.respond_to? :required_rubygems_version=
        block.call(gemspec) if block_given?
        gemspec
      end

      def gem_name
        define_spec.full_name
      end
      private :gem_name

      def gem_file
        File.join('pkg', "#{gem_name}.gem")
      end

      def build_gem(gemspec)
        if defined?(::Gem::Package) && ::Gem::Package.respond_to?(:build)
          gem_file_name = ::Gem::Package.build(gemspec)
        else
          gem_file_name = ::Gem::Builder.new(gemspec).build
        end

        FileUtils.mkdir_p('pkg')

        FileUtils.mv(gem_file_name, 'pkg')
      end

      # Binary package helpers

      def bin_pkg_manifest
        # create MANIFEST list with included files
        manifest = Rake::FileList.new
        manifest.include "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include "lib/wx/doc/gen/**/*.rb"
        if WXRuby3.config.get_config('with-wxwin')
          manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
        end
        manifest
      end

      def make_bin_name
        if WXRuby3.config.platform == :linux
          distro = Config::Platform::PkgManager.distro
          "wxruby3_#{distro[:distro]}_#{distro[:release] || '0'}"
        else
          "wxruby3_#{WXRuby3.config.platform}"
        end
      end
      private :make_bin_name

      def bin_pkg_name
        gemspec = ::Gem::Specification.new(make_bin_name, WXRuby3::WXRUBY_VERSION)
        gemspec.platform = ::Gem::Platform.local.to_s
        gemspec.full_name
      end
      private :bin_pkg_name

      def bin_pkg_file
        File.join('pkg', "#{bin_pkg_name}.pkg")
      end

      def build_bin_pkg(fname)
        # make sure pkg directory exists
        FileUtils.mkdir_p('pkg')

        # package registry
        registry = []
        # package temp deflate stream
        deflate_stream = Tempfile.new(File.basename(fname, '.*'), binmode: true)
        begin
          # pack binaries into temp deflate stream
          bin_pkg_manifest.each do |path|
            registry << pack_file(deflate_stream, path)
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

      def pack_file(os, path)
        pack = true
        entry = [path, File.stat(path).mode, 0]
        unless WXRuby3.config.windows?
          if File.symlink?(path)
            pack = false
            entry << File.readlink(path)
          end
        end
        if pack
          offs = os.tell
          os.write(Zlib::Deflate.deflate(File.read(path, binmode: true)))
          entry[2] = os.tell - offs # packed data size
        end
        entry
      end
      private :pack_file

      # Gem installation helpers

      def install_gem
        # check if there exists a pre-built binary release package for the current platform
        if has_release_package?
          # download the binary release package
          $stdout.puts "Downloading #{bin_pkg_url}..."
          if WXRuby3.config.download_file(bin_pkg_url, bin_pkg_name+'.pkg')
            install_bin_pkg(bin_pkg_name+'.pkg')
          else
            $stdout.puts "WARNING: Unable to download binary release package (#{bin_pkg_name})! Reverting to source install."
          end
        end
      end

      def bin_pkg_url
        # which package are we looking for
        pkg_name = bin_pkg_name
        "https://github.com/mcorino/wxRuby3/releases/download/v#{WXRuby3::WXRUBY_VERSION}/#{pkg_name}.pkg"
      end
      private :bin_pkg_url

      def has_release_package?
        # check if the release package exists on Github
        uri = URI(bin_pkg_url)
        $stdout.print "Checking #{uri.to_s}..." if WXRuby3.config.verbose?
        response = Net::HTTP.start('github.com', use_ssl: true) do |http|
          request = Net::HTTP::Head.new(uri)
          http.request(request)
        end
        $stdout.puts "response #{response}" if WXRuby3.config.verbose?
        # directly found or with redirect
        Net::HTTPOK === response || Net::HTTPRedirection === response
      end
      private :has_release_package?

      def install_bin_pkg(fname)
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
      private :install_bin_pkg

    end

  end

end
