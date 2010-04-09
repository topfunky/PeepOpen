# -*- coding: utf-8 -*-
# PreferencesWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/9/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class PreferencesWindowController < NSWindowController

  attr_accessor :applicationPopup

  def show(sender)
    showWindow(sender)
    window.center
  end

  def installPlugin(sender)
    rawTitle = applicationPopup.titleOfSelectedItem
    selector = "install#{rawTitle.gsub(' ', '')}:".to_sym
    performSelector(selector, withObject:self)
  end

  def installTextMate(sender)
    fileManager = NSFileManager.defaultManager
    applicationSupportPath =
      NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                          NSUserDomainMask,
                                          true).lastObject
    textmateBundlesPath = NSString.pathWithComponents([
                                                       applicationSupportPath,
                                                       "TextMate",
                                                       "Bundles"
                                                      ])
    # Returns false on error
    fileManager.createDirectoryAtPath(textmateBundlesPath,
                                      withIntermediateDirectories:true,
                                      attributes:nil,
                                      error:nil)
    # Delete existing PeepOpen.tmbundle if installed in ~/Library
    installedPeepOpenBundlePath =
      textmateBundlesPath.stringByAppendingPathComponent("PeepOpen.tmbundle")
    if fileManager.fileExistsAtPath(installedPeepOpenBundlePath)
      fileManager.removeItemAtPath(installedPeepOpenBundlePath,
                                   error:nil)
    end

    # Copy bundle to ~/Library/ApplicationSupport/TextMate/Bundles
    resourcePath = NSBundle.mainBundle.resourcePath
    localPeepOpenBundlePath = NSString.pathWithComponents([
                                                           resourcePath,
                                                           "Support",
                                                           "PeepOpen.tmbundle"
                                                          ])
    fileManager.copyItemAtPath(localPeepOpenBundlePath,
                               toPath:installedPeepOpenBundlePath,
                               error:nil)
    # Use AppleScript to reload bundles
    reloadCommand =
      NSAppleScript.alloc.initWithSource('tell app "TextMate" to reload bundles')
    reloadCommand.executeAndReturnError(nil)

    runConfirmationAlertWithMessage("The TextMate plugin was installed successfully!",
                                    informativeText:"Open at least one file in a project and type ⌘-T to navigate with PeepOpen.")
  end

  def installEmacs(sender)

  end

  def installAquamacsEmacs(sender)

  end

  def installMacVim(sender)

  end

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

  def alertDidEnd(alert, returnCode:returnCode, contextInfo:contextInfo)
    window.close
  end

end

