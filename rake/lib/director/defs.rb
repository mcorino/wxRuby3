#--------------------------------------------------------------------
# @file    defs.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Defs < Director

      def setup
        spec.items.replace ['defs.h']
        spec.ignore %w{
          wxINT8_MIN
          wxINT8_MAX
          wxUINT8_MAX
          wxINT16_MIN
          wxINT16_MAX
          wxUINT16_MAX
          wxINT32_MIN
          wxINT32_MAX
          wxUINT32_MAX
          wxINT64_MIN
          wxINT64_MAX
          wxUINT64_MAX
          wxVaCopy
          wxDataFormatId
        }
        super
      end

      def generator
        WXRuby3::DefsGenerator.new
      end

      protected def create_rake_tasks(frake)
        super
        frake << <<~__TASK
          file '#{File.join(Config.instance.common_dir, 'typedefs.i')}' => '#{File.join(Config.instance.classes_dir, 'Defs.i')}'
          __TASK
      end
    end # class Defs

  end # class Director

end # module WXRuby3
