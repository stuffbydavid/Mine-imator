#include "Generated/GmlFunc.hpp"

namespace CppProject
{
	RealType abs(RealType rl)
	{
		return std::abs(rl);
	}

	RealType arccos(RealType rl)
	{
		return std::acos(std::clamp(rl, -1.0, 1.0));
	}

	RealType arcsin(RealType rl)
	{
		return std::asin(std::clamp(rl, -1.0, 1.0));
	}

	RealType arctan(RealType rl)
	{
		return std::atan(rl);
	}

	RealType arctan2(RealType y, RealType x)
	{
		return std::atan2(y, x);
	}

	RealType ceil(RealType rl)
	{
		// Limit precision to 6 decimals, to avoid 1.0000006 becoming 2
		double db = rl;
		double prec = 100000.0;
		db = ((IntType)(db * prec)) / prec;
		return std::ceil(db);
	}

	RealType cos(RealType rl)
	{
		return std::cos(rl);
	}

	RealType dcos(RealType rl)
	{
		return std::cos(DEGTORAD * rl);
	}

	RealType degtorad(RealType rl)
	{
		return DEGTORAD * rl;
	}

	RealType dsin(RealType rl)
	{
		return std::sin(DEGTORAD * rl);
	}

	RealType floor(RealType rl)
	{
		return std::floor(rl);
	}

	RealType frac(RealType rl)
	{
		return rl - std::floor(rl);
	}

	RealType lengthdir_x(RealType len, RealType dir)
	{
		return len * std::cos(DEGTORAD * dir);
	}

	RealType lengthdir_y(RealType len, RealType dir)
	{
		return -len * std::sin(DEGTORAD * dir);
	}

	RealType lerp(RealType a, RealType b, RealType amt)
	{
		return a + (b - a) * amt;
	}

	RealType log2(RealType rl)
	{
		return std::log2(rl);
	}

	RealType point_direction(RealType x1, RealType y1, RealType x2, RealType y2)
	{
		return -RADTODEG * std::atan2(y2 - y1, x2 - x1);
	}

	RealType point_distance_3d(RealType x1, RealType y1, RealType z1, RealType x2, RealType y2, RealType z2)
	{
		return std::sqrt(std::pow(x2 - x1, 2.0) + std::pow(y2 - y1, 2.0) + std::pow(z2 - z1, 2.0));
	}

	RealType point_distance(RealType x1, RealType y1, RealType x2, RealType y2)
	{
		return std::sqrt(std::pow(x2 - x1, 2.0) + std::pow(y2 - y1, 2.0));
	}

	BoolType point_in_triangle(RealType px, RealType py, RealType x1, RealType y1, RealType x2, RealType y2, RealType x3, RealType y3)
	{
		auto area = [](RealType x1, RealType y1, RealType x2, RealType y2, RealType x3, RealType y3)
		{
			return std::abs((x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2)) / 2.0);
		};

		RealType A = area(x1, y1, x2, y2, x3, y3);
		RealType A1 = area(px, py, x2, y2, x3, y3);
		RealType A2 = area(x1, y1, px, py, x3, y3);
		RealType A3 = area(x1, y1, x2, y2, px, py);
		RealType eps = 1e-4;
		return (std::abs(A - (A1 + A2 + A3)) < eps);
	}

	RealType power(RealType rl, RealType exp)
	{
		return std::pow(rl, exp);
	}

	RealType radtodeg(RealType rl)
	{
		return RADTODEG * rl;
	}

	RealType round(RealType rl)
	{
		return std::round(rl);
	}

	RealType sign(RealType rl)
	{
		if (rl > 0.0)
			return 1.0;
		if (rl < 0.0)
			return -1.0;
		return 0.0;
	}

	RealType sin(RealType rl)
	{
		return std::sin(rl);
	}

	RealType sqr(RealType rl)
	{
		return rl * rl;
	}

	RealType sqrt(RealType rl)
	{
		return std::sqrt(rl);
	}
	
	RealType tan(RealType rl)
	{
		return std::tan(rl);
	}
}
