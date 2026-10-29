#include "Generated/Scripts.hpp"

#include "Asset/VertexBuffer.hpp"
#include "World/GZIP.hpp"

#include <QDataStream>

#define BLOCK_MESH_CACHE_ENABLED 1

namespace CppProject
{
	static constexpr uchar BLOCK_MESH_CACHE_FORMAT = 5;

	// 2.0 mesh cache uses untransformed vertices and a 32x32 static block sheet
	static constexpr uchar BLOCK_MESH_CACHE_FORMAT_LEGACY = 2;
	static constexpr IntType BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE = 32;

	void res_save_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return;
	#endif

		obj_resource* res = self.object;
		if (!res->block_meshes.Size())
			return;

		QByteArray assetsVersion = VarGetStr(global::_app->setting_minecraft_assets_version).QStr().toUtf8();
		qint64 totalBytes = sizeof(uchar) + sizeof(quint16) + assetsVersion.size() + sizeof(qint64) * 3 + sizeof(qint32) * 3;
		RealType approxGzipRatio = 0.14;

		for (IntType s = 0; s < res->block_meshes.Size(); s++)
		{
			totalBytes += sizeof(quint8);

			obj_block_mesh* blockMesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
			if (!blockMesh || !blockMesh->block_vbuffer_render_order.Size())
				continue;

			totalBytes += sizeof(quint64);

			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
			{
				if (!blockMesh->block_vbuffer_active.BoolValue(i))
					continue;

				VertexBuffer* vbuf = FindVertexBuffer(blockMesh->block_vbuffer.IntValue(i));
				if (!vbuf)
					return;

				totalBytes += vbuf->GetWriteBytes();
			}
		}

		if (totalBytes > std::numeric_limits<int>::max())
		{
			WARNING("Block mesh cache exceeds the byte array size limit");
			return;
		}
		
		IntType mb = ceil((totalBytes / 1000000.0) * approxGzipRatio);
		if (mb > 50)
		{
			if (res->scenery_cache_save == null_)
				res->scenery_cache_save = question(text_get({ "load_scenery/save_cache", string(mb) + StringType("MB") }));

			if (!res->scenery_cache_save)
				return;
		}

		Timer tmr;
		QByteArray data;
		data.reserve((int)totalBytes);

		QDataStream out(&data, QIODevice::WriteOnly);

		// Save format
		uchar format = BLOCK_MESH_CACHE_FORMAT;
		out << format;

		// Save Minecraft assets version
		out << (quint16)assetsVersion.size();
		out.writeRawData(assetsVersion.constData(), assetsVersion.size());

		// Save size
		out << (qint64)res->scenery_size[X_];
		out << (qint64)res->scenery_size[Y_];
		out << (qint64)res->scenery_size[Z_];
		out << (qint32)res->block_meshes_num.Value(X_);
		out << (qint32)res->block_meshes_num.Value(Y_);
		out << (qint32)res->block_meshes_num.Value(Z_);

		// Write meshes and active buffers in XYZ order
		for (IntType s = 0; s < res->block_meshes.Size(); s++)
		{
			obj_block_mesh* blockMesh = ObjTypeOpt(obj_block_mesh, res->block_meshes.Value(s));
			BoolType present = blockMesh && blockMesh->block_vbuffer_render_order.Size();
			out << quint8(present);
			if (!present)
				continue;

			quint64 mask = 0;
			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
				if (blockMesh->block_vbuffer_active.BoolValue(i))
					mask |= quint64(1) << i;

			out << mask;
			for (IntType i = 0; i < e_block_depth_amount * e_block_vbuffer_amount; i++)
				if (mask & (quint64(1) << i))
					FindVertexBuffer(blockMesh->block_vbuffer.IntValue(i))->Write(out);
		}

		tmr.Print("Write block mesh cache (" + filename.QStr() + ")");

		if (out.status() != QDataStream::Ok || data.size() != totalBytes)
		{
			WARNING("Could not serialize block mesh cache");
			return;
		}

