#pragma once

#include "Common.hpp"

// Shader code for unpacking the vertex buffer data
#define UNPACK_VERTEX_NORMAL(attr) "vec3(" \
			"float(" attr " & uint(255)), " \
			"float((" attr " >> uint(8)) & uint(255)), " \
			"float((" attr " >> uint(16)) & uint(255))) / 127.0 - vec3(1.0)"
#define UNPACK_VERTEX_COLOR(attr) "vec4(" \
			"float(" attr " & uint(255)), " \
			"float((" attr " >> uint(8)) & uint(255)), " \
			"float((" attr " >> uint(16)) & uint(255)), " \
			"float((" attr " >> uint(24)) & uint(255))) / 255.0"
#define UNPACK_VERTEX_WAVE(attr) "vec4(" \
			"float(" attr " & uint(1)), " \
			"float((" attr " & uint(2)) >> uint(1)), " \
			"float((" attr " >> uint(8)) & uint(255)) / 255.0, " \
			"float((" attr " & uint(4)) >> uint(2)))"

namespace CppProject
{
	// A vertex in a primitive 2D shape.
	struct PrimitiveVertex
	{
		PrimitiveVertex(QPointF pos, QPointF uv, IntType color = -1, RealType alpha = 1.0);

		// Overrides the color of the vertex.
		void SetColor(QColor color);

		// Apply a transform to the vertex position and UVs.
		void Apply(QTransform transform, float depth, UvRect uvRect);

		// Set shader attributes.
		static void SetAttributes();

		float x, y, depth;
		float r, g, b, a;
		float u, v;
	};

	// A vertex stored in a 3D vertex buffer.
	// The fields after the tangent are Minecraft data used by shaderpacks (see ShaderPack/SpTransformer.hpp).
	struct Vertex
	{
		Vertex() {}
		Vertex(RealType x, RealType y, RealType z,
			   RealType nx, RealType ny, RealType nz,
			   IntType color, RealType alpha,
			   RealType u, RealType v,
			   BoolType waveXY, BoolType waveZ, RealType emissive, BoolType subsurface);

		// A flag in the first byte of the data int, up to 8 are allowed
		enum Flag
		{
			WAVE_XY = 0,
			WAVE_Z = 1,
			SUBSURFACE = 2
		};

		// Compare with a previously added vertex for index buffer generation
		bool operator==(const Vertex& o) const;

		// Sets the normal vector.
		void SetNormal(RealType nx, RealType ny, RealType nz);

		// Sets the tangent vector.
		void SetTangent(RealType tx, RealType ty, RealType tz);

		// Set the color
		void SetColor(IntType color, RealType alpha);

		// Enable a flag
		void EnableFlag(Flag flag);

		// Set emissive value
		void SetEmissive(RealType emissive);

		// Set the object index
		void SetIndex(IntType index);

		// Set the Mine-imator block and state ID the vertex belongs to (for shaderpack block IDs).
		void SetBlock(IntType blockId, IntType stateId);

		// Set the light levels (0-15, fractions allowed for smooth lighting) and ambient occlusion (0-1).
		void SetLight(RealType blockLight, RealType skyLight, RealType ao);

		// Set the fluid flag of the light data (mc_Entity.y).
		void SetFluid(BoolType fluid);

		// Set the texture coordinate at the center of the face.
		void SetMidTexCoord(RealType u, RealType v);

		// Set the offset to the center of the block in 1/64 block units and the light emission (0-15).
		void SetMidBlock(RealType dx, RealType dy, RealType dz, IntType emission);

		// Set shader attributes.
		static void SetAttributes();

		float x, y, z; // 0
		uint32_t normal; // 1
		uint32_t color; // 2
		float u, v; // 3
		uint32_t data = 0; // 4
		uint32_t tangent = 0;
		uint32_t block = 0; // Block ID (12 bits) | state ID (20 bits), 0 for none
		uint32_t midTex = 0xFFFFFFFF; // U16 | V16 of the face center, all bits set for none
		uint32_t light = 0x00FFF000; // Block light (0-240) | sky light (0-240) << 8 | AO (0-255) << 16 | flags << 24
		uint32_t midBlock = 0; // Signed 8 bit X/Y/Z offset to the block center | emission << 24
	};
}