/// string_natural_digits(value)
/// @arg value

function string_natural_digits(value)
{
	var digits, maxdigits;
	digits = 0
	maxdigits = 0
	for (var i = 1; i <= string_length(value); i++)
	{
		var c = string_char_at(value, i);
		if (ord(c) >= ord("0") && ord(c) <= ord("9"))
			digits++
		else
		{
			maxdigits = max(maxdigits, digits)
			digits = 0
		}
	}
	return max(maxdigits, digits)
}
