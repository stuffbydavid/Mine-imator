#pragma once
#include "Common.hpp"
#include "FastVector.hpp"
#include "VarType.hpp"

namespace CppProject
{
	// An array that can store any amount of any type in heap memory.
	// Attempting to read/write outside the bounds will resize the array.
	struct ArrType
	{
		ArrType() {}
		ArrType(const ArrType& other) { *this = other; };
		~ArrType();

		ArrType& operator=(const ArrType&); // arr = otherArr
		VarType& operator[](IntType); // arr[i] = value
		BoolType operator==(const ArrType& arr) const; // arr == otherArr

		VarType Value(IntType index) const;
		void Append(const VarType& value) { vec.Append(value); }
		void Append(const ArrType& arr, IntType startIndex);
		IntType Size() const { return vec.Size(); }
		IntType Find(const VarType& value) const;

		static ArrType From(VarArgs);
		void Debug() const;

		FastVector<VarType> vec;
	};
}