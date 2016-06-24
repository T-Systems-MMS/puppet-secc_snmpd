module Puppet::Parser::Functions
  newfunction(:bin_to_hex, :type => :rvalue) do |args|

    raise(Puppet::ParseError, "bin_to_hex(): Wrong number of arguments given (#{args.size} instead of 1)") if args.size != 1

    input_str = args[0]
    input_str.each_byte.map { |b| b.to_s(16) }.join
  end
end