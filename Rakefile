Dir['Vendor/*/lib'].each do |dir|
  $: << dir
end
require "rake"

require "choctop"
require "yaml"

config = YAML.load_file("config.yml")

ChocTop.new do |s|
  # Remote upload target (set host if not same as Info.plist['SUFeedURL'])
  # s.host     = 'fuzzywindow.com'
  s.remote_dir = config["remote_dir"]

  s.build_target = "Embed"
  
  s.user = "rails"
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

desc "Package download with source and release notes"
task :pkg do
  raise "Please provide VERSION=0.5.0" unless ENV["VERSION"]
  
  dotted_version = ENV["VERSION"]
  numeric_version = dotted_version.gsub('.', '')
  pkg_dir = "peepcode-peepopen-#{numeric_version}-code"
  
  if File.exist?(pkg_dir)
    rm_rf pkg_dir
  end
  mkdir pkg_dir
  system "cd #{pkg_dir} && wget http://peepcode.com/system/apps/PeepOpen/release_notes.html"
  system "cd #{pkg_dir} && wget http://peepcode.com/system/apps/PeepOpen/PeepOpen.dmg"
  system "git archive master > #{pkg_dir}/source.tar"
  system "zip -r #{pkg_dir}.zip #{pkg_dir}"
end

