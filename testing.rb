framework 'Cocoa'

main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = '/Users/martin/work/macruby/onWeb/PeepOpen/build/Debug/PeepOpen.app/Contents/Resources'
fj= File.join(dir_path, '*.{rb,rbo}')
fjmap = Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq
puts "#{main}"
puts "#{dir_path}"
puts "#{fj}"
puts "#{fjmap}"
puts "#{$:}"