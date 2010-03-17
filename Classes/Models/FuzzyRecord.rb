# FuzzyRecord.rb
# FuzzyWindow
#
# Created by Geoffrey Grosenbach on 3/16/10.
# Copyright 2010 Topfunky Corporation. All rights reserved.

class FuzzyRecord

  attr_accessor *[:projectRoot,
                  :filePath, :filePaths,
                  :modifiedAt,
                  :scmStatus, :scmName,
                  :codeObjectName, :codeObjectNames]

  def initWithProjectRoot(theProjectRoot, filePath:theFilePath)
    @projectRoot = theProjectRoot
    @filePath = theFilePath
    self
  end

end

