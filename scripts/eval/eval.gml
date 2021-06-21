/// eval(str, def)
/// @arg str
/// @arg def
function eval(str, def)
{
	var i, values, ops, result;
	values = ds_stack_create()
	ops = ds_stack_create()
	
	for (i = 1; i < string_length(str) + 1; i++)
	{
		var char = string_char_at(str, i);
		
		if (char = " ") // Whitespace
			continue
		else if (char = "(") // Open brace
			ds_stack_push(ops, char)
		else if (eval_is_digit(char)) // Digit
		{
			var val, dec, deccheck, decamount;
			val = 0
			dec = 0
			deccheck = false
			decamount = 0
			
			// Check for more digits
			while (i < (string_length(str) + 1) && eval_is_digit(string_char_at(str, i)))
			{
				if (string_char_at(str, i) = ".")
				{
					deccheck = true
					i++
					continue
				}
				
				if (deccheck)
				{
					dec = (dec * 10) + real(string_char_at(str, i))
					decamount++
				}
				else
					val = (val * 10) + real(string_char_at(str, i))
				
				i++
			}
			i--
			
			if (decamount > 0)
				dec /= power(10, decamount)
		
			ds_stack_push(values, val + dec)
		}
		else if (char = ")") // Closing brace
		{
			while (!ds_stack_empty(ops) && ds_stack_top(ops) != "(")
			{
				var val2, val1, op;
				val2 = ds_stack_top(values)
				ds_stack_pop(values)
				
				val1 = ds_stack_top(values)
				ds_stack_pop(values)
				
				op = ds_stack_top(ops)
				ds_stack_pop(ops)
				
				ds_stack_push(values, eval_solve(val1, val2, op))
			}
			
			// Pop opening brace
			if (!ds_stack_empty(ops))
				ds_stack_pop(ops)
		}
		else // Operator
		{
			// Solve previous operations if needed before adding current operator
			while (!ds_stack_empty(ops) && eval_precedence(ds_stack_top(ops)) >= eval_precedence(char))
			{
				var val2, val1, op;
				val2 = ds_stack_top(values)
				ds_stack_pop(values)
				
				val1 = ds_stack_top(values)
				ds_stack_pop(values)
				
				op = ds_stack_top(ops)
				ds_stack_pop(ops)
				
				ds_stack_push(values, eval_solve(val1, val2, op))
			}
			
			// Add current operator
			ds_stack_push(ops, char)
		}
	}
	
	// Solve operations left over from expression
	while (!ds_stack_empty(ops))
	{
		var val2, val1, op;
		val2 = ds_stack_top(values)
		ds_stack_pop(values)
		
		val1 = ds_stack_top(values)
		ds_stack_pop(values)
		
		op = ds_stack_top(ops)
		ds_stack_pop(ops)
		
		ds_stack_push(values, eval_solve(val1, val2, op))
	}
	
	result = ds_stack_top(values)
	ds_stack_destroy(values)
	ds_stack_destroy(ops)
	
	if (result = undefined)
		return string_get_real(str, def)
	else
		return result
}

/// eval_solve(a, b, operation)
/// @arg a
/// @arg b
/// @arg operation
/// @desc Manually solves operation between two numbers
function eval_solve(a, b, op)
{
	if (a = undefined || b = undefined || op = undefined)
		return undefined
	
	switch (op)
	{
		case "+": return a + b;
		case "-": return a - b;
		case "*": return a * b;
		case "/": return a / b;
		case "^": return power(a, b);
	}
}

/// eval_is_digit(char)
/// @arg char
/// @desc Determines if a character is a digit
function eval_is_digit(char)
{
	var digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."];
	
	for (var i = 0; i < 11; i++)
	{
		if (char = digits[i])
			return true
	}
	
	return false
}

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
		case "*": return 2;
		
		case "^": return 3;
	}
	
	return 0
}
