#pragma once
#include "Matrix.hpp"
#include "Bounds.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	struct VertexBuffer;

	// Performs a raycast against rendered world objects in a given view.
	struct Raycast
	{
		// A rendered object with a vertex buffer, world transform and timeline id (0 for ground).
		struct WorldObject
		{
			IntType vbufId, tlId;
			Matrix transform;
		};

		// A registered hit in the world.
		struct Hit
		{
			BoolType found = false;
			RealType distance = 0;
			VecType position, normal;
			BoolType hasBlockPos = false;
			VecType blockPos;
			Bounds blockBounds;
			IntType face = -1, tlId = 0;
		};

		// Replaces the world objects recorded for the view's color pass.
		void Begin(IntType view);

		// Stops recording before overlays and other render passes.
		void End();

		// Records a world object using the current timeline id.
		void AddObject(const VertexBuffer& vbuf, const Matrix& transform);

		// Finds the nearest hit in the world along the ray.
		Hit Cast(IntType view, const VecType& origin, const VecType& direction, RealType distance, BoolType placing, BoolType build);

		IntType tlId = -1;
		QHash<IntType, QVector<WorldObject>> viewObjects;
		QVector<WorldObject>* objects = nullptr;

	private:
		IntType buildBoxesWorldId = -1; // Retains one fitted hit per view until the scene changes
		QHash<IntType, Hit> buildBoxes;
	};
}
