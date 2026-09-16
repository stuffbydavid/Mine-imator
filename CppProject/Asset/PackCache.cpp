#include "Generated/GmlFunc.hpp"
#include "Generated/Scripts.hpp"

#include "Asset/DataStructure.hpp"
#include "Asset/Object.hpp"
#include "Asset/Sprite.hpp"
#include "Render/TexturePage.hpp"

#include <QBuffer>
#include <QCryptographicHash>
#include <QDataStream>
#include <QSaveFile>

namespace CppProject
{
	static constexpr uchar PACK_CACHE_FORMAT = 4;
	static constexpr qint64 PACK_CACHE_MAX_IMAGE_BYTES = 512LL * 1024 * 1024;
	static constexpr qint32 PACK_CACHE_MAX_RECORDS = 100000;

	struct PackCacheSource
	{
		qint64 size = -1;
		qint64 modified = -1;
	};

	static BoolType PackCacheReject(const QString& reason)
	{
		DEBUG("Pack cache rejected: " + reason);
		return false;
	}

	// Read source size and timestamp
	static PackCacheSource PackCacheSourceInfo(const StringType& filename)
	{
		QFileInfo file(filename.QStr());
		if (!file.exists() || !file.isFile())
			return {};
		return { file.size(), file.lastModified().toMSecsSinceEpoch() };
	}

	static StringType PackCacheSourceFilename(Scope<obj_resource> self)
	{
		if (self->id == global::mc_res)
			return global::load_assets_zip_file;
		return global::save_folder + "/" + self->filename.ToStr();
	}

	// Hash the current asset definitions
	static QByteArray PackCacheMidataDigest()
	{
		QFile file(global::load_assets_file.QStr());
		if (!file.open(QIODevice::ReadOnly))
			return {};
		return QCryptographicHash::hash(file.readAll(), QCryptographicHash::Sha256);
	}

	static QImage PackCacheSpriteImage(IntType id)
	{
		Sprite* sprite = FindSprite(id);
		if (!sprite || sprite->frames.isEmpty())
			return {};

		Sprite::Frame* frame = sprite->frames[0];
		if (frame->pageLoc)
			return frame->pageLoc->page->image.copy(frame->pageLoc->rect);
		return frame->image;
	}

	// Store a sprite as a PNG record
	static BoolType PackCacheWriteSprite(QDataStream& out, IntType id)
	{
		QImage image = PackCacheSpriteImage(id);
		QByteArray png;
		if (!image.isNull())
		{
			QBuffer buffer(&png);
			if (!buffer.open(QIODevice::WriteOnly) || !image.save(&buffer, "PNG"))
				return false;
		}

		out << (qint64)png.size();
		if (!png.isEmpty() && out.writeRawData(png.constData(), png.size()) != png.size())
			return false;

		return out.status() == QDataStream::Ok;
	}

	static BoolType PackCacheReadSprite(QDataStream& in, IntType& id, QVector<Sprite*>& sprites)
	{
		qint64 size = 0;
		in >> size;
		if (in.status() != QDataStream::Ok || size < 0 || size > PACK_CACHE_MAX_IMAGE_BYTES)
			return false;

		id = null_;
		if (!size)
			return true;

		QByteArray png((int)size, '\0');
		if (in.readRawData(png.data(), (int)size) != size)
			return false;

		QImage image;
		if (!image.loadFromData(png, "PNG"))
			return false;

		auto sprite = new Sprite(image, {});
		sprites.append(sprite);
		id = sprite->id;

		return true;
	}

	// Store short UTF-8 keys
	static BoolType PackCacheWriteString(QDataStream& out, const StringType& value)
	{
		QByteArray data = value.QStr().toUtf8();
		if (data.size() > UINT16_MAX)
			return false;

		out << (quint16)data.size();
		return data.isEmpty() || out.writeRawData(data.constData(), data.size()) == data.size();
	}

	static BoolType PackCacheReadString(QDataStream& in, StringType& value)
	{
		quint16 size = 0;
		in >> size;
		if (in.status() != QDataStream::Ok)
			return false;

		QByteArray data(size, '\0');
		if (size && in.readRawData(data.data(), size) != size)
			return false;

		value = QString::fromUtf8(data);
		return true;
	}

	// Store block texture depth values
	static BoolType PackCacheWriteDepthList(QDataStream& out, IntType id)
	{
		List* list = FindList(id);
		qint32 count = list ? list->vec.size() : 0;
		out << count;
		for (qint32 i = 0; i < count; i++)
			out << (uchar)VarGetInt(list->Value(i));

		return out.status() == QDataStream::Ok;
	}

