load "TinyParser.rb"

parse = Parser.new("input1.tiny")
mytree = parse.program()
puts mytree.toStringList()
