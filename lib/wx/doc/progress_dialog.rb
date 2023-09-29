# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


class Wx::ProgressDialog

  # Updates the dialog, setting the progress bar to the new value and updating the message if new one is specified.
  #
  # Returns <code>false</code> if the "Cancel" button has been pressed, <code>true</code> if neither "Cancel" nor
  # "Skip" has been pressed and <code>:skipped</code> if "Skip" has been pressed.
  #
  # If false is returned, the application can either immediately destroy the dialog or ask the user for the confirmation
  # and if the abort is not confirmed the dialog may be resumed with #resume method.
  #
  # If value is the maximum value for the dialog, the behaviour of the function depends on whether Wx::PD_AUTO_HIDE was
  # used when the dialog was created. If it was, the dialog is hidden and the function returns immediately. If it was
  # not, the dialog becomes a modal dialog and waits for the user to dismiss it, meaning that this function does not
  # return until this happens.
  #
  # Notice that if newmsg is longer than the currently shown message, the dialog will be automatically made wider to
  # account for it. However if the new message is shorter than the previous one, the dialog doesn't shrink back to
  # avoid constant resizes if the message is changed often. To do this and fit the dialog to its current contents you
  # may call fit explicitly. An alternative would be to keep the number of lines of text constant in order to avoid
  # jarring dialog size changes. You may also want to make the initial message, specified when creating the dialog,
  # wide enough to avoid having to resize the dialog later, e.g. by appending a long string of unbreakable spaces
  # (wxString(L'\u00a0', 100)) to it.
  # @param [Integer] value The new value of the progress meter. It should be less than or equal to the maximum value given to the constructor.
  # @param [String] newmsg The new messages for the progress dialog text, if it is empty (which is the default) the message is not changed.
  # @return [Boolean,:skipped]
  def update(value, newmsg = '') end

  # Like #update but makes the gauge control run in indeterminate mode.
  #
  # In indeterminate mode the remaining and the estimated time labels (if present) are set to "Unknown" or to newmsg
  # (if it's non-empty). Each call to this function moves the progress bar a bit to indicate that some progress was done.
  # @param [String] newmsg
  # @return [Boolean,:skipped]
  def pulse(newmsg = '') end

end
