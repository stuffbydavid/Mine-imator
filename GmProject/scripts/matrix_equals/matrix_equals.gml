function matrix_equals(a, b)
{
	for (var i = 0; i < 16; i++)
		if (abs(a[@i] - b[@i]) > 0.001)
			return false
			
	return true
}