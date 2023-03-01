#include "VarType.hpp"
#include "VecType.hpp"
#include "MatrixType.hpp"
#include "ArrType.hpp"

namespace CppProject
{
	VarType VarArgs::outOfBounds;

	VarType::VarType(const Type& type)
	{
		// Assign empty value
		switch (type)
		{
			case UNDEFINED_t: SetUndefined(); break;
			case REAL_t: SetReal(); break;
			case INTEGER_t: SetInt(); break;
			case BOOLEAN_t: SetBool(); break;
			case STRING_t: SetStr(); break;
			case VECTOR_t: SetVec(VecType()); break;
			case MATRIX_t: SetMat(MatrixType()); break;
			case ARRAY_t: SetArr(ArrType()); break;
		}
	}

	VarType::~VarType()
	{
		FreeData();
	}

	VarType& VarType::operator[](IntType index) // .. = var[i], var[i] = ..
	{
		if (!IsContainer()) // Convert to array if needed
			SetArr(ArrType());

		switch (type)
		{
			case VECTOR_t:
				if (index > 4) // Convert to array
					return Arr()[index];
				else
					return Vec()[index];
			case MATRIX_t: return Mat()[index];
			case ARRAY_t: return Arr()[index];
		}

		return *this;
	}

	VarType VarType::operator-() const // -var
	{
		switch (type)
		{
			case UNDEFINED_t: return 0;
			case BOOLEAN_t: return Bool() ? -1 : 1;
			case REAL_t: return -Real();
			case INTEGER_t: return -Int();
			default:
				WARNING("-Variant: Invalid type " + TypeName(type));
		}
		return 0;
	}

	BoolType VarType::operator==(const ArrType& arr) const // var == array
	{
		WARNING("Variant: Unsupported operation Variant == Array");
		return false;
	}

	VarType::operator VecType() const
	{
		return ToVec();
	}

	VarType::operator MatrixType() const
	{
		return ToMat();
	}

	VarType::operator ArrType() const
	{
		return ToArr();
	}

	RealType& VarType::Real()
	{
		if (IsRealRef())
			return *rlRef;
		if (IsVariantRef())
			return vRef->Real();

		if (!IsReal())
			SetReal(ToReal());

		return rl;
	}

	IntType& VarType::Int()
	{
		if (IsVariantRef())
			return vRef->Int();

		if (!IsInt())
			SetInt(ToInt());

		return in;
	}

	BoolType& VarType::Bool()
	{
		if (IsVariantRef())
			return vRef->Bool();

		if (!IsBool())
			SetBool(ToBool());

		return bl;
	}

	StringType& VarType::Str()
	{
		if (IsVariantRef())
			return vRef->Str();

		if (!IsString())
			SetStr(ToStr());

		return str;
	}

	VecType& VarType::Vec()
	{
		if (IsVariantRef())
			return vRef->Vec();

		if (IsArray()) // array->vec
			SetVec(Arr());
		else if (!IsVec()) // non-vec->vec
			SetVec(VecType());

		return *vec;
	}

	MatrixType& VarType::Mat()
	{
		if (IsMatrixRef())
			return *matRef;
		if (IsVariantRef())
			return vRef->Mat();

		if (IsArray()) // array->matrix
			SetMat(Arr());
		else if (!IsMatrix()) // non-mat->mat
			SetMat(MatrixType());

		return *mat;
	}

	ArrType& VarType::Arr()
	{
		if (IsArrayRef())
			return *arrRef;
		if (IsVariantRef())
			return vRef->Arr();

		if (IsVec()) // vec->array
			SetArr(Vec());
		else if (IsMatrix()) // matrix->array
			SetArr(Mat());
		else if (!IsArray()) // non-array->array
			SetArr(ArrType());

		return *arr;
	}

	VarType& VarType::Ref(IntType index)
	{
		switch (type)
		{
			case VECTOR_t: return Vec()[index];
			case MATRIX_t: return Mat()[index];
			case ARRAY_t: return Arr()[index];
			default:
				FATAL("Variant: Ref() on invalid type " + TypeName(type));
		}
		return *this;
	}

	VarType VarType::Value(IntType index) const
	{
		switch (type)
		{
			case VECTOR_t: return Vec().Value(index);
			case MATRIX_t: return Mat().Value(index);
			case ARRAY_t: return Arr().Value(index);
			default:
				FATAL("Variant: Value() const on invalid type " + TypeName(type));
		}
		return *this;
	}

	RealType VarType::Real() const
	{
		if (IsRealRef())
			return *rlRef;
		if (IsVariantRef())
			return vRef->Real();

		if (!IsReal())
			FATAL("Variant: Real() const on non-real");

		return rl;
	}

	IntType VarType::Int() const
	{
		if (IsVariantRef())
			return vRef->Int();

		if (!IsInt())
			FATAL("Variant: Int() const on non-int");

		return in;
	}

	BoolType VarType::Bool() const
	{
		if (IsVariantRef())
			return vRef->Bool();

		if (!IsBool())
			FATAL("Variant: Bool() const on non-bool");

		return bl;
	}

