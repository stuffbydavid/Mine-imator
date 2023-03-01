#pragma once
#include "Common.hpp"
#include "StringType.hpp"

// Optimized macros to get the value of a VarType, avoiding copy operations if possible
#define VarGetReal(v) ((v).IsReal() ? (v).Real() : (v).ToReal())
#define VarGetInt(v) ((v).IsInt() ? (v).Int() : (v).ToInt())
#define VarGetBool(v) ((v).IsBool() ? (v).Bool() : (v).ToBool())
#define VarGetStr(v) ((v).IsString() ? (v).Str() : (v).ToStr())
#define VarGetVec(v) ((v).IsVector() ? (v).Vec() : (v).ToVec())
#define VarGetMat(v) ((v).IsMatrix() ? (v).Mat() : (v).ToMat())
#define VarGetArr(v) ((v).IsArray() ? (v).Arr() : (v).ToArr())

namespace CppProject
{
	struct VecType;
	struct MatrixType;
	struct ArrType;

	// A variant type that can store a real, string or array value, keeping track of the last assigned.
	struct VarType
	{
		VarType() {}
		~VarType();
		VarType(const Type& type);

		VarType(const VarType& var) { SetVar(var, false); }
		VarType(RealType rl) { SetReal(rl); }
		VarType(IntType in) { SetInt(in); }
		VarType(int in) { SetInt(in); }
		VarType(BoolType bl) { SetBool(bl); }
		VarType(const StringType& str) { SetStr(str); }
		VarType(const char* str) { SetStr(str); }
		VarType(const VecType& vec) { SetVec(vec); }
		VarType(const MatrixType& vec) { SetMat(vec); }
		VarType(const ArrType& arr) { SetArr(arr); }

		inline VarType& operator=(const VarType& var) { SetVar(var, true); return *this; } // var = otherVar
		inline VarType& operator=(RealType rl) { SetReal(rl); return *this; } // var = real
		inline VarType& operator=(IntType in) { SetInt(in); return *this; } // var = int
		inline VarType& operator=(int in) { SetInt(in); return *this; } // var = int
		inline VarType& operator=(BoolType bl) { SetBool(bl); return *this; }; // var = bool
		inline VarType& operator=(const StringType& str) { SetStr(str); return *this; }; // var = string
		inline VarType& operator=(const char* str) { SetStr(str); return *this; }; // var = string
		inline VarType& operator=(const VecType& vec) { SetVec(vec); return *this; }; // var = vec
		inline VarType& operator=(const MatrixType& mat) { SetMat(mat); return *this; }; // var = matrix
		inline VarType& operator=(const ArrType& arr) { SetArr(arr); return *this; }; // var = array

		VarType& operator[](IntType); // var[i] = ..
		VarType operator-() const; // -var
		inline BoolType operator!() const { return !VarGetBool(*this); } // !var

		BoolType operator==(RealType) const; // var == real
		BoolType operator==(IntType) const; // var == int
		inline BoolType operator==(int in) const { return (*this == (IntType)in); } // var == int
		BoolType operator==(BoolType bl) const { return VarGetBool(*this) == bl; } // var == bool
		BoolType operator==(const StringType& str) const; // var == string
		inline BoolType operator==(const char* str) const { return (*this == StringType(str)); } // var == string
		BoolType operator==(const ArrType&) const; // var == array
		BoolType operator==(const VarType&) const; // var == otherVar

		inline BoolType operator!=(RealType rl) const { return !(*this == rl); } // var != real
		inline BoolType operator!=(IntType in) const { return !(*this == in); } // var != int
		inline BoolType operator!=(int in) const { return !(*this == (IntType)in); } // var != int
		inline BoolType operator!=(BoolType bl) const { return !(*this == bl); } // var != bool
		inline BoolType operator!=(const StringType& str) const { return !(*this == str); } // var != string
		inline BoolType operator!=(const char* str) const { return !(*this == StringType(str)); } // var != string
		inline BoolType operator!=(const ArrType& arr) const { return !(*this == arr); } // var != array
		inline BoolType operator!=(const VarType& v) const { return !(*this == v); } // var != otherVar

