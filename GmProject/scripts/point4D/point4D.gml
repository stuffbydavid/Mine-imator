/// CppSeparate VecType point4D(RealType, RealType, RealType, RealType)
/// @arg x
/// @arg y
/// @arg z
/// @arg w

function point4D(xx, yy, zz, w)
{
	gml_pragma("forceinline")
	
	return [ xx, yy, zz, w ]
}
