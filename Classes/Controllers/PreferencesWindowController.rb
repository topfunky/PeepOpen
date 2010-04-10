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
    runConfirmationAlertWithMessage("The Emacs plugin is coming soon...",
                                    informativeText:"Check updates for the latest version.")
  end

  def installAquamacsEmacs(sender)
    runConfirmationAlertWithMessage("The Aquamacs Emacs plugin is coming soon...",
                                    informativeText:"Check updates for the latest version.")
  end

  def installMacVim(sender)
    fileManager = NSFileManager.defaultManager

    dotvimDirectoryPath =
      NSString.pathWithComponents(["~", ".vim"]).stringByExpandingTildeInPath()

    resourcePath = NSBundle.mainBundle.resourcePath
    localVimPluginPath = NSString.pathWithComponents([
                                                      resourcePath,
                                                      "Support",
                                                      "vim-peepopen"
                                                     ])

    # If ~/.vim/bundle exists, copy vim-peepopen directory there
    pathogenBundlePath =
      dotvimDirectoryPath.stringByAppendingPathComponent("bundle")
    if fileManager.fileExistsAtPath(pathogenBundlePath)
      # Pathogen installation to ~/.vim/bundle
      installedVimPluginPath =
        pathogenBundlePath.stringByAppendingPathComponent("vim-peepopen")
      if fileManager.fileExistsAtPath(installedVimPluginPath)
        fileManager.removeItemAtPath(installedVimPluginPath, error:nil)
      end
      fileManager.copyItemAtPath(localVimPluginPath,
                                 toPath:installedVimPluginPath,
                                 error:nil)
    else
      # Normal ~/.vim/plugin installation
      dotvimPluginPath =
        dotvimDirectoryPath.stringByAppendingPathComponent("plugin")
      fileManager.createDirectoryAtPath(dotvimPluginPath,
                                        withIntermediateDirectories:true,
                                        attributes:nil,
                                        error:nil)
      installedPeepOpenPluginPath =
        dotvimPluginPath.stringByAppendingPathComponent("peepopen.vim")
      if fileManager.fileExistsAtPath(installedPeepOpenPluginPath)
        fileManager.removeItemAtPath(installedPeepOpenPluginPath, error:nil)
      end
      localPeepOpenPluginPath =
        NSString.pathWithComponents([localVimPluginPath,
                                     "plugin",
                                     "peepopen.vim"
                                    ])
      fileManager.copyItemAtPath(localPeepOpenPluginPath,
                                 toPath:installedPeepOpenPluginPath,
                                 error:nil)
    end

    runConfirmationAlertWithMessage("The MacVim plugin was installed successfully!",
                                    informativeText:"Restart Vim, open a Vim project and type <Leader>p to choose a file with PeepOpen.")
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

