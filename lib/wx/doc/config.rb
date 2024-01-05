# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # {Wx::ConfigBase} defines the basic interface of all config classes.
  # In Ruby this class is an empty placeholder providing access to the static
  # {Wx::ConfigBase.create}, {Wx::ConfigBase.set} and {Wx::ConfigBase.get}
  # methods as well as providing the base for a similar inheritance hierarchy
  # as in C++.
  class ConfigBase

    # Create a new config instance and sets it as the current one unless a global config was already created/installed. If
    # forced_create is true any existing global config will be replaced by a new config instance.
    # This function will create the most appropriate implementation of Wx::ConfigBase available for the current platform.
    # If use_hash_config is true this means that a Wx::Config instance will created and appropriately wrapped in C++
    # otherwise the default C++ config for the current/active platform will be used.
    # @param [Boolean] forced_create specifies to force replacing any existing global config if true
    # @param [Boolean] use_hash_config specifies to create a Ruby Hash based config when required if true
    # @return [Wx::ConfigBase] the current configuration object
    def self.create(forced_create=false, use_hash_config: false) end

    # Sets the config object as the current one, returns the previous current object (both the parameter and returned
    # value may be nil).
    # @param [Wx::ConfigBase,nil] config the config object to install
    # @return [Wx::ConfigBase] the previous current configuration object
    def self.set(config) end

    # Get the current config object.
    # If there is no current object and create_on_demand is true, this creates a default config instance appropriate for
    # the current/active platform (registry based for Windows and file based otherwise).
    # @param [Boolean] create_on_demand specifies whether to create a configuration object if none has been created/installed before
    # @return [Wx::ConfigBase,nil] the current configuration object
    def self.get(create_on_demand=true) end

    # Config path separator
    SEPARATOR = '/'

    # Common configuration access methods for either the root object or any nested group objects.
    module Interface

      # Iterate all value entries at the current object (no recursion).
      # Passes key/value pairs to the given block or returns an Enumerator is no block given.
      # @yieldparam [String] key entry key
      # @yieldparam [Boolean,String,Integer,Float] value entry value
      # @return [Object,Enumerator] either the last result of the executed block or an enumerator if no block given
      def each_entry(&block) end

      # Iterate all group entries at the current object (no recursion).
      # Passes key/value pairs to the given block or returns an Enumerator is no block given.
      # @yieldparam [String] key entry key
      # @yieldparam [Wx::Config::Group] value entry value
      # @return [Object,Enumerator] either the last result of the executed block or an enumerator if no block given
      def each_group(&block) end

      # Returns the total number of value entries at the current object only (if recurse is false) or including
      # any nested groups (if recurse is true)
      # @param [Boolean] recurse
      # @return [Integer] count
      def number_of_entries(recurse=false) end

      # Returns the total number of group entries at the current object only (if recurse is false) or including
      # any nested groups (if recurse is true)
      # @param [Boolean] recurse
      # @return [Integer] count
      def number_of_groups(recurse=false) end

      # Returns if a value entry exists matching the given path string.
      # Path strings can be absolute (starting with {SEPARATOR}) or relative to the current object and can have
      # relative segments embedded ('.' and '..' are supported).
      # @param [String] path_str entry path
      # @return [Boolean] true if entry exists, false otherwise
      def has_entry?(path_str) end

      # Returns if a group entry exists matching the given path string.
      # Path strings can be absolute (starting with {SEPARATOR}) or relative to the current object and can have
      # relative segments embedded ('.' and '..' are supported).
      # @param [String] path_str entry path
      # @return [Boolean] true if entry exists, false otherwise
      def has_group?(path_str) end

      # Returns a value for an entry at the current object identified by `key`.
      # @param [String] key entry key
      # @return [Boolean,String,Integer,Float,Wx::Config::Group,nil] value entry value
      def get(key) end

      # Sets a value for an entry at the current object identified by `key` or deletes the entry if `val` is nil.
      # Returns the new value for the entry.
      # Group entries can be set using Hash values (entry values in the hash will be sanitized).
      # @param [String] key entry key
      # @param [Boolean,String,Integer,Float,Hash,nil] val entry value
      # @return [Boolean,String,Integer,Float,Wx::Config::Group,nil] value entry value
      def set(key, val) end

      # Removes the entry identified by `path_str` if it exists and returns it's value.
      # @param [String] path_str entry path
      # @return [Boolean,String,Integer,Float,Hash,nil] entry value
      def delete(path_str) end

      # Changes key for the entry at the current object identified by `old_key` to `new_key` if it exists.
      # @param [String] old_key current entry key
      # @param [String] new_key new entry key
      # @return [Boolean] true if the entry was renamed, false otherwise
      def rename(old_key, new_key) end

      # Returns a value for an entry from the configuration identified by `path_str`.
      # Provides arbitrary access though the entire configuration using absolute or relative paths.
      # Supports coercing configuration values to a specified output type (Integer,Float,String,TrueClass,FalseClass).
      # By default returns un-coerced value.
      # Raises exception if incompatible coercion is specified.
      # @param [String] path_str
      # @param [Class,Proc,nil] output output type (or converter proc) to convert to (with)
      # @return [Boolean,String,Integer,Float,Wx::Config::Group,nil] value entry value
      def read(path_str, output=nil) end

      # Returns a value for an entry from the configuration identified by `path_str`.
      # Provides arbitrary access though the entire configuration using absolute or relative paths.
      # @param [String] path_str
      # @return [Boolean,String,Integer,Float,Wx::Config::Group,nil] value entry value
      def [](path_str) end

      # Sets a value for an entry from the configuration identified by `path_str` or deletes the entry if `val` is nil.
      # Returns the new value for the entry.
      # Group entries can be set using Hash values (entry values in the hash will be sanitized).
      # @param [String] path_str
      # @param [Boolean,String,Integer,Float,Hash,nil] val entry value
      # @return [Boolean,String,Integer,Float,Wx::Config::Group,nil] value entry value
      def write(path_str, val) end
      alias :[]= :write

      # Returns the path string for the current configuration object.
      # @return [String]
      def to_s; end

      # Returns the Hash object used to store the settings for the current configuration object.
      # @return [Hash]
      def to_h; end

      # Returns true if the current configuration object is the root (Wx::Config) object, false otherwise
      # (for Wx::Config::Group objects).
      # @return [Boolean]
      def root?; end

      # Returns the root (Wx::Config) object
      # @return [Wx::Config] root configuration object
      def root; end

      # Returns the path segment array for the current configuration object.
      # @return [Array<String>] path array
      def path; end

      # Returns the parent configuration object or nil if this for the root object.
      # @return [Wx::Config,Wx::Config::Group,nil] root object
      def parent; end

    end

  end

  # This is an abstract class wrapping the default C++ Config class for the active platform
  # (on Windows this would be `wxRegConfig` and `wxFileConfig` otherwise).
  #
  # Unless {Wx::ConfigBase.create} or {Wx::ConfigBase.set} has been called this is what will be
  # returned by {Wx::ConfigBase.get}.
  class ConfigWx < ConfigBase

    class Group

      include ConfigBase::Interface

    end

    include ConfigBase::Interface

    # Deletes all configuration content and returns true if successful.
    # Also deletes any persisted storage (files or registry entries).
    # @return [Boolean]
    def clear; end

    # Replaces the configuration content with the content of the provided Hash.
    # @param [Hash] hash content to replace configuration
    # @return [self]
    def replace(hash) end

  end

  # Configuration class for wxRuby which stores it's settings in a (possibly nested) Hash.
  # This way configurations can be easily persisted using any commonly used Ruby methods like
  # YAML or JSON files.
  #
  # Wx::Config supports Boolean (true or false), Integer, Float and String values and nested groups
  # (essentially nested hashes). Any entry values set will be sanitized to match the supported types, i.e.
  # if the value matches a supported type the value is accepted unaltered otherwise Integer (`to_int`), Float (`to_f`)
  # or String (`to_s`) coercion are applied (in that order). Hash values are installed as nested groups.
  #
  # Like the C++ wxConfigBase derivatives Wx::Config supports arbitrary access using path strings which support
  # absolute paths ('/xxxx') and relative paths ('xxx/xxx', '../xxx', './xxxx'). Relative segments can also be
  # embedded in the path strings ('/aaa/bbb/../ccc').
  class Config < ConfigBase

    class Group

      include ConfigBase::Interface

    end

    include ConfigBase::Interface

    # Constructor.
    # @param [Hash] hash optional Hash initializing configuration object
    # @return [Wx::Config]
    def initialize(hash = nil)end

    # Deletes all configuration content and returns if successful.
    # @return [true]
    def clear; end

    # Replaces the configuration content with the content of the provided Hash.
    # Values will be sanitized (see {Wx::Config}).
    # @param [Hash] hash content to replace configuration
    # @return [self]
    def replace(hash) end

  end

end
