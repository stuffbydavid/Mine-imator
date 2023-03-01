#pragma once
#include "Asset.hpp"
#include "Heap.hpp"
#include "Type/VarType.hpp"

namespace CppProject
{
	// Buffer asset
	struct Buffer : Asset
	{
		// Creates a buffer for reading
		Buffer(StringType filename);

		// Creates a buffer for writing
		Buffer(IntType size, BoolType grow, IntType align);

		// Writes a value to the buffer at the given position and increments it.
		BoolType WriteVar(int type, VarType var, IntType& pos);

		// Reads a value from the buffer at the given position and increments it.
		VarType ReadVar(int type, IntType& pos);

		// Saves the buffer contents to a filename.
		void Save(StringType filename);

		// Returns the size of a data type stored in the buffer.
		IntType GetDataSize(int type);

		IntType pos = 0;
		BoolType grow = false;
		IntType align = 1;
		Heap<uchar> data;
	};
}