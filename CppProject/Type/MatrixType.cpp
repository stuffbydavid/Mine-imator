#include "VarType.hpp"

#include "Generated/Scripts.hpp"
#include "Render/Matrix.hpp"

namespace CppProject
{
	MatrixType::~MatrixType()
	{
		FreeData();
	}

	MatrixType::MatrixType(const Matrix& mat)
	{
		matrix = mat;
	}

	MatrixType::MatrixType(const ArrType& arr)
	{
		matrix = arr;
	}

	MatrixType& MatrixType::operator=(const MatrixType& other)
	{
		matrix = other.matrix;
		deleteArrayAndReset(mRef);
		return *this;
	}

	RealType& MatrixType::Real(IntType i)
	{
	#if DEBUG_MODE
		if (i < 0 || i > 15)
			FATAL("MatrixType: Real() with index outside of range: " + NumStr(i));
	#endif
		return matrix.m[i];
	}

	VarType& MatrixType::operator[](IntType i)
	{
	#if DEBUG_MODE
		if (i < 0 || i > 15)
			FATAL("MatrixType: [] with index outside of range: " + NumStr(i));
	#endif
		CreateRef();
		return mRef[i];
	}

	VarType MatrixType::Value(IntType i) const
	{
	#if DEBUG_MODE
		if (i < 0 || i > 15)
			FATAL("MatrixType: Value() const with index outside of range: " + NumStr(i));
	#endif
		return matrix.m[i];
	}

	MatrixType::operator ArrType() const
	{
		ArrType arr;
		arr.vec.Alloc(16);
		for (IntType i = 0; i < 16; i++)
			arr.vec.Append(matrix.m[i]);

		return arr;
	}

	MatrixType::operator Matrix() const
	{
		return matrix;
	}

	void MatrixType::CreateRef()
	{
		if (mRef)
			return;

		// Allocate VarType reference to Matrix elements
		// This is slow and Real() is preferred where possible
		mRef = new VarType[16];
		for (int j = 0; j < 16; j++)
			mRef[j].SetVar(VarType::CreateRef(matrix.m[j]), false);
	}
	
	void MatrixType::FreeData()
	{
		deleteArrayAndReset(mRef);
	}

	MatrixType matrix_create(VecType pos, VecType rot, VecType sca)
	{
		return matrix_build(pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, sca.x, sca.y, sca.z);
	}

	MatrixType matrix_create_ortho(RealType left, RealType right, RealType bottom, RealType top, RealType zNear, RealType zFar)
	{
		return Matrix::Ortho(left, right, bottom, top, zNear, zFar);
	}

	MatrixType matrix_inverse(MatrixType mat)
	{
		return mat.matrix.GetInversed();
	}

	VecType matrix_position(MatrixType mat)
	{
		return { mat.matrix.m[MAT_X], mat.matrix.m[MAT_Y], mat.matrix.m[MAT_Z] };
	}

	void matrix_remove_rotation(VarType ref)
	{
		if (ref.IsMatrix())
		{
			Matrix& glMat = ref.Mat().matrix;
			VecType sca = glMat.GetScale();
			glMat.m[0] = sca.x;
			glMat.m[1] = 0.0;
			glMat.m[2] = 0.0;
			glMat.m[4] = 0.0;
			glMat.m[5] = sca.y;
			glMat.m[6] = 0.0;
			glMat.m[8] = 0.0;
			glMat.m[9] = 0.0;
			glMat.m[10] = sca.z;
		}
		else if (ref.IsArray())
		{
			ArrType& arr = ref.Arr();
			VecType sca = Matrix(arr).GetScale();
			arr[0] = sca.x;
			arr[1] = 0.0;
			arr[2] = 0.0;
			arr[4] = 0.0;
			arr[5] = sca.y;
			arr[6] = 0.0;
			arr[8] = 0.0;
			arr[9] = 0.0;
			arr[10] = sca.z;
		}
		else
			WARNING("Invalid input");
	}

	void matrix_remove_scale(VarType ref)
	{
		if (ref.IsMatrix())
		{
			Matrix& glMat = ref.Mat().matrix;
			VecType sca = glMat.GetScale();
			glMat.m[0] /= sca.x;
			glMat.m[1] /= sca.x;
			glMat.m[2] /= sca.x;
			glMat.m[4] /= sca.y;
			glMat.m[5] /= sca.y;
			glMat.m[6] /= sca.y;
			glMat.m[8] /= sca.z;
			glMat.m[9] /= sca.z;
			glMat.m[10] /= sca.z;
		}
		else if (ref.IsArray())
		{
			ArrType& arr = ref.Arr();
			VecType sca = Matrix(arr).GetScale();
			arr[0] /= sca.x;
			arr[1] /= sca.x;
			arr[2] /= sca.x;
			arr[4] /= sca.y;
			arr[5] /= sca.y;
			arr[6] /= sca.y;
			arr[8] /= sca.z;
			arr[9] /= sca.z;
			arr[10] /= sca.z;
		}
		else
			WARNING("Invalid input");
	}

	MatrixType matrix_transpose(MatrixType mat)
	{
		return mat.matrix.GetTransposed();
	}
}