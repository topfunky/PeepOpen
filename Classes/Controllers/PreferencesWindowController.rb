# -*- coding: utf-8 -*-
# PreferencesWindowController.rb
# PeepOpen
#
# Created by Geoffrey Grosenbach on 4/9/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class PreferencesWindowController < NSWindowController

  attr_accessor :applicationPopup, :editorView, :updatesView, :scmView, :ignoresView
  attr_accessor :editorToolbarItem, :updatesToolbarItem, :scmToolbarItem, :ignoresToolbarItem
  attr_accessor :gitExecutableLabel
  attr_accessor :currentView

  include NSWindowControllerHelper

  class InstallPluginError < StandardError; end

  def awakeFromNib
    applicationPopup.selectItemWithObjectValue(NSUserDefaults.standardUserDefaults.objectForKey('editorApplicationName'))
  end

  def show(sender)
    NSApp.activateIgnoringOtherApps(true)
    window.center
    showWindow(sender)
  end

  def windowDidLoad
    switchToView(editorView, item:editorToolbarItem, animate:false)
  end

  def windowDidResignKey(notification)
    saveSelectedEditorApplicationName()
  end

  def switchToEditor(sender)
    switchToView(editorView, item:editorToolbarItem, animate:true)
  end

  def switchToUpdates(sender)
    switchToView(updatesView, item:updatesToolbarItem, animate:true)
  end

  def switchToIgnores(sender)
    switchToView(ignoresView, item:ignoresToolbarItem, animate:true)
  end

  def switchToSCM(sender)
    switchToView(scmView, item:scmToolbarItem, animate:true)
    shellString = NSProcessInfo.processInfo.environment.objectForKey("SHELL") || "/bin/bash"
    gitExecutableLocation = `#{shellString} -l -c "which git"`

    # TODO: Use a legit pipe with full functionality.
    #     task = NSTask.alloc.init
    #     pipe = NSPipe.pipe

    #     task.launchPath = "which"
    #     task.arguments = ["git"]
    #     task.standardOutput = pipe
    #     task.environment = ENV
    #     task.standardInput = NSPipe.pipe

    #     task.launch
    #     task.waitUntilExit
    #     data = pipe.fileHandleForReading.readDataToEndOfFile
    #     gitExecutableLocation = NSString.alloc.initWithData(data, encoding:NSUTF8StringEncoding)

    gitExecutableLabel.stringValue = (gitExecutableLocation == "" ? "Git not found" : gitExecutableLocation)
  end

  ##
  # Modified from the Ingredients documentation viewer project.
  #
  # NOTE: Views for each pane must be configured to stick to the
  # bottom of the window.

  def switchToView(view, item:toolbarItem, animate:animate)
    window.toolbar.setSelectedItemIdentifier(toolbarItem.itemIdentifier)

    if (currentView.respondsToSelector("removeFromSuperview"))
      currentView.removeFromSuperview
    end

    view.setFrameOrigin([0,0])
    window.contentView.addSubview(view)
    setCurrentView(view)

    borderHeight = window.frame.size.height - window.contentView.frame.size.height

    newWindowFrame = window.frame
    newWindowFrame.size.height = view.frame.size.height + borderHeight
    newWindowFrame.origin.y += window.frame.size.height - newWindowFrame.size.height

    window.setFrame(newWindowFrame, display:true, animate:true)
  end

  def saveSelectedEditorApplicationName
    # Force NSComboBox to give up focus and save its value.
    window.makeFirstResponder(nil)
    # HACK: The binding between Shared User Defaults Controller and the combo box does not appear to work,
    # do it programmatically
    NSUserDefaults.standardUserDefaults.setObject(@applicationPopup.objectValueOfSelectedItem, forKey:"editorApplicationName")
  end

  def installPlugin(sender)
    saveSelectedEditorApplicationName()
    editorApplicationName = NSUserDefaults.standardUserDefaults.stringForKey("editorApplicationName")
    unless NSUserDefaults.standardUserDefaults.synchronize
      NSLog("Couldn't update UserPreferences in PreferencesController.installPlugin")
    end
    selector = "install#{editorApplicationName.gsub(' ', '')}:".to_sym
    if self.respondsToSelector(selector)
      performSelector(selector, withObject:self)
    else
      runWarningAlertWithMessage("No Plugin Found", informativeText:"We don't have a plugin for that editor yet. You can fork our project and add one for future releases: http://github.com/topfunky/PeepOpen-EditorSupport")
    end
  end

  def installTextMate(sender)
    fileManager = NSFileManager.defaultManager
    applicationSupportPath =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
    NSUserDomainMask,
    true).lastObject

    textmateSupportPath = NSString.pathWithComponents([applicationSupportPath, "TextMate"])
    textmateBundlesPath = NSString.pathWithComponents([textmateSupportPath, "Bundles"])
    textmatePluginsPath = NSString.pathWithComponents([textmateSupportPath, "PlugIns"])

    # Returns false on error
    fileManager.createDirectoryAtPath(textmateBundlesPath,
    withIntermediateDirectories:true,
    attributes:nil,
    error:nil)
    fileManager.createDirectoryAtPath(textmatePluginsPath,
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

    installedPeepOpenPluginPath =
    textmatePluginsPath.stringByAppendingPathComponent("PeepOpen.tmplugin")

    # Remove existing PeepOpen plugin
    if fileManager.fileExistsAtPath(installedPeepOpenPluginPath)
      fileManager.removeItemAtPath(installedPeepOpenPluginPath,
      error:nil)
    end

    # Copy plugin to ~/Library/ApplicationSupport/TextMate/Plugins
    resourcePath = NSBundle.mainBundle.resourcePath
    localPeepOpenBundlePath = NSString.pathWithComponents([
      resourcePath,
      "Support",
      "PeepOpen.tmplugin"
    ])
    fileManager.copyItemAtPath(localPeepOpenBundlePath,
    toPath:installedPeepOpenPluginPath,
    error:nil)

    runConfirmationAlertWithMessage("The TextMate plugin was installed successfully!",
    informativeText:"Restart TextMate and type ⌘-T to navigate with PeepOpen.")
  end

  def installEmacs(sender)
    fileManager = NSFileManager.defaultManager

    dotEmacsDirectoryPath =
    NSString.pathWithComponents(["~", ".emacs.d", "vendor"]).stringByExpandingTildeInPath()

    resourcePath = NSBundle.mainBundle.resourcePath
    localPeepOpenPluginPath = NSString.pathWithComponents([
      resourcePath,
      "Support",
      "peepopen.el"
    ])

    fileManager.createDirectoryAtPath(dotEmacsDirectoryPath,
    withIntermediateDirectories:true,
    attributes:nil,
    error:nil)
    installedPeepOpenPluginPath =
    dotEmacsDirectoryPath.stringByAppendingPathComponent("peepopen.el")
    if fileManager.fileExistsAtPath(installedPeepOpenPluginPath)
      fileManager.removeItemAtPath(installedPeepOpenPluginPath, error:nil)
    end
    fileManager.copyItemAtPath(localPeepOpenPluginPath,
    toPath:installedPeepOpenPluginPath,
    error:nil)

    runConfirmationAlertWithMessage("The Emacs plugin was installed successfully!",
    informativeText:"Some additional Emacs configuration is required. See ~/.emacs.d/vendor/peepopen.el for the details.")
  end

  def installAquamacs(sender)
    fileManager = NSFileManager.defaultManager
    dotEmacsDirectoryPath =
    NSString.pathWithComponents(["~",
      "Library",
      "Application Support",
    "Aquamacs Emacs"]).stringByExpandingTildeInPath()
    dotEmacsVendorDirectoryPath =
    dotEmacsDirectoryPath.stringByAppendingPathComponent("vendor")

    resourcePath = NSBundle.mainBundle.resourcePath
    bundleSupportPath =
    NSString.pathWithComponents([NSBundle.mainBundle.resourcePath, "Support"])

    fileManager.createDirectoryAtPath(dotEmacsVendorDirectoryPath,
    withIntermediateDirectories:true,
    attributes:nil,
    error:nil)
    ["vendor/peepopen.el", "vendor/textmate.el", "Preferences.sample.el"].each do |filename|
      installedFilePath = dotEmacsDirectoryPath.stringByAppendingPathComponent(filename)
      if fileManager.fileExistsAtPath(installedFilePath)
        fileManager.removeItemAtPath(installedFilePath, error:nil)
      end
      bundleFilePath =
      bundleSupportPath.stringByAppendingPathComponent(File.basename(filename))
      fileManager.copyItemAtPath(bundleFilePath,
      toPath:installedFilePath,
      error:nil)
    end

    runConfirmationAlertWithMessage("The Aquamacs plugin was installed successfully!",
    informativeText:"Some additional Aquamacs configuration is required. See ~/Library/Application Support/Aquamacs Emacs/Preferences.sample.el for the details.")
  end

  def installXcode(sender)
    runConfirmationAlertWithMessage("See the Help menu for Xcode installation.",
    informativeText:"The PeepOpen Help menu includes instructions for configuring Xcode to use PeepOpen.")
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
      dotvimPluginPath = dotvimDirectoryPath.stringByAppendingPathComponent("plugin")
      fileManager.createDirectoryAtPath(dotvimPluginPath, withIntermediateDirectories:true, attributes:nil, error:nil)
      installedPeepOpenPluginPath = dotvimPluginPath.stringByAppendingPathComponent("peepopen.vim")
      if fileManager.fileExistsAtPath(installedPeepOpenPluginPath)
        fileManager.removeItemAtPath(installedPeepOpenPluginPath, error:nil)
      end
      localPeepOpenPluginPath = NSString.pathWithComponents([localVimPluginPath,
        "plugin",
        "peepopen.vim"
      ])
      fileManager.copyItemAtPath(localPeepOpenPluginPath, toPath:installedPeepOpenPluginPath, error:nil)
    end

    runConfirmationAlertWithMessage("The MacVim plugin was installed successfully!", informativeText:"Restart Vim, open a Vim project and type <Leader>p to choose a file with PeepOpen.")
  end

  def installCoda(sender)
    fileManager = NSFileManager.defaultManager

    resourcePath = NSBundle.mainBundle.resourcePath
    localCodaPluginPath = NSString.pathWithComponents([
      resourcePath,
      "Support",
      "PeepOpen.codaplugin"
    ])

    runConfirmationAlertWithMessage("The Coda plugin will be installed now.",
    informativeText:"Open a Site in Coda and hit ^⌥⌘-T or use the Plug-ins menu.")
    # HACK: Run openFile after so dialog doesn't show over Coda.
    NSWorkspace.sharedWorkspace.openFile(localCodaPluginPath, withApplication:"Coda")
  end

  def installBBEdit(sender)
    installBareBonesEditorPlugin("BBEdit")
  end

  def installTextWrangler(sender)
    installBareBonesEditorPlugin("TextWrangler")
  end

  # Install BBEdit or TextWrangler plugin.
  def installBareBonesEditorPlugin(bareBonesEditorName)
    fileManager = NSFileManager.alloc.init
    resourcePath = NSBundle.mainBundle.resourcePath
    errorMessage = nil
    sourcePluginFile = NSString.pathWithComponents([
      resourcePath,
      "Support",
      "PeepOpen-bbedit",
      "#{bareBonesEditorName}.applescript"
    ])

    success = false
    osApplicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, true).lastObject
    [
      File.expand_path(NSString.pathWithComponents(["~/Dropbox", "Application Support"])),
      osApplicationSupportPath
    ].each do |applicationSupportPath|

      bareBonesScriptPath = NSString.pathWithComponents([applicationSupportPath, bareBonesEditorName, "Scripts"])
      targetPluginFile     = NSString.pathWithComponents([bareBonesScriptPath, "PeepOpen.applescript"])

      next unless File.exists?(bareBonesScriptPath)

      error = Pointer.new(:object)

      # Remove the file if it exists. Ignore errors.
      if fileManager.fileExistsAtPath(targetPluginFile)
        fileManager.removeItemAtPath(targetPluginFile, error:error)
      end
      # Replace it with the new one.
      if fileManager.copyItemAtPath(sourcePluginFile, toPath:(targetPluginFile), error:error)
        success = true
      else
        errorMessage = "Couldn't copy from #{sourcePluginFile} to #{targetPluginFile}. #{error[0].localizedDescription}"
        raiseError(errorMessage)
      end

    end

    if success
      runConfirmationAlertWithMessage("The BBEdit plugin was installed successfully!", informativeText:"Now create a shortcut\n\nWindow -> Palettes -> Scripts\nSelect PeepOpen and click Set Key ...\nEnter a shortcut key combination\n(recommend Command + Option + T)")
    else
      raiseError("Sorry, the plugin could not be installed.")
    end

  rescue InstallPluginError => e
    runWarningAlertWithMessage("The BBEdit plugin failed!", informativeText:e)
  end

  def raiseError(errorMessage)
    NSLog(errorMessage)
    raise InstallPluginError, errorMessage
  end

end