		BoolType operator>(RealType) const; // var > real
		BoolType operator>(IntType) const; // var > int
		inline BoolType operator>(int in) const { return (*this > (IntType)in); } ; // var > int
		BoolType operator>(const StringType&) const; // var > string
		BoolType operator>(const VarType&) const; // var > otherVar
		BoolType operator<(RealType) const; // var < real
		BoolType operator<(IntType) const; // var < int
		inline BoolType operator<(int in) const { return (*this < (IntType)in); }; // var < int
		BoolType operator<(const StringType&) const; // var < string
		BoolType operator<(const VarType&) const; // var < otherVar

		inline BoolType operator>=(RealType rl) const { return VarGetReal(*this) >= rl; }; // var >= real
		inline BoolType operator>=(IntType in) const { return VarGetReal(*this) >= in; }; // var >= int
		inline BoolType operator>=(int in) const { return (*this >= (IntType)in); } // var >= int
		BoolType operator>=(const VarType&) const; // var >= otherVar
		inline BoolType operator<=(RealType rl) const { return VarGetReal(*this) <= rl; }; // var <= real
		inline BoolType operator<=(IntType in) const { return VarGetReal(*this) <= in; } // var <= int
		inline BoolType operator<=(int in) const { return (*this <= (IntType)in); } // var <= int
		BoolType operator<=(const VarType&) const; // var <= otherVar
		
		inline VarType operator+(RealType rl) const { return VarGetReal(*this) + rl; } // var + real
		VarType operator+(IntType) const; // var + int
		inline VarType operator+(int in) const { return *this + (IntType)in; } // var + int
		inline VarType operator+(BoolType bl) const { return *this + (bl ? 1 : 0); } // var + bool
		inline StringType operator+(const StringType& str) const { return VarGetStr(*this) + str; }; // var + string
		VarType operator+(const VarType&) const; // var + otherVar
		void operator+=(RealType); // var += real
		void operator+=(IntType); // var += int
		inline void operator+=(int in) { *this += (IntType)in; } // var += int
		inline void operator+=(BoolType bl) { *this += (bl ? 1 : 0); } // var += bool
		void operator+=(const StringType&); // var += string
		void operator+=(const VarType&); // var += otherVar
		inline VarType operator-(RealType rl) const { return *this + (-rl); } // var - real
		inline VarType operator-(IntType in) const { return *this + (-in); } // var - int
		inline VarType operator-(int in) const { return *this + (-(IntType)in); } // var - int
		inline VarType operator-(BoolType bl) const { return *this + (bl ? -1 : 0); } // var + bool
		VarType operator-(const VarType&) const; // var - otherVar
		inline void operator-=(RealType rl) { *this += -rl; } // var -= real
		inline void operator-=(IntType in) { *this += -in; } // var -= int
		inline void operator-=(int in) { *this += -(IntType)in; } // var -= int
		inline void operator-=(BoolType bl) { *this += (bl ? -1 : 0); } // var -= bool
		void operator-=(const VarType&); // var -= otherVar

		inline VarType operator*(RealType rl) const { return VarGetReal(*this) * rl; } // var * real
		VarType operator*(IntType) const; // var * int
		inline VarType operator*(int in) const { return (*this * (IntType)in); } // var * int
		inline VarType operator*(BoolType bl) const { return *this * (bl ? 1 : 0); } // var * bool
		inline VarType operator*(const VarType& v) const { return VarGetReal(*this) * VarGetReal(v); } // var * otherVar
		void operator*=(RealType rl); // var *= real
		void operator*=(IntType in); // var *= int
		inline void operator*=(int in) { *this *= (IntType)in; } // var *= int
		inline void operator*=(const VarType& v) { *this *= VarGetReal(v); } // var *= otherVar
		VarType operator/(RealType) const; // var / real
		inline VarType operator/(IntType in) const { return *this / (RealType)in; } // var / int
		inline VarType operator/(int in) const { return *this / (RealType)in; } // var / int
		inline VarType operator/(const VarType& v) const { return *this / VarGetReal(v); } // var / otherVar
		void operator/=(RealType); // var /= real
		void operator/=(IntType in) { *this /= (RealType)in; } // var /= int
		inline void operator/=(int in) { *this /= (RealType)in; } // var /= int
		inline void operator/=(const VarType& v) { *this /= VarGetReal(v); } // var /= otherVar

