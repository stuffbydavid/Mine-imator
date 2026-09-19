/// minecraft_parse_key(key, textprefix)
/// Returns an array with the first category of the key and a formatted display value.

function minecraft_parse_key(key, textprefix = "")
{
	var first, formatted, split;
	first = ""
	split = string_split_escaped(key, "/")
	formatted = ""
	
	for (var i = 0; i < array_length(split); i++)
	{
		var str = split[i];
		if (first = "")
			first = str
		
		// Format key
		str = string_replace_all(split[i], "_", " ")
		str = string_replace_all(str, ".ogg", "")
		str = string_upper(string_char_at(str, 1)) + string_copy(str, 2, string_length(str) - 1)
		
		// Extract digits (str2_1)
		var strlen, num1, num1done, num2;
		strlen = string_length(str)
		num1 = ""
		num1done = false
		num2 = ""
		for (var j = strlen; j > 0; j--)
		{
			var c = string_char_at(str, j);
			if (ord(c) >= ord("0") && ord(c) <= ord("9"))
			{
				if (!num1done)
					num1 = c + num1
				else
					num2 = c + num2
			}
			else if (c = " ")
			{
				if (num1done)
					break
				num1done = true
			}
			else
				break
			
			str = string_copy(str, 1, string_length(str) - 1)
		}
		
		// Translate key
		if (text_exists(textprefix + str))
			str = text_get(textprefix + str)
		
		formatted += str
		if (num2 != "")
			formatted += (str != "" ? " " : "") + num2
		if (num1 != "")
			formatted += (str != "" || num2 != "" ? " " : "") + num1
		
		if (i < array_length(split) - 1)
			formatted += " / "
			
	}
	
	return array(first, formatted)
}
