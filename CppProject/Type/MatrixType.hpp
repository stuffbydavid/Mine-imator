#pragma once
#include "Render/Matrix.hpp"

namespace CppProject
{
	struct VarType;

	// Wrapper for Matrix with support for [].
	struct MatrixType
	{
		MatrixType() {}
		~MatrixType();
		MatrixType(const Matrix& matrix);
		MatrixType(const MatrixType& other) { *this = other; }
		MatrixType(const ArrType& arr);

		MatrixType& operator=(const MatrixType& other); // mat = otherMat

		RealType& Real(IntType); // .. = mat.Real(i), mat.Real(i) = ..
		VarType& operator[](IntType); // mat[i] = ..
		VarType Value(IntType) const;

		operator ArrType() const;
		operator Matrix() const;

		void CreateRef();
		void FreeData();

		Matrix matrix;
		VarType* mRef = nullptr; // References to matrix values
	};
}