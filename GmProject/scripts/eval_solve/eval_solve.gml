/// @desc Manually solves operation between two numbers.
/// @arg number1
/// @arg number2
/// @arg operation

function eval_solve(a, b, op)
{
	// Process negative number
	if (is_undefined(a) && !is_undefined(b) && op = "-")
		a = 0
	
	if (is_undefined(a) || is_undefined(b) || is_undefined(op))
		return undefined
	
	switch (op)
	{
		case "+": return a + b
		case "-": return a - b
		case "*": return a * b
		case "/": return b != 0 ? a / b : 0
		case "^": return power(a, b)
		case "%": return (a mod b)
	}
}
