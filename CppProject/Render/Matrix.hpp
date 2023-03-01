#pragma once
#include "Common.hpp"

namespace CppProject
{
	struct ArrType;
	struct VecType;

	// 4x4 GPU column-major matrix.
	struct Matrix
	{
		Matrix() {};
		Matrix(RealType m0, RealType m4, RealType m8, RealType m12,
			   RealType m1, RealType m5, RealType m9, RealType m13,
			   RealType m2, RealType m6, RealType m10, RealType m14,
			   RealType m3, RealType m7, RealType m11, RealType m15);
		Matrix(const ArrType& arr);
		Matrix(const Matrix& other);

		BoolType operator==(const Matrix& other) const; // mat == otherMat
		BoolType operator!=(const Matrix& other) const { return !(*this == other); }; // mat != otherMat
		Matrix& operator=(const Matrix& other); // mat = otherMat
		Matrix& operator=(const ArrType& other); // mat = array
		Matrix operator*(const Matrix& other) const; // mat * mat
		Matrix operator*=(const Matrix& other) { *this = *this * other; return *this; }; // mat *= mat
		VecType operator*(const VecType& vec) const; // mat * vec

		void SetToIdentity();
		Matrix GetInversed() const;
		Matrix GetTransposed() const;
		VecType GetScale() const;
		void Copy(float* dst) const;

		static Matrix Identity();
		static Matrix Perspective(RealType fov, RealType ratio, RealType zNear, RealType zFar);
		static Matrix Ortho(RealType left, RealType right, RealType bottom, RealType top, RealType zNear, RealType zFar);
		static Matrix LookAt(const VecType& eye, const VecType& at, const VecType& up);
		static Matrix Translation(RealType x, RealType y, RealType z);
		static Matrix Translation(const VecType& vec);
		static Matrix Rotation(VecType axis, RealType angle);
		static Matrix Rotation(RealType pitch, RealType roll, RealType yaw);
		static Matrix Rotation(const VecType& angles);
		static Matrix Scale(RealType x, RealType y, RealType z);
		static Matrix Scale(const VecType& vec);

		RealType m[16];
	};
}