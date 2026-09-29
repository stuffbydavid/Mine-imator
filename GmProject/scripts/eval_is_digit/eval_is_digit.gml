/// @desc Determines if a character is a digit.
/// @arg character

function eval_is_digit(char)
{
	var digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];
	
	for (var i = 0; i < array_length(digits); i++)
		if (char = digits[i])
			return true
	
	return false
}
