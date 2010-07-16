require 'ruble'

bundle do |bundle|
  bundle.author = 'Andrew Shebanow'
  bundle.display_name = 'PeepOpen'
  bundle.description = "Conversion of PeepOpen textmate bundle"
  bundle.copyright = "Copryright 2010 Aptana. Distributed under MIT license."

  bundle.menu "PeepOpen" do |menu|    
    menu.command "PeepOpen File" do |cmd|
      cmd.key_binding = 'M1+T'
      cmd.output = :discard
      cmd.input = :none
      cmd.invoke.mac = <<-EOF
        if (set -u; : $TM_PROJECT_DIRECTORY) 2> /dev/null
        then
          open -a PeepOpen "$TM_PROJECT_DIRECTORY"
        fi
        EOF
    end
  end
end
