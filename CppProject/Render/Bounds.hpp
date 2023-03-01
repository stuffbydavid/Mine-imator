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

		// Returns a list of 8 points for each corner of the bounds.
		QVector<VecType> GetPoints() const;

		// Adds the given point to the bounds.
		void AddPoint(VecType point);

		// Adds the given bounds.
		void AddBounds(const Bounds& bounds);

		// Adds the given transformed bounds.
		void AddBounds(const Bounds& bounds, Matrix transform);

		VecType minPoint, maxPoint;
		BoolType empty = true;
	};
}