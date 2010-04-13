require "rubygems"
require "rake"

require "choctop"
require "yaml"

config = YAML.load_file("config.yml")

ChocTop.new do |s|
  # Remote upload target (set host if not same as Info.plist['SUFeedURL'])
  # s.host     = 'fuzzywindow.com'
  s.remote_dir = config["remote_dir"]

  s.build_target = "Embed"
  
  s.user = "deploy"
  s.transport = :scp

  # Custom DMG
  s.background_file = "dmg-background.png"
  # s.app_icon_position = [100, 90]
  # s.applications_icon_position =  [400, 90]
  # s.volume_icon = "dmg.icns"
  # s.applications_icon = "appicon.icns" # or "appicon.png"
end

desc "Build app, generate appcast XML, upload"
task :release => [:clean, :dmg, :upload]

desc "Delete all build-related directories"
task :clean do
  rm_rf "appcast"
  rm_rf "build"
end