		inline VarType operator&(IntType in) const { return VarGetInt(*this) & in; } // var & int
		inline VarType operator|(IntType in) const { return VarGetInt(*this) | in; } // var | int
		inline VarType operator<<(IntType in) const { return VarGetInt(*this) << in; } // var << int
		inline VarType operator>>(IntType in) const { return VarGetInt(*this) >> in; } // var >> int
		inline VarType operator&(int in) const { return VarGetInt(*this) & (IntType)in; } // var & int
		inline VarType operator|(int in) const { return VarGetInt(*this) | (IntType)in; } // var | int
		inline VarType operator<<(int in) const { return VarGetInt(*this) << (IntType)in; }; // var << int
		inline VarType operator>>(int in) const { return VarGetInt(*this) >> (IntType)in; }; // var >> int
		inline VarType& operator++() { *this += 1; return *this; } // ++var
		inline VarType operator++(int) { VarType tmp = *this; *this += 1; return tmp; } // var++
		inline VarType& operator--() { *this -= 1; return *this; } // --var
		inline VarType operator--(int) { VarType tmp = *this; *this -= 1; return tmp; } // var--

		inline operator RealType() const { return ToReal(); } // real = var
		inline operator IntType() const { return ToInt(); } // int = var
		inline operator int() const { return (int)ToInt(); } // int = var
		inline operator BoolType() const { return ToBool(); } // bool = var
		inline operator StringType() const { return ToStr(); } // string = var
		operator VecType() const; // vec = var
		operator MatrixType() const; // matrix = var
		operator ArrType() const; // array = var

		// Value reference
		RealType& Real();
		IntType& Int();
		BoolType& Bool();
		StringType& Str();
		VecType& Vec();
		MatrixType& Mat();
		ArrType& Arr();
		VarType& Var() { return *this; }
		VarType& Ref(IntType index);
		VarType Value(IntType index) const;

		inline operator VecType& () { return Vec(); }
		inline operator MatrixType& () { return Mat(); }
		inline operator ArrType& () { return Arr(); }

		// Const reference
		RealType Real() const;
		IntType Int() const;
		BoolType Bool() const;
		const StringType& Str() const;
		const VecType& Vec() const;
		const MatrixType& Mat() const;
		const ArrType& Arr() const;

		// Convert
		RealType ToReal() const;
		IntType ToInt() const;
		BoolType ToBool() const;
		StringType ToStr() const;
		VecType ToVec() const;
		MatrixType ToMat() const;
		ArrType ToArr() const;

		// Overwrite
		void SetVar(const VarType& arr, BoolType copyRefValue = true);
		void SetUndefined();
		void SetReal(RealType rl = 0.0);
		void SetInt(IntType in = 0);
		void SetBool(BoolType bl = false);
		void SetStr(const StringType& str = StringType());
		void SetVec(const VecType& vec);
		void SetMat(const MatrixType& mat);
		void SetArr(const ArrType& arr);

		// Create reference a value or other variant
		static VarType CreateRef(RealType& rl);
		static VarType CreateRef(MatrixType& mat);
		static VarType CreateRef(ArrType& arr);
		static VarType CreateRef(VarType& var);
		static VarType CreateRef(const VarType& var) { return var; }

