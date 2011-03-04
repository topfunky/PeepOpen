#
#  SessionConfig.rb
#
#  Created by Martin Hawkins on 2011-02-03.
#  Copyright (c) 2011 Topfunky Corporation. All rights reserved.
#

class SessionConfig
  
  attr_accessor :editorName

	def initialize(editorName)
    @editorName = editorName
	end

end