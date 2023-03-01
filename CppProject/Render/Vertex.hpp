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

		// Set shader attributes.
		static void SetAttributes();

		float x, y, z; // 0
		uint32_t normal; // 1
		uint32_t color; // 2
		float u, v; // 3
		uint32_t data = 0; // 4
		uint32_t tangent = 0;
	};
}