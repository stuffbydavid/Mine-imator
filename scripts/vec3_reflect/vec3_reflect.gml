/// vec3_reflect(vector, normal)
/// @arg vector
/// @arg normal

function vec3_reflect(v, n)
{
	gml_pragma("forceinline")
	
	return vec3_sub(v, vec3_mul(vec3_mul(n, vec3_dot(v, n)), 2))
}
