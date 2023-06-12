/// dec_to_hex(value, [length])
/// @arg value
/// @arg [length]

function dec_to_hex(dec, len = 0)
{
	if (!dec)
		return "0"
	
	var h, hex, byte, hi, lo;
	
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
