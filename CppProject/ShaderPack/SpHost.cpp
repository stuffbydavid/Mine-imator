#include "SpHost.hpp"

#include "World/World.hpp"
#include "AppHandler.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Render/FrameBuffer.hpp"
#include "Render/Texture.hpp"
#include "Render/TexturePage.hpp"

#include <QDir>

#if API_OPENGL
#include "SpRenderer.hpp"

#include <QOpenGLContext>
#include <QOpenGLExtraFunctions>
#include <QRegularExpression>

// Minecraft version reported to shaderpacks (MC_VERSION)
#define MC_VERSION_STRING "26.3"
#endif

namespace CppProject
{
	ArrType shaderpack_list(StringType dir)
	{
		// Folders with a "shaders" folder and zip files
		ArrType list;
		QDir d(dir.QStr());
		QStringList names;
		for (const QFileInfo& info : d.entryInfoList(QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, QDir::Name | QDir::IgnoreCase))
		{
			if (info.isDir() ? QDir(info.filePath()).exists("shaders") : info.suffix().toLower() == "zip")
				names.append(info.fileName());
		}
		for (const QString& name : names)
			list.Append(StringType(name));
		return list;
	}

#if API_OPENGL
	using namespace ShaderPacks;

	namespace
	{
		// A vertex buffer submitted during a recorded frame.
		struct DrawRecord
		{
			QVector<HostMesh> meshes;
			ObjectState object;
			GeometryPhase phase;
			BoolType shadows;
		};

		struct HostState
		{
			std::unique_ptr<Pack> pack;
			std::unique_ptr<Renderer> renderer;
			QString path, error;

			// Recording
			BoolType recording = false;
			QVector<DrawRecord> records;
			GeometryPhase phase = GeometryPhase::Entities;
			BoolType shadows = true;
			QVector4D color = QVector4D(1.f, 1.f, 1.f, 1.f);
			HostTexture texture, normals, specular;
			HostTexture sun, moon;
			BoolType moonPhaseGrid = true;

			// Frame
			FrameState frame;
			QMatrix4x4 miToMc; // Mine-imator world (16 units per block, Z up) to Minecraft world
		};

		HostState& Host()
		{
			static HostState state;
			return state;
		}

		QMatrix4x4 ToQMatrix(const Matrix& m)
		{
			QMatrix4x4 q;
			float* d = q.data(); // Column-major like Matrix
			for (int i = 0; i < 16; i++)
				d[i] = (float)m.m[i];
			return q;
		}

		QVector3D ToQVector(const VecType& v)
		{
			return QVector3D((float)v.x, (float)v.y, (float)v.z);
		}

		// Returns the GL texture and UV rectangle of a Mine-imator texture ID.
		HostTexture ResolveTexture(IntType id)
		{
			HostTexture t;
			if (id <= 0)
				return t;

			if (TexturePageLocation* loc = TexturePageLocation::Find(id))
			{
				Texture* tex = loc->page->GetTexture();
				t.id = (unsigned int)tex->GetId();
				t.uvRect = QVector4D((float)loc->uvRect.x, (float)loc->uvRect.y, (float)loc->uvRect.w, (float)loc->uvRect.h);
				t.size = QSize(loc->page->size, loc->page->size);

				// Mipmaps are only built while texture filtering is enabled for the object
				t.mipmapped = GFX->mipMap && Texture::hasMipMaps.value(t.id, false);
			}
			else
				t.id = (unsigned int)id; // Surface or other OpenGL texture

			// Mine-imator stores textures bottom-up and flips V when sampling, fold that into the rectangle
			t.uvRect = QVector4D(t.uvRect.x(), 1.f - t.uvRect.y(), t.uvRect.z(), -t.uvRect.w());
			return t;
		}

