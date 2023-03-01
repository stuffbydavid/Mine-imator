#include "VarType.hpp"

namespace CppProject
{
	BoolType VarType::operator==(const StringType& str) const // var == string
	{
		if (!IsString())
			return false;

		return (Str() == str);
	}

	BoolType VarType::operator>(const StringType& str) const // var > string
	{
		// For hash/map support
		if (!IsString())
			return !IsAnyReal(); // reals are < string

		return Str() > str;
	}

	BoolType VarType::operator<(const StringType& str) const // var < string
	{
		// For hash/map support
		if (!IsString())
			return IsAnyReal(); // reals are < string

		return Str() < str;
	}

	void VarType::operator+=(const StringType& str) // var += string
	{
		if (!IsString())
		{
			WARNING("Variant += String: Invalid type " + TypeName(type));
			return;
		}

		Str() += str;
	}
}