	static BoolType PackCacheReadDepthList(QDataStream& in, List*& list)
	{
		qint32 count = 0;
		in >> count;
		if (in.status() != QDataStream::Ok || count < 0 || count > PACK_CACHE_MAX_RECORDS)
			return false;

		list = new List();
		for (qint32 i = 0; i < count; i++)
		{
			uchar value = 0;
			in >> value;
			if (in.status() != QDataStream::Ok || value > e_block_depth_DEPTH2)
				return false;

			list->vec.append({ (IntType)value, 0 });
		}
		return true;
	}

	// Store texture and UV lookup maps
	static BoolType PackCacheWriteSpriteMap(QDataStream& out, IntType id)
	{
		Map* map = FindMap(id);
		if (!map)
		{
			out << (qint32)0;
			return out.status() == QDataStream::Ok;
		}

		qint32 count = map->map.size();
		out << count;
		if (count < 0 || count > PACK_CACHE_MAX_RECORDS)
			return false;

		for (auto it = map->map.cbegin(); it != map->map.cend(); it++)
			if (!PackCacheWriteString(out, it.key().ToStr()) || !PackCacheWriteSprite(out, it.value().value))
				return false;
		
		return true;
	}

	static BoolType PackCacheReadSpriteMap(QDataStream& in, Map*& map, QVector<Sprite*>& sprites)
	{
		qint32 count = 0;
		in >> count;
		if (in.status() != QDataStream::Ok || count < 0 || count > PACK_CACHE_MAX_RECORDS)
			return false;

		map = new Map();
		for (qint32 i = 0; i < count; i++)
		{
			StringType key;
			IntType value = null_;
			if (!PackCacheReadString(in, key) || !PackCacheReadSprite(in, value, sprites))
				return false;
			map->Set(key, { value, 0 });
		}
		return true;
	}

	static BoolType PackCacheWriteUvMap(QDataStream& out, IntType id)
	{
		Map* map = FindMap(id);
		if (!map)
		{
			out << (qint32)0;
			return out.status() == QDataStream::Ok;
		}

		qint32 count = map->map.size();
		out << count;
		if (count < 0 || count > PACK_CACHE_MAX_RECORDS)
			return false;

		for (auto it = map->map.cbegin(); it != map->map.cend(); it++)
		{
			if (!it.value().value.IsArray() || !PackCacheWriteString(out, it.key().ToStr()))
				return false;

			const ArrType& values = it.value().value.Arr();
			if (values.Size() != 4)
				return false;

			for (IntType j = 0; j < 4; j++)
				out << VarGetReal(values.Value(j));
		}
		return out.status() == QDataStream::Ok;
	}

	static BoolType PackCacheReadUvMap(QDataStream& in, Map*& map)
	{
		qint32 count = 0;
		in >> count;
		if (in.status() != QDataStream::Ok || count < 0 || count > PACK_CACHE_MAX_RECORDS)
			return false;

		map = new Map();
		for (qint32 i = 0; i < count; i++)
		{
			StringType key;
			ArrType values;
			if (!PackCacheReadString(in, key))
				return false;

			for (IntType j = 0; j < 4; j++)
			{
				RealType value = 0;
				in >> value;
				values[j] = value;
			}

			if (in.status() != QDataStream::Ok)
				return false;

			map->Set(key, { values, 0 });
		}
		return true;
	}

	static void PackCacheDeleteSprites(const QVector<Sprite*>& sprites)
	{
		for (Sprite* sprite : sprites)
			delete sprite;
	}