		// Returns the Minecraft block ID of a Mine-imator block and state with the pack's block.properties.
		void BuildBlockTable(HostState& h)
		{
			QVector<int> offsets, ids;
			if (!h.pack || !h.pack->idMap.hasBlocks)
			{
				h.renderer->SetBlockIdTable(offsets, ids);
				return;
			}

			// Minecraft IDs of each Mine-imator block with the state variables they imply
			QHash<obj_block*, QVector<QPair<QString, ArrType>>> blockMcIds;
			for (auto it = Builder::mcBlockIdObjMap.constBegin(); it != Builder::mcBlockIdObjMap.constEnd(); ++it)
			{
				QString mcId = it.key().QStr();
				if (mcId == "grass_path")
					continue;
				blockMcIds[it.value()].append({ mcId, Builder::mcBlockIdStateVarsMap.value(it.key()) });
			}

			offsets.fill(-1, Builder::blocks.Size());
			for (IntType b = 1; b < Builder::blocks.Size(); b++)
			{
				obj_block* block = Builder::blocks.Value(b);
				if (!block || !blockMcIds.contains(block))
					continue;

				const QVector<QPair<QString, ArrType>>& candidates = blockMcIds[block];
				IntType states = std::max<IntType>(1, (IntType)block->state_id_amount);
				offsets[b] = ids.size();

				for (IntType s = 0; s < states; s++)
				{
					// State variables of the Mine-imator state as name/value pairs
					QHash<QString, QString> vars;
					ArrType arr = block_get_state_id_state_vars(block->id, s);
					for (IntType i = 0; i + 1 < arr.Size(); i += 2)
						vars[arr.Value(i).ToStr().QStr()] = arr.Value(i + 1).ToStr().QStr();

					// The Minecraft ID whose implied variables match the state best
					int best = -1, bestScore = -1;
					for (int c = 0; c < candidates.size(); c++)
					{
						const ArrType& implied = candidates[c].second;
						int score = 0;
						bool match = true;
						for (IntType i = 0; i + 1 < implied.Size(); i += 2)
						{
							if (vars.value(implied.Value(i).ToStr().QStr()) == implied.Value(i + 1).ToStr().QStr())
								score++;
							else
								match = false;
						}
						if (match)
							score += 1000;
						if (score > bestScore)
						{
							best = c;
							bestScore = score;
						}
					}

					int id = -1;
					if (best >= 0)
					{
						QHash<QString, QString> state = vars;
						const ArrType& implied = candidates[best].second;
						for (IntType i = 0; i + 1 < implied.Size(); i += 2)
							state.remove(implied.Value(i).ToStr().QStr());
						id = h.pack->idMap.BlockId("minecraft:" + candidates[best].first, state);
					}
					ids.append(id);
				}
			}

			h.renderer->SetBlockIdTable(offsets, ids);
		}

		// Restores the OpenGL state Mine-imator expects after the shaderpack pipeline ran.
		void RestoreGfxState(GLint fbo, const GLint viewport[4])
		{
			QOpenGLExtraFunctions* gl = QOpenGLContext::currentContext()->extraFunctions();
			for (int u = 0; u < 32; u++)
				gl->glBindSampler(u, 0);
			gl->glActiveTexture(GL_TEXTURE0);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
			gl->glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
			gl->glBindVertexArray(GFX->glCurrentVboId);
			gl->glFrontFace(GL_CW);
			gl->glDepthFunc(GL_LEQUAL);
			gl->glDisable(GL_SCISSOR_TEST);
			gl->glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

			if (GFX->depthTest)
				gl->glEnable(GL_DEPTH_TEST);
			else
				gl->glDisable(GL_DEPTH_TEST);
			gl->glDepthMask(GFX->depthMask ? GL_TRUE : GL_FALSE);

			if (GFX->culling)
				gl->glEnable(GL_CULL_FACE);
			else
				gl->glDisable(GL_CULL_FACE);
			gl->glCullFace(GFX->cullFront ? GL_FRONT : GL_BACK);

			gl->glEnable(GL_BLEND);
			gl->glBlendFuncSeparate(GFX->glBlendMap[GFX->blendSrcFactor], GFX->glBlendMap[GFX->blendDstFactor],
									GFX->glBlendMap[GFX->blendAlphaSrcFactor], GFX->glBlendMap[GFX->blendAlphaDstFactor]);

			if (GFX->shader && GFX->shader->IsLoaded())
				gl->glUseProgram(GFX->shader->program->programId());
			else
				gl->glUseProgram(0);
		}

		// Draws the recorded geometry of the given phases.
		void DrawRecords(HostState& h, const QVector<GeometryPhase>& phases, BoolType shadowPass)
		{
			for (GeometryPhase phase : phases)
			{
				bool begun = false, available = true;
				for (const DrawRecord& rec : h.records)
				{
					if (rec.phase != phase || (shadowPass && !rec.shadows))
						continue;
					if (!begun)
					{
						begun = true;
						available = h.renderer->BeginPhase(phase);
					}
					if (!available)
						break;
					for (const HostMesh& mesh : rec.meshes)
						h.renderer->Draw(mesh, rec.object);
				}
				if (begun && available)
					h.renderer->EndPhase();
			}
		}
	}

