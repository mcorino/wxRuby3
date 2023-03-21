###
# wxRuby3 rake doc generation support
# Copyright (c) M.J.N. Corino, The Netherlands
###
require_relative './lib/config'

if WXRuby3.is_bootstrapped?

  WXRuby3::Director.each_package do |pkg|

    namespace pkg.name.downcase do

      if WXRuby3.is_configured?

        task :doc => ['config:bootstrap', *pkg.all_swig_files] do
          pkg.generate_docs
        end

      end

    end

  end

  def all_doc_targets
    WXRuby3::Director.all_packages.collect {|p| "wxruby:#{p.name.downcase}:doc".to_sym }
  end

else

  def all_doc_targets
    []
  end

end