	void res_save_pack_cache(Scope<obj_resource> self, StringType filename)
	{
		obj_resource* res = self.object;
		obj_minecraft_assets* assets = ObjType(obj_minecraft_assets, global::mc_assets);
		List* modelTextures = FindList(assets->model_texture_list);

		QByteArray midataDigest = PackCacheMidataDigest();
		if (!modelTextures || midataDigest.isEmpty())
			return;

		QSaveFile file(filename.QStr());
		if (!file.open(QIODevice::WriteOnly))
			return;

		QDataStream out(&file);
		QByteArray assetsVersion = global::_app->setting_minecraft_assets_version.QStr().toUtf8();
		PackCacheSource sourceInfo = PackCacheSourceInfo(PackCacheSourceFilename(self));

		// Write cache identity
		out << PACK_CACHE_FORMAT;
		out << (quint16)assetsVersion.size();
		out.writeRawData(assetsVersion.constData(), assetsVersion.size());
		out << (quint8)midataDigest.size();
		out.writeRawData(midataDigest.constData(), midataDigest.size());
		out << sourceInfo.size;
		out << sourceInfo.modified;
		out << (qint32)VarGetInt(res->pack_format);

		// Write processed textures
		auto writeSprite = [&out](IntType id) { return PackCacheWriteSprite(out, id); };
		BoolType valid = writeSprite(res->block_preview_texture);

		for (IntType i = 0; valid && i < modelTextures->vec.size(); i++)
		{
			VarType name = modelTextures->Value(i);
			valid = writeSprite(DsMap(res->model_texture_map).Value(name))
				&& writeSprite(DsMap(res->model_texture_material_map).Value(name))
				&& writeSprite(DsMap(res->model_texture_normal_map).Value(name));
		}

		for (IntType size = 0; valid && size < e_block_sheet_static_amount; size++)
			valid = writeSprite(res->block_sheet_texture[size])
				&& writeSprite(res->block_sheet_texture_material[size])
				&& writeSprite(res->block_sheet_texture_normal[size]);

		qint32 animatedFrames = VarGetInt(global::minecraft_block_animated_sheet_frame_count);
		out << animatedFrames;
		if (!res->block_sheet_texture[e_block_sheet_ANIMATED].IsArray()
			|| !res->block_sheet_texture_material[e_block_sheet_ANIMATED].IsArray()
			|| !res->block_sheet_texture_normal[e_block_sheet_ANIMATED].IsArray())
			valid = false;
		else
		{
			const ArrType& diffuse = res->block_sheet_texture[e_block_sheet_ANIMATED].Arr();
			const ArrType& material = res->block_sheet_texture_material[e_block_sheet_ANIMATED].Arr();
			const ArrType& normal = res->block_sheet_texture_normal[e_block_sheet_ANIMATED].Arr();

			if (diffuse.Size() != animatedFrames || material.Size() != animatedFrames || normal.Size() != animatedFrames)
				valid = false;

			for (IntType frame = 0; valid && frame < animatedFrames; frame++)
				valid = writeSprite(diffuse.Value(frame)) && writeSprite(material.Value(frame)) && writeSprite(normal.Value(frame));
		}

		valid = valid && PackCacheWriteDepthList(out, res->block_sheet_depth_list)
			&& PackCacheWriteDepthList(out, res->block_sheet_ani_depth_list);
		valid = valid
			&& writeSprite(res->colormap_grass_texture)
			&& writeSprite(res->colormap_foliage_texture)
			&& writeSprite(res->colormap_dry_foliage_texture);

		for (IntType size = 0; valid && size < e_item_sheet_amount; size++)
			valid = writeSprite(res->item_sheet_texture[size])
				&& writeSprite(res->item_sheet_texture_material[size])
				&& writeSprite(res->item_sheet_texture_normal[size]);

		for (IntType i = 0; valid && i < 2; i++)
			valid = writeSprite(res->particles_texture[i]);

		valid = valid && PackCacheWriteSpriteMap(out, res->particle_texture_map)
			&& PackCacheWriteSpriteMap(out, res->particle_texture_atlas_map)
			&& PackCacheWriteUvMap(out, res->particle_texture_uvs_map)
			&& PackCacheWriteUvMap(out, res->particle_texture_pixeluvs_map);

		valid = valid && writeSprite(res->sun_texture);
		for (IntType i = 0; valid && i < 8; i++)
			valid = writeSprite(res->moon_textures[i]);

		valid = valid
			&& writeSprite(res->clouds_texture)
			&& writeSprite(res->glint_armor_texture)
			&& writeSprite(res->glint_item_texture);

		if (!valid || out.status() != QDataStream::Ok || !file.commit())
			file.cancelWriting();

		DEBUG("Pack cache saved to " + filename.QStr());
	}

