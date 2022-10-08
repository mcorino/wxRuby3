#--------------------------------------------------------------------
# @file    streams.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------
require 'tempfile'
require 'fileutils'

module WXRuby3

  class Stream

    class << self
      private

      def _stack
        @stack ||= []
      end

      def _start_transaction
        _stack << (@transaction = [])
      end

      def _close_transaction
        _stack.pop
        @transaction = _stack.last
      end

      def _transaction
        @transaction
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
          rescue
            # restore backup
            FileUtils.mv(ftmp_name, @fullpath)
            raise
          end
          # remove backup
          File.unlink(ftmp_name)
        else
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

    def <<(txt)
      do_indent << txt;
      self
    end

    def puts(txt='')
      if ::Array === txt
        txt.each { |ln| do_indent.puts(ln) }
      else
        do_indent.puts(txt)
      end
      self
    end

    def iputs(txt='', lvl_inc=1)
      if ::Array === txt
        txt.each { |ln| do_indent(lvl_inc).puts(ln) }
      else
        do_indent(lvl_inc).puts(txt)
      end
      self
    end

    def indent(lvl_inc=1, &block)
      prev_level = @indent_level
      begin
        @indent_level += lvl_inc
        block.call
      ensure
        @indent_level = prev_level
      end
    end

    private

    def do_indent(lvl_inc=0)
      @fout << (' ' * ((@indent_level+lvl_inc) * @indent_level))
      @fout
    end

  end

  class CodeStream < Stream

    class Doc
      def initialize(stream)
        @stream = stream
      end

      def <<(txt)
        lns = txt.split("\n")
        last = lns.pop
        lns.each {|ln| (@stream << '# ').puts(ln) }
        @stream << '# ' << last
        self
      end

      def puts(txt='')
        if ::Array === txt
          txt.each { |ln| self << ln; @stream.puts }
        else
          self << txt; @stream.puts
        end
      end

      def iputs(txt='', lvl_inc=1)
        @stream.indent(lvl_inc) do
          puts(txt)
        end
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
