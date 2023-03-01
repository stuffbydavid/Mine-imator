#include "VarType.hpp"
#include "ArrType.hpp"

namespace CppProject
{
	BoolType VarType::operator==(const VarType& other) const // var == otherVar
	{
		if (IsUndefined() || other.IsUndefined())
			return (IsUndefined() == other.IsUndefined());

		switch (type)
		{
			case REAL_t: return (Real() == VarGetReal(other));
			case INTEGER_t: return (Int() == VarGetReal(other));
			case BOOLEAN_t:
			{
				if (other.IsBool())
					return (Bool() == other.Bool());
				return (ToInt() == VarGetReal(other));
			}
			case STRING_t: return (Str() == VarGetStr(other));
			case ARRAY_t: return Arr() == VarGetArr(other);
			default:
				WARNING("Variant == Variant: Invalid left type " + TypeName(type));
		}
		return false;
	}

	BoolType VarType::operator>(const VarType& other) const // var > otherVar
	{
		// For map/hash support
		if (IsAnyReal() && !other.IsAnyReal()) // reals are < string
			return false;
		if (IsString() && !other.IsString()) // strings are > real
			return true;

		switch (type)
		{
			case REAL_t: return (Real() > VarGetReal(other));
			case INTEGER_t: return (Int() > VarGetReal(other));
			case BOOLEAN_t: return (ToInt() > VarGetReal(other));
			case STRING_t: return (Str() > VarGetStr(other));
			default:
				WARNING("Variant > Variant: Invalid left type " + TypeName(type));
		}
		return false;
	}

	BoolType VarType::operator>=(const VarType& other) const // var >= otherVar
	{
		switch (type)
		{
			case REAL_t: return (Real() >= VarGetReal(other));
			case INTEGER_t: return (Int() >= VarGetReal(other));
			case BOOLEAN_t: return (ToInt() >= VarGetReal(other));
			case STRING_t: return (Str() >= VarGetStr(other));
			default:
				WARNING("Variant >= Variant: Invalid left type " + TypeName(type));
		}
		return false;
	}

	BoolType VarType::operator<(const VarType& other) const // var < otherVar
	{
		// For map/hash support
		if (IsAnyReal() && !other.IsAnyReal()) // reals are < string
			return true;
		if (IsString() && !other.IsString()) // strings are > real
			return false;

		switch (type)
		{
			case REAL_t: return (Real() < VarGetReal(other));
			case INTEGER_t: return (Int() < VarGetReal(other));
			case BOOLEAN_t: return (ToInt() < VarGetReal(other));
			case STRING_t: return (Str() < VarGetStr(other));
			default:
				WARNING("Variant < Variant: Invalid left type " + TypeName(type));
		}
		return true;
	}

	BoolType VarType::operator<=(const VarType& other) const // var <= otherVar
	{
		switch (type)
		{
			case REAL_t: return (Real() <= VarGetReal(other));
			case INTEGER_t: return (Int() <= VarGetReal(other));
			case BOOLEAN_t: return (ToInt() <= VarGetReal(other));
			case STRING_t: return (Str() <= VarGetStr(other));
			default:
				WARNING("Variant <= Variant: Invalid left type " + TypeName(type));
		}
		return true;
	}

	VarType VarType::operator+(const VarType& other) const // var + otherVar
	{
		switch (type)
		{
			case REAL_t: return Real() + VarGetReal(other);
			case INTEGER_t:
			{
				if (other.IsReal()) // Convert to real
					return ToReal() + other.Real();
				return Int() + VarGetInt(other);
			}
			case BOOLEAN_t:
			{
				if (other.IsReal()) // Convert to real
					return ToReal() + other.Real();
				return ToInt() + VarGetInt(other);
			}
			case STRING_t: return Str() + VarGetStr(other);
			default:
				WARNING("Variant + Variant: Invalid left type " + TypeName(type));
		}
		return *this;
	}

	void VarType::operator+=(const VarType& other) // var += otherVar
	{
		switch (type)
		{
			case REAL_t: Real() += VarGetReal(other); break;
			case INTEGER_t:
			{
				if (other.IsReal()) // Convert to real
				{
					SetReal(Int() + other.Real());
					break;
				}
				Int() += VarGetInt(other);
				break;
			}
			case BOOLEAN_t: // Convert to real
			{
				SetReal(ToInt() + VarGetReal(other));
				break;
			}
			case STRING_t: Str() += VarGetStr(other); break;
			default:
				WARNING("Variant += Variant: Invalid left type " + TypeName(type));
		}
	}

	VarType VarType::operator-(const VarType& other) const // var - otherVar
	{
		switch (type)
		{
			case REAL_t: return Real() - VarGetReal(other);
			case INTEGER_t:
			{
				if (other.IsReal()) // Convert to real
					return ToReal() - other.Real();
				return Int() - VarGetInt(other);
			}
			case BOOLEAN_t:
			{
				if (other.IsReal()) // Convert to real
					return ToReal() - other.Real();
				return ToInt() - VarGetInt(other);
			}
			default:
				WARNING("Variant - Variant: Invalid left type " + TypeName(type));
		}
		return *this;
	}

	void VarType::operator-=(const VarType& other) // var -= otherVar
	{
		switch (type)
		{
			case REAL_t: Real() -= VarGetReal(other); break;
			case INTEGER_t:
			{
				if (other.IsReal()) // Convert to real
				{
					SetReal(Int() - other.Real());
					break;
				}
				Int() -= VarGetInt(other);
				break;
			}
			case BOOLEAN_t: // Convert to real
			{
				SetReal(ToInt() - VarGetReal(other));
				break;
			}
			default:
				WARNING("Variant -= Variant: Invalid left type " + TypeName(type));
		}
	}
}