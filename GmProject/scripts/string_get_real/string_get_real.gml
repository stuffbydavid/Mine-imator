/// string_get_real(string, [invalid])
/// @arg string
/// @arg [invalid]
/// @desc An acceptable real number takes the following form:
/// [whitespaces] [sign] [digits] [. [digits]] [{e |E} [sign] [digits]] [whitespaces]
/// At least one digit or a decimal point must be present in prior to the exponent part

function string_get_real(str, inv = undefined)
{
	if (is_undefined(str))
		return inv
	
	var len, state;
	
	// Trim white spaces at the end (to make it easier to check the final state)
	len = string_length(str)
	while (len > 1 && string_char_at(str, len) == " ")
		len--
	
	// Now check the string with a state machine
	state = 0
	for (var i = 1; i <= len; i++)
	{
		var c = string_char_at(str, i)
		if (c = " ") // Ignore white spaces at the beginning
		{
			if (state = 0)
				continue
			else
				return inv
		}
		else if (c = "-" || c = "+") // A sign is allowed at the beginning or after 'E'
		{
			if (state = 0 || state = 5)
				state++
			else
				return inv
		}
		else if (ord(c) >= ord("0") && ord(c) <= ord("9")) // A digit is allowed at serveral places...
		{
			if (state <= 2) // At the beginning, after a sign or another digit
				state = 2
			else if (state <= 4) // After a decimal point
				state = 4
			else if (state <= 7) // After an exponent
				state = 7
			else // Not allowed in other places
				return inv
		}
		else if (c = ".") // A decimal point is allowed at the beginning, after a sign or a digit
		{
			if (state <= 2)
				state = 3
			else return inv
		}
		else // No other letters are allowed
			return inv
	}
	
	// Additional checking/changes to make sure it works with real()
	
	// Finally, check if the string only contains minus symbols or decimals
	if (string_replace(string_replace(str, "-", ""), ".", "") = "")
		return inv
	
	// real() function doesn't like "-." being used, so a 0 must be inserted
	if (string_contains(str, "-."))
		str = string_replace(str, "-.", "-0.")
	
	if (state >= 2)
		return real(str)
	
	return inv
}
