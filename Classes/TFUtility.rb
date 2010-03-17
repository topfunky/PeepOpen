# TFUtility.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/17/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.


def TFLogRect(aFrame)
  NSLog("origin.x %f origin.y %f size.width %f size.height %f", aFrame.origin.x,
        aFrame.origin.y,
        aFrame.size.width,
        aFrame.size.height)
end
