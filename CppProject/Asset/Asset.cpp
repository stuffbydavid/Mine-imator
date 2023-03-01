#include "Asset.hpp"

namespace CppProject
{
	FastVector<Asset*> Asset::assets;
	QHash<QString, IntType> Asset::subAssetNameIdMap;
	QHash<IntType, Asset*> Asset::subAssetIdAssetMap;

	Asset::Asset(IntType assetId, IntType subAssetId, QString subAssetName) :
		assetId(assetId), subAssetId(subAssetId)
	{
		id = assets.Append(this) + ID_OFFSET;

		if (subAssetId > 0)
		{
			subAssetIdAssetMap[subAssetId] = this;

			if (subAssetName != "")
				subAssetNameIdMap[subAssetName] = subAssetId;
		}
	}

	Asset::~Asset()
	{
		assets.Remove(id - ID_OFFSET);
	}
}