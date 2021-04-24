/// mod_fix(x, y)
/// @arg x
/// @arg y

function mod_fix(xx, yy)
{
	while (xx < 0)
		xx += yy
	
	return (xx mod yy)
}
