#include "VarType.hpp"

namespace CppProject
{
	BoolType VarType::operator==(RealType rl) const // var == real
	{
		if (IsUndefined() || IsString() || IsContainer())
			return false;

		return VarGetReal(*this) == rl;
	}

	BoolType VarType::operator>(RealType rl) const // var > real
	{
		// For hash/map support
		if (IsString())
			return true; // strings are > real

		return VarGetReal(*this) > rl;
	}

	BoolType VarType::operator<(RealType rl) const // var < real
	{
		// For hash/map support
		if (IsString())
			return false; // strings are > real

		return VarGetReal(*this) < rl;
	}

	void VarType::operator+=(RealType rl) // var += real
	{
		switch (type)
		{
			case REAL_t: Real() += rl; break;
			case INTEGER_t: SetReal(Int() + rl); break; // Convert to real
			case BOOLEAN_t: SetReal(ToInt() + rl); break; // Convert to real
			default:
				WARNING("Variant += Real: Invalid left type " + TypeName(type));
		}
	}

	void VarType::operator*=(RealType rl) // var *= real
	{
		switch (type)
		{
			case REAL_t: Real() *= rl; break;
			case INTEGER_t: SetReal(Int() * rl); break; // Convert to real
			case BOOLEAN_t: SetReal(ToInt() * rl); break; // Convert to real
			default:
				WARNING("Variant *= Real: Invalid left type " + TypeName(type));
		}
	}

	VarType VarType::operator/(RealType rl) const // var / real
	{
		return VarGetReal(*this) / rl;
	}

	void VarType::operator/=(RealType rl) // var /= real
	{
		if (rl == 0.0) // Divide by 0
		{
			WARNING("Variant / Real: Division by 0.");
			return;
		}

		switch (type)
		{
			case REAL_t: Real() /= rl; break;
			case INTEGER_t: SetReal(Int() / rl); break; // Convert to real
			case BOOLEAN_t: SetReal(ToInt() / rl); break; // Convert to real
			default:
				WARNING("Variant /= Real: Invalid left type " + TypeName(type));
		}
	}

	VarType operator/(RealType rl, const VarType& v) // real / var
	{
		return rl / VarGetReal(v);
	}
}