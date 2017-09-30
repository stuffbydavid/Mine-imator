/// test_ext(value, if0, if1, if2...)
/// @arg value
/// @arg if0
/// @arg if1
/// @arg if2...

//gml_pragma("forceinline")

for (var a = 0; a < 15; a++)
	if (argument[0] = a)
		return argument[a + 1]

return 0