		Gzip::WriteAsync(std::move(data), filename.QStr(), "Block mesh cache", 8);
	}

	static BoolType LoadLegacyBlockCache(Scope<obj_resource> self, QDataStream& in);

	BoolType res_load_block_cache(Scope<obj_resource> self, StringType filename)
	{
	#if !BLOCK_MESH_CACHE_ENABLED
		return false;
	#endif

		Timer tmr;
		tmr.Print("Unzip block mesh cache");

		QByteArray data;
		BoolType decompressed = Gzip::Decompress(filename, data);
		if (!decompressed)
			return false;

		tmr.Reset();

		QDataStream in(&data, QIODevice::ReadOnly);

		uchar format = 0;
		in >> format;
		if (in.status() != QDataStream::Ok)
			return false;

		// Legacy file
		if (format == BLOCK_MESH_CACHE_FORMAT_LEGACY)
		{
			BoolType loaded = LoadLegacyBlockCache(self, in);
			if (loaded)
				tmr.Print("Load legacy block mesh cache");

			return loaded;
		}

		if (in.status() != QDataStream::Ok || format != BLOCK_MESH_CACHE_FORMAT)
			return false;

		quint16 assetsVersionSize = 0;
		in >> assetsVersionSize;
		if (in.status() != QDataStream::Ok || !assetsVersionSize || assetsVersionSize > 64)
			return false;

		QByteArray assetsVersion(assetsVersionSize, '\0');
		if (in.readRawData(assetsVersion.data(), assetsVersionSize) != assetsVersionSize
			|| assetsVersion != VarGetStr(global::_app->setting_minecraft_assets_version).QStr().toUtf8())
			return false;

		// Load size
		qint64 sizeX = 0, sizeY = 0, sizeZ = 0;
		qint32 dimX = 0, dimY = 0, dimZ = 0;
		in >> sizeX;
		in >> sizeY;
		in >> sizeZ;
		in >> dimX;
		in >> dimY;
		in >> dimZ;
		if (in.status() != QDataStream::Ok || sizeX <= 0 || sizeY <= 0 || sizeZ <= 0 ||
			sizeX > std::numeric_limits<qint32>::max() || sizeY > std::numeric_limits<qint32>::max() ||
			sizeZ > std::numeric_limits<qint32>::max() ||
			dimX != (sizeY + block_mesh_size - 1) / block_mesh_size ||
			dimY != (sizeX + block_mesh_size - 1) / block_mesh_size ||
			dimZ != (sizeZ + block_mesh_size - 1) / block_mesh_size)
			return false;

		qint64 meshCount = qint64(dimX) * dimY * dimZ;
		if (meshCount > in.device()->bytesAvailable() || meshCount > std::numeric_limits<int>::max())
			return false;

		const IntType vbufCount = e_block_depth_amount * e_block_vbuffer_amount;
		QVector<QVector<VertexBuffer*>> meshVbuffers((int)meshCount);
		BoolType valid = true;

		for (IntType s = 0; s < meshCount && valid; s++)
		{
			quint8 present = 0;
			in >> present;
			if (in.status() != QDataStream::Ok || present > 1)
			{
				valid = false;
				break;
			}

			if (!present)
				continue;

			quint64 mask = 0;
			in >> mask;
			if (in.status() != QDataStream::Ok || !mask || (mask >> vbufCount))
			{
				valid = false;
				break;
			}

			meshVbuffers[s].resize(vbufCount);
			for (IntType i = 0; i < vbufCount; i++)
			{
				if (!(mask & (quint64(1) << i)))
					continue;

				VertexBuffer* vbuf = new VertexBuffer(in);
				meshVbuffers[s][i] = vbuf;
				if (!vbuf->valid || !vbuf->numIndices)
				{
					valid = false;
					break;
				}
			}
		}

		if (!valid || !in.atEnd())
		{
			for (const auto& vbuffers : meshVbuffers)
				for (VertexBuffer* vbuf : vbuffers)
					delete vbuf;
			
			return false;
		}

		block_meshes_destroy(self);

		ArrType meshes, meshActive;
		BoolType transparent = false;

		for (IntType s = 0; s < meshCount; s++)
		{
			meshes[s] = null_;
			meshActive[s] = false;
			if (meshVbuffers[s].isEmpty())
				continue;

			obj_block_mesh* blockMesh = new obj_block_mesh;
			ArrType buffers, active, depths;
			for (IntType d = 0; d < e_block_depth_amount; d++)
				depths[d] = false;

			for (IntType i = 0; i < vbufCount; i++)
			{
				if (i % e_block_vbuffer_amount == 0)
					blockMesh->block_vbuffer_render_offsets[i / e_block_vbuffer_amount] = blockMesh->block_vbuffer_render_order.Size();

				VertexBuffer* vbuf = meshVbuffers[s][i];
				buffers[i] = (vbuf ? vbuf->id : null_);
				active[i] = (vbuf != nullptr);
				if (vbuf)
				{
					IntType depth = i / e_block_vbuffer_amount;
					depths[depth] = true;
					if (depth != e_block_depth_DEPTH0)
						transparent = true;

					blockMesh->block_vbuffer_render_order.Append(i);
				}
			}

			blockMesh->block_vbuffer = buffers;
			blockMesh->block_vbuffer_active = active;
			blockMesh->block_vbuffer_depth_active = depths;
			blockMesh->block_vbuffer_render_offsets[e_block_depth_amount] = blockMesh->block_vbuffer_render_order.Size();

			meshes[s] = blockMesh->id;
			meshActive[s] = true;
		}

		self->scenery_size = { (RealType)sizeX, (RealType)sizeY, (RealType)sizeZ };
		self->block_meshes_num = ArrType::From({ (RealType)dimX, (RealType)dimY, (RealType)dimZ });
		self->block_meshes = meshes;
		self->block_meshes_active = meshActive;
		self->block_meshes_transparent = transparent;

		tmr.Print("Read block mesh cache");
		
		return true;
	}

	// Load 2.0 legacy .meshcache file.
	static BoolType LoadLegacyBlockCache(Scope<obj_resource> self, QDataStream& in)
	{
		qint64 sizeX = 0, sizeY = 0, sizeZ = 0;
		in >> sizeX;
		in >> sizeY;
		in >> sizeZ;
		if (in.status() != QDataStream::Ok || sizeX <= 0 || sizeY <= 0 || sizeZ <= 0 ||
			sizeX > std::numeric_limits<qint32>::max() || sizeY > std::numeric_limits<qint32>::max() ||
			sizeZ > std::numeric_limits<qint32>::max())
			return false;

		const qint32 dimX = (sizeY + block_mesh_size - 1) / block_mesh_size;
		const qint32 dimY = (sizeX + block_mesh_size - 1) / block_mesh_size;
		const qint32 dimZ = (sizeZ + block_mesh_size - 1) / block_mesh_size;
		const qint64 meshCount = qint64(dimX) * dimY * dimZ;
		if (meshCount > std::numeric_limits<int>::max())
			return false;

		VarType sheetSize = global::minecraft_block_sheet_size.Value(e_block_sheet_STATIC16);
		const RealType staticUvScaleX = BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE / sheetSize.Value(X_).ToReal();
		const RealType staticUvScaleY = BLOCK_MESH_CACHE_LEGACY_SHEET_SIZE / sheetSize.Value(Y_).ToReal();
		const RealType legacyBlockWidth = (RealType)sizeY * block_size_;
		const IntType vbufCount = e_block_depth_amount * e_block_vbuffer_amount;
		QVector<QVector<VertexBuffer*>> meshVbuffers((int)meshCount);

		// Format 2 stores RGBA before the UV coordinates
		struct LegacyVertex
		{
			float x, y, z;
			uint32_t normal, color;
			float u, v;
			uint32_t data, tangent;
		};
		static_assert(sizeof(LegacyVertex) == 36, "Unexpected legacy vertex layout");

		QHash<uint32_t, uint8_t> colorIndices;
		const ArrType& colors = ObjType(obj_resource, global::mc_res)->block_colors;
		for (IntType i = e_biome_color_amount; i < colors.Size() / 4; i++)
		{
			// Biome colors use the legacy buffer type, cloud colors are not block tints
			if (i >= e_color_palette_CLOUDS_TOP && i < e_color_palette_amount)
				continue;

			IntType offset = i * 4;
			IntType color = make_color_rgb(
				std::round(colors.RealValue(offset) * 255),
				std::round(colors.RealValue(offset + 1) * 255),
				std::round(colors.RealValue(offset + 2) * 255)
			);
			colorIndices[color] = i + 1;
		}

		struct LegacyBuffer
		{
			e_block_vbuffer buffer;
			uint8_t colorIndex;
		};
		static const QVector<LegacyBuffer> legacyBuffers = {
			{ e_block_vbuffer_STATIC16, 0 },
			{ e_block_vbuffer_ANIMATED, 0 },
			{ e_block_vbuffer_STATIC16, e_biome_color_GRASS + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_FOLIAGE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_OAK + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_SPRUCE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_BIRCH + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_JUNGLE + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_ACACIA + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_DARK_OAK + 1 },
			{ e_block_vbuffer_STATIC16, e_biome_color_LEAVES_MANGROVE + 1 },
			{ e_block_vbuffer_WATER, 0 }
		};
		constexpr RealType meshStride = block_mesh_size * block_size_;

		auto rotateDirection = [](uint32_t packed)
		{
			return ((packed >> 8) & 255u) |
					((255u - (packed & 255u)) << 8) |
					(packed & 0xFFFF0000u);
		};

		BoolType valid = true;
		for (IntType d = 0; d < e_block_depth_amount && valid; d++)
		for (IntType vb = 0; vb < legacyBuffers.size() && valid; vb++)
		{
			qint64 numMeshes = 0;
			in >> numMeshes;
			if (in.status() != QDataStream::Ok || numMeshes < 0 ||
				numMeshes > in.device()->bytesAvailable() / (sizeof(qint64) * 2))
			{
				valid = false;
				break;
			}

			const IntType target = d * e_block_vbuffer_amount + legacyBuffers[vb].buffer;
			const BoolType staticSheet = legacyBuffers[vb].buffer == e_block_vbuffer_STATIC16;
			for (qint64 m = 0; m < numMeshes && valid; m++)
			{
				qint64 numVert = 0, numInd = 0;
				in >> numVert;
				in >> numInd;
				if (in.status() != QDataStream::Ok || numVert <= 0 || numInd <= 0 || numInd % 3 != 0)
				{
					valid = false;
					break;
				}

				const qint64 vertexBytes = numVert * sizeof(LegacyVertex);
				const qint64 indexBytes = numInd * sizeof(uint32_t);
				if (vertexBytes > std::numeric_limits<int>::max() || indexBytes > std::numeric_limits<int>::max() ||
					vertexBytes + indexBytes > in.device()->bytesAvailable())
				{
					valid = false;
					break;
				}

				QVector<LegacyVertex> legacyVertices((int)numVert);
				QVector<Vertex> vertices((int)numVert);
				QVector<uint32_t> indices((int)numInd);
				if (in.readRawData((char*)legacyVertices.data(), (int)vertexBytes) != vertexBytes ||
					in.readRawData((char*)indices.data(), (int)indexBytes) != indexBytes)
				{
					valid = false;
					break;
				}

				for (IntType v = 0; v < numVert; v++)
				{
					const LegacyVertex& old = legacyVertices[v];
					Vertex& vertex = vertices[v];
					vertex.x = old.x;
					vertex.y = old.y;
					vertex.z = old.z;
					vertex.u = old.u;
					vertex.v = old.v;
					vertex.data1 = old.normal;
					vertex.data2 = old.data;
					vertex.tangent = old.tangent;

					if (!std::isfinite(vertex.x) || !std::isfinite(vertex.y) || !std::isfinite(vertex.z))
					{
						valid = false;
						break;
					}

					float oldX = vertex.x;
					vertex.x = vertex.y;
					vertex.y = legacyBlockWidth - oldX;
					vertex.data1 = rotateDirection(vertex.data1);

					uint8_t colorIndex = legacyBuffers[vb].colorIndex;
					uint32_t color = old.color & 0x00FFFFFFu;
					if (color != 0x00FFFFFFu)
						colorIndex = colorIndices.value(color, colorIndex);

					vertex.SetColorIndex(colorIndex);
					vertex.tangent = rotateDirection(vertex.tangent);

					if (staticSheet)
					{
						vertex.u *= staticUvScaleX;
						vertex.v *= staticUvScaleY;
					}
				}

				if (!valid)
					break;

				for (IntType i = 0; i < numInd && valid;)
				{
					BoolType quad = i + 5 < numInd && indices[i] == indices[i + 5] &&
						indices[i + 2] == indices[i + 3];

					const IntType count = quad ? 4 : 3;
					uint32_t corners[4] = { indices[i], indices[i + 1], indices[i + 2], quad ? indices[i + 4] : 0 };
					for (IntType c = 0; c < count; c++)
						if (corners[c] >= numVert)
							valid = false;

					if (!valid)
						break;

					RealType pos[3] = { 0, 0, 0 };
					for (IntType c = 0; c < count; c++)
					{
						const Vertex& vertex = vertices[corners[c]];
						pos[X_] += vertex.x;
						pos[Y_] += vertex.y;
						pos[Z_] += vertex.z;
					}

					const uint32_t normal = vertices[corners[0]].data1;
					const uint8_t packedNormal[3] = { uint8_t(normal), uint8_t(normal >> 8), uint8_t(normal >> 16) };
					IntType axis = 0;
					for (IntType a = 1; a < 3; a++)
						if (std::abs((IntType)packedNormal[a] - 127) > std::abs((IntType)packedNormal[axis] - 127))
							axis = a;

					// Bias boundary faces toward the block behind their normal
					pos[axis] -= (packedNormal[axis] > 127 ? 0.01 : -0.01) * count;

					// Convert face centers back to builder axes for mesh indexing
					const IntType sx = (IntType)std::clamp(std::floor((legacyBlockWidth - pos[Y_] / count) / meshStride), 0.0, (double)dimX - 1);
					const IntType sy = (IntType)std::clamp(std::floor(pos[X_] / count / meshStride), 0.0, (double)dimY - 1);
					const IntType sz = (IntType)std::clamp(std::floor(pos[Z_] / count / meshStride), 0.0, (double)dimZ - 1);
					const IntType meshIndex = (sz * dimY + sy) * dimX + sx;

					if (meshVbuffers[meshIndex].isEmpty())
						meshVbuffers[meshIndex].resize(vbufCount);

					VertexBuffer*& vbuf = meshVbuffers[meshIndex][target];
					if (!vbuf)
						vbuf = new VertexBuffer;

					if (quad)
						vbuf->AddFace(vertices[corners[0]], vertices[corners[1]], vertices[corners[2]], vertices[corners[3]]);
					else
						vbuf->AddTriangle(vertices[corners[0]], vertices[corners[1]], vertices[corners[2]]);

					i += quad ? 6 : 3;
				}
			}
		}

		if (!valid || !in.atEnd())
		{
			// Free buffers
			for (const auto& buffers : meshVbuffers)
			for (VertexBuffer* vbuf : buffers)
			{
				if (!vbuf)
					continue;

				delete vbuf;
			}

			return false;
		}

		ArrType meshes, meshActive;
		BoolType transparent = false;

		for (IntType s = 0; s < meshCount; s++)
		{
			meshes[s] = null_;
			meshActive[s] = false;
			if (meshVbuffers[s].isEmpty())
				continue;

			obj_block_mesh* blockMesh = new obj_block_mesh;
			ArrType buffers, active, depths;
			for (IntType d = 0; d < e_block_depth_amount; d++)
				depths[d] = false;

			for (IntType i = 0; i < vbufCount; i++)
			{
				if (i % e_block_vbuffer_amount == 0)
					blockMesh->block_vbuffer_render_offsets[i / e_block_vbuffer_amount] = blockMesh->block_vbuffer_render_order.Size();

				VertexBuffer* vbuf = meshVbuffers[s][i];
				if (vbuf)
					vbuf->Complete(false);

				buffers[i] = (vbuf ? vbuf->id : null_);
				active[i] = (vbuf != nullptr);
				if (vbuf)
				{
					IntType depth = i / e_block_vbuffer_amount;
					depths[depth] = true;
					blockMesh->block_vbuffer_render_order.Append(i);
					if (depth != e_block_depth_DEPTH0)
						transparent = true;
				}
			}

			blockMesh->block_vbuffer = buffers;
			blockMesh->block_vbuffer_active = active;
			blockMesh->block_vbuffer_depth_active = depths;
			blockMesh->block_vbuffer_render_offsets[e_block_depth_amount] = blockMesh->block_vbuffer_render_order.Size();
			meshes[s] = blockMesh->id;
			meshActive[s] = true;
		}

		block_meshes_destroy(self);

		self->scenery_size = { (RealType)sizeX, (RealType)sizeY, (RealType)sizeZ };
		self->block_meshes_num = ArrType::From({ (RealType)dimX, (RealType)dimY, (RealType)dimZ });
		self->block_meshes = meshes;
		self->block_meshes_active = meshActive;
		self->block_meshes_transparent = transparent;

		return true;
	}
}