	const StringType& VarType::Str() const
	{
		if (IsVariantRef())
			return vRef->Str();

		if (!IsString())
			FATAL("Variant: Str() const on non-string");

		return str;
	}

	const VecType& VarType::Vec() const
	{
		if (IsVariantRef())
			return vRef->Vec();

		if (!IsVec())
			FATAL("Variant: Vec() const on non-vector");

		return *vec;
	}

	const MatrixType& VarType::Mat() const
	{
		if (IsVariantRef())
			return vRef->Mat();
		if (IsMatrixRef())
			return *matRef;

		if (!IsMatrix())
			FATAL("Variant: Mat() const on non-matrix");

		return *mat;
	}

	const ArrType& VarType::Arr() const
	{
		if (IsArrayRef())
			return *arrRef;
		if (IsVariantRef())
			return vRef->Arr();

		if (!IsArray())
			FATAL("Variant: Arr() const on non-array");

		return *arr;
	}

	RealType VarType::ToReal() const
	{
		switch (lastAssigned)
		{
			case UNDEFINED_t: return 0.0;
			case REAL_t: return rl;
			case REAL_REF_t: return *rlRef;
			case INTEGER_t: return (RealType)in;
			case BOOLEAN_t: return bl ? 1.0 : 0.0;
			case VARIANT_REF_t: return vRef->ToReal();
			default:
				WARNING("Variant: ToReal() invalid type " + TypeName(lastAssigned));
		}
		return 0.0;
	}

	IntType VarType::ToInt() const
	{
		switch (lastAssigned)
		{
			case UNDEFINED_t: return 0;
			case REAL_t: return (IntType)rl;
			case REAL_REF_t: return (IntType)*rlRef;
			case INTEGER_t: return in;
			case BOOLEAN_t: return bl ? 1 : 0;
			case VARIANT_REF_t: return vRef->ToInt();
			default:
				WARNING("Variant: ToInt() invalid type " + TypeName(lastAssigned));
		}
		return 0;
	}

	BoolType VarType::ToBool() const
	{
		switch (lastAssigned)
		{
			case UNDEFINED_t: return false;
			case REAL_t: return rl > 0.0;
			case REAL_REF_t: return *rlRef > 0.0;
			case INTEGER_t: return in > 0;
			case BOOLEAN_t: return bl;
			case VARIANT_REF_t: return vRef->ToBool();
			case STRING_t:
				if (str == "true")
					return true;
				else if (str == "false")
					return false;
			default:
				WARNING("Variant: ToBool() invalid type " + TypeName(lastAssigned));
		}
		return false;
	}

	StringType VarType::ToStr() const
	{
		IntType containerSize = 0;
		switch (lastAssigned)
		{
			case UNDEFINED_t: return "undefined";
			case REAL_t:
			case REAL_REF_t: return NumStr(Real(), 2);
			case INTEGER_t: return NumStr(Int(), 2);
			case BOOLEAN_t: return Bool() ? "1" : "0";
			case STRING_t: return str;
			case VECTOR_t: containerSize = vec->size; break;
			case MATRIX_t:
			case MATRIX_REF_t: containerSize = 16; break;
			case ARRAY_t:
			case ARRAY_REF_t: containerSize = Arr().Size(); break;
			case VARIANT_REF_t: return vRef->ToStr();
		}

		if (containerSize > 0)
		{
			StringType contStr = "";
			for (IntType i = 0; i < containerSize; i++)
				contStr += (i > 0 ? ", " : "") + Value(i).Str();
			return "[ " + contStr + " ]";
		}
		return "";
	}

	VecType VarType::ToVec() const
	{
		switch (lastAssigned)
		{
			case VECTOR_t: return *vec;
			case ARRAY_t: return *arr; // array->vector
			case ARRAY_REF_t: return *arrRef; // array->vector
			case VARIANT_REF_t: return vRef->ToVec();
			default:
				WARNING("Variant: ToVec() invalid type " + TypeName(lastAssigned));
		}

		return VecType();
	}

	MatrixType VarType::ToMat() const
	{
		switch (lastAssigned)
		{
			case MATRIX_t: return *mat;
			case MATRIX_REF_t: return *matRef;
			case ARRAY_t: return *arr; // array->matrix
			case ARRAY_REF_t: return *arrRef; // array->matrix
			case VARIANT_REF_t: return vRef->ToMat();
			default:
				WARNING("Variant: ToMat() invalid type " + TypeName(lastAssigned));
		}

		return MatrixType();
	}

	ArrType VarType::ToArr() const
	{
		switch (lastAssigned)
		{
			case UNDEFINED_t: return ArrType();
			case VECTOR_t: return *vec; // vector->array
			case MATRIX_t: return *mat; // matrix->array
			case MATRIX_REF_t: return *matRef; // matrix->array
			case ARRAY_t: return *arr;
			case ARRAY_REF_t: return *arrRef;
			case VARIANT_REF_t: return vRef->ToArr();
			default:
				WARNING("Variant: ToArr() invalid type " + TypeName(lastAssigned));
		}

		return ArrType();
	}

