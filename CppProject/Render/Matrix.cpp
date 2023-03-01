#include "Matrix.hpp"

#include "Type/VarType.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	Matrix::Matrix(RealType m0, RealType m4, RealType m8, RealType m12,
				   RealType m1, RealType m5, RealType m9, RealType m13,
				   RealType m2, RealType m6, RealType m10, RealType m14,
				   RealType m3, RealType m7, RealType m11, RealType m15)
	{
		m[0] = m0; m[4] = m4; m[8] = m8; m[12] = m12;
		m[1] = m1; m[5] = m5; m[9] = m9; m[13] = m13;
		m[2] = m2; m[6] = m6; m[10] = m10; m[14] = m14;
		m[3] = m3; m[7] = m7; m[11] = m11; m[15] = m15;
	}

	Matrix::Matrix(const ArrType& arr)
	{
		if (arr.Size() != 16)
			FATAL("MatrixType: Invalid array with size " + NumStr(arr.Size()));

		for (IntType i = 0; i < 16; i++)
			m[i] = arr.Value(i).Real();
	}

	Matrix::Matrix(const Matrix& other)
	{
		memcpy(&m, &other.m, 16 * sizeof(RealType));
	}

	BoolType Matrix::operator==(const Matrix& other) const
	{
		for (IntType i = 0; i < 16; i++)
			if (m[i] != other.m[i])
				return false;

		return true;
	}

	Matrix& Matrix::operator=(const Matrix& other)
	{
		memcpy(&m, &other.m, 16 * sizeof(RealType));
		return *this;
	}

	Matrix& Matrix::operator=(const ArrType& arr)
	{
		if (arr.Size() != 16)
			FATAL("MatrixType: Invalid array with size " + NumStr(arr.Size()));

		for (IntType i = 0; i < 16; i++)
			m[i] = arr.Value(i).Real();

		return *this;
	}

	Matrix Matrix::operator*(const Matrix& other) const
	{
		Matrix p;
		for (IntType i = 0; i < 4; i++)
		{
			for (IntType j = 0; j < 4; j++)
			{
				p.m[i * 4 + j] = 0.0;

				for (IntType k = 0; k < 4; k++)
					p.m[i * 4 + j] += m[i * 4 + k] * other.m[k * 4 + j];
			}
		}
		return p;
	}

	VecType Matrix::operator*(const VecType& vec) const
	{
		if (vec.size == 4) // 4D
			return {
				m[0] * vec.x + m[4] * vec.y + m[8] * vec.z + m[12] * vec.w,
				m[1] * vec.x + m[5] * vec.y + m[9] * vec.z + m[13] * vec.w,
				m[2] * vec.x + m[6] * vec.y + m[10] * vec.z + m[14] * vec.w,
				m[3] * vec.x + m[7] * vec.y + m[11] * vec.z + m[15] * vec.w
			};
		else // 3D
			return {
				m[0] * vec.x + m[4] * vec.y + m[8] * vec.z,
				m[1] * vec.x + m[5] * vec.y + m[9] * vec.z,
				m[2] * vec.x + m[6] * vec.y + m[10] * vec.z
			};
	}

	void Matrix::SetToIdentity()
	{
		m[0] = 1.0; m[4] = 0.0; m[8] = 0.0; m[12] = 0.0;
		m[1] = 0.0; m[5] = 1.0; m[9] = 0.0; m[13] = 0.0;
		m[2] = 0.0; m[6] = 0.0; m[10] = 1.0; m[14] = 0.0;
		m[3] = 0.0; m[7] = 0.0; m[11] = 0.0; m[15] = 1.0;
	}

	Matrix Matrix::GetInversed() const
	{
		Matrix inv = {
			 m[5] * m[10] * m[15] - m[5] * m[11] * m[14] - m[9] * m[6] * m[15] + m[9] * m[7] * m[14] + m[13] * m[6] * m[11] - m[13] * m[7] * m[10],
			-m[4] * m[10] * m[15] + m[4] * m[11] * m[14] + m[8] * m[6] * m[15] - m[8] * m[7] * m[14] - m[12] * m[6] * m[11] + m[12] * m[7] * m[10],
			 m[4] * m[9] * m[15] - m[4] * m[11] * m[13] - m[8] * m[5] * m[15] + m[8] * m[7] * m[13] + m[12] * m[5] * m[11] - m[12] * m[7] * m[9],
			-m[4] * m[9] * m[14] + m[4] * m[10] * m[13] + m[8] * m[5] * m[14] - m[8] * m[6] * m[13] - m[12] * m[5] * m[10] + m[12] * m[6] * m[9],

			-m[1] * m[10] * m[15] + m[1] * m[11] * m[14] + m[9] * m[2] * m[15] - m[9] * m[3] * m[14] - m[13] * m[2] * m[11] + m[13] * m[3] * m[10],
			 m[0] * m[10] * m[15] - m[0] * m[11] * m[14] - m[8] * m[2] * m[15] + m[8] * m[3] * m[14] + m[12] * m[2] * m[11] - m[12] * m[3] * m[10],
			-m[0] * m[9] * m[15] + m[0] * m[11] * m[13] + m[8] * m[1] * m[15] - m[8] * m[3] * m[13] - m[12] * m[1] * m[11] + m[12] * m[3] * m[9],
			 m[0] * m[9] * m[14] - m[0] * m[10] * m[13] - m[8] * m[1] * m[14] + m[8] * m[2] * m[13] + m[12] * m[1] * m[10] - m[12] * m[2] * m[9],

			 m[1] * m[6] * m[15] - m[1] * m[7] * m[14] - m[5] * m[2] * m[15] + m[5] * m[3] * m[14] + m[13] * m[2] * m[7] - m[13] * m[3] * m[6],
			-m[0] * m[6] * m[15] + m[0] * m[7] * m[14] + m[4] * m[2] * m[15] - m[4] * m[3] * m[14] - m[12] * m[2] * m[7] + m[12] * m[3] * m[6],
			 m[0] * m[5] * m[15] - m[0] * m[7] * m[13] - m[4] * m[1] * m[15] + m[4] * m[3] * m[13] + m[12] * m[1] * m[7] - m[12] * m[3] * m[5],
			-m[0] * m[5] * m[14] + m[0] * m[6] * m[13] + m[4] * m[1] * m[14] - m[4] * m[2] * m[13] - m[12] * m[1] * m[6] + m[12] * m[2] * m[5],

			-m[1] * m[6] * m[11] + m[1] * m[7] * m[10] + m[5] * m[2] * m[11] - m[5] * m[3] * m[10] - m[9] * m[2] * m[7] + m[9] * m[3] * m[6],
			 m[0] * m[6] * m[11] - m[0] * m[7] * m[10] - m[4] * m[2] * m[11] + m[4] * m[3] * m[10] + m[8] * m[2] * m[7] - m[8] * m[3] * m[6],
			-m[0] * m[5] * m[11] + m[0] * m[7] * m[9] + m[4] * m[1] * m[11] - m[4] * m[3] * m[9] - m[8] * m[1] * m[7] + m[8] * m[3] * m[5],
			 m[0] * m[5] * m[10] - m[0] * m[6] * m[9] - m[4] * m[1] * m[10] + m[4] * m[2] * m[9] + m[8] * m[1] * m[6] - m[8] * m[2] * m[5]
		};

		RealType det = m[0] * inv.m[0] + m[1] * inv.m[4] + m[2] * inv.m[8] + m[3] * inv.m[12];
		if (det == 0.0)
			return Matrix();

		RealType invDet = 1.0 / det;
		for (IntType i = 0; i < 16; i++)
			inv.m[i] *= invDet;

		return inv;
	}

	Matrix Matrix::GetTransposed() const
	{
		Matrix t;
		for (IntType i = 0; i < 4; i++)
			for (IntType j = 0; j < 4; j++)
				t.m[i * 4 + j] = m[j * 4 + i];
		return t;
	}

	VecType Matrix::GetScale() const
	{
		return VecType(
			sqrtf(m[0] * m[0] + m[1] * m[1] + m[2] * m[2]),
			sqrtf(m[4] * m[4] + m[5] * m[5] + m[6] * m[6]),
			sqrtf(m[8] * m[8] + m[9] * m[9] + m[10] * m[10])
		);
	}

	void Matrix::Copy(float* dst) const
	{
		for (IntType i = 0; i < 16; i++)
			dst[i] = m[i];
	}

	Matrix Matrix::Identity()
	{
		Matrix i;
		i.SetToIdentity();
		return i;
	}

	Matrix Matrix::Perspective(RealType fov, RealType ratio, RealType zNear, RealType zFar)
	{
		RealType iFov = 1.0 / tan((fov / 2.0) * DEGTORAD);
		return {
			iFov / ratio, 0.0, 0.0, 0.0,
			0.0, iFov, 0.0, 0.0,
			0.0, 0.0, zFar / (zFar - zNear), -zNear * zFar / (zFar - zNear),
			0.0, 0.0, 1.0, 0.0
		};
	}
	
	Matrix Matrix::Ortho(RealType left, RealType right, RealType bottom, RealType top, RealType zNear, RealType zFar)
	{
		return {
			2.0 / (right - left), 0.0, 0.0, -(right + left) / (right - left),
			0.0, 2.0 / (top - bottom), 0.0, -(top + bottom) / (top - bottom),
			0.0, 0.0, -2.0 / (zFar - zNear), -(zFar + zNear) / (zFar - zNear),
			0.0, 0.0, 0.0, 1.0
		};
	}

	Matrix Matrix::LookAt(const VecType& eye, const VecType& at, const VecType& up)
	{
		VecType look = VecType(at - eye).GetNormalized();
		VecType side = VecType::CrossProduct(up, look).GetNormalized();
		VecType newUp = VecType::CrossProduct(look, side);

		return Matrix(
				   side.x, side.y, side.z, -VecType::DotProduct(side, eye),
				   newUp.x, newUp.y, newUp.z, -VecType::DotProduct(newUp, eye),
				   look.x, look.y, look.z, -VecType::DotProduct(look, eye),
				   0.0, 0.0, 0.0, 1.0
			   );
	}

	Matrix Matrix::Translation(RealType x, RealType y, RealType z)
	{
		return {
			1.0, 0.0, 0.0, x,
			0.0, 1.0, 0.0, y,
			0.0, 0.0, 1.0, z,
			0.0, 0.0, 0.0, 1.0
		};
	}

	Matrix Matrix::Translation(const VecType& vec)
	{
		return Translation(vec.x, vec.y, vec.z);
	}

	Matrix Matrix::Rotation(VecType axis, RealType angle)
	{
		RealType s = sin(angle * DEGTORAD);
		RealType c = cos(angle * DEGTORAD);
		RealType x = axis.x;
		RealType y = axis.y;
		RealType z = axis.z;
		return {
			x * x + (1.0 - x * x) * c, x * y * (1.0 - c) - z * s, x * z * (1.0 - c) + y * s, 0.0,
			x * y * (1.0 - c) + z * s, y * y + (1.0 - y * y) * c, y * z * (1.0 - c) - x * s, 0.0,
			x * z * (1.0 - c) - y * s, y * z * (1.0 - c) + x * s, z * z + (1.0 - z * z) * c, 0.0,
			0.0, 0.0, 0.0, 1.0
		};
	}

	Matrix Matrix::Rotation(RealType pitch, RealType roll, RealType yaw)
	{
		return Rotation({ 0, 0, 1 }, yaw) *
			   Rotation({ 1, 0, 0 }, pitch) *
			   Rotation({ 0, 1, 0 }, roll);
	}

	Matrix Matrix::Rotation(const VecType& angles)
	{
		return Rotation(angles.x, angles.y, angles.z);
	}

	Matrix Matrix::Scale(RealType x, RealType y, RealType z)
	{
		return {
			x, 0.0, 0.0, 0.0,
			0.0, y, 0.0, 0.0,
			0.0, 0.0, z, 0.0,
			0.0, 0.0, 0.0, 1.0
		};
	}

	Matrix Matrix::Scale(const VecType& vec)
	{
		return Scale(vec.x, vec.y, vec.z);
	}
}