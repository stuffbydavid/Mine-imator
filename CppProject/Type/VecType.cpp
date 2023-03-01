#include "VarType.hpp"

#include "Generated/Scripts.hpp"
#include "Render/Matrix.hpp"

#include <QtMath>

namespace CppProject
{
	FastVector<VecType*> VecType::refList;

	VecType::~VecType()
	{
		FreeData();
	}

	VecType::VecType(const VecType& vec)
	{
		*this = vec;
	}

	VecType::VecType(const ArrType& arr)
	{
		size = std::clamp(arr.Size(), IntType(2), IntType(4));
		z = w = 0.0;
		for (IntType i = 0; i < size; i++)
			*(&x + i) = arr.Value(i);
	}

	VecType VecType::operator-() const
	{
		return { -x, -y, -z, -w };
	}

	VecType& VecType::operator=(const VecType& vec)
	{
		x = vec.x;
		y = vec.y;
		z = vec.z;
		w = vec.w;
		size = vec.size;
		return *this;
	}

	VecType VecType::operator+(const VecType& vec) const
	{
		return { x + vec.x, y + vec.y, z + vec.z, w + vec.w };
	}

	VecType VecType::operator-(const VecType& vec) const
	{
		return { x - vec.x, y - vec.y, z - vec.z, w - vec.w };
	}

	VecType VecType::operator*(RealType rl) const
	{
		return { x * rl, y * rl, z * rl, w * rl };
	}

	VecType VecType::operator/(RealType rl) const
	{
		return { x / rl, y / rl, z / rl, w / rl };
	}

	void VecType::operator+=(const VecType& vec)
	{
		x += vec.x;
		y += vec.y;
		z += vec.z;
		if (size > 3)
			w += vec.w;
	}

	void VecType::operator-=(const VecType& vec)
	{
		x -= vec.x;
		y -= vec.y;
		z -= vec.z;
		if (size > 3)
			w -= vec.w;
	}

	void VecType::operator*=(RealType rl)
	{
		x *= rl;
		y *= rl;
		z *= rl;
		if (size > 3)
			w *= rl;
	}

	void VecType::operator/=(RealType rl)
	{
		x /= rl;
		y /= rl;
		z /= rl;
		if (size > 3)
			w /= rl;
	}

	VecType::operator ArrType() const
	{
		ArrType arr;
		arr.vec.Alloc(size);
		if (size == 2)
			arr.vec = { x, y };
		else if (size == 3)
			arr.vec = { x, y, z };
		else
			arr.vec = { x, y, z, w };
		return arr;
	}

	RealType& VecType::Real(IntType i)
	{
	#if DEBUG_MODE
		if (i < 0 || i >= size)
			FATAL("VecType: Real() with index outside of range: " + NumStr(i));
	#endif
		return *(&x + i);
	}

	VarType& VecType::operator[](IntType i)
	{
	#if DEBUG_MODE
		if (i < 0 || i >= size)
			FATAL("VecType: [] with index outside of range: " + NumStr(i));
	#endif
		CreateRef();
		return ref[i];
	}

	VarType VecType::Value(IntType i) const
	{
		if (i < 0 || i >= size)
			return 0;
		return *(&x + i);
	}

	RealType VecType::GetLength() const
	{
		return sqrtf(x * x + y * y + z * z + w * w);
	}

	VecType VecType::GetNormalized() const
	{
		RealType len = GetLength();
		if (len > 0.0)
			return { x / len, y / len, z / len, w / len };
		return *this;
	}

