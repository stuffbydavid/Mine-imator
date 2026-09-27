/// eval_precedence(operator)
/// @arg operator
/// @desc Gets operator importance

function eval_precedence(op)
{
	switch (op)
	{
		case "-": 
		case "+": return 1;
		
		case "/": 
		case "*":
		case "%": return 2;
		
		case "^": return 3;
	}
	
	return 0
}