	BoolType res_load_pack_cache(Scope<obj_resource> self, StringType filename)
	{
		obj_resource* res = self.object;
		obj_minecraft_assets* assets = ObjType(obj_minecraft_assets, global::mc_assets);
		List* modelTextures = FindList(assets->model_texture_list);

		DEBUG("Loading pack cache from " + filename.QStr());

		QByteArray midataDigest = PackCacheMidataDigest();
		if (!modelTextures || midataDigest.isEmpty())
			return PackCacheReject("assets");

		QFile file(filename.QStr());
		if (!file.open(QIODevice::ReadOnly))
			return PackCacheReject("file");

		QDataStream in(&file);

		// Read cache identity
		uchar format = 0;
		quint16 assetsVersionSize = 0;
		quint8 digestSize = 0;
		qint64 sourceSize = -1;
		qint64 sourceModified = -1;
		qint32 packFormat = 0;
		in >> format;
		in >> assetsVersionSize;
		if (in.status() != QDataStream::Ok || format != PACK_CACHE_FORMAT || !assetsVersionSize || assetsVersionSize > 64)
			return PackCacheReject("header");

		QByteArray assetsVersion(assetsVersionSize, '\0');
		if (in.readRawData(assetsVersion.data(), assetsVersionSize) != assetsVersionSize
			|| assetsVersion != global::_app->setting_minecraft_assets_version.QStr().toUtf8())
			return PackCacheReject("version");

		in >> digestSize;
		QByteArray digest(digestSize, '\0');
		if (in.status() != QDataStream::Ok || !digestSize || in.readRawData(digest.data(), digestSize) != digestSize || digest != midataDigest)
			return PackCacheReject("midata");

		in >> sourceSize;
		in >> sourceModified;
		in >> packFormat;
		if (in.status() != QDataStream::Ok)
			return PackCacheReject("sheet size");

		PackCacheSource sourceInfo = PackCacheSourceInfo(PackCacheSourceFilename(self));
		if (sourceInfo.size >= 0 && (sourceInfo.size != sourceSize || sourceInfo.modified != sourceModified))
			return PackCacheReject("source changed");

		// Read into temporary assets
		QVector<Sprite*> sprites;
		QVector<Map*> maps;
		QVector<List*> lists;
		QVector<ArrType> modelSprites;
		ArrType blockDiffuse, blockMaterial, blockNormal;
		ArrType animatedDiffuse, animatedMaterial, animatedNormal;
		ArrType itemDiffuse, itemMaterial, itemNormal, particles, moons;
		IntType packImage = null_, grass = null_, foliage = null_, dryFoliage = null_;
		IntType sun = null_, clouds = null_, glintArmor = null_, glintItem = null_;
		List* staticDepth = nullptr;
		List* animatedDepth = nullptr;
		Map* particleMap = nullptr;
		Map* particleAtlasMap = nullptr;
		Map* particleUvsMap = nullptr;
		Map* particlePixelUvsMap = nullptr;

		BoolType valid = PackCacheReadSprite(in, packImage, sprites);
		for (IntType i = 0; valid && i < modelTextures->vec.size(); i++)
		{
			ArrType images;
			IntType diffuse = null_, material = null_, normal = null_;
			valid = PackCacheReadSprite(in, diffuse, sprites)
				&& PackCacheReadSprite(in, material, sprites)
				&& PackCacheReadSprite(in, normal, sprites);

			images[0] = diffuse;
			images[1] = material;
			images[2] = normal;
			modelSprites.append(images);
		}

		for (IntType size = 0; valid && size < e_block_sheet_static_amount; size++)
		{
			IntType diffuse = null_, material = null_, normal = null_;
			valid = PackCacheReadSprite(in, diffuse, sprites)
				&& PackCacheReadSprite(in, material, sprites)
				&& PackCacheReadSprite(in, normal, sprites);

			blockDiffuse[size] = diffuse;
			blockMaterial[size] = material;
			blockNormal[size] = normal;
		}

		qint32 animatedFrames = 0;
		in >> animatedFrames;
		if (in.status() != QDataStream::Ok ||
			animatedFrames != VarGetInt(global::minecraft_block_animated_sheet_frame_count) ||
			animatedFrames < 0 ||
			animatedFrames > PACK_CACHE_MAX_RECORDS)
			valid = false;

		for (qint32 frame = 0; valid && frame < animatedFrames; frame++)
		{
			IntType diffuse = null_, material = null_, normal = null_;
			valid = PackCacheReadSprite(in, diffuse, sprites)
				&& PackCacheReadSprite(in, material, sprites)
				&& PackCacheReadSprite(in, normal, sprites);
			animatedDiffuse[frame] = diffuse;
			animatedMaterial[frame] = material;
			animatedNormal[frame] = normal;
		}

		valid = valid && PackCacheReadDepthList(in, staticDepth);
		if (staticDepth)
			lists.append(staticDepth);

		valid = valid && PackCacheReadDepthList(in, animatedDepth);
		if (animatedDepth)
			lists.append(animatedDepth);

		valid = valid
			&& PackCacheReadSprite(in, grass, sprites)
			&& PackCacheReadSprite(in, foliage, sprites)
			&& PackCacheReadSprite(in, dryFoliage, sprites);

		for (IntType size = 0; valid && size < e_item_sheet_amount; size++)
		{
			IntType diffuse = null_, material = null_, normal = null_;
			valid = PackCacheReadSprite(in, diffuse, sprites)
				&& PackCacheReadSprite(in, material, sprites)
				&& PackCacheReadSprite(in, normal, sprites);
			itemDiffuse[size] = diffuse;
			itemMaterial[size] = material;
			itemNormal[size] = normal;
		}

		for (IntType i = 0; valid && i < 2; i++)
		{
			IntType image = null_;
			valid = PackCacheReadSprite(in, image, sprites);
			particles[i] = image;
		}

		valid = valid && PackCacheReadSpriteMap(in, particleMap, sprites);
		if (particleMap)
			maps.append(particleMap);

		valid = valid && PackCacheReadSpriteMap(in, particleAtlasMap, sprites);
		if (particleAtlasMap)
			maps.append(particleAtlasMap);

		valid = valid && PackCacheReadUvMap(in, particleUvsMap);
		if (particleUvsMap)
			maps.append(particleUvsMap);

		valid = valid && PackCacheReadUvMap(in, particlePixelUvsMap);
		if (particlePixelUvsMap)
			maps.append(particlePixelUvsMap);

		valid = valid && PackCacheReadSprite(in, sun, sprites);

		for (IntType i = 0; valid && i < 8; i++)
		{
			IntType image = null_;
			valid = PackCacheReadSprite(in, image, sprites);
			moons[i] = image;
		}

		valid = valid
			&& PackCacheReadSprite(in, clouds, sprites)
			&& PackCacheReadSprite(in, glintArmor, sprites)
			&& PackCacheReadSprite(in, glintItem, sprites);

		if (!valid || in.status() != QDataStream::Ok || !in.atEnd())
		{
			PackCacheDeleteSprites(sprites);

			for (Map* map : maps)
				delete map;
			for (List* list : lists)
				delete list;

			return PackCacheReject("payload");
		}

		auto diffuseMap = new Map();
		auto materialMap = new Map();
		auto normalMap = new Map();
		for (IntType i = 0; i < modelTextures->vec.size(); i++)
		{
			VarType name = modelTextures->Value(i);
			diffuseMap->Set(name, { modelSprites[i].Value(0), 0 });
			materialMap->Set(name, { modelSprites[i].Value(1), 0 });
			normalMap->Set(name, { modelSprites[i].Value(2), 0 });
		}

		// Apply fully validated assets
		res->pack_format = (IntType)packFormat;
		res->block_preview_texture = packImage;

		res->model_texture_map = diffuseMap->id;
		res->model_texture_material_map = materialMap->id;
		res->model_texture_normal_map = normalMap->id;

		res->block_sheet_texture = blockDiffuse;
		res->block_sheet_texture[e_block_sheet_ANIMATED] = animatedDiffuse;
		res->block_sheet_texture_material = blockMaterial;
		res->block_sheet_texture_material[e_block_sheet_ANIMATED] = animatedMaterial;
		res->block_sheet_texture_normal = blockNormal;
		res->block_sheet_texture_normal[e_block_sheet_ANIMATED] = animatedNormal;
		res->block_sheet_depth_list = staticDepth->id;
		res->block_sheet_ani_depth_list = animatedDepth->id;

		res->colormap_grass_texture = grass;
		res->colormap_foliage_texture = foliage;
		res->colormap_dry_foliage_texture = dryFoliage;

		res->item_sheet_texture = itemDiffuse;
		res->item_sheet_texture_material = itemMaterial;
		res->item_sheet_texture_normal = itemNormal;

		res->particles_texture = particles;
		res->particle_texture_map = particleMap->id;
		res->particle_texture_atlas_map = particleAtlasMap->id;
		res->particle_texture_uvs_map = particleUvsMap->id;
		res->particle_texture_pixeluvs_map = particlePixelUvsMap->id;

		res->sun_texture = sun;
		res->moon_textures = moons;
		res->clouds_texture = clouds;

		res->glint_armor_texture = glintArmor;
		res->glint_item_texture = glintItem;

		DEBUG("Pack cache loaded");

		return true;
	}
}
