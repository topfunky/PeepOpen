# PeepOpen-BBEdit

AppleScript plugin to launch PeepCode for the current project or document in BBEdit or TextWrangler.

## Installation

The install will copy scripts for BBEdit or TextWrangler to the following directories:

    ~/Library/Application Support/BBEdit/Scripts
    ~/Dropbox/Application Support/BBEdit/Scripts
    ~/Library/Application Support/TextWrangler/Scripts
    ~/Dropbox/Application Support/TextWrangler/Scripts

To run the install:

    rake all           # Install all scripts (BBEdit and TextWrangler)
    rake bbedit        # Install BBEdit script
    rake textwrangler  # Install TextWrangler script

## Installation

	mkdir -p ~/Library/Application\ Support/BBEdit/Scripts/PeepOpen
	cp PeepOpen.applescript ~/Library/Application\ Support/BBEdit/Scripts/PeepOpen/.

To add a shortcut key:

	Window -> Palettes -> Scripts

	Select PeepOpen and click Set Key ...
	Enter a shortcut key combination (recommend Command + Option + T)

## Credits
=======
	Select PeepOpen -> Peep Open and click Set Key ...
	Enter a shortcut key combination (recommend Command + Option + T)

## PeepOpen Preferences

To help find the root of a project, you can add BBEdit Project Documents to the Project Root Pattern:
	^(\.git|\.hg|Rakefile|Makefile|README\.?.*|build\.xml|.*\.xcodeproj|.*\.bbprojectd)$


## Credit

Thanks to Bare Bones Software, Inc. for the initial AppleScript code.

## License

Copyright (c) 2011 Andrew Carter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
