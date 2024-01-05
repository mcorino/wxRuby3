# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class ConfigBase

    SEPARATOR = '/'.freeze

    module Interface

      # provide auto-magic accessor support for config objects
      def method_missing(sym, *args, &block)
        unless block_given? || args.size>1
          setter = false
          key = sym.to_s.sub(/=\z/) { |_| setter = true; '' }
          if (!setter && args.empty?) || (!has_group?(key) && setter && args.size==1)
            if setter
              return set(key, args.shift)
            else
              return get(key)
            end
          elsif setter && args.size == 1 && args.first.is_a?(::Hash) && has_group?(key)
            return set(key, args.shift)
          end
        end
        super
      end

    end

  end

  class ConfigWx < ConfigBase

    include ConfigBase::Interface

    # add protection against exceptions raised in blocks
    wx_for_path = instance_method :for_path
    define_method :for_path do |path, &block|
      if block
        ex = nil
        rc = wx_for_path.bind(self).call(path) do |cfg, key|
          begin
            block.call(cfg, key)
          rescue Exception
            ex = $!
            nil
          end
        end
        raise ex if ex
        rc
      else
        nil
      end
    end
    private :for_path # make this method private (internal use only)

    # add Enumerator support

    wx_each_entry = instance_method :each_entry
    define_method :each_entry do |&block|
      if block_given?
        wx_each_entry.bind(self).call { |k| block.call(k, read(k)) }
      else
        ::Enumerator.new { |y| wx_each_entry.bind(self).call { |k| y << [k, read_entry(k)] } }
      end
    end

    wx_each_group = instance_method :each_group
    define_method :each_group do |&block|
      if block_given?
        wx_each_group.bind(self).call { |k| block.call(k, Group.new(self, self.path.dup.push(k))) }
      else
        ::Enumerator.new { |y| wx_each_group.bind(self).call { |k| y << [k, Group.new(self, self.path.dup.push(k))] } }
      end
    end

    # make this return a path array
    wx_path = instance_method :path
    define_method :path do
      wx_path.bind(self).call.split(ConfigBase::SEPARATOR)
    end

    # protect against attempts to rename complete paths
    wx_rename = instance_method :rename
    define_method :rename do |old_key, new_key|
      raise ArgumentError, 'No paths allowed' if old_key.index(ConfigBase::SEPARATOR) || new_key.index(ConfigBase::SEPARATOR)
      wx_rename.bind(self).call(old_key, new_key)
    end

    # fix recursive number_of_xxx methods as wxRegConfig does not support this currently
    wx_number_of_entries = instance_method :number_of_entries
    define_method :number_of_entries do |recurse=false|
      if recurse
        each_group.inject(wx_number_of_entries.bind(self).call) { |c, (_, g)| c + g.number_of_entries(true) }
      else
        wx_number_of_entries.bind(self).call
      end
    end

    wx_number_of_groups = instance_method :number_of_groups
    define_method :number_of_groups do |recurse=false|
      if recurse
        each_group.inject(wx_number_of_groups.bind(self).call) { |c, (_, g)| c + g.number_of_groups(true) }
      else
        wx_number_of_groups.bind(self).call
      end
    end

    def root?
      true
    end

    def root
      self
    end

    def parent
      nil
    end

    def read(path_str, output=nil)
      if has_group?(path_str)
        raise TypeError, "Cannot convert group" unless output.nil?
        Group.new(self, get_path(path_str))
      else
        val = read_entry(path_str)
        return val unless val && output
        case
        when ::String == output || ::String === output
          val.to_s
        when ::Integer == output || ::Integer === output
          Kernel.Integer(val)
        when ::Float == output || ::Float === output
          Kernel.Float(val)
        when ::TrueClass == output || ::FalseClass == output || output == true || output == false
          val.is_a?(Integer) ? val != 0 : !!val
        else
          raise ArgumentError, "Unknown coercion type #{output.is_a?(::Class) ? output : output.class}" unless output.nil? || output.is_a?(::Proc)
          output ? output.call(val) : val
        end
      end
    end
    alias :[] :read

    def write(path_str, val)
      if val.nil?
        delete(path_str)
        nil
      elsif val.is_a?(::Hash)
        raise ArgumentError, 'Cannot change existing value entry to group.' if has_entry?(path_str)
        group = Group.new(self, get_path(path_str))
        val.each_pair { |k, v| group.set(k, v) }
        group
      else
        raise ArgumentError, 'Cannot change existing group to value entry.' if has_group?(path_str)
        write_entry(path_str, val)
        read_entry(path_str)
      end
    end
    alias :[]= :write

    def get_path(path_str)
      path_str = path_str.to_s
      abs = path_str.start_with?(ConfigBase::SEPARATOR)
      segs = path_str.split(ConfigBase::SEPARATOR)
      segs.shift if abs
      abs ? segs : (self.path+segs)
    end
    protected :get_path

    def get(key)
      raise ArgumentError, 'No paths allowed' if key.index(ConfigBase::SEPARATOR)
      if has_entry?(key)
        read_entry(key)
      elsif has_group?(key)
        Group.new(self, self.path.dup.push(key))
      else
        nil
      end
    end

    def set(key, val)
      raise ArgumentError, 'No paths allowed' if key.index(ConfigBase::SEPARATOR)
      if val.nil?
        delete(key)
        nil
      else
        if (!val.is_a?(::Hash) && !has_group?(key)) || has_entry?(key)
          raise ArgumentError, 'Cannot change existing value entry to group.' if val.is_a?(::Hash)
          write_entry(key, val)
          read_entry(key)
        else
          raise ArgumentError, 'Cannot change existing group to value entry.' if has_group?(key) && !val.is_a?(::Hash)
          delete(key)
          group = Group.new(self, self.path.dup.push(key))
          val.each_pair { |k, v| group.set(k, v) }
          group
        end
      end
    end

    def to_s
      ConfigBase::SEPARATOR
    end

    def to_h
      data = each_entry.inject({}) { |hash, pair| hash[pair.first] = pair.last; hash }
      each_group.inject(data) { |hash, pair| hash[pair.first] = pair.last.to_h; hash }
    end

    def replace(hash)
      raise ArgumentError, 'Expected Hash' unless hash.is_a?(::Hash)
      clear
      hash.each_pair { |k,v| self.set(k, v) }
      self
    end

    class Group

      include ConfigBase::Interface

      def initialize(parent, path)
        @parent = parent
        @path = path.freeze
        @path_str = ConfigBase::SEPARATOR + @path.join(ConfigBase::SEPARATOR) + ConfigBase::SEPARATOR
      end

      def root?
        false
      end

      def root
        @parent.root
      end

      def path
        @path
      end

      def parent
        @parent
      end

      def each_entry(&block)
        if block_given?
          root.__send__(:for_path, @path_str) do |cfg, _|
            cfg.each_entry(&block)
          end
        else
          ::Enumerator.new { |y| root.__send__(:for_path, @path_str) { |cfg,_| cfg.each_entry { |k,v| y << [k, v] } } }
        end
      end

      def each_group(&block)
        if block_given?
          root.__send__(:for_path, @path_str) do |cfg, _|
            cfg.each_group(&block)
          end
        else
          ::Enumerator.new { |y| root.__send__(:for_path, @path_str) { |cfg,_| cfg.each_group { |k,g| y << [k, g] } } }
        end
      end

      def number_of_entries(recurse=false)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.number_of_entries(recurse) }
      end

      def number_of_groups(recurse=false)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.number_of_groups(recurse) }
      end

      def get(key)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.get(key) }
      end

      def set(key, val)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.set(key, val) }
      end

      def delete(path_str)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.delete(path_str) }
      end

      def rename(old_key, new_key)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.rename(old_key, new_key) }
      end

      def has_entry?(path_str)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.has_entry?(path_str) }
      end

      def has_group?(path_str)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.has_group?(path_str) }
      end

      def read(path_str, output=nil)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.read(path_str, output) }
      end
      alias :[] :read

      def write(path_str, val)
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.write(path_str, val) }
      end
      alias :[]= :write

      def to_s
        @path_str
      end

      def to_h
        root.__send__(:for_path, @path_str) { |cfg,_| cfg.to_h }
      end

    end

  end

  class Config < ConfigBase

    include ConfigBase::Interface

    module Interface

      def each_entry(&block)
        if block_given?
          data.select { |_,v| !v.is_a?(::Hash) }.each(&block)
        else
          ::Enumerator.new { |y| data.each_pair { |k,v| y << [k,v] unless v.is_a?(::Hash) } }
        end
      end

      def each_group(&block)
        if block_given?
          data.select { |_,g| g.is_a?(::Hash) }.each { |k,_| block.call(k, Group.new(self, self.path.dup.push(k))) }
        else
          ::Enumerator.new { |y| data.each_pair { |k,g| y << [k,Group.new(self, self.path.dup.push(k))] if g.is_a?(::Hash) } }
        end
      end

      def number_of_entries(recurse=false)
        if recurse
          each_group.inject(each_entry.inject(0) { |c, _| c + 1 }) { |c, (_, g)| c + g.number_of_entries(true) }
        else
          each_entry.inject(0) { |c, _| c + 1 }
        end
      end

      def number_of_groups(recurse=false)
        if recurse
          each_group.inject(0) { |c, (_,g)| c + 1 + g.number_of_groups(true) }
        else
          each_group.inject(0) { |c, _| c + 1 }
        end
      end

      def has_entry?(path_str)
        segments, abs = get_path(path_str)
        return false if segments.empty?
        entry = segments.pop
        group_data = if segments.empty?
                       data
                     else
                       segments = self.path + segments unless abs || root?
                       get_group_at(segments)
                     end
        !!(group_data && group_data.has_key?(entry) && !group_data[entry].is_a?(::Hash))
      end

      def has_group?(path_str)
        segments, abs = get_path(path_str)
        return root? if segments.empty?
        segments = self.path + segments unless abs || root?
        !!get_group_at(segments)
      end

      def get(key)
        key = key.to_s
        raise ArgumentError, 'No paths allowed' if key.index(ConfigBase::SEPARATOR)
        elem = data[key]
        if elem.is_a?(::Hash)
          Group.new(self, self.path.dup.push(key))
        else
          elem
        end
      end

      def set(key, val)
        key = key.to_s
        raise ArgumentError, 'No paths allowed' if key.index(ConfigBase::SEPARATOR)
        hsh = data
        exist = hsh.has_key?(key)
        elem = exist ? hsh[key] : nil
        if val.nil?
          hsh.delete(key) if exist
          nil
        elsif val.is_a?(::Hash)
          raise ArgumentError, 'Cannot change existing value entry to group.' if exist && !elem.is_a?(::Hash)
          hsh[key] = {} unless elem
          group = Group.new(self, self.path.dup.push(key))
          val.each_pair { |k, v| group.set(k, v) }
          group
        else
          raise ArgumentError, 'Cannot change existing group to value entry.' if exist && elem.is_a?(::Hash)
          hsh[key] = val
        end
      end

      def delete(path_str)
        segments, abs = get_path(path_str)
        return nil if segments.empty?
        last = segments.pop
        group_data = if segments.empty?
                       data
                     else
                       segments = self.path + segments unless abs || root?
                       get_group_at(segments, create_missing_groups: false)
                     end
        group_data ? group_data.delete(last) : nil
      end

      def rename(old_key, new_key)
        old_key = old_key.to_s
        new_key = new_key.to_s
        raise ArgumentError, 'No paths allowed' if old_key.index(ConfigBase::SEPARATOR) || new_key.index(ConfigBase::SEPARATOR)
        hsh = data
        if hsh.has_key?(old_key) && !hsh.has_key?(new_key)
          hsh[new_key] = hsh.delete(old_key)
          true
        else
          false
        end
      end

      def read(path_str, output=nil)
        segments, abs = get_path(path_str)
        return nil if segments.empty?
        last = segments.pop
        group_data = if segments.empty?
                       segments = self.path.dup unless abs || root?
                       data
                     else
                       segments = self.path + segments unless abs || root?
                       get_group_at(segments)
                     end
        val = group_data ? group_data[last] : nil
        if val.is_a?(::Hash)
          raise TypeError, "Cannot convert group" unless output.nil?
          Group.new(self, segments.dup.push(last))
        else
          return val unless val && output
          case
          when ::String == output || ::String === output
            val.to_s
          when ::Integer == output || ::Integer === output
            Kernel.Integer(val)
          when ::Float == output || ::Float === output
            Kernel.Float(val)
          when ::TrueClass == output || ::FalseClass == output || output == true || output == false
            val.is_a?(::Integer) ? val != 0 :  !!val
          else
            raise ArgumentError, "Unknown coercion type #{output.is_a?(::Class) ? output : output.class}" unless output.nil? || output.is_a?(::Proc)
            output ? output.call(val) : val
          end
        end
      end
      alias :[] :read

      def write(path_str, val)
        segments, abs = get_path(path_str)
        return false if segments.empty?
        last = segments.pop
        group_data = if segments.empty?
                       segments = self.path.dup unless abs || root?
                       data
                     else
                       segments = self.path + segments unless abs || root?
                       get_group_at(segments, create_missing_groups: true)
                     end
        raise ArgumentError, "Unable to resolve path #{segments+[last]}" unless group_data
        exist = group_data.has_key?(last)
        elem = exist ? group_data[last] : nil
        if val.nil?
          group_data.delete(last) if exist
          nil
        elsif val.is_a?(::Hash)
          raise ArgumentError, 'Cannot change existing value entry to group.' if exist && !elem.is_a?(::Hash)
          group_data[last] = {} unless elem
          group = Group.new(self, segments.dup.push(last))
          val.each_pair { |k, v| group.set(k, v) }
          group
        else
          raise ArgumentError, 'Cannot change existing group to value entry.' if exist && elem.is_a?(::Hash)
          group_data[last] = val
        end
      end
      alias :[]= :write

      def to_s
        ConfigBase::SEPARATOR+self.path.join(ConfigBase::SEPARATOR)
      end

      def to_h
        data
      end

      def get_path(path_str)
        path_str = path_str.to_s
        abs = path_str.start_with?(ConfigBase::SEPARATOR)
        segs = path_str.split(ConfigBase::SEPARATOR)
        segs.shift if abs
        [segs, abs]
      end
      protected :get_path

    end

    class Group

      include ConfigBase::Interface

      include Interface

      def initialize(parent, path)
        @parent = parent
        @path = path.freeze
      end

      def data
        self.root.__send__(:get_group_at, @path, create_missing_groups: true, is_pruned: true)
      end
      protected :data

      def root?
        false
      end

      def root
        @parent.root
      end

      def path
        @path
      end

      def parent
        @parent
      end

      def get_group_at(segments, create_missing_groups: false)
        root.__send__(:get_group_at, segments, create_missing_groups: create_missing_groups)
      end
      protected :get_group_at

    end

    include Interface

    def initialize(hash = nil)
      @data = {}
      replace(hash) if hash
    end

    def data
      @data
    end
    protected :data

    def root?
      true
    end

    def root
      self
    end

    def path
      []
    end

    def parent
      nil
    end

    def clear
      @data.clear
      true
    end

    def replace(hash)
      raise ArgumentError, 'Expected Hash' unless hash.is_a?(::Hash)
      @data.clear
      hash.each_pair { |k,v| self.set(k, v) }
      self
    end

    def get_group_at(segments, create_missing_groups: false, is_pruned: false)
      unless is_pruned
        # prune segments (process relative segments)
        segments = segments.inject([]) do |lst, seg|
          case seg
          when '..'
            lst.pop # remove previous
            # forget ..
          when '.'
            # forget
          else
            lst << seg
          end
          lst
        end
      end
      # find group matching segments
      segments.inject(@data) do |hsh, seg|
        if hsh.has_key?(seg)
          return nil unless hsh[seg].is_a?(::Hash)
          hsh[seg]
        else
          return nil unless create_missing_groups
          hsh[seg] = {}
        end
      end
    end
    protected :get_group_at

  end

end
