#pragma once
#include "Common.hpp"

namespace CppProject
{
	struct VertexBuffer;

	// Connects Mine-imator's renderer with the shaderpack renderer.
	// While a shaderpack frame is recorded (see shaderpack_frame_begin/end in GML), submitted vertex
	// buffers and textures are captured instead of drawn, then replayed through the shaderpack pipeline.
	namespace ShaderPackHost
	{
		// Returns whether vertex buffer submissions are currently recorded for a shaderpack frame.
		BoolType IsRecording();

		// Records a vertex buffer with the current matrix, textures and object settings.
		void RecordVertexBuffer(VertexBuffer* buffer);

		// Captures a texture set on a sampler of the current Mine-imator shader.
		void SetTexture(IntType sampler, IntType id);
	}
}