	void VarType::SetVar(const VarType& var, BoolType copyRefValue)
	{
		switch (var.lastAssigned)
		{
			case UNDEFINED_t: SetUndefined(); break;
			case REAL_t: SetReal(var.rl); break;
			case REAL_REF_t:
			{
				if (copyRefValue)
					SetReal(*var.rlRef);
				else
				{
					rlRef = var.rlRef;
					type = REAL_t;
					lastAssigned = REAL_REF_t;
				}
				break;
			}
			case INTEGER_t: SetInt(var.in); break;
			case BOOLEAN_t: SetBool(var.bl); break;
			case STRING_t: SetStr(var.str); break;
			case VECTOR_t: SetVec(*var.vec); break;
			case MATRIX_t: SetMat(*var.mat); break;
			case MATRIX_REF_t:
			{
				if (copyRefValue)
					SetMat(*var.matRef);
				else
				{
					matRef = var.matRef;
					type = MATRIX_t;
					lastAssigned = MATRIX_REF_t;
				}
				break;
			}
			case ARRAY_t: SetArr(*var.arr); break;
			case ARRAY_REF_t:
			{
				if (copyRefValue)
					SetArr(*var.arrRef);
				else
				{
					arrRef = var.arrRef;
					type = ARRAY_t;
					lastAssigned = ARRAY_REF_t;
				}
				break;
			}
			case VARIANT_REF_t:
			{
				if (copyRefValue)
					SetVar(*var.vRef, true);
				else
				{
					vRef = var.vRef;
					type = var.type;
					lastAssigned = VARIANT_REF_t;
				}
				break;
			}
		}
	}

	void VarType::SetUndefined()
	{
		FreeData();
		type = lastAssigned = UNDEFINED_t;
	}

	void VarType::SetReal(RealType rl)
	{
		if (IsRealRef())
			*rlRef = rl;
		else
		{
			FreeData();
			this->rl = rl;
			type = lastAssigned = REAL_t;
		}
	}

	void VarType::SetInt(IntType in)
	{
		if (IsRealRef())
			*rlRef = in;
		else
		{
			FreeData();
			this->in = in;
			type = lastAssigned = INTEGER_t;
		}
	}

	void VarType::SetBool(BoolType bl)
	{
		if (IsRealRef())
			*rlRef = bl ? 1.0 : 0.0;
		else
		{
			FreeData();
			this->bl = bl;
			type = lastAssigned = BOOLEAN_t;
		}
	}

	void VarType::SetStr(const StringType& str)
	{
		if (lastAssigned != STRING_t)
		{
			FreeData();
			memset(&this->str, 0, sizeof(StringType));
		}
		this->str = str;
		type = lastAssigned = STRING_t;
	}

	void VarType::SetVec(const VecType& vec)
	{
		if (lastAssigned != VECTOR_t)
		{
			FreeData();
			this->vec = new VecType(vec);
		}
		else
			*this->vec = vec;
		type = lastAssigned = VECTOR_t;
	}

	void VarType::SetMat(const MatrixType& mat)
	{
		if (lastAssigned != MATRIX_t)
		{
			FreeData();
			this->mat = new MatrixType(mat);
		}
		else
			*this->mat = mat;
		type = lastAssigned = MATRIX_t;
	}

	void VarType::SetArr(const ArrType& arr)
	{
		if (lastAssigned != ARRAY_t)
		{
			FreeData();
			this->arr = new ArrType(arr);
		}
		else
			*this->arr = arr;
		type = lastAssigned = ARRAY_t;
	}

	VarType VarType::CreateRef(RealType& rl)
	{
		VarType v;
		v.rlRef = &rl;
		v.type = REAL_t;
		v.lastAssigned = REAL_REF_t;
		return v;
	}

	VarType VarType::CreateRef(MatrixType& mat)
	{
		VarType v;
		v.matRef = &mat;
		v.type = MATRIX_t;
		v.lastAssigned = MATRIX_REF_t;
		return v;
	}

	VarType VarType::CreateRef(ArrType& arr)
	{
		VarType v;
		v.arrRef = &arr;
		v.type = ARRAY_t;
		v.lastAssigned = ARRAY_REF_t;
		return v;
	}

	VarType VarType::CreateRef(VarType& var)
	{
		VarType v;
		v.vRef = &var;
		v.type = var.type;
		v.lastAssigned = VARIANT_REF_t;
		return v;
	}

	void VarType::FreeData()
	{
		switch (lastAssigned)
		{
			case STRING_t: str.Clear(); break;
			case VECTOR_t: delete vec; break;
			case MATRIX_t: delete mat; break;
			case ARRAY_t: delete arr; break;
		}
	}

	void VarType::Debug() const
	{
		if (IsArray())
			Arr().Debug();
	}

	const VarType& VarArgs::Value(IntType index) const
	{
		if (offset + index >= (IntType)args.size())
			return outOfBounds;

		return *(args.begin() + offset + index);
	}

	IntType VarArgs::Find(const VarType& value) const
	{
		IntType index = 0;
		for (const VarType& arg : args)
		{
			if (arg == value && index >= offset)
				return index - offset;
			index++;
		}
		return -1;
	}
}