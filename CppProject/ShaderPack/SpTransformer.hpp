#pragma once
#include "SpPack.hpp"

namespace ShaderPacks
{
	// Kind of program, decides how built-in inputs are provided.
	enum class ProgramKind
	{
		Geometry,  // gbuffers_* and shadow* programs, rendering host geometry
		Composite, // Fullscreen passes (begin, prepare, deferred, composite, shadowcomp, final)
		Compute
	};

	// Vertex attribute locations of the host vertex format used by geometry programs.
	// Matches CppProject::Vertex (52 bytes):
	//   vec3 position, uint normal (xyz8), uint color (rgba8), vec2 uv, uint data, uint tangent (xyz8),
	//   uint block (id12 | state20), uint midTex (u16 v16), uint light (block8 sky8 ao8 flags8),
	//   uint midBlock (dx8 dy8 dz8 emission8)
	enum VertexAttrib
	{
		ATTR_POSITION = 0,
		ATTR_NORMAL,
		ATTR_COLOR,
		ATTR_UV,
		ATTR_DATA,
		ATTR_TANGENT,
		ATTR_BLOCK,
		ATTR_MIDTEX,
		ATTR_LIGHT,
		ATTR_MIDBLOCK,
		ATTR_COUNT
	};

	// Attribute names in transformed shaders, indexed by VertexAttrib.
	extern const char* vertexAttribNames[ATTR_COUNT];

	struct TransformParams
	{
		ProgramKind kind = ProgramKind::Geometry;
		QString programName;
		bool alphaTest = false; // Insert an alpha test for compatibility profile gbuffers programs
	};

	struct TransformResult
	{
		QString sources[STAGE_COUNT];
		QStringList warnings;
		bool ok = true;
		QString error;

		// Fragment output locations used by the program (from gl_FragData or layouts)
		QVector<int> fragmentOutputs;
	};

	// Converts a program from the OptiFine/Iris dialect (compatibility profile GLSL, mc_* attributes)
	// into core profile GLSL using Mine-imator's vertex format and uniforms.
	TransformResult TransformProgram(const ProgramSource& program, const TransformParams& params);
}
