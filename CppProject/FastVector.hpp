#pragma once
#include "Heap.hpp"

namespace CppProject
{
	// Fast vector optimized for speed over memory usage.
	// The stored data must have 0 data as its default state.
	template <typename T> struct FastVector
	{
		FastVector(IntType size = 0)
		{
			if (size)
				heap.Alloc(size);
		}

		inline FastVector<T>& operator=(const FastVector<T>& vec)
		{
			if (!size && !vec.size)
				return *this;

			heap.Copy(vec.heap, vec.size);
			size = vec.size;
			return *this;
		}

		inline FastVector<T>& operator=(std::initializer_list<T> list)
		{
			heap.Alloc(list.size());
			for (const T& value : list)
				Append(value);

			return *this;
		}

		inline T& operator[](IntType index)
		{
		#if DEBUG_MODE
			if (index < 0 || index >= size)
				FATAL("Heap []: Invalid index " + NumStr(index));
		#endif
			return heap.data[index];
		}

		inline const T& Value(IntType index) const
		{
		#if DEBUG_MODE
			if (index < 0 || index >= size)
				FATAL("Heap []: Invalid index " + NumStr(index));
		#endif
			return heap.data[index];
		}

		inline const T* Data() const
		{
			return heap.data;
		}

		inline IntType Size() const
		{
			return size;
		}

		inline IntType SizeInBytes() const
		{
			return size * sizeof(T);
		}

		inline void Alloc(IntType size)
		{
			if (heap.Size() < size)
				heap.Alloc(size);
		}

		inline void Resize(IntType size)
		{
			Alloc(size);
			this->size = size;
		}

		inline IntType Append(const T& value)
		{
			if (size >= heap.size)
				heap.Alloc(std::max(IntType(1), (IntType)ceilf(heap.Size() * 1.25)));
			heap.data[size] = value;
			return size++;
		}

		inline void Remove(IntType index)
		{
			heap.Erase(index);
		}

		inline void Trim()
		{
			if (heap.size > size)
				heap.Alloc(size);
		}

		inline void Reset()
		{
			// Reset without clearing data, this assumes the data has been cleared manually
			size = 0;
		}

		inline void Clear()
		{
			heap.FreeData();
			heap = Heap<T>();
			size = 0;
		}

		Heap<T> heap;
		IntType size = 0;
	};
}