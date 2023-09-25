
module Wx

  class ConfigBase

    SEPARATOR = '/'.freeze

    module Interface

      def each(&block)
        if block_given?
          @data.each_pair(&block)
        else
          @data.each_pair
        end
      end

      def each_entry(&block)
        if block_given?
          @data.keys.select { |k| !@data[k].is_a?(::Hash) }.each(&block)
        else
          ::Enumerator.new { |y| @data.keys.each { |k| y << k if !@data[k].is_a?(::Hash) } }
        end
      end

      def each_group(&block)
        if block_given?
          @data.keys.select { |k| @data[k].is_a?(::Hash) }.each(&block)
        else
          ::Enumerator.new { |y| @data.keys.each { |k| y << k if @data[k].is_a?(::Hash) } }
        end
      end

      def has_entry?(path_str)
        segments, abs = get_path(path_str)
        return false if segments.empty?
        entry = segments.pop
        group_data = if segments.empty?
                       @data
                     else
                       unless abs || root?
                         segments = path + segments
                       end
                       get_group_at(segments)
                     end
        group_data && group_data.has_key?(entry) && !group_data[entry].is_a?(::Hash)
      end

      def has_group?(path_str)
        segments, abs = get_path(path_str)
        return root? if segments.empty?
        unless abs || root?
          segments = path + segments
        end
        !!get_group_at(segments)
      end

      def get(key)
        key = key.to_s
        elem = @data[key]
        if elem.is_a?(::Hash)
          Group.new(self, path + [key], elem)
        else
          elem
        end
      end

      def set(key, val)
        key = key.to_s
        exist = @data.has_key?(key)
        elem = exist ? @data[key] : nil
        if val.nil?
          @data.delete(key) if exist
          nil
        elsif val.is_a?(::Hash)
          raise ArgumentError, 'Cannot change existing value entry to group.' if exist && !elem.is_a?(::Hash)
          group = Group.new(self, segments + [key], val)
          elem.each_pair { |k, v| group.set(k, v) }
          group
        else
          raise ArgumentError, 'Cannot change existing group to value entry.' if exist && elem.is_a?(::Hash)
          @data[key] = sanitize_value(val)
        end
      end

      def delete(key)
        @data.delete(key.to_s)
      end

      def rename(old_key, new_key)
        old_key = old_key.to_s
        new_key = new_key.to_s
        if @data.has_key?(old_key) && !@data.has_key?(new_key)
          @data[new_key] = @data.delete(old_key)
          true
        else
          false
        end
      end

      def [](path_str)
        segments, abs = get_path(path_str)
        return nil if segments.empty?
        last = segments.pop
        group_data = if segments.empty?
                       @data
                     else
                       unless abs || root?
                         segments = path + segments
                       end
                       get_group_at(segments, create_missing_groups: true)
                     end
        raise ArgumentError, "Unable to resolve path #{segments+[last]}" unless group_data
        elem = group_data[last]
        if elem.is_a?(::Hash)
          Group.new(self, segments, elem)
        else
          elem
        end
      end

      def []=(path_str, val)
        segments, abs = get_path(path_str)
        return false if segments.empty?
        last = segments.pop
        group_data = if segments.empty?
                       @data
                     else
                       unless abs || root?
                         segments = path + segments
                       end
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
          group = Group.new(self, segments, val)
          elem.each_pair { |key, val| group.set(key, val) }
          group
        else
          raise ArgumentError, 'Cannot change existing group to value entry.' if exist && elem.is_a?(::Hash)
          group_data[last] = sanitize_value(val)
        end
      end

      def to_s
        SEPARATOR+path.join(SEPARATOR)
      end

      def get_path(path_str)
        path_str = path_str.to_s
        abs = path_str.start_with?(SEPARATOR)
        segs = path_str.split(SEPARATOR)
        segs.shift if abs
        [segs, abs]
      end
      protected :get_path

      def sanitize_value(val)
        case val
        when TrueClass, FalseClass, Numeric, String
          val
        else
          if val.respond_to?(:to_int)
            val.to_int
          elsif val.respond_to?(:to_f)
            val.to_f
          else
            val.to_s
          end
        end
      end
      protected :sanitize_value

    end

    class Group

      include Interface

      def initialize(parent, path, data)
        @parent = parent
        @path = path.freeze
        @data = data
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

      def get_group_at(segments, create_missing_groups: false)
        root.__send__(:get_group_at, segments)
      end
      protected :get_group_at

    end

    include Interface

    def initialize(hash = {})
      @data = hash
    end

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

    def set(hash)
      @data.replace(hash)
    end

    def get_group_at(segments, create_missing_groups: false)
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
