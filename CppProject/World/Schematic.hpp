#pragma once
#include "World.hpp"
#include "Render/Bounds.hpp"

namespace CppProject
{
	// Manage and export blocks for Sponge .schem or legacy .schematic files.
	struct SchematicExport
	{
		// Initialize NBT data and storage for the selected box.
		SchematicExport(const WorldBox& selection, IntType dataVersion, BoolType skipIncompatible = false, BoolType applyFilter = true);

		// Initialize and add the source blocks and current timeline edits.
		SchematicExport(obj_timeline* timeline);

		// Return the extension for the selected schematic format.
		QString Extension() const;

		// Copy compatible chunk blocks and block entities into the Schematic.
		void AddChunk(Chunk& chunk);

		// Copy entities stored separately from terrain chunks.
		void AddEntityRegion(const QString& filename, const WorldVec& regionPos, const BoolType* includedChunks);

		// Serialize and save a Schematic file.
		void Save(const QString& filename);

		// Return the local origin, exported timeline save IDs and hidden mesh cells.
		ArrType GetTimelineData() const;

		// Serialize and asynchronously save a world resource snapshot.
		void SaveResource(obj_resource* resource);

		WorldBox box;
		BoolType exportOnly = true, legacy, skipIncompatible, applyFilter;
		NbtCompound* schematic = nullptr;
		QString error;

	private:
		struct Block
		{
			VecType pos;
			BuilderState state;
			obj_timeline* timeline = nullptr;
		};

		struct Painting
		{
			obj_timeline* timeline;
			VecType pos;
			IntType facing, width, height;
		};

		// Create the initial Schematic file structure and allocate volume for blocks.
		void Initialize();

		// Serialize the collected Schematic as NBT.
		QByteArray Serialize();

		// Parse the source blocks from an imported resource.
		void AddResource();

		// Parse a timeline object and its child block parts.
		void AddTimeline(obj_timeline* parent);

		// Add a block to the Schematic from parsed user-added blocks or timeline parts.
		void AddBlock(const Block& block);

		// Add supported entities from the timeline into the Schematic.
		void AddEntities();

		// Copy entities from a chunk's entity list.
		void AddEntities(NbtCompound& chunk);

		// Returns the offset of a block position relative to the Schematic origin.
		IntType GetOffset(const VecType& pos) const;

		// Adds the block state into the Schematic palette, or returns the existing index.
		uint32_t GetPaletteIndex(BuilderState state, BoolType filter = true);

		// Returns a list of connected blocks for a given block and state.
		QVector<Block> GetConnectedBlocks(obj_block* block, IntType state);

		// Resolve legacy source states and copy shared properties to upper halves.
		BuilderState GetResourceState(const WorldVec& pos);

		// Parse the front or back text from a given sign timeline.
		NbtCompound* GetSignText(obj_timeline* sign, BoolType back);

		IntType dataVersion, skippedChunks = 0;
		NbtCompound root;
		NbtCompound* palette = nullptr;
		NbtList* entities = nullptr;
		Heap<uint32_t> indices;

		obj_timeline* timeline = nullptr;
		obj_resource* resource = nullptr;
		BoolType keepWater = true;
		Matrix inverse;
		WorldVec sourceSize = { 0, 0, 0 }, repeat = { 1, 1, 1 };
		Bounds bounds;
		QVector<Block> addedBlocks, parts;
		QHash<quint64, uint32_t> paletteIndices;
		QMap<IntType, Block> addedBlockMap;
		QVector<Painting> paintings;
	};
}
