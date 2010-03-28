require "Vendor/dust-0.1.6/lib/dust"

Dir.glob(File.expand_path('../**/*_test.rb', __FILE__)).each { |test| require test }