		// Type
		inline Type GetType() const { return (Type)type; }
		inline BoolType IsUndefined() const { return (type == UNDEFINED_t); }
		inline BoolType IsAnyReal() const { return (IsReal() || IsInt() || IsBool()); }
		inline BoolType IsReal() const { return (type == REAL_t); }
		inline BoolType IsInt() const { return (type == INTEGER_t); }
		inline BoolType IsBool() const { return (type == BOOLEAN_t); }
		inline BoolType IsString() const { return (type == STRING_t); }
		inline BoolType IsVec() const { return (type == VECTOR_t); }
		inline BoolType IsMatrix() const { return (type == MATRIX_t); }
		inline BoolType IsArray() const { return (type == ARRAY_t); }
		inline BoolType IsContainer() const { return (IsArray() || IsVec() || IsMatrix()); }
		inline BoolType IsRealRef() const { return (lastAssigned == REAL_REF_t); }
		inline BoolType IsMatrixRef() const { return (lastAssigned == MATRIX_REF_t); }
		inline BoolType IsArrayRef() const { return (lastAssigned == ARRAY_REF_t); }
		inline BoolType IsVariantRef() const { return (lastAssigned == VARIANT_REF_t); }

		void FreeData();
		void Debug() const;

	private:
		Type type = UNDEFINED_t;
		Type lastAssigned = UNDEFINED_t;

		// Data
		union
		{
			RealType rl;
			IntType in;
			BoolType bl;
			StringType str;
			ArrType* arr;
			VecType* vec;
			MatrixType* mat;
			RealType* rlRef;
			MatrixType* matRef;
			ArrType* arrRef;
			VarType* vRef;
		};
	};

	// Used for passing variable arguments into functions or new arrays
	struct VarArgs
	{
		VarArgs(const VarArgs& other, IntType offset = 0) : args(other.args), offset(other.offset + offset) {}
		VarArgs(std::initializer_list<VarType> args = {}) : args(args) {}
		const VarType& operator[](IntType index) const { return Value(index); }
		const VarType& Value(IntType index) const;
		IntType Size() { return args.size() - offset; }
		IntType Find(const VarType& value) const;

		std::initializer_list<VarType> args;
		IntType offset = 0;
		static VarType outOfBounds;
	};

	static inline BoolType operator==(RealType rl, const VarType& v) { return (v == rl); } // real == var
	static inline BoolType operator==(IntType in, const VarType& v) { return (v == in); } // int == var
	static inline BoolType operator==(int in, const VarType& v) { return (v == (IntType)in); } // int == var
	static inline BoolType operator==(BoolType bl, const VarType& v) { return (v == bl); } // bool == var
	static inline BoolType operator==(const StringType& str, const VarType& v) { return (v == str); } // string == var
	static inline BoolType operator==(const ArrType& arr, const VarType& v) { return (v == arr); } // array == var
	
	static inline BoolType operator!=(RealType rl, const VarType& v) { return !(v == rl); } // real != var
	static inline BoolType operator!=(IntType in, const VarType& v) { return !(v == in); } // int != var
	static inline BoolType operator!=(int in, const VarType& v) { return !(v == (IntType)in); } // int != var
	static inline BoolType operator!=(BoolType bl, const VarType& v) { return !(v == bl); } // bool != var
	static inline BoolType operator!=(const StringType& str, const VarType& v) { return !(v == str); } // string != var
	static inline BoolType operator!=(const ArrType& arr, const VarType& v) { return !(v == arr); } // array != var
	
	static inline BoolType operator>(RealType rl, const VarType& v) { return (v < rl); } // real > var
	static inline BoolType operator>(IntType in, const VarType& v) { return (v < in); } // int > var
	static inline BoolType operator>(int in, const VarType& v) { return (v < (IntType)in); } // int > var
	static inline BoolType operator>(const StringType& str, const VarType& v) { return (v < str); } // string > var
	static inline BoolType operator<(RealType rl, const VarType& v) { return (v > rl); } // real < var
	static inline BoolType operator<(IntType in, const VarType& v) { return (v > in); } // int < var
	static inline BoolType operator<(int in, const VarType& v) { return (v > (IntType)in); } // int < var
	static inline BoolType operator<(const StringType& str, const VarType& v) { return (v > str); } // int < var
	