	namespace ShaderPackHost
	{
		BoolType IsRecording()
		{
			return Host().recording;
		}

		void RecordVertexBuffer(VertexBuffer* buffer)
		{
			HostState& h = Host();
			DrawRecord rec;
			for (Mesh<>* mesh : buffer->meshes)
			{
				if (!mesh->glVertexBuffer || !mesh->glIndexBuffer || !mesh->numIndices)
					continue;
				HostMesh m;
				m.vbo = mesh->glVertexBuffer->bufferId();
				m.ibo = mesh->glIndexBuffer->bufferId();
				m.indexCount = (int)mesh->numIndices;
				m.vertexStride = sizeof(Vertex);
				rec.meshes.append(m);
			}
			if (rec.meshes.isEmpty())
				return;

			rec.object.model = h.miToMc * ToQMatrix(GFX->matrixM);
			rec.object.colorModulator = h.color;
			rec.object.texture = h.texture;
			rec.object.normals = h.normals;
			rec.object.specular = h.specular;
			rec.object.cullBackFaces = GFX->culling;
			rec.phase = h.phase;
			rec.shadows = h.shadows;
			h.records.append(rec);
		}

		void SetTexture(IntType sampler, IntType id)
		{
			HostState& h = Host();
			Shader* shader = GFX->shader;
			if (!shader)
				return;

			// Sampler name of the Mine-imator shader used for recording (see render_world)
			QString name;
			for (auto it = shader->samplerNameMap.constBegin(); it != shader->samplerNameMap.constEnd(); ++it)
				if (it.value() == sampler)
					name = it.key().QStr();

			if (name == "uTexture")
				h.texture = ResolveTexture(id);
			else if (name == "uTextureNormal")
			{
				// Only use normal maps laid out like the base texture
				HostTexture n = ResolveTexture(id);
				h.normals = (n.uvRect == h.texture.uvRect) ? n : HostTexture();
			}
		}
	}

	BoolType shaderpack_load(StringType path, StringType options)
	{
		HostState& h = Host();
		shaderpack_unload();
		h.path = path.QStr();

		QOpenGLContext* ctx = QOpenGLContext::currentContext();
		if (!ctx)
		{
			h.error = "No OpenGL context";
			return false;
		}

		// Option values as "NAME=value" separated by semicolons or new lines, "!profile=NAME" selects a profile
		LoadSettings settings;
		for (const QString& entry : options.QStr().split(QRegularExpression("[;\\n]"), Qt::SkipEmptyParts))
		{
			int eq = entry.indexOf('=');
			if (eq <= 0)
				continue;
			QString key = entry.left(eq).trimmed(), value = entry.mid(eq + 1).trimmed();
			if (key == "!profile")
				settings.profile = value;
			else
				settings.optionValues[key] = value;
		}

		QOpenGLFunctions* f = ctx->functions();
		QSurfaceFormat format = ctx->format();
		int glVersion = format.majorVersion() * 100 + format.minorVersion() * 10;
		QString glslString = QString::fromLatin1((const char*)f->glGetString(GL_SHADING_LANGUAGE_VERSION));
		QStringList glslParts = glslString.section(' ', 0, 0).split('.');
		int glslVersion = glslParts.value(0).toInt() * 100 + glslParts.value(1).left(2).toInt();
		QStringList extensions;
		for (const QByteArray& e : ctx->extensions())
			extensions.append(QString::fromLatin1(e));
		settings.environmentDefines = CreateStandardMacros(MC_VERSION_STRING, glVersion, glslVersion,
														   QString::fromLatin1((const char*)f->glGetString(GL_VENDOR)),
														   QString::fromLatin1((const char*)f->glGetString(GL_RENDERER)), extensions);
		settings.computeSupported = (glVersion >= 430);
		settings.tessellationSupported = (glVersion >= 400);

		QOpenGLExtraFunctions* gl = ctx->extraFunctions();
		GLint prevFbo = 0, viewport[4];
		gl->glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFbo);
		gl->glGetIntegerv(GL_VIEWPORT, viewport);
		struct Restore
		{
			GLint fbo;
			const GLint* viewport;
			~Restore() { RestoreGfxState(fbo, viewport); }
		} restore{ prevFbo, viewport };

		QString error;
		h.pack = Pack::Load(h.path, settings, &error);
		if (!h.pack)
		{
			h.error = error;
			return false;
		}

