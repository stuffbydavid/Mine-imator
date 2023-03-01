#pragma once
#include "ArrType.hpp"
#include "FastVector.hpp"

namespace CppProject
{
	struct VarType;

	// 2D/3D/4D Vector with support for [].
	struct VecType
	{
		VecType() { x = y = z = w = 0.0; }
		~VecType();
		VecType(RealType x, RealType y) : x(x), y(y), z(0.0), w(0.0), size(2) {}
		VecType(RealType x, RealType y, RealType z) : x(x), y(y), z(z), w(0.0), size(3) {}
		VecType(RealType x, RealType y, RealType z, RealType w) : x(x), y(y), z(z), w(w), size(4) {}
		VecType(const VecType& vec); // vec(vec)
		VecType(const ArrType& arr); // vec(arr)

		VecType& operator=(const VecType& v); // vec = otherVec
		VecType operator-() const; // -vec
		VecType operator+(const VecType& v) const; // vec + otherVec
		VecType operator-(const VecType& v) const; // vec - otherVec
		VecType operator*(RealType rl) const; // vec * real
		VecType operator/(RealType rl) const; // vec / real
		void operator+=(const VecType& v); // vec += otherVec
		void operator-=(const VecType& v); // vec -= otherVec
		void operator*=(RealType rl); // vec *= real
		void operator/=(RealType rl); // vec *= real

		RealType& Real(IntType); // vec.Real(i) = ..
		VarType& operator[](IntType); // vec[i] = ..
		VarType Value(IntType) const;

		operator ArrType() const; // arr = vec

		RealType GetLength() const;
		VecType GetNormalized() const;
		static RealType DotProduct(const VecType& v1, const VecType& v2);
		static VecType CrossProduct(const VecType& v1, const VecType& v2);

		void CreateRef();
		void FreeData();
		static void CleanHeapData();

		RealType x, y, z, w;
		VarType* ref = nullptr; // References to x, y, z, w
		IntType refHeapIndex = 0;
		uint8_t size = 4;

		static FastVector<VecType*> refList;
	};
}