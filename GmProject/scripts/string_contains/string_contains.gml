/// string_contains(string, search)
/// @arg string
/// @arg search

function string_contains(str, search)
{
	return (string_pos(search, str) > 0)
}
