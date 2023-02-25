
module Wx::PRT

  # not a real dialog but let's be consistent
  def self.PageSetupDialog(*args, &block)
    dlg = PageSetupDialog.new(*args)
      begin
        block.call(dlg) if block_given?
      rescue Exception
        Wx.log_debug "#{$!}\n#{$!.backtrace.join("\n")}"
        raise
      end
  end

end
