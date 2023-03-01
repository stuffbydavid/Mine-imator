#pragma once
#include "Common.hpp"
#include "FastVector.hpp"
#include "Type/StringType.hpp"

// Convert an integer ID to a pointer
#define FindAssetReq(type, id) Asset::Find<type>(id, ID_##type, 0, true)
#define FindAssetOpt(type, id) Asset::Find<type>(id, ID_##type, 0, false)
#define FindSubAssetReq(structName, type, id) Asset::Find<structName>(id, ID_##type, ID_##structName, true)
#define FindSubAssetOpt(structName, type, id) Asset::Find<structName>(id, ID_##type, ID_##structName, false)

// id->pointer shortcuts for different structs
#define FindScript(id) FindAssetOpt(Script, id)
#define FindSprite(id) FindAssetOpt(Sprite, id)
#define FindShader(id) FindAssetOpt(Shader, id)
#define FindFont(id) FindAssetOpt(Font, id)
#define FindSurface(id) FindAssetOpt(Surface, id)
#define FindBuffer(id) FindAssetOpt(Buffer, id)
#define FindTextFile(id) FindAssetOpt(TextFile, id)
#define FindVertexBuffer(id) FindAssetOpt(VertexBuffer, id)
#define FindList(id) FindAssetOpt(List, id)
#define FindMap(id) FindAssetOpt(Map, id)
#define FindStack(id) FindAssetOpt(Stack, id)
#define FindPriority(id) FindAssetOpt(Priority, id)
#define FindSound(id) FindAssetOpt(Sound, id)
#define FindSoundInstance(id) FindAssetOpt(SoundInstance, id)

// Array/Map access macros
#define DsList(id) (*FindAssetReq(List, id))
#define DsMap(id) (*FindAssetReq(Map, id))
#define DsGrid(id) (*FindAssetReq(Grid, id))

#define ID_Script 1
#define ID_Sprite 2
#define ID_Shader 3
#define ID_Font 4
#define ID_Surface 5
#define ID_Buffer 6
#define ID_TextFile 7
#define ID_VertexBuffer 8
#define ID_List 9
#define ID_Map 10
#define ID_IntHashMap 11
#define ID_StringHashMap 12
#define ID_Stack 13
#define ID_Priority 14
#define ID_Object 15
#define ID_Sound 16
#define ID_SoundInstance 17

#define ID_OFFSET 10000

namespace CppProject
{
	struct Asset;

	// Base class for assets in the project with an unique instance id.
	struct Asset
	{
		// Load sprites, shaders from memory/file system and define scripts.
		static void Load();

		// Returns an asset/subasset from a given instance id.
		// If required is enabled, an exception will be thrown if the located asset doesn't match the expected type(s).
		template <typename T> static T* Find(IntType id, IntType assetId, IntType subAssetId, BoolType required)
		{
			// Negative id
			if (id < 0)
			{
				if (required)
					FATAL("Invalid id " + NumStr(id));
				return nullptr;
			}

			// Lookup asset from hash table/heap
			Asset* asset = nullptr;
			if (id < ID_OFFSET) // Look for sub-asset id->asset mapping
				asset = subAssetIdAssetMap.value(id, nullptr);
			else
				asset = assets.Value(id - ID_OFFSET);

			// Check asset is valid
			if (!asset)
			{
				if (required)
					FATAL("Invalid id " + NumStr(id));
				return nullptr;
			}

			// Check type
			if (asset->assetId != assetId || (subAssetId > 0 && asset->subAssetId != subAssetId))
			{
				if (required)
					FATAL("Unexpected type for id " + NumStr(id));
				return nullptr;
			}
			return (T*)asset;
		}

		IntType id; // Instance id
		IntType assetId, subAssetId; // Asset id

		static FastVector<Asset*> assets;
		static QHash<QString, IntType> subAssetNameIdMap; // Maps an sub-asset name to an id
		static QHash<IntType, Asset*> subAssetIdAssetMap; // Maps a sub-asset id to the last added instance

	protected:
		Asset(IntType assetId, IntType subAssetId = 0, QString subAssetName = "");
		virtual ~Asset();
	};
}
