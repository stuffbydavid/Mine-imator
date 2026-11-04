/// CppSeparate IntType builder_irandom(ScopeAny, IntType, IntType = 0, BoolType = true)
/// @arg x
/// @arg [salt]
/// @arg [usez]

function builder_irandom(xx, salt = 0, usez = true)
{
	var seed = 17;
	for (var a = X; a <= (usez ? Z : Y); a++)
		seed = (seed * 16807 + build_pos[a]) mod 2147483647
	
	seed = (seed + salt) mod 2147483647
	
	if (seed < 0)
		seed += 2147483647
	
	for (var i = 0; i < 3; i++)
		seed = ((seed ^ (seed >> 13)) * 48271 + 1) mod 2147483647
	
	return seed mod (floor(max(0, xx)) + 1)
}
