/// eval_solve(a, b, operation)
/// @arg a
/// @arg b
/// @arg operation
/// @desc Manually solves operation between two numbers

function eval_solve(a, b, op)
{
	// Process negative number
	if (a = undefined && b != undefined && op = "-")
		a = 0
	
	if (a = undefined || b = undefined || op = undefined)
		return undefined
	
	switch (op)
	{
		case "+": return a + b;
		case "-": return a - b;
		case "*": return a * b;
		case "/": return b != 0 ? a / b : 0;
		case "^": return power(a, b);
		case "%": return (a mod b);
	}
}
