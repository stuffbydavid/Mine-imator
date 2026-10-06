#pragma once
#include "SpCommon.hpp"
#include "SpExpression.hpp"

namespace ShaderPacks
{
	class Preprocessor;

	// Converts a buffer name ("colortex3", "gaux1", "gcolor", ...) to its index, -1 if invalid.
	int ColorBufferIndex(const QString& name);

	// Blend mode for a program or one of its buffers.
	struct BlendModeSpec
	{
		bool off = false;
		unsigned int src = 0, dst = 0, srcAlpha = 0, dstAlpha = 0; // OpenGL enums
	};

	// Alpha test for a program.
	struct AlphaTestSpec
	{
		bool off = false;
		unsigned int func = 0; // OpenGL comparison enum
		float ref = 0.1f;
	};

	// Viewport scale for a composite pass.
	struct ScaleSpec
	{
		float scale = 1.f, offsetX = 0.f, offsetY = 0.f;
	};

	// Custom size of a color buffer.
	struct BufferSizeSpec
	{
		bool relative = true;
		float width = 1.f, height = 1.f;
	};

	// A custom texture bound to a sampler for a stage.
	struct TextureSpec
	{
		QString path; // Path inside the pack, or "minecraft:..." resource
		bool raw = false; // Raw binary data
		unsigned int target = 0; // GL_TEXTURE_1D/2D/3D/RECTANGLE for raw textures
		unsigned int internalFormat = 0, pixelFormat = 0, pixelType = 0;
		int width = 0, height = 0, depth = 0;
	};

	// A raw custom texture replaces samplers of a matching type and name in the programs of a stage,
	// by renaming them to a generated custom texture name (Iris' customTexturePatching).
	struct SamplerPatchSpec
	{
		QString stage, sampler, newName;
		unsigned int target = 0;
	};

	// Custom image (Iris "image.<name>=...").
	struct ImageSpec
	{
		QString name, samplerName;
		unsigned int internalFormat = 0, pixelFormat = 0, pixelType = 0;
		bool clear = true, relative = false;
		float width = 0.f, height = 0.f, depth = 0.f; // depth > 0 for 3D images
	};

	// Custom uniform or variable defined in shaders.properties.
	struct CustomUniformSpec
	{
		ExprValue::Type type = ExprValue::FLOAT;
		QString name;
		QString source;
		std::shared_ptr<Expression> expression;
		bool isVariable = false;
	};

	// Contents of shaders.properties.
	struct ShaderProperties
	{
		// Parses the (raw) shaders.properties source, preprocessing it with the given preprocessor.
		void Load(const QString& source, Preprocessor& pp);

		OrderedProperties props;	// Preprocessed properties
		OrderedProperties original; // Unprocessed properties (for screens/sliders/profiles)

		// Returns a boolean directive (e.g. "oldLighting"), def if unset.
		bool Flag(const QString& key, bool def) const;

		// Returns the cloud setting: "off", "fast", "fancy" or empty if not set.
		QString clouds;

		QHash<QString, QString> programEnabled;			  // program -> boolean option expression
		QHash<QString, BlendModeSpec> blend;			  // "program" or "program.bufferIndex"
		QHash<QString, AlphaTestSpec> alphaTest;		  // program -> alpha test
		QHash<QString, ScaleSpec> scale;				  // program -> scale
		QHash<QString, QHash<int, bool>> flip;			  // program -> buffer -> flip
		QHash<int, BufferSizeSpec> bufferSize;			  // color buffer -> size
		QHash<QString, QHash<QString, TextureSpec>> textures; // stage -> sampler -> texture
		QHash<QString, TextureSpec> customTextures;		  // customTexture.<name> and generated customtex<n>
		QVector<SamplerPatchSpec> samplerPatches;		  // Raw texture.<stage>.<sampler> directives
		QVector<ImageSpec> images;
		QHash<int, QPair<qint64, QString>> bufferObjects; // index -> size, optional file
		QString noiseTexture;
		QVector<CustomUniformSpec> uniforms;			  // In definition order, variables included
		QStringList requiredFeatures, optionalFeatures;
		QHash<QString, QString> profiles;				  // profile name -> definition
		QHash<QString, QString> screens;				  // "" for the main screen
		QHash<QString, int> screenColumns;
		QStringList sliders;
	};

	// A block entry from block.properties.
	struct BlockEntry
	{
		QString ns, name;
		bool isTag = false;
		QHash<QString, QStringList> properties;
	};

	// Maps blocks, items and entities to the IDs defined by the pack.
	struct IdMap
	{
		// Parses block/item/entity/dimension properties sources (already preprocessed).
		void LoadBlocks(const QString& source);
		void LoadItems(const QString& source);
		void LoadEntities(const QString& source);
		void LoadDimensions(const QString& source);

		// Returns the block ID for a block ("minecraft:stone") with state properties, or -1.
		// tags returns the tags (as "minecraft:leaves") that contain the block.
		int BlockId(const QString& id, const QHash<QString, QString>& state, const QStringList& tags = QStringList()) const;

		// Returns the item or entity ID, or -1.
		int ItemId(const QString& id) const { return items.value(Namespaced(id), -1); }
		int EntityId(const QString& id) const { return entities.value(Namespaced(id), -1); }

		static QString Namespaced(const QString& id) { return id.contains(':') ? id : "minecraft:" + id; }

		struct IndexedEntry
		{
			int order;
			int id;
			BlockEntry entry;
		};

		QHash<QString, QVector<IndexedEntry>> blocksByName; // "minecraft:stone" -> entries
		QHash<QString, QVector<IndexedEntry>> blocksByTag;	// "minecraft:leaves" -> entries
		QHash<QString, int> items, entities;
		QHash<QString, QString> dimensions;
		QHash<QString, QString> layers; // block -> render layer override
		bool hasBlocks = false;
	};
}
