<!--
# @markup markdown
# @title 14. Configuration support
-->

# 14. Configuration support

## Introduction

wxRuby3 fully supports the wxWidgets config classes providing a Ruby-fied interface.

The config classes provide a way to store some application configuration information providing features
that make them very useful for storing all kinds of small to medium volumes of hierarchically-organized, 
heterogeneous data.
In wxWidgets these were especially designed for storing application configuration information and intended to be 
mostly limited to that. That meant the information to be stored was intended to be:

* Typed, i.e. strings, booleans or numbers for the moment. You cannot store binary data, for example.
* Small. For instance, it is not recommended to use the Windows registry (which is the default storage medium on 
  that platform) for amounts of data more than a couple of kilobytes.
* Not performance critical, neither from speed nor from a memory consumption point of view.

As you will see wxRuby3 extends the support in this area and provides means to forego a lot of these restrictions.

The config classes also are intended to abstract away a lot of platform differences. In this area wxRuby3 extends the
support also.

## Default configuration support

When the default, global, config instance is used (by using {Wx::ConfigBase.get} with default argument) this will be 
a platform specific instance. On Windows platforms a Windows registry based implementation is used and on other 
platforms a text format configuration file.

wxRuby3 provides a single wrapper class for these with {Wx::ConfigWx}. This is an abstract class that cannot be 
instantiated in Ruby which provides a common, Ruby-fied interface supported by all config classes in wxRuby3.

While wxWidgets does a decent job of abstracting platform differences it is in no way perfect in this area. With the
text format configuration files for example the stored values loose all type information since everything is stored
as strings. This also differs from the registry based implementation where some type information is not lost but some
(like boolean types) is.
This is not a problem when accessing information for which the structure and types are exactly known as the config
classes offer type specific readers (as well as writers) which coerce values to their expected types but may offer 
nasty surprises when more reflectively accessing data of which the exact typing and structure is not known.

In Ruby where we more or less expect to have common API-s that can return or accept any type of object needing to be
type specific is awkward. wxRuby3 works around this as much as possible for the {Wx::ConfigWx} wrapper class but also
provides an alternative config class integrated with the wxWidgets framework that does not suffer from these restrictions.

## Enhanced Ruby configuration support

Instead of the default, platform specific, config classes it is also possible to use a custom wxRuby3 extension providing
a config class which is implemented in pure Ruby and integrated in the wxWidgets configuration framework.
To use an instance of this class as the global config instance the {Wx::ConfigBase.create} should be called at application
initialization time with it's `:use_hash_config` keyword argument set to `true` (and possibly, to be sure, it's 
`forced_create` argument set to `true` also). This would create an instance of {Wx::Config} and install that as the global config instance (if no other instance was
yet installed or, overruling that condition, if `forced_create` was set to `true`).<br>
Alternatively a {Wx::Config} (or derivative) instance could be explicitly instantiated in code and assigned as global 
instance with {Wx::ConfigBase.set}.

As the keyword argument indicates {Wx::Config} is a Ruby `Hash` based config class implementation. 

Value objects are stored Ruby-style as-is into it's internal hash table (maintaining full type information) and are also 
retrieved as-is by default (to maintain compatibility with the {Wx::ConfigWx} wrapper type coercion options are provided). 
Grouping is based of nested `Hash` instances.

Because of the `Hash` based implementation and lack of (the need for) type coercion the {Wx::Config} class does have **any**
restrictions of the type of data stored. The only possible type restrictions to enforce may come from usage contexts:

* In case of value entries shared with wxWidgets framework code (like for example entries save by the persistence 
framework; see [here](15_persistence.md)) value types should be restricted to those supported by the wxWidget platform
specific classes and correspond to what the framework code expects.
* In case of the need to save/restore the configuration data to/from persistent storage which imposes type restrictions these 
should be applied.

With {Wx::Config} it would be perfectly alright to store arrays or any kind of arbitrary object (only be aware that `Hash`
instances will always be expected to provide configuration structure by default) as long as these do not conflict with
expectations of framework code or storage mechanisms.

With the standard Ruby YAML and JSON serialization support this also provides improved platform independent configuration 
persistence options with full type information maintainability. 

## Differences between default and enhanced configuration support

The major difference is, as described above, the absence of type restrictions in the enhanced Ruby config class {Wx::Config}.

Another difference is that {Wx::Config} will not automatically create missing groups or entries on reading. This will only
happen when writing configuration values.

A last difference is that the default support is by default backed up by persistent storage (windows registry or file) and
the wxRuby enhanced support only provides in-memory storage (`Hash` instance) by default. +
Persisting configuration data from {Wx::Config} will require coding customized storage and retrieval operations (which is
trivial using standard YAML or JSON support).  

## Differences between wxWidgets config interface and wxRuby

In wxRuby there is no option to provide a default value argument when reading values. The reasoning is that Ruby itself
provides more than enough options to elegantly provide for defaults with statement options like `var ||= default` or
`var = get('something') || default`.

As a consequence wxRuby also does not support recording defaults on read operations (and also does not provide the
corresponding option setter/getter in the interface).
