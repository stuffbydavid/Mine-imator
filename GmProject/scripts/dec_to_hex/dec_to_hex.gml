/// dec_to_hex(value, [length])
/// @arg value
/// @arg [length]

function dec_to_hex()
{
	var dec, len, hex, h, byte, hi, lo;
	dec = argument[0]
	
	if (argument_count > 0)
		len = argument[1]
	else
		len = 0
	
	if (!dec)
		return "0"
	
	h = "0123456789ABCDEF"
	hex = ""
	while (dec)
	{
		byte = dec & 255
		hi = string_char_at(h, byte div 16 + 1)
		lo = string_char_at(h, byte mod 16 + 1)
		hex = hi + lo + hex
		dec = dec >> 8
	}
	
	repeat (max(0, len - string_length(hex)))
		hex = "0" + hex
	
	return hex
}
