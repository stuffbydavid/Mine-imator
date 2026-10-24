#include "Generated/Scripts.hpp"

namespace CppProject
{
	static IntType SplinePointSize(const ArrType& point)
	{
		return point.Size();
	}

	static IntType SplinePointSize(const VarType& point)
	{
		if (point.IsArray())
			return point.Arr().Size();
		if (point.IsVec())
			return point.Vec().size;
		if (point.IsMatrix())
			return 16;
		return 0;
	}

	template <typename Point> static ArrType LerpSplinePoints(const Point& p1, const Point& p2, RealType amount)
	{
		ArrType point;
		IntType size = SplinePointSize(p1);
		point.vec.Alloc(size);
		for (IntType i = 0; i < size; i++)
			point.Append(lerp(p1.Value(i), p2.Value(i), amount));
		return point;
	}

	ArrType spline_get_point(RealType t, const ArrType& points, BoolType closed, BoolType smooth, RealType amount)
	{
		RealType p0 = floor(t / 2.0) * 2.0;
		RealType p1 = p0 + 1.0;
		RealType p2 = p1 + 1.0;
		RealType curvet = percent(t, p0, p2);

		if (amount == 0.0)
			amount = points.Size();

		if (closed)
		{
			p0 = mod_fix(p0, amount);
			p1 = mod_fix(p1, amount);
			p2 = mod_fix(p2, amount);
		}
		else
		{
			p0 = std::max(0.0, std::min(p0, amount - 1.0));
			p1 = std::max(0.0, std::min(p1, amount - 1.0));
			p2 = std::max(0.0, std::min(p2, amount - 1.0));
		}

		if (amount == points.Size())
			curvet = percent(t, p0, p2);

		// Open endpoints return an independent sample with the original extra channels
		if (!closed && (t <= 0.0 || t >= amount - 1.0))
		{
			IntType i;
			VecType pos;
			if (t <= 0.0)
			{
				i = 0;
				VecType start = points.ValueRef(i).ToVec();
				VecType next = points.ValueRef(i + 1).ToVec();
				pos = point3D_add(start, vec3_mul(vec3_normalize(point3D_sub(start, next)), abs(t)));
			}
			else
			{
				i = points.Size() - 1;
				const VarType& previous = points.ValueRef(i - 1);
				VecType tangent(previous.Value(PATH_TANGENT_X), previous.Value(PATH_TANGENT_Y), previous.Value(PATH_TANGENT_Z));
				pos = point3D_add(points.ValueRef(i).ToVec(), vec3_mul(tangent, abs(t - i)));
			}

			ArrType point = points.ValueRef(i).ToArr();
			point[X_] = pos.x;
			point[Y_] = pos.y;
			point[Z_] = pos.z;
			point[PATH_TANGENT_X] = point.Value(PATH_TANGENT_X);
			return point;
		}

		// Borrow only the samples needed for interpolation, never the complete table
		const VarType& a = points.ValueRef((IntType)p0);
		const VarType& b = points.ValueRef((IntType)p1);
		if (smooth)
		{
			const VarType& c = points.ValueRef((IntType)p2);
			ArrType first = LerpSplinePoints(a, b, curvet);
			ArrType second = LerpSplinePoints(b, c, curvet);
			return LerpSplinePoints(first, second, curvet);
		}
		if (curvet < 0.5)
			return LerpSplinePoints(a, b, curvet * 2.0);

		const VarType& c = points.ValueRef((IntType)p2);
		return LerpSplinePoints(b, c, (curvet - 0.5) * 2.0);
	}
}
