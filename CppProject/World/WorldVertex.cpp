#include "World.hpp"

#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	WorldVertex::WorldVertex(const WorldVec& regionPos, uint16_t blockData)
	{
		pos = (regionPos.x << 20) | ((regionPos.y - CHUNK_HEIGHT_MIN) << 10) | regionPos.z;
		data = blockData;
	}

	void WorldVertex::SetAttributes()
	{
	#if API_OPENGL
		IntType aPos = GFX->shader->attributeLocation[0];
		IntType aData = GFX->shader->attributeLocation[1];
		GFX->glEnableVertexAttribArray(aPos);
		GFX->glEnableVertexAttribArray(aData);
		GL_CHECK_ERROR();

		IntType offset = 0;
		GFX->glVertexAttribIPointer(aPos, 1, GL_UNSIGNED_INT, sizeof(WorldVertex), (void*)offset), offset += sizeof(uint32_t);
		GFX->glVertexAttribIPointer(aData, 1, GL_UNSIGNED_INT, sizeof(WorldVertex), (void*)offset);
		GL_CHECK_ERROR();
	#endif
	}
}
