/// CppSeparate VecType point3D(RealType x, RealType y = 0.0, RealType z = 0.0)
/// point3D(x, y, z)
/// @arg x
/// @arg y
/// @arg z

function point3D(xx, yy = 0, zz = 0)
{
	gml_pragma("forceinline")
	
	return [xx, yy, zz]
}
