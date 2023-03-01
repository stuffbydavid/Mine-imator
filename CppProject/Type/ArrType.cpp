#include "ArrType.hpp"

namespace CppProject
{
	ArrType::~ArrType()
	{
		for (IntType i = 0; i < vec.Size(); i++)
			vec[i].FreeData();
	}

	ArrType& ArrType::operator=(const ArrType& other) // arr = otherArr
	{
		if (!vec.Size() && !other.Size())
			return *this;

		for (IntType i = 0; i < vec.Size(); i++)
			vec[i].FreeData();

		vec.Clear();
		vec.Alloc(other.Size());
		for (IntType i = 0; i < other.vec.Size(); i++)
			vec.Append(other.vec.Value(i));

		return *this;
	}

	VarType& ArrType::operator[](IntType index) // .. = arr[i], arr[i] = ..
	{
	#if DEBUG_MODE
		if (index < 0) // Invalid index
			FATAL("ArrType []: Invalid index " + NumStr(index));
	#endif
		IntType sz = Size();
		if (index >= sz) // Resize vector and add reals
		{
			vec.Alloc(index);
			for (IntType i = sz; i <= index; i++)
				vec.Append(0.0);
		}

		return vec[index];
	}

	BoolType ArrType::operator==(const ArrType& other) const // arr == otherArr
	{
		if (vec.Size() != other.vec.Size())
			return false;

		for (IntType i = 0; i < vec.Size(); i++)
			if (vec.Value(i) != other.vec.Value(i))
				return false;

		return true;
	}

	VarType ArrType::Value(IntType index) const
	{
		if (index < 0 || index >= vec.Size()) // Invalid index, undefined
			return VarArgs::outOfBounds;

		return vec.Value(index);
	}

	void ArrType::Append(const ArrType& arr, IntType startIndex)
	{
		vec.Alloc(vec.Size() + arr.Size());
		for (IntType i = startIndex; i < arr.Size(); i++)
			vec.Append(arr.Value(i));
	}

	IntType ArrType::Find(const VarType& value) const
	{
		for (IntType i = 0; i < vec.Size(); i++)
			if (vec.Value(i) == value)
				return i;

		return -1;
	}

	ArrType ArrType::From(VarArgs vArgs)
	{
		ArrType arr;
		arr.vec.Alloc(vArgs.Size());
		for (IntType i = 0; i < vArgs.Size(); i++)
			arr.vec.Append(vArgs[i]);
		return arr;
	}

	void ArrType::Debug() const
	{
		Printer::indent++;
		for (IntType i = 0; i < vec.Size(); i++)
		{
			const VarType& value = vec.Value(i);
			DEBUG(NumStr(i) + ": " + value.ToStr() + " [" + TypeName(value.GetType()) + "]");
			value.Debug();
		}
		Printer::indent--;
	}

	ArrType array(VarArgs args)
	{
		return ArrType::From(args);
	}

	ArrType array_add(VarType arrRef, VarType vals, BoolType merge)
	{
		if (vals.IsArray() && merge)
			arrRef.Arr().Append(vals.Arr(), 0);
		else
			arrRef.Arr().Append(vals);

		return arrRef;
	}

	BoolType array_contains(VarType arrRef, VarType val)
	{
		return (arrRef.Arr().Find(val) > -1);
	}

	ArrType array_copy_1d(VarType var)
	{
		if (var.IsInt())
			return ArrType();
		return var.ToArr();
	}

	ArrType array_copy_2d(ArrType arr)
	{
		ArrType newArr;
		for (IntType i = 0; i < arr.Size(); i++)
			for (IntType j = 0; j < arr[i].Arr().Size(); j++)
				newArr[i][j] = arr[i][j];
		return newArr;
	}
}