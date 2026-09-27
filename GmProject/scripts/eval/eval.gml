/// eval(str, default)
/// @arg str
/// @arg default

function eval(str, def)
{
	var i, values, ops, result, lastoperator;
	values = ds_stack_create()
	ops = ds_stack_create()
	lastoperator = ""
	
	for (i = 1; i < string_length(str) + 1; i++)
	{
		var char = string_char_at(str, i);
		
		if (char = " ") // Whitespace
			continue
		else if (char = "(") // Open brace
		{
			if (lastoperator == "--")
				ds_stack_push(ops, "-(")
			else
				ds_stack_push(ops, "(")
			
			lastoperator = ""
		}
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
			
			if (lastoperator = "--")
				ds_stack_push(values, -(val + dec))
			else
				ds_stack_push(values, val + dec)
			
			lastoperator = ""
		}
		else if (char = ")") // Closing brace
		{
			while (!ds_stack_empty(ops) && !(ds_stack_top(ops) = "(" || ds_stack_top(ops) = "-("))
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
			{
				// Flip result sign
				if (ds_stack_top(ops) = "-(")
				{
					var val = -ds_stack_top(values);
					ds_stack_pop(values)
					ds_stack_push(values, val)
				}
				
				ds_stack_pop(ops)
			}
			
			lastoperator = ""
		}
		else // Operator
		{
			// Last character was an operator, account for an upcoming negative number?
			if (lastoperator != "" && char = "-")
			{
				lastoperator = "--"
				continue;
			}
			
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
			lastoperator = char
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
		return def
	else
		return result
}
