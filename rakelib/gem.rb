# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake gem support
###

require 'set'
require 'rubygems'
require 'zlib'
require 'tempfile'
require 'json'
require 'uri'
require 'net/https'
require 'fileutils'
require 'digest/sha2'

require_relative './lib/config'
require_relative './install'

module WXRuby3

  module Gem

    BINPKG_EXT = '.pkg'
    DIGEST_EXT = '.sha'

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

      def gemspec_file
        "#{gem_name}.gemspec"
      end

      def gem_file
        File.join('pkg', "#{gem_name}.gem")
      end

      # Binary package helpers

      def bin_pkg_manifest
        # create MANIFEST list with included files
        manifest = Rake::FileList.new
        manifest.include "lib/*.#{WXRuby3.config.dll_mask}"
        manifest.include 'lib/wx/**/events/*.rb', 'lib/wx/**/ext/*.rb', 'lib/wx/core/font/*.rb'
        manifest.include "lib/wx/doc/gen/**/*.rb"
        if WXRuby3.config.get_config('with-wxwin')
          manifest.include "ext/*.#{WXRuby3.config.dll_mask}"
        end
        manifest
      end

      def make_bin_name
        basename = "wxruby3#{WXRuby3.config.with_wxhead? ? '-head' : ''}"
        os = WXRuby3.config.sysinfo.os
        case os.id
        when :windows
          "#{basename}_#{os.distro}_ruby#{WXRuby3::Config.rb_ver_major}#{WXRuby3::Config.rb_ver_minor}"
        else
          "#{basename}_#{os.distro}_#{os.release || '0'}_ruby#{WXRuby3::Config.rb_ver_major}#{WXRuby3::Config.rb_ver_minor}"
        end
      end
      private :make_bin_name

      def bin_pkg_name
        gemspec = ::Gem::Specification.new(make_bin_name, WXRuby3::WXRUBY_VERSION)
        platform = ::Gem::Platform.new(RB_CONFIG["arch"])
        if platform.os == 'darwin'
          # loose the version for darwin kernels as that does not seem to affect wxRuby runtime compatibility
          # (until proven otherwise)
          platform.version = nil
        end
        gemspec.platform = platform.to_s
        gemspec.full_name
      end
      private :bin_pkg_name

      def bin_pkg_file
        File.join('pkg', bin_pkg_name+BINPKG_EXT)
      end

      def build_bin_pkg
        fname = bin_pkg_file

        # package registry and essential config
        registry = []
        config = %w{wxwininstdir with-wxwin}.reduce({}) { |h, k| h[k] = WXRuby3.config.get_config(k); h }
        # package temp deflate stream
        deflate_stream = Tempfile.new(File.basename(fname, '.*'), binmode: true)
        begin
          # pack binaries into temp deflate stream
          bin_pkg_manifest.each do |path|
            registry << pack_file(deflate_stream, path)
          end
          # convert registry and config to deflated json string
          registry_json_z = Zlib::Deflate.deflate(registry.to_json)
          config_json_z = Zlib::Deflate.deflate(config.to_json)

          # create final package archive
          deflate_stream.rewind
          digest = Digest::SHA256.new
          File.open(fname, 'w', binmode: true) do |fout|
            # pack config
            data = [config_json_z.size].pack('Q')
            digest << data
            fout.write(data)
            digest << config_json_z
            fout.write(config_json_z)
            # pack registry
            data = [registry_json_z.size].pack('Q')
            digest << data
            fout.write(data)
            digest << registry_json_z
            fout.write(registry_json_z)
            # pack files
            registry.each do |entry|
              if entry[2] > 0
                data = deflate_stream.read(entry[2])
                digest << data
                fout.write(data)
              end
            end
          end
          sha_file = File.join('pkg', bin_pkg_name+DIGEST_EXT)
          File.open(sha_file, 'w') { |fsha| fsha << digest.hexdigest! }
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

      def install_gem(prebuilt_only: false, package: nil)
        # check if a user specified binary package is to be used
        if package
          uri = File.file?(package) ? nil : URI(package)
          if uri.nil? || uri.scheme == 'file'
            filename = package
            if uri
              filename = uri.host ? "#{uri.host}:#{uri.path}" : uri.path
              filename = nil unless File.file?(filename)
            end
            if filename
              $stdout.puts "Installing user package #{filename}..."
              exit(1) unless install_bin_pkg(filename)
              $stdout.puts 'Done!'
              true
            else
              $stderr.puts "ERROR: Cannot access file #{package}."
              exit(1)
            end
          elsif uri.scheme == 'http' || uri.scheme == 'https'
            # download the binary release package
            $stdout.puts "Downloading #{uri}..."
            filename = File.basename(uri.path)
            if WXRuby3.config.download_file(uri.to_s, filename)
              sha_file = File.basename(filename, '.*')+DIGEST_EXT
              sha_uri = File.join(File.dirname(uri.to_s), sha_file)
              unless WXRuby3.config.download_file(sha_uri, sha_file)
                $stderr.puts "ERROR: Unable to download digest signature for binary release package : #{package}"
                exit(1)
              end
              exit(1) unless install_bin_pkg(filename)
              # cleanup, remove downloaded files
              FileUtils.rm_f([filename, sha_file])
              true
            else
              $stderr.puts "ERROR: Unable to download binary release package (#{package})!"
              exit(1)
            end
          else
          end
        # check if there exists a pre-built binary release package for the current platform
        elsif has_release_package?
          # download the binary release package
          $stdout.puts "Downloading #{bin_pkg_url(BINPKG_EXT)}..."
          if WXRuby3.config.download_file(bin_pkg_url(BINPKG_EXT), bin_pkg_name+BINPKG_EXT)
            unless WXRuby3.config.download_file(bin_pkg_url(DIGEST_EXT), bin_pkg_name+DIGEST_EXT)
              $stderr.puts "ERROR: Unable to download digest signature for binary release package : #{bin_pkg_name}"
              exit(1)
            end
            exit(1) unless install_bin_pkg(bin_pkg_name+BINPKG_EXT)
            # cleanup, remove downloaded files
            FileUtils.rm_f([bin_pkg_name+BINPKG_EXT, bin_pkg_name+DIGEST_EXT])
            true
          else
            if prebuilt_only
              $stderr.puts "ERROR: Unable to download binary release package (#{bin_pkg_name})!"
              exit(1)
            end
            $stdout.puts "WARNING: Unable to download binary release package (#{bin_pkg_name})! Reverting to source install."
            false
          end
        else
          if prebuilt_only
            $stderr.puts "ERROR: No binary release package available!"
            exit(1)
          end
          false
        end
      end

      def bin_pkg_url(ext)
        # which package are we looking for
        pkg_name = bin_pkg_name
        "https://github.com/mcorino/wxRuby3/releases/download/v#{WXRuby3::WXRUBY_VERSION}/#{pkg_name}#{ext}"
      end
      private :bin_pkg_url

      def has_release_package?
        # check if the release package exists on Github
        uri = URI(bin_pkg_url(BINPKG_EXT))
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
        # first get digest signature (if available)
        sha_file = File.join(File.dirname(fname), File.basename(fname, '.*')+DIGEST_EXT)
        unless File.file?(sha_file)
          $stderr.puts "ERROR: Cannot access package digest signature file : #{sha_file}."
          return false
        end
        sha_sig = File.read(sha_file)
        File.open(fname, 'r', binmode: true) do |fin|
          # check digest signature
          digest = Digest::SHA256.new
          while (data = fin.read(1024*1024))
            digest << data
          end
          if sha_sig != digest.hexdigest!
            $stderr.puts 'ERROR: Package digest signature does NOT match.'
            return false
          end
          fin.rewind
          # get packed config size
          config_size = fin.read(8).unpack('Q').shift
          # unpack config
          config = JSON.parse!(Zlib::Inflate.inflate(fin.read(config_size)))
          # get packed registry size
          registry_size = fin.read(8).unpack('Q').shift
          # unpack registry
          registry = JSON.parse!(Zlib::Inflate.inflate(fin.read(registry_size)))
          # unpack and create binaries
          registry.each do |entry|
            path, mode, size, symlink = entry
            if symlink
              FileUtils.mkdir_p(File.dirname(symlink))
              FileUtils.ln_s(symlink, path)
            else
              FileUtils.mkdir_p(File.dirname(path))
              File.open(path, 'w', binmode: true) do |fbin|
                fbin << Zlib::Inflate.inflate(fin.read(size))
              end
              File.chmod(mode, path)
            end
          end
          # merge config
          config.each_pair { |k,v| WXRuby3.config.set_config(k, v) }
        end
        true
      end
      private :install_bin_pkg

    end

  end

end