	static inline BoolType operator>=(RealType rl, const VarType& v) { return (v <= rl); } // real >= var
	static inline BoolType operator>=(IntType in, const VarType& v) { return (v <= in); } // int >= var
	static inline BoolType operator>=(int in, const VarType& v) { return (v <= (IntType)in); } // int >= var
	static inline BoolType operator<=(RealType rl, const VarType& v) { return (v >= rl); } // real <= var
	static inline BoolType operator<=(IntType in, const VarType& v) { return (v >= in); } // int <= var
	static inline BoolType operator<=(int in, const VarType& v) { return (v >= (IntType)in); } // int <= var
	
	static inline VarType operator+(RealType rl, const VarType& v) { return (v + rl); } // real + var
	static inline VarType operator+(IntType in, const VarType& v) { return (v + in); } // int + var
	static inline VarType operator+(int in, const VarType& v) { return (v + (IntType)in); } // int + var
	static inline StringType operator+(const StringType& str, const VarType& v) { return str + VarGetStr(v); } // string + var
	static inline VarType operator-(RealType rl, const VarType& v) { return (rl + (-v)); } // real - var
	static inline VarType operator-(IntType in, const VarType& v) { return (in + (-v)); } // int - var
	static inline VarType operator-(int in, const VarType& v) { return ((IntType)in + (-v)); } // int - var
	
	static inline VarType operator*(RealType rl, const VarType& v) { return (v * rl); } // real * var
	static inline VarType operator*(IntType in, const VarType& v) { return (v * in); } // int * var
	static inline VarType operator*(int in, const VarType& v) { return (v * (IntType)in); } // int * var
	VarType operator/(RealType rl, const VarType& v); // real / var
	static VarType operator/(IntType in, const VarType& v) { return (RealType)in / v; } // int / var

	static inline VarType operator&(IntType in, const VarType& v) { return in & VarGetInt(v); } // int & var
	static inline VarType operator|(IntType in, const VarType& v) { return in | VarGetInt(v); } // int | var
	static inline VarType operator<<(IntType in, const VarType& v) { return in << VarGetInt(v); } // int << var
	static inline VarType operator>>(IntType in, const VarType& v) { return in >> VarGetInt(v); } // int >> var
	static inline VarType operator/(int in, const VarType& v) { return ((IntType)in / VarGetInt(v)); } // int / var
	static inline VarType operator&(int in, const VarType& v) { return ((IntType)in & VarGetInt(v)); } // int & var
	static inline VarType operator|(int in, const VarType& v) { return ((IntType)in | VarGetInt(v)); } // int | var
	static inline VarType operator<<(int in, const VarType& v) { return ((IntType)in << VarGetInt(v)); } // int << var
	static inline VarType operator>>(int in, const VarType& v) { return ((IntType)in >> VarGetInt(v)); } // int >> var

	static inline void operator+=(RealType& rl, const VarType& v) { rl = rl + v; } // real += var
	static inline void operator+=(IntType& in, const VarType& v) { in = in + v; } // int += var
	static inline void operator+=(int& in, const VarType& v) { in = (int)((IntType)in + v); } // int += var
	static inline void operator+=(StringType& str, const VarType& v) { str = str + v; } // string += var
	static inline void operator-=(RealType& rl, const VarType& v) { rl = rl - v; } // real -= var
	static inline void operator-=(IntType& in, const VarType& v) { in = in - v; } // int -= var
	static inline void operator-=(int& in, const VarType& v) { in = (int)((IntType)in - v); } // int -= var

	static inline void operator*=(RealType& rl, const VarType& v) { rl = rl * v; } // real *= var
	static inline void operator*=(IntType& in, const VarType& v) { in = in * v; } // int *= var
	static inline void operator*=(int& in, const VarType& v) { in = (int)((IntType)in * v); } // int *= var
	static inline void operator/=(RealType& rl, const VarType& v) { rl = rl / v; } // real /= var
	static inline void operator/=(IntType& in, const VarType& v) { in = in / v; } // int /= var
	static inline void operator/=(int& in, const VarType& v) { in = (int)((IntType)in / v); } // int /= var
}
