-- PeepOpen support for BBEdit
-- Launches PeepOpen for either the current project directory, 
-- first project file, or the current file.

set _theFile to missing value

tell application "BBEdit"
	if (count of text windows) > 0 then
		-- Get the first text window. This will return any window that can
		-- contain a text document (standalone window, project window, etc.)
		-- and skips over Find windows, Scratchpads, and whatnot
		set _firstTextWindow to text window 1
		
		if (class of _firstTextWindow is project window) then
			set _projectDocument to project document of _firstTextWindow
			if (on disk of _projectDocument) then
				set _theProjectDir to file of _projectDocument
				
				tell application "Finder"
					set _theFile to container of _theProjectDir
				end tell
			else
				-- Shipping versions of BBEdit don't provide direct access
				-- to the Instaproject root, so fake it by asking for
				-- the first node from the project list
				set _theFile to item 1 of _projectDocument
			end if
		else if (class of _firstTextWindow is text window) then
			if (on disk of document of _firstTextWindow) then
				set _theFile to file of document of _firstTextWindow
			end if
		end if
	end if
end tell

if _theFile is equal to missing value then
	-- No base file found for reference
	-- Signal error by beep and end
	beep
else
	tell application "Finder"
		-- To use this path as a hunk of a URL, we need to encode it. 
		-- Ask the Finder to give back a URL, and then extract the 
		-- salient text out of it
		set _url to URL of _theFile
	end tell
	
	-- Separate the path from the URL scheme,
	-- and eat the "localhost" portion as well
	set _originalDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to {"file://localhost"}
	set _chunks to (every text item in (_url as text)) as list
	set AppleScript's text item delimiters to _originalDelimiters
	set _fullPath to item 2 of _chunks
	
	-- Construct the PeepOpen URL
	set _peepOpenURL to "peepopen://" & _fullPath & "?editor=BBEdit"
	
	-- Launch PeepOpen
	open location _peepOpenURL
end if