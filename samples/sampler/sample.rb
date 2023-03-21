###
# wxRuby3 sampler application
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WxRuby

  ART_FOLDER = File.join(__dir__, '..', 'art')

  module Sample
    ROOT = File.expand_path(File.join(__dir__, '..'))
    RUBY = ENV["RUBY"] || File.join(
      RbConfig::CONFIG["bindir"],
      RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]).
      sub(/.*\s.*/m, '"\&"')

    Description = Struct.new(:file, :summary, :description, :thumbnail, keyword_init: true) do
      def name
        File.basename(self.file, '.*').downcase
      end

      def path
        File.dirname(self.file)
      end

      def category
        File.basename(path).modulize!
      end

      def image_file
        basename = self[:thumbnail] || "tn_#{self.name}"
        if File.exist?(tn_file = File.join(self.path, "#{basename}_#{Wx::PLATFORM}.png"))
          return tn_file
        elsif File.exist?(tn_file = File.join(self.path, "#{basename}.png"))
          return tn_file
        end
        nil
      end

      def image
        if (img_file = image_file)
          img = Wx::Image.new(img_file)
          scale = 320.0 / img.height
          img = img.copy.rescale((img.width*scale).to_i, (img.height*scale).to_i)
          img.to_bitmap
        else
          Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION)
        end
      end

      def thumbnail
        if (img_file = image_file)
          img = Wx::Image.new(img_file)
          if (scale = img.height / 50.0) > 1.0
            img = img.copy.rescale((img.width/scale).to_i, (img.height/scale).to_i)
          end
          img.to_bitmap
        else
          Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION)
        end
      end
    end

    class SampleEntry
      def initialize(mod, newfiles)
        @module = mod
        @runner = nil
        @description = nil
        # filter new required files; keep only .rb from sample path
        @files = newfiles.select { |fp| File.extname(fp) == '.rb' && fp.start_with?(path) }
      end

      attr_reader :files

      def description
        @description ||= Description.new(**@module.describe)
      end

      def file
        description.file
      end

      def path
        description.path
      end

      def category
        description.category
      end

      def summary
        description.summary
      end

      def run
        @runner = @module.run
      end

      def running?
        !!@runner
      end

      def active?
        @runner && @runner.active?
      end

      def read
        @runner ? @runner.read : ''
      end

      def close
        begin
          return @runner.close if @runner
        ensure
          @runner = nil
        end
        ''
      end

      def close_window(win)
        if EmbeddedRunner === @runner && @runner.frame == win
          @runner.frame = nil
        end
      end

      class Copy < SampleEntry
        def initialize(desc, files)
          super(nil, [])
          @description = desc
          @files = files
        end

        def run
          @runner = SpawnedRunner.new(description.file)
        end
      end

      def copy_to(dest)
        # create description clone
        desc_clone = description.dup
        # create sample folder at dest
        sample_folder = File.join(dest, File.basename(path))
        FileUtils.mkdir_p(sample_folder)
        # copy main file
        desc_clone.file = File.join(sample_folder, File.basename(file))
        FileUtils.cp(file, desc_clone.file)
        # copy required files
        files_copy = []
        files.each do |f|
          files_copy << File.join(sample_folder, File.basename(f))
          FileUtils.cp(f, files_copy.last)
        end
        # copy thumbnail image file if any
        if description.image_file
          desc_clone[:thumbnail] = File.join(sample_folder, File.basename(description.image_file))
          FileUtils.cp(description.image_file, desc_clone[:thumbnail])
        end
        # copy sample specific resources (not .rb or 'tn_*.png' files and not directories)
        Dir[File.join(path, '*')].each do |fp|
          unless File.directory?(fp) || File.extname(fp) == '.rb' || /\Atn_.*\.png\Z/ =~ File.basename(fp)
            FileUtils.cp(fp, File.join(sample_folder, File.basename(fp)))
          end
        end
        # copy art folder to dest
        art_dest = File.join(dest, 'art')
        FileUtils.mkdir_p(art_dest)
        Dir[File.join(ART_FOLDER, '*')].each do |fp|
          FileUtils.cp(fp, File.join(art_dest, File.basename(fp)))
        end
        # copy sample.xpm
        FileUtils.cp(File.join(ROOT, 'sample.xpm'), File.join(dest, 'sample.xpm'))
        # copy and return SampleEntry::Copy
        Copy.new(desc_clone, files_copy)
      end

      class EmbeddedRunner
        def initialize(frame)
          @frame = frame
        end
        attr_accessor :frame
        def close
          @frame.close(true) if @frame
          @frame = nil
          ''
        end
        def active?
          !!@frame
        end
        def read
          ''
        end
      end

      class SpawnedRunner
        def initialize(sample_file)
          # capture stderr and stdout of child process
          @r_p, @w_p = IO.pipe
          cap_opt = {out: @w_p, :err=>[:child, :out]}
          @pid = ::Process.spawn(RUBY, '-I', File.join(ROOT, '..', 'lib'), sample_file, cap_opt)
        end

        def check_status
          return false unless @pid
          begin
            tmp, status = ::Process.waitpid2(@pid, ::Process::WNOHANG)
            if tmp==@pid and status.success? == false
              return false
            end
            return true
          rescue Errno::ECHILD, Errno::ESRCH
            return false
          end
        end
        private :check_status

        def active?
          check_status
        end

        def read
          if check_status
            begin
              @r_p.read_nonblock(4096) || ''
            rescue EOFError
              ''
            rescue Errno::EAGAIN, Errno::EINTR, IO::EWOULDBLOCKWaitReadable
              ''
            end
          else
            close
          end
        end

        def close
          begin
            if check_status
              ::Process.kill('SIGKILL', @pid) rescue Errno::ESRCH
              10.times do
                sleep(0.1)
                return unless check_status
              end
              ::Process.kill('SIGKILL', @pid) if check_status
              @w_p.close
              return @r_p.read
            end
            return ''
          ensure
            @r_p.close if @r_p
            @pid = nil
            @w_p = nil
            @r_p = nil
          end
        end
      end
    end

    class << self

      def loading_sample
        @loading_sample
      end

      def samples
        @samples ||= []
      end

      def categories
        @categories ||= {}
      end

      def category_samples(cat)
        categories[cat] ||= []
      end

      def sample_captures
        @captures ||= []
      end
      private :sample_captures

      def collect_samples
        Dir[File.join(ROOT, '*')].each do |entry|
          if File.directory?(entry)
            category = File.basename(entry)
            unless 'bigdemo' ==  category || 'sampler' == category
              category.modulize!
              Dir[File.join(entry, '*.rb')].each do |rb|
                # only if this is a file (paranoia check) and contains 'include WxRuby::Sample'
                if File.file?(rb) && (sample_lns = File.readlines(rb)).any? { |ln| /\s+include\s+WxRuby::Sample/ =~ ln }
                  # register currently required files
                  cur_loaded = ::Set.new($LOADED_FEATURES)
                  @loading_sample = rb
                  # cannot use (Kernel#load with) an anonymous module because that will break the Wx::Dialog functor
                  # functionality for one thing (that code will attempt to define a module method for a new dialog class
                  # in the class/module scope in which the dialog class is defined working from the dialog class name;
                  # this will fail for anonymous modules as these cannot be identified by name)
                  sample_mod = Sample.const_set("SampleLoader_#{File.basename(rb, '.*').modulize!}", Module.new)
                  sample_mod.module_eval File.read(rb), rb, 1
                  # determine additionally required files
                  new_loaded = ::Set.new($LOADED_FEATURES) - cur_loaded
                  sample_captures.each do |mod|
                    samples << (smpl = SampleEntry.new(mod, new_loaded))
                    category_samples(smpl.category) << (samples.size-1)
                  end
                  sample_captures.clear
                  @loading_sample = nil
                end
              end
            end
          end
        end
      end

    end

    module SampleMethods
      def activate
        raise NotImplementedError, '#activate needs an override'
      end

      def run
        SampleEntry::EmbeddedRunner.new(activate)
      end

      def execute(sample_file)
        SampleEntry::SpawnedRunner.new(sample_file)
      end
      private :execute
    end

    def self.included(mod)
      mod.extend SampleMethods
      sample_captures << mod
    end

  end

end
