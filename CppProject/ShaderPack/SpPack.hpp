#pragma once
#include "SpCommon.hpp"
#include "SpFormats.hpp"
#include "SpOptions.hpp"
#include "SpPackFiles.hpp"
#include "SpProperties.hpp"

#include <QVector4D>

namespace ShaderPacks
{
	// Shader stages of a program.
	enum Stage
	{
		STAGE_VERTEX,
		STAGE_GEOMETRY,
		STAGE_TESS_CONTROL,
		STAGE_TESS_EVAL,
		STAGE_FRAGMENT,
		STAGE_COMPUTE,
		STAGE_COUNT
	};

	// Preprocessed source of one shader stage.
	struct StageSource
	{
		QString version;		// "#version ..." line
		QStringList extensions; // Hoisted "#extension" lines
		QString body;			// Preprocessed code
		QStringList errors;

		bool IsValid() const { return !body.isNull(); }
	};

	// A program (set of stages) loaded from the pack, e.g. "gbuffers_terrain" or "composite2".
	struct ProgramSource
	{
		QString name;
		StageSource stages[STAGE_COUNT];

		// Directives found in the fragment shader
		QVector<int> drawBuffers = { 0 };
		bool explicitDrawBuffers = false;
		QSet<int> mipmappedBuffers;

		// Compute work group settings
		bool hasWorkGroups = false, hasWorkGroupsRender = false;
		int workGroups[3] = { 1, 1, 1 };
		float workGroupsRender[2] = { 1.f, 1.f };

		bool IsValid() const { return stages[STAGE_VERTEX].IsValid() && stages[STAGE_FRAGMENT].IsValid(); }
		bool IsCompute() const { return stages[STAGE_COMPUTE].IsValid(); }
	};

	// Render target settings for a color buffer (colortex0-15).
	struct RenderTargetSettings
	{
		QString formatName = "RGBA8";
		InternalFormatInfo format;
		bool clear = true;
		bool hasClearColor = false;
		QVector4D clearColor;
	};

	// Settings of a shadow color buffer or depth buffer.
	struct ShadowBufferSettings
	{
		QString formatName = "RGBA8";
		InternalFormatInfo format;
		bool clear = true;
		QVector4D clearColor = QVector4D(1.f, 1.f, 1.f, 1.f);
		bool nearest = false;
		bool mipmap = false;
		bool hardwareFiltering = false;
	};

	// Pack-wide settings defined through const directives.
	struct PackDirectives
	{
		RenderTargetSettings colorTargets[16];
		ShadowBufferSettings shadowColor[8];
		ShadowBufferSettings shadowDepth[2];

		int shadowMapResolution = 1024;
		float shadowDistance = 160.f;
		float shadowDistanceRenderMul = -1.f;
		float entityShadowDistanceMul = 1.f;
		float shadowIntervalSize = 2.f;
		float shadowNearPlane = -100.05f, shadowFarPlane = 156.f;
		float shadowMapFov = -1.f; // > 0 enables perspective shadows
		float voxelDistance = 0.f;

		float sunPathRotation = 0.f;
		float ambientOcclusionLevel = 1.f;
		float wetnessHalflife = 600.f, drynessHalflife = 200.f;
		float eyeBrightnessHalflife = 10.f, centerDepthHalflife = 1.f;
		int noiseTextureResolution = 256;
	};

	// Values passed in when loading a pack.
	struct LoadSettings
	{
		QHash<QString, QString> optionValues; // User option values
		QString profile;					  // Profile to apply before option values (optional)
		QString dimension = "minecraft:overworld";
		QList<QPair<QString, QString>> environmentDefines; // Standard macros (MC_VERSION, ...)
		bool computeSupported = true;
		bool tessellationSupported = true;
	};

	// A loaded shaderpack with preprocessed program sources.
	class Pack
	{
	public:
		// Loads a pack from a folder or zip file. Returns nullptr on error.
		static std::unique_ptr<Pack> Load(const QString& path, const LoadSettings& settings, QString* error = nullptr);

		// Returns a program by name, or nullptr if it doesn't exist (or is disabled).
		const ProgramSource* Program(const QString& name) const;

		// Returns the first existing program following the OptiFine fallback chain, or nullptr.
		const ProgramSource* ResolveProgram(const QString& name) const;

		// Returns the fallback program name of a gbuffers/shadow program ("" if none).
		static QString FallbackProgram(const QString& name);

		// Returns the compute programs run with a composite pass ("composite3" -> composite3, composite3_a, ...).
		QVector<const ProgramSource*> ComputePrograms(const QString& passName) const;

		// Returns whether any of the given program names exist.
		bool HasShadowPass() const;

		std::unique_ptr<PackFiles> files;
		Options options;
		ShaderProperties properties;
		IdMap idMap;
		LanguageMap language;
		PackDirectives directives;
		QString dimensionFolder; // Folder programs are loaded from ("" for the root)
		QStringList disabledPrograms;
		QStringList warnings;
		QHash<QString, ProgramSource> programs;
		QList<QPair<QString, QString>> environmentDefines; // Final macros used for preprocessing
		bool usesShadowTextures = false;

	private:
		void LoadPrograms(const IncludeResolver& includes, const QStringList& programFiles);
		void ParseDirectives();
	};

	// Creates the standard environment macros (MC_VERSION, MC_GL_VERSION, ...) for the current OpenGL context.
	QList<QPair<QString, QString>> CreateStandardMacros(const QString& mcVersion, int glVersion, int glslVersion,
														const QString& vendor, const QString& renderer, const QStringList& glExtensions);
}
