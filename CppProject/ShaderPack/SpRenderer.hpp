#pragma once
#include "SpPack.hpp"
#include "SpTransformer.hpp"

#include <QImage>
#include <QMatrix4x4>
#include <QVector2D>
#include <QVector3D>
#include <QVector4D>

class QOpenGLExtraFunctions;
class QOpenGLFunctions_3_3_Core;

namespace ShaderPacks
{
	// Double precision vector for world positions.
	struct DVec3
	{
		double x = 0.0, y = 0.0, z = 0.0;
	};

	// State of the world and camera for a frame, supplied by the host.
	// Coordinates are in Minecraft world space (Y up, 1 unit per block).
	struct FrameState
	{
		int width = 1, height = 1;

		// Camera
		DVec3 cameraPosition;
		float yaw = 0.f, pitch = 0.f, roll = 0.f; // Degrees, Minecraft conventions (yaw 0 = looking south/+Z)
		float fov = 70.f;	   // Vertical field of view in degrees
		float nearPlane = 0.05f;
		float renderDistance = 256.f; // "far" uniform in blocks
		QMatrix4x4 jitter;			  // Optional projection jitter (TAA)

		// Time
		int worldTime = 6000; // 0-23999
		int worldDay = 0;
		float frameTimeCounter = 0.f; // Seconds
		float frameTime = 1.f / 60.f;
		int moonPhase = 0;

		// Weather and environment
		float rainStrength = 0.f;
		float thunderStrength = 0.f;
		QVector3D fogColor = QVector3D(0.73f, 0.83f, 1.f);
		QVector3D skyColor = QVector3D(0.47f, 0.65f, 1.f);
		float fogStart = 0.f, fogEnd = 256.f, fogDensity = 0.f;
		int isEyeInWater = 0;
		int eyeBrightnessSky = 240, eyeBrightnessBlock = 0; // 0-240
		float screenBrightness = 1.f;
		float nightVision = 0.f, blindness = 0.f;
		float temperature = 0.8f, rainfall = 0.4f;
		int biomeCategory = 5; // CAT_PLAINS
		int biomePrecipitation = 1;
	};

	// Gbuffers and shadow program groups, see Pack::FallbackProgram for fallbacks.
	enum class GeometryPhase
	{
		SkyBasic,
		SkyTextured,
		Clouds,
		TerrainSolid,
		TerrainCutout,
		Water, // Translucent terrain
		Entities,
		EntitiesTranslucent,
		Block,
		BlockTranslucent,
		Particles,
		ParticlesTranslucent,
		Weather,
		Textured,
		TexturedLit,
		Basic,
		Hand,
		Count
	};

	// Texture reference supplied by the host for drawing.
	struct HostTexture
	{
		unsigned int id = 0;   // OpenGL texture name, 0 for default
		QVector4D uvRect = QVector4D(0.f, 0.f, 1.f, 1.f); // Sub-rectangle for textures in atlases/pages
		QSize size;			   // Size of the full texture in pixels
	};

	// Per-object state for a draw call.
	struct ObjectState
	{
		QMatrix4x4 model;		 // Object to world matrix (in Minecraft world space, absolute)
		QVector4D colorModulator = QVector4D(1.f, 1.f, 1.f, 1.f);
		QVector4D entityColor = QVector4D(0.f, 0.f, 0.f, 0.f);
		int entityId = -1;
		int blockEntityId = -1;
		int itemId = -1;
		HostTexture texture, normals, specular;
		bool cullBackFaces = true;
	};

	// Host vertex buffer to draw with the current program (layout of CppProject::Vertex).
	struct HostMesh
	{
		unsigned int vbo = 0, ibo = 0;
		int indexCount = 0;
		int vertexStride = 52;
	};

	// Renders a shaderpack pipeline with OpenGL (requires a current OpenGL 3.3+ core context).
	class Renderer
	{
	public:
		Renderer();
		~Renderer();

		// Prepares the renderer for a loaded pack, compiling all programs. Returns false on error.
		bool Init(Pack* pack, QString* error = nullptr);

		// Releases all OpenGL resources (requires the context to be current).
		void Destroy();

		// Provides block IDs from block.properties: offsets[blockId] into the ids array indexed by state.
		void SetBlockIdTable(const QVector<int>& offsets, const QVector<int>& ids);

		// Resolves "minecraft:" resource textures used in texture.<stage>.<name> directives.
		std::function<HostTexture(const QString& resource)> resourceTextureProvider;

		// Begins a frame: resizes and clears buffers, updates uniforms and runs setup/begin passes.
		void BeginFrame(const FrameState& state);

		// Shadow pass, returns whether the pack uses shadows. Draw geometry between Begin/EndShadow.
		bool BeginShadow();
		void EndShadow();

		// Selects the program for a geometry phase, returns false if no program exists for it.
		// shadow selects the shadow program variant (only valid between BeginShadow/EndShadow).
		bool BeginPhase(GeometryPhase phase);
		void EndPhase();

		// Draws a mesh with the current phase program.
		void Draw(const HostMesh& mesh, const ObjectState& object);

		// Ends solid geometry: copies depth for translucents and runs the deferred passes.
		void BeginTranslucent();

		// Runs composite and final passes, writing to the given framebuffer.
		void EndFrame(unsigned int targetFbo, const QRect& viewport);

		// Returns whether the renderer is ready to draw.
		bool IsReady() const { return ready; }

		// Matrices of the current frame
		QMatrix4x4 GbufferModelView() const;
		QMatrix4x4 GbufferProjection() const;

		// Sky geometry helpers (Minecraft-like sky disc, sun and moon quads) drawn with the sky programs.
		void DrawSky(const HostTexture& sun, const HostTexture& moon);

		// Debugging: saves all render targets as images in a folder and returns statistics per target.
		QStringList DumpTargets(const QString& folder);

		// Debugging: reads a pixel of the current (read side) contents of a color target.
		QVector4D ReadTargetPixel(int buffer, int x, int y);

		// Errors from the last Init/frame
		QStringList errors;

		struct Impl;

	private:
		std::unique_ptr<Impl> impl;
		bool ready = false;
	};
}
