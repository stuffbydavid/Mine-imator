#include "Generated/Scripts.hpp"

#include <simplexnoise1234.c>

namespace CppProject
{
	RealType lib_math_simplex1d(RealType x)
	{
		return snoise1(x);
	}

	RealType lib_math_simplex2d(RealType x, RealType y)
	{
		return snoise2(x, y);
	}

	RealType lib_math_simplex3d(RealType x, RealType y, RealType z)
	{
		return snoise3(x, y, z);
	}

	RealType lib_math_simplex4d(RealType x, RealType y, RealType z, RealType w)
	{
		return snoise4(x, y, z, w);
	}
}