		h.renderer.reset(new Renderer);
		if (!h.renderer->Init(h.pack.get(), &error))
		{
			h.error = error;
			h.renderer.reset();
			h.pack.reset();
			return false;
		}
		BuildBlockTable(h);

		h.error = h.renderer->errors.join('\n');
		DEBUG("Loaded shaderpack " + h.path);
		return true;
	}

	void shaderpack_unload()
	{
		HostState& h = Host();
		if (h.renderer)
			h.renderer->Destroy();
		h.renderer.reset();
		h.pack.reset();
		h.records.clear();
		h.recording = false;
		h.error.clear();
	}

	BoolType shaderpack_is_loaded()
	{
		return Host().renderer != nullptr;
	}

	StringType shaderpack_get_path()
	{
		return Host().path;
	}

	StringType shaderpack_get_error()
	{
		return Host().error;
	}

	void shaderpack_frame_begin(VecType from, VecType to, VecType up, RealType fov, RealType zNear, RealType zFar,
								RealType skyTime, RealType skyRotation, RealType time, IntType width, IntType height)
	{
		HostState& h = Host();
		if (!h.renderer)
			return;

		// Minecraft's east (+X) points to the sunrise direction of Mine-imator's sky rotation, Y up,
		// and Mine-imator's left-handed world is mirrored into Minecraft's right-handed one.
		const RealType groundHeight = 64.0;
		RealType a = (skyRotation - 90.0) * DEGTORAD;
		RealType dx = std::cos(a), dy = -std::sin(a);
		QMatrix4x4 m;
		m.setRow(0, QVector4D(dx, dy, 0.f, 0.f) / 16.f);
		m.setRow(1, QVector4D(0.f, 0.f, 1.f / 16.f, groundHeight));
		m.setRow(2, QVector4D(-dy, dx, 0.f, 0.f) / 16.f);
		m.setRow(3, QVector4D(0.f, 0.f, 0.f, 1.f));
		h.miToMc = m;

		FrameState& f = h.frame;
		f.width = (int)std::max<IntType>(1, width);
		f.height = (int)std::max<IntType>(1, height);
		QVector3D eye = h.miToMc.map(ToQVector(from));
		f.cameraPosition = { eye.x(), eye.y(), eye.z() };

		// View rotation from the look direction and up vector in Minecraft space
		QVector3D forward = h.miToMc.mapVector(ToQVector(to) - ToQVector(from)).normalized();
		QVector3D upDir = h.miToMc.mapVector(ToQVector(up)).normalized();
		if (forward.isNull())
			forward = QVector3D(0.f, 0.f, 1.f);
		if (upDir.isNull() || std::abs(QVector3D::dotProduct(forward, upDir)) > 0.999f)
			upDir = QVector3D(0.f, 1.f, 0.f);
		QMatrix4x4 view;
		view.lookAt(QVector3D(0.f, 0.f, 0.f), forward, upDir);
		f.useViewRotation = true;
		f.viewRotation = view;
		f.clockwiseFrontFaces = true; // Mine-imator's meshes, the view is mirrored into Minecraft's coordinates
		f.pitch = (float)(std::asin(qBound(-1.f, -forward.y(), 1.f)) * RADTODEG);
		f.yaw = (float)(std::atan2(-forward.x(), forward.z()) * RADTODEG);

		f.fov = (float)fov;
		f.nearPlane = (float)std::max(0.01, zNear / 16.0);
		f.renderDistance = (float)qBound(32.0, zFar / 16.0, 1024.0);

		// Sky time 0 is noon in Mine-imator
		RealType worldTime = std::fmod(6000.0 + skyTime / 360.0 * 24000.0, 24000.0);
		if (worldTime < 0.0)
			worldTime += 24000.0;
		f.worldTime = (int)worldTime;
		f.frameTimeCounter = (float)std::fmod(time / 60.0, 3600.0);
		f.frameTime = 1.f / 60.f;

		h.records.clear();
		h.phase = GeometryPhase::Entities;
		h.shadows = true;
		h.color = QVector4D(1.f, 1.f, 1.f, 1.f);
		h.texture = h.normals = h.specular = HostTexture();
		h.recording = true;
	}

	void shaderpack_set_environment(IntType skyColor, IntType fogColor, RealType rain, RealType thunder, IntType moonPhase)
	{
		HostState& h = Host();
		h.frame.moonPhase = (int)((moonPhase % 8 + 8) % 8);
		auto color = [](IntType c) { return QVector3D((c & 255) / 255.f, ((c >> 8) & 255) / 255.f, ((c >> 16) & 255) / 255.f); };
		h.frame.skyColor = color(skyColor);
		h.frame.fogColor = color(fogColor);
		h.frame.rainStrength = (float)rain;
		h.frame.thunderStrength = (float)thunder;
	}

	void shaderpack_set_sky_textures(IntType sun, IntType moon, BoolType moonPhaseGrid)
	{
		HostState& h = Host();
		h.sun = ResolveTexture(sun);
		h.moon = ResolveTexture(moon);
		h.moonPhaseGrid = moonPhaseGrid;
	}

	void shaderpack_set_phase(IntType phase)
	{
		if (phase >= 0 && phase < (IntType)GeometryPhase::Count)
			Host().phase = (GeometryPhase)phase;
	}

	void shaderpack_set_shadows(BoolType shadows)
	{
		Host().shadows = shadows;
	}

	void shaderpack_set_color(IntType color, RealType alpha)
	{
		Host().color = QVector4D((color & 255) / 255.f, ((color >> 8) & 255) / 255.f, ((color >> 16) & 255) / 255.f, (float)alpha);
	}

	BoolType shaderpack_frame_end(IntType surfaceId, IntType iterations)
	{
		HostState& h = Host();
		h.recording = false;
		Surface* surface = FindSurface(surfaceId);
		if (!h.renderer || !surface || !surface->frameBuffer)
			return false;

		GFX->SubmitBatch();
		QOpenGLExtraFunctions* gl = QOpenGLContext::currentContext()->extraFunctions();
		GLint prevFbo = 0, viewport[4];
		gl->glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFbo);
		gl->glGetIntegerv(GL_VIEWPORT, viewport);

		static const QVector<GeometryPhase> solidPhases = {
			GeometryPhase::TerrainSolid, GeometryPhase::TerrainCutout, GeometryPhase::Entities,
			GeometryPhase::Block, GeometryPhase::Particles, GeometryPhase::Textured, GeometryPhase::TexturedLit,
			GeometryPhase::Basic, GeometryPhase::Clouds
		};
		static const QVector<GeometryPhase> translucentPhases = {
			GeometryPhase::Water, GeometryPhase::EntitiesTranslucent, GeometryPhase::BlockTranslucent,
			GeometryPhase::ParticlesTranslucent, GeometryPhase::Weather
		};
		QVector<GeometryPhase> allPhases = solidPhases + translucentPhases;

		IntType count = std::max<IntType>(1, iterations);
		for (IntType i = 0; i < count; i++)
		{
			h.renderer->BeginFrame(h.frame);
			if (h.renderer->BeginShadow())
			{
				DrawRecords(h, allPhases, true);
				h.renderer->EndShadow();
			}
			h.renderer->DrawSky(h.sun, h.moon, h.moonPhaseGrid);
			DrawRecords(h, solidPhases, false);
			h.renderer->BeginTranslucent();
			DrawRecords(h, translucentPhases, false);
			h.renderer->EndFrame(surface->frameBuffer->glFboId, QRect(0, 0, surface->size.width(), surface->size.height()));
		}

		h.records.clear();
		RestoreGfxState(prevFbo, viewport);

		QStringList errors = h.renderer->errors;
		h.renderer->errors.clear();
		if (!errors.isEmpty())
			h.error = errors.join('\n');
		return true;
	}

#else // Direct3D 11 builds

	namespace ShaderPackHost
	{
		BoolType IsRecording() { return false; }
		void RecordVertexBuffer(VertexBuffer*) {}
		void SetTexture(IntType, IntType) {}
	}

	BoolType shaderpack_load(StringType, StringType) { return false; }
	void shaderpack_unload() {}
	BoolType shaderpack_is_loaded() { return false; }
	StringType shaderpack_get_path() { return ""; }
	StringType shaderpack_get_error() { return "Shaderpacks require the OpenGL renderer"; }
	void shaderpack_frame_begin(VecType, VecType, VecType, RealType, RealType, RealType, RealType, RealType, RealType, IntType, IntType) {}
	void shaderpack_set_environment(IntType, IntType, RealType, RealType, IntType) {}
	void shaderpack_set_sky_textures(IntType, IntType, BoolType) {}
	void shaderpack_set_phase(IntType) {}
	void shaderpack_set_shadows(BoolType) {}
	void shaderpack_set_color(IntType, RealType) {}
	BoolType shaderpack_frame_end(IntType, IntType) { return false; }
#endif
}
