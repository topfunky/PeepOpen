module NSWindowControllerHelper
  
def runConfirmationAlertWithMessage(theMessage, informativeText:theInformativeText)
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle("OK")
    alert.setMessageText(theMessage)
    alert.setInformativeText(theInformativeText)
    alert.setAlertStyle(NSInformationalAlertStyle)
    alert.beginSheetModalForWindow(window,
                                   modalDelegate:self,
                                   didEndSelector:"alertDidEnd:returnCode:contextInfo:",
                                   contextInfo:nil)
  end

  def runWarningAlertWithMessage(theMessage, informativeText:theInformativeText)
    alert = NSAlert.alloc.init
    alert.addButtonWithTitle("OK")
    alert.setMessageText(theMessage)
    alert.setInformativeText(theInformativeText)
    alert.setAlertStyle(NSWarningAlertStyle)
    alert.beginSheetModalForWindow(window,
                                   modalDelegate:self,
                                   didEndSelector:nil,
                                   contextInfo:nil)
  end

  def alertDidEnd(alert, returnCode:returnCode, contextInfo:contextInfo)
    # Do nothing
  end
end
