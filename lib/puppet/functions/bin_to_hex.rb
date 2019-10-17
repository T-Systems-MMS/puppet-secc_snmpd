Puppet::Functions.create_function(:bin_to_hex) do
  dispatch :bin_to_hex do
    param 'String', :input_str
    return_type 'String'
  end

  def bin_to_hex(input_str)
    input_str.each_byte.map { |b| b.to_s(16) }.join
  end
end
