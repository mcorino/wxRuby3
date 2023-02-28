###
# wxRuby3 buildtools configuration
# Copyright (c) M.J.N. Corino, The Netherlands
###
require 'tempfile'
require 'fileutils'

module WXRuby3

  class Stream

    class << self
      private

      def _stack
        Thread.current[:stream_transaction_stack] ||= []
      end

      def _start_transaction
        _stack << []
      end

      def _close_transaction
        _stack.pop
      end

      def _transaction
        _stack.last
      end

      def _commit
        _transaction.reject! { |stream| stream.save; true }
      end

      def _rollback
        _transaction.reject! { |stream| stream.remove; true } if _transaction
      end

      def _push(stream)
        _transaction << stream if _transaction
      end

    end
    def self.transaction(&block)
      _start_transaction
      begin
        block.call if block_given?
        _commit
      ensure
        _rollback # after successful transaction should be nothing left
        _close_transaction
      end
    end

    def self.rollback
      _rollback
    end

    module OutputMethods
      def <<(txt)
        lns = txt.split("\n", -1)
        last_ln = lns.pop
        lns.each {|ln| puts(ln) }
        indented_put(last_ln)
        self
      end

      def puts(txt='')
        if ::Array === txt
          txt.each { |ln| puts(ln) }
        elsif (lns = txt.split("\n", -1)).size>1
          lns.each { |ln| puts(ln) }
        else
          indented_put(txt).puts
          @indent_next = true
        end
        self
      end

      def iputs(txt='', lvl_inc=1)
        indent(lvl_inc) do
          puts(txt)
        end
        self
      end

      def indent(lvl_inc=1, &block)
        prev_level = @indent_level
        begin
          @indent_level += lvl_inc
          @indent_next = true
          block.call
        ensure
          @indent_level = prev_level
        end
      end
    end

    include OutputMethods

    def initialize(path, indent: 2)
      if path
        @path = path
        @fullpath = File.expand_path(path)
        @name = File.basename(path)
        @ext = File.extname(path).sub(/^\./, '')
      else
        @path = @fullpath = @name = @ext = ''
      end
      @fout = Tempfile.new(@name)
      Stream.__send__(:_push, self)
      @indent = indent
      @indent_level = 0
      @indent_next = true
    end

    attr_reader :path, :fullpath, :name, :ext

    def save
      if @fout
        fgen = @fout
        @fout = nil
        fgen.close(false) # close but do NOT unlink
        if File.exist?(@fullpath)
          # create temporary backup
          ftmp = Tempfile.new(@name)
          ftmp_name = ftmp.path.dup
          ftmp.close(true) # close AND unlink
          FileUtils::mv(@fullpath, ftmp_name) # backup existing file
          # replace original
          begin
            # rename newly generated file
            FileUtils.mv(fgen.path, @fullpath)
            # preserve file mode
            FileUtils.chmod(File.lstat(ftmp_name).mode, @fullpath)
          rescue Exception
            # restore backup
            FileUtils.mv(ftmp_name, @fullpath)
            raise
          end
          # remove backup
          File.unlink(ftmp_name)
        else
          # make sure the file's folder exists
          FileUtils.mkdir_p(File.dirname(@fullpath))
          # just rename newly generated file
          FileUtils.mv(fgen.path, @fullpath)
          # set default mode for new files
          FileUtils.chmod(0666 - File.umask, @fullpath)
        end
      end
    end

    def remove
      if @fout
        @fout.close(true)
        @fout = nil
      end
    end

    private

    def indented_put(s)
      @fout << (' ' * ((@indent_level) * @indent)) if @indent_next
      @fout << s
      @indent_next = false
      @fout
    end

  end

  class CodeStream < Stream

    class Doc

      include Stream::OutputMethods

      def initialize(stream)
        @stream = stream
        @indent_level = 0
        @indent_next = true
      end

      private

      def indented_put(s)
        @stream << '# ' if @indent_next
        @stream << (' ' * ((@indent_level) * @stream.instance_variable_get('@indent'))) if @indent_next
        @stream << s
        @indent_next = false
        @stream
      end
    end

    def initialize(path, indent: 2)
      super
      @doc = nil
    end

    def doc
      @doc ||= Doc.new(self)
    end

  end

end
