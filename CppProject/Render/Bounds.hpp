#pragma once
#include "Type/VecType.hpp"
#include "Matrix.hpp"
#include "Vertex.hpp"

namespace CppProject
{
	// Axis-aligned bounding box defined by 2 points
	struct Bounds
	{
		Bounds() {}
		Bounds(VecType minPoint, VecType maxPoint) : minPoint(minPoint), maxPoint(maxPoint), empty(false) {}
		Bounds(const Heap<Vertex>& vertexData);

		// Reset the bounds
		void Reset() { empty = true; }

		// Checks whether the point is inside or on the bounds
		BoolType ContainsPoint(VecType point) const;

		// Adds the given point to the bounds.
		void AddPoint(VecType point);

		// Adds the given bounds.
		void AddBounds(const Bounds& bounds);

		// Adds the given transformed bounds.
		void AddBounds(const Bounds& bounds, const Matrix& transform);

		VecType minPoint, maxPoint;
		BoolType empty = true;
	};
}
