#pragma once
#include "SpCommon.hpp"

namespace ShaderPacks
{
	// Texture format info for an OptiFine/Iris format name such as "RGBA16F".
	struct InternalFormatInfo
	{
		unsigned int internalFormat = 0; // GL internal format
		unsigned int pixelFormat = 0;	 // Matching GL pixel format for uploads/clears
		unsigned int pixelType = 0;		 // Matching GL pixel type
		bool isInteger = false;
		bool isDepth = false;
	};

	// Returns format info from a name, ok is false for unknown names.
	InternalFormatInfo ParseInternalFormat(const QString& name, bool* ok = nullptr);

	// Parses a pixel format name ("RGBA", "RED_INTEGER", ...), returns 0 for unknown names.
	unsigned int ParsePixelFormat(const QString& name);

	// Parses a pixel type name ("UNSIGNED_BYTE", "FLOAT", ...), returns 0 for unknown names.
	unsigned int ParsePixelType(const QString& name);

	// Parses a texture target name ("TEXTURE_2D", ...), returns 0 for unknown names.
	unsigned int ParseTextureTarget(const QString& name);

	// Parses a blend factor name ("SRC_ALPHA", ...), returns -1 for unknown names.
	int ParseBlendFactor(const QString& name);

	// Parses an alpha test function name ("GREATER", ...), returns 0 for unknown names.
	unsigned int ParseCompareFunc(const QString& name);

	// Returns the GLSL image format qualifier name for an internal format ("rgba16f").
	QString ImageFormatQualifier(unsigned int internalFormat);
}
