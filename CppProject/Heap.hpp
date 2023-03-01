#pragma once
#include "Common.hpp"
#include <QByteArray>

namespace CppProject
{
	// Heap storage wrapper.
	template <typename T> struct Heap
	{
		Heap(IntType initialSize = 0)
		{
			if (initialSize)
				Alloc(initialSize);
		};

		~Heap()
		{
			free(data);
		}

		inline Heap<T>& operator=(const Heap<T>& heap)
		{
			Copy(heap, heap.size);
			return *this;
		}

		inline Heap<T>& operator=(const QByteArray& byteArray)
		{
			Copy(byteArray, byteArray.size());
			return *this;
		}

		inline T& operator[](IntType index)
		{
		#if DEBUG_MODE
			if (index < 0 || index >= size)
				FATAL("Heap []: Invalid index " + NumStr(index));
		#endif
			return data[index];
		}

		inline const T& Value(IntType index) const
		{
		#if DEBUG_MODE
			if (index < 0 || index >= size)
				FATAL("Heap []: Invalid index " + NumStr(index));
		#endif
			return data[index];
		}

		inline const T* Data() const
		{
			return data;
		}

		inline IntType Size() const
		{
			return size;
		}

		inline IntType SizeInBytes() const
		{
			return size * sizeof(T);
		}

		inline void Copy(const Heap<T>& heap, IntType size, IntType srcOffset = 0, IntType dstOffset = 0)
		{
			IntType newSize = std::max(this->size, dstOffset + size);
			if (newSize > this->size)
				Alloc(newSize);
			memcpy(data + dstOffset, heap.Data() + srcOffset, size * sizeof(T));
			this->size = newSize;
		}

		inline void Copy(const QByteArray& byteArray, IntType size, IntType srcOffset = 0, IntType dstOffset = 0)
		{
			IntType newSize = std::max(this->size, dstOffset + size);
			if (newSize > this->size)
				Alloc(newSize);
			memcpy(data + dstOffset, byteArray.constData() + srcOffset, size * sizeof(T));
			this->size = newSize;
		}

		inline void Alloc(IntType size, BoolType clear = true)
		{
			IntType sizeBytes = this->size * sizeof(T);
			IntType newSizeBytes = size * sizeof(T);
			if (data)
				data = (T*)realloc(data, newSizeBytes);
			else
				data = (T*)malloc(newSizeBytes);

			if (size > this->size && clear)
				memset(data + this->size, 0, newSizeBytes - sizeBytes);
			this->size = size;
		}

		inline void Write(IntType index, const T& value)
		{
			data[index] = value;
		}

		inline void Erase(IntType index)
		{
			memset(data + index, 0, sizeof(T));
		}

		inline void Reset()
		{
			size = 0;
		}

		inline void FreeData()
		{
			free(data);
			data = nullptr;
			size = 0;
		}

		T* data = nullptr;
		IntType size = 0;
	};
}