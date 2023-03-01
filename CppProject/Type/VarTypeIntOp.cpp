#include "VarType.hpp"
#include "Asset/Scope.hpp"

namespace CppProject
{
	BoolType VarType::operator==(IntType in) const // var == int
	{
		if (IsUndefined())
			return in == 0;
		
		if (IsString() || IsContainer())
			return false;

		return VarGetReal(*this) == in;
	}

	BoolType VarType::operator>(IntType in) const // var > int
	{
		// For hash/map support
		if (IsString())
			return true; // strings are > real

		return VarGetReal(*this) > in;
	}

	BoolType VarType::operator<(IntType in) const // var < int
	{
		// For hash/map support
		if (IsString())
			return false; // strings are > real

		return VarGetReal(*this) < in;
	}

	VarType VarType::operator+(IntType in) const // var + int
	{
		if (type == REAL_t)
			return VarGetReal(*this) + in;
		else
			return VarGetInt(*this) + in;
	}

	void VarType::operator+=(IntType in) // var += int
	{
		switch (type)
		{
			case REAL_t: Real() += in; break;
			case INTEGER_t: Int() += in; break;
			case BOOLEAN_t: SetInt(ToInt() + in); break; // Convert to int
			default: SetInt(in); break;
		}
	}

	VarType VarType::operator*(IntType in) const // var * int
	{
		if (type == REAL_t)
			return VarGetReal(*this) * in;
		else
			return VarGetInt(*this) * in;
	}

	void VarType::operator*=(IntType in) // var *= int
	{
		switch (type)
		{
			case REAL_t: Real() *= in; break;
			case INTEGER_t: Int() *= in; break;
			case BOOLEAN_t: SetInt(ToInt() * in); break; // Convert to int
			default:
				WARNING("Variant *= Integer: Invalid left type " + TypeName(type));
		}
	}
}