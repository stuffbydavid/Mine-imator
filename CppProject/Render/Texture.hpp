#pragma once

#include "Common.hpp"
#include "Render/GraphicsApiHandler.hpp"

namespace CppProject
{
	// Wrapper for a texture, mipmaps are only generated when required.
	struct Texture
	{
		Texture(const QImage& img);
		~Texture();

		// Returns the unique ID of the texture and generate mipmaps if enabled.
		IntType GetId();

	#if OS_WINDOWS
		ID3D11Texture2D* d3dTex = nullptr;
		ID3D11ShaderResourceView* d3dSRV = nullptr;
		IntType d3dSRVId = 0;

		static QHash<IntType, ID3D11ShaderResourceView*> d3dIdSRVMap;
		static IntType d3dSRVNextId;
	#endif
		GLuint glTexId = 0;

		static QHash<IntType, BoolType> hasMipMaps;
	};
}
