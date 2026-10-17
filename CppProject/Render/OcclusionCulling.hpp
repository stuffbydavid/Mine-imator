#pragma once
#include "Mesh.hpp"

namespace CppProject
{
	struct Shader;

	// Conditions scene draws on conservative, current-pass depth queries
	struct OcclusionCulling
	{
		~OcclusionCulling();

		BoolType Begin(const Bounds& bounds, IntType numIndices, BoolType safe = true);
		void End();
		void EndFrame();

	private:
		struct Query
		{
		#if OS_WINDOWS
			ID3D11Predicate* predicate = nullptr;
		#endif
			GLuint id = 0;
		};

		void FreeQuery(Query& query);

		Shader* shader = nullptr;
		Mesh<> quad;
		QVector<Query> queries;
		IntType nextQuery = 0;
		BoolType active = false;
	};
}