	RealType VecType::DotProduct(const VecType& v1, const VecType& v2)
	{
		if (v1.size == 3 || v2.size == 3)
			return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z);
		else
			return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w);
	}

	VecType VecType::CrossProduct(const VecType& v1, const VecType& v2)
	{
		return {
			v1.y * v2.z - v1.z * v2.y,
			v1.z * v2.x - v1.x * v2.z,
			v1.x * v2.y - v1.y * v2.x
		};
	}

	void VecType::CreateRef()
	{
		if (ref)
			return;

		// Allocate VarType reference to x/y/z/w reals
		// This is slow and Real() is preferred where possible
		ref = new VarType[size];
		for (IntType j = 0; j < size; j++)
			ref[j].SetVar(VarType::CreateRef(*(&x + j)), false);

		refHeapIndex = refList.Append(this);
	}

	void VecType::FreeData()
	{
		if (!ref)
			return;

		deleteArrayAndReset(ref);
		refList.Remove(refHeapIndex);
	}

	void VecType::CleanHeapData()
	{
		for (IntType i = 0; i < refList.Size(); i++)
			if (VecType* hVec = refList[i])
				hVec->FreeData();
		
		refList.Clear();
	}

	VecType point2D(RealType x, RealType y)
	{
		return { x, y };
	}

	VecType point2D_add(VecType p1, VecType p2)
	{
		return vec2_add(p1, p2);
	}

	VecType point2D_copy(VecType p)
	{
		return p;
	}

	BoolType point2D_equal(VecType p1, VecType p2)
	{
		return (p1.x == p2.x && p1.y == p2.y);
	}

	VecType point2D_mul(VecType p, VarType mul)
	{
		return vec2_mul(p, mul);
	}

	VecType point2D_sub(VecType p1, VecType p2)
	{
		return { p1.x - p2.x, p1.y - p2.y };
	}

	VecType point3D(RealType x, RealType y, RealType z)
	{
		return { x, y, z };
	}

	VecType point3D_add(VecType p1, VecType p2)
	{
		return { p1.x + p2.x, p1.y + p2.y, p1.z + p2.z };
	}

	VecType point3D_angle(VecType p1, VecType p2)
	{
		VecType dir = vec3_sub(p2, p1);
		RealType yaw = qAtan2(dir.x, dir.y);
		RealType pitch = qAtan2(qSqrt(qPow(dir.x, 2.0) + qPow(dir.y, 2.0)), dir.z);

		return { RADTODEG * pitch, 0, RADTODEG * yaw };
	}

	VecType point3D_copy(VecType p)
	{
		return p;
	}

	RealType point3D_distance(VecType p1, VecType p2)
	{
		return vec3_sub(p2, p1).GetLength();
	}

	VecType point3D_mul(VecType p, VarType mul)
	{
		return vec3_mul(p, mul);
	}

	VecType point3D_mul_matrix(VecType p, MatrixType mat)
	{
		VecType pm = mat.matrix * VecType(p.x, p.y, p.z, 1.0);
		return { pm.x, pm.y, pm.z };
	}

	VecType point3D_sub(VecType p1, VecType p2)
	{
		return vec3_sub(p1, p2);
	}

	VecType point4D(RealType x, RealType y, RealType z, RealType w)
	{
		return { x, y, z, w };
	}

	VecType point4D_homogenize(VecType p)
	{
		return vec4_homogenize(p);
	}

	VecType point4D_mul_matrix(VecType p, MatrixType mat)
	{
		return vec4_mul_matrix(p, mat);
	}

	VecType vec2(VarType x, VarType y)
	{
		if (y.IsUndefined())
			return { x, x };
		else
			return { x, y };
	}

	VecType vec2_add(VecType v1, VecType v2)
	{
		return { v1.x + v2.x, v1.y + v2.y };
	}

	VecType vec2_div(VecType v, VarType div)
	{
		if (div.IsVec() || div.IsArray())
		{
			const VecType& v2 = div.Vec();
			return { v.x / v2.x, v.y / v2.y };
		}
		else
		{
			RealType rl = div.ToReal();
			return { v.x / rl, v.y / rl };
		}
	}

	RealType vec2_dot(VecType v1, VecType v2)
	{
		return v1.x * v2.x + v1.y * v2.y;
	}

	RealType vec2_length(VecType v)
	{
		return qSqrt(v.x * v.x + v.y * v.y);
	}

	VecType vec2_mul(VecType v, VarType mul)
	{
		if (mul.IsVec() || mul.IsArray())
		{
			const VecType& v2 = mul.Vec();
			return { v.x * v2.x, v.y * v2.y };
		}
		else
		{
			RealType rl = mul.ToReal();
			return { v.x * rl, v.y * rl };
		}
	}

	VecType vec2_normalize(VecType v)
	{
		RealType len = vec2_length(v);
		return { v.x / len, v.y / len };
	}

	VecType vec3(VarType x, VarType y, VarType z)
	{
		if (y.IsUndefined())
			return { x, x, x };
		else
			return { x, y, z };
	}

	VecType vec3_add(VecType v, VarType add)
	{
		if (add.IsVec() || add.IsArray())
		{
			const VecType& v2 = add.Vec();
			return { v.x + v2.x, v.y + v2.y, v.z + v2.z };
		}
		else
		{
			RealType rl = add.ToReal();
			return { v.x + rl, v.y + rl, v.z + rl };
		}
	}

	VecType vec3_cross(VecType v1, VecType v2)
	{
		return {
			v1.y * v2.z - v1.z * v2.y,
			v1.z * v2.x - v1.x * v2.z,
			v1.x * v2.y - v1.y * v2.x,
		};
	}

	VecType vec3_div(VecType v, VarType div)
	{
		if (div.IsVec() || div.IsArray())
		{
			const VecType& v2 = div.Vec();
			return { v.x / v2.x, v.y / v2.y, v.z / v2.z };
		}
		else
		{
			RealType rl = div.ToReal();
			return { v.x / rl, v.y / rl, v.z / rl };
		}
	}

	RealType vec3_dot(VecType v1, VecType v2)
	{
		return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z);
	}

	BoolType vec3_equals(VecType v1, VecType v2)
	{
		return (std::abs(v1.x - v2.x) < 0.0001 && std::abs(v1.y - v2.y) < 0.0001 && std::abs(v1.z - v2.z) < 0.0001);
	}

	RealType vec3_length(VecType v)
	{
		return std::sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	}

	VecType vec3_mul(VecType v, VarType mul)
	{
		if (mul.IsVec() || mul.IsArray())
		{
			const VecType& v2 = mul.Vec();
			return { v.x * v2.x, v.y * v2.y, v.z * v2.z };
		}
		else
		{
			RealType rl = mul.ToReal();
			return { v.x * rl, v.y * rl, v.z * rl };
		}
	}

	VecType vec3_mul_matrix(VecType v, MatrixType mat)
	{
		return mat.matrix * VecType(v.x, v.y, v.z);
	}

	VecType vec3_normalize(VecType v)
	{
		RealType len = vec3_length(v);
		if (len == 0.0)
			return v;
		return { v.x / len, v.y / len, v.z / len };
	}

	VecType vec3_reflect(VecType v, VecType n)
	{
		return vec3_sub(v, vec3_mul(vec3_mul(n, vec3_dot(v, n)), 2.0));
	}

	VecType vec3_sub(VecType v1, VecType v2)
	{
		return { v1.x - v2.x, v1.y - v2.y, v1.z - v2.z };
	}

	VecType vec4(VarType x, VarType y, VarType z, VarType w)
	{
		if (y.IsUndefined())
			return { x, x, x, x };
		else
			return { x, y, z, w };
	}

	VecType vec4_add(VecType v, VarType add)
	{
		if (add.IsVec() || add.IsArray())
		{
			const VecType& v2 = add.Vec();
			return { v.x + v2.x, v.y + v2.y, v.z + v2.z, v.w + v2.w };
		}
		else
		{
			RealType rl = add.ToReal();
			return { v.x + rl, v.y + rl, v.z + rl, v.w + rl };
		}
	}

	VecType vec4_div(VecType v, VarType div)
	{
		if (div.IsVec() || div.IsArray())
		{
			const VecType& v2 = div.Vec();
			return { v.x / v2.x, v.y / v2.y, v.z / v2.z, v.w / v2.w };
		}
		else
		{
			RealType rl = div.ToReal();
			return { v.x / rl, v.y / rl, v.z / rl, v.w / rl };
		}
	}

	RealType vec4_dot(VecType v1, VecType v2)
	{
		return (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w);
	}

	VecType vec4_floor(VecType v)
	{
		return { (RealType)std::floor(v.x), (RealType)std::floor(v.y), (RealType)std::floor(v.z), (RealType)std::floor(v.w) };
	}

	VecType vec4_homogenize(VecType p)
	{
		return { p.x / p.w, p.y / p.w, p.z / p.w, 0.f };
	}

	VecType vec4_max(VecType v1, VecType v2)
	{
		return {
			std::max(v1.x, v2.x),
			std::max(v1.y, v2.y),
			std::max(v1.z, v2.z),
			std::max(v1.w, v2.w)
		};
	}

	VecType vec4_min(VecType v1, VecType v2)
	{
		return {
			std::min(v1.x, v2.x),
			std::min(v1.y, v2.y),
			std::min(v1.z, v2.z),
			std::min(v1.w, v2.w)
		};
	}

	VecType vec4_mul(VecType v, VarType mul)
	{
		if (mul.IsVec() || mul.IsArray())
		{
			const VecType& v2 = mul.Vec();
			return { v.x * v2.x, v.y * v2.y, v.z * v2.z, v.w * v2.w };
		}
		else
		{
			RealType rl = mul.ToReal();
			return { v.x * rl, v.y * rl, v.z * rl, v.w * rl };
		}
	}

	VecType vec4_mul_matrix(VecType v, MatrixType mat)
	{
		return mat.matrix * v;
	}

	VecType vec4_sub(VecType v, VarType sub)
	{
		if (sub.IsVec() || sub.IsArray())
		{
			const VecType& v2 = sub.Vec();
			return { v.x - v2.x, v.y - v2.y, v.z - v2.z, v.w - v2.w };
		}
		else
		{
			RealType rl = sub.ToReal();
			return { v.x - rl, v.y - rl, v.z - rl, v.w - rl };
		}
	}
}
