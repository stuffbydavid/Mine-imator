/// string_natural_digits(value)
/// @arg value

function string_natural_digits(value)
{
	var digits, maxdigits;
	digits = 0
	maxdigits = 0
	for (var i = 1; i <= string_length(value); i++)
	{
		if (string_pos(string_char_at(value, i), "0123456789") > 0)
			digits++
		else
		{
			maxdigits = max(maxdigits, digits)
			digits = 0
		}
	}
	return max(maxdigits, digits)
}
