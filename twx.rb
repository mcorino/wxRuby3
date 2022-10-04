
$ruby_cmd = `which ruby`.chomp
$ruby_cmd << " -I#{File.join(File.dirname(__FILE__), 'lib')} "

def run_test(test)
  system "#{$ruby_cmd} #{test}.rb"
end

# run_test './samples/minimal/nothing'
# run_test './samples/minimal/minimal'
# run_test './samples/event/event'
# run_test './samples/event/update_ui_event'
#run_test './samples/controls/controls'
# run_test './samples/text/textctrl'
# run_test './samples/text/rich_textctrl'
# run_test './samples/text/unicode'
# run_test './samples/text/scintilla'
run_test './samples/dialogs/dialogs'
