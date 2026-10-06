#include "SpRenderer.hpp"
#include "SpFormats.hpp"

#include <QDateTime>
#include <QOpenGLContext>
#include <QOpenGLExtraFunctions>
#include <QOpenGLFunctions_3_3_Core>
#include <QRegularExpression>

#include <cmath>
#include <random>

#ifndef GL_COMPUTE_SHADER
#define GL_COMPUTE_SHADER 0x91B9
#endif
#ifndef GL_COMPUTE_WORK_GROUP_SIZE
#define GL_COMPUTE_WORK_GROUP_SIZE 0x8267
#endif
#ifndef GL_SHADER_STORAGE_BUFFER
#define GL_SHADER_STORAGE_BUFFER 0x90D2
#endif
#ifndef GL_ALL_BARRIER_BITS
#define GL_ALL_BARRIER_BITS 0xFFFFFFFF
#endif
#ifndef GL_TESS_CONTROL_SHADER
#define GL_TESS_CONTROL_SHADER 0x8E88
#define GL_TESS_EVALUATION_SHADER 0x8E87
#endif

namespace ShaderPacks
{
	namespace
	{
		const double PI = 3.14159265358979323846;

		// Value of a uniform supplied by the renderer
		struct UVal
		{
			enum Type { NONE, FLOAT, INT } type = NONE;
			int components = 1; // 1-4, 9 = mat3, 16 = mat4
			float f[16] = { 0 };
			int i[4] = { 0 };

			static UVal Float(float v) { UVal u; u.type = FLOAT; u.f[0] = v; return u; }
			static UVal Int(int v) { UVal u; u.type = INT; u.i[0] = v; u.f[0] = (float)v; return u; }
			static UVal Vec2(float x, float y) { UVal u; u.type = FLOAT; u.components = 2; u.f[0] = x; u.f[1] = y; return u; }
			static UVal Vec3(const QVector3D& v) { UVal u; u.type = FLOAT; u.components = 3; u.f[0] = v.x(); u.f[1] = v.y(); u.f[2] = v.z(); return u; }
			static UVal Vec4(const QVector4D& v) { UVal u; u.type = FLOAT; u.components = 4; u.f[0] = v.x(); u.f[1] = v.y(); u.f[2] = v.z(); u.f[3] = v.w(); return u; }
			static UVal IVec2(int x, int y) { UVal u; u.type = INT; u.components = 2; u.i[0] = x; u.i[1] = y; u.f[0] = x; u.f[1] = y; return u; }
			static UVal IVec3(int x, int y, int z) { UVal u; u.type = INT; u.components = 3; u.i[0] = x; u.i[1] = y; u.i[2] = z; u.f[0] = x; u.f[1] = y; u.f[2] = z; return u; }
			static UVal Mat4(const QMatrix4x4& m)
			{
				UVal u;
				u.type = FLOAT;
				u.components = 16;
				const float* d = m.constData(); // Column-major
				for (int k = 0; k < 16; k++)
					u.f[k] = d[k];
				return u;
			}
			static UVal Mat3(const QMatrix4x4& m)
			{
				UVal u;
				u.type = FLOAT;
				u.components = 9;
				for (int c = 0; c < 3; c++)
					for (int r = 0; r < 3; r++)
						u.f[c * 3 + r] = m(r, c);
				return u;
			}
		};

		// Where the texture for a sampler comes from
		enum class SamplerSource
		{
			None,
			ColorTarget,	 // index = buffer
			DepthTex,		 // index = 0-2
			ShadowDepth,	 // index = 0-1
			ShadowColor,	 // index = 0-7
			Noise,
			Lightmap,
			ObjectTexture,	 // gtexture in gbuffers
			ObjectNormals,
			ObjectSpecular,
			Custom,			 // customTextures[name]
			Image,			 // custom image used as a sampler, index = image
			BlockOffsets,
			BlockIds,
		};

		struct Tex
		{
			GLuint id = 0;
			GLenum target = GL_TEXTURE_2D;
			int w = 0, h = 0, d = 1;
			InternalFormatInfo format;
			int levels = 1;
		};

		bool IsSamplerType(GLenum type)
		{
			switch (type)
			{
				case GL_SAMPLER_1D: case GL_SAMPLER_2D: case GL_SAMPLER_3D: case GL_SAMPLER_CUBE:
				case GL_SAMPLER_1D_SHADOW: case GL_SAMPLER_2D_SHADOW: case GL_SAMPLER_2D_RECT: case GL_SAMPLER_2D_RECT_SHADOW:
				case GL_SAMPLER_1D_ARRAY: case GL_SAMPLER_2D_ARRAY: case GL_SAMPLER_BUFFER:
				case GL_INT_SAMPLER_1D: case GL_INT_SAMPLER_2D: case GL_INT_SAMPLER_3D: case GL_INT_SAMPLER_2D_RECT:
				case GL_UNSIGNED_INT_SAMPLER_1D: case GL_UNSIGNED_INT_SAMPLER_2D: case GL_UNSIGNED_INT_SAMPLER_3D:
				case GL_UNSIGNED_INT_SAMPLER_2D_RECT: case GL_INT_SAMPLER_BUFFER: case GL_UNSIGNED_INT_SAMPLER_BUFFER:
					return true;
			}
			return false;
		}

		bool IsImageType(GLenum type)
		{
			return type >= 0x904C && type <= 0x906C; // GL_IMAGE_1D .. GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY
		}

		bool IsShadowSamplerType(GLenum type)
		{
			return type == GL_SAMPLER_2D_SHADOW || type == GL_SAMPLER_1D_SHADOW || type == GL_SAMPLER_2D_RECT_SHADOW;
		}
	}

	struct Renderer::Impl
	{
		Renderer* owner = nullptr;
		Pack* pack = nullptr;
		QOpenGLFunctions_3_3_Core* gl = nullptr;
		QOpenGLExtraFunctions* ex = nullptr;
		int glVersion = 33;
		bool computeSupported = false;

		// Render targets
		struct ColorTarget
		{
			bool used = false;
			Tex main, alt;
			RenderTargetSettings settings;
		};
		ColorTarget colorTargets[16];
		Tex depthTex[3];
		Tex shadowDepth[2];
		Tex shadowColor[8];
		bool shadowColorUsed[8] = {};
		bool shadowEnabled = false;
		int shadowResolution = 1024;
		Tex noiseTex, lightmapTex, whiteTex, defaultNormalsTex, defaultSpecularTex, blockOffsetsTex, blockIdsTex;
		QHash<QString, Tex> customTextures; // "stage:sampler" or "custom:name"

		struct ImageTarget
		{
			ImageSpec spec;
			Tex tex;
		};
		QVector<ImageTarget> images;
		QHash<int, GLuint> ssbos;

		int width = 0, height = 0;
		bool fullClear = true;

		// Sampler objects
		GLuint samplerNearest = 0, samplerLinear = 0, samplerLinearMip = 0, samplerNearestMip = 0;
		GLuint samplerShadowCompare = 0, samplerShadowCompareNearest = 0, samplerRepeatLinear = 0, samplerAtlas = 0, samplerAtlasNoMip = 0;

		// Geometry
		GLuint vao = 0, quadVbo = 0, quadIbo = 0;
		GLuint skyVbo = 0, skyIbo = 0;
		int skyDiscIndices = 0, skyBottomOffset = 0, skyBottomIndices = 0, skySunriseOffset = 0, skySunriseIndices = 0;
		int starsOffset = 0, starsIndices = 0, sunOffset = 0, moonOffset = 0;

		// Programs
		struct SamplerBinding
		{
			QString name;
			GLint location;
			GLenum type;
			int unit;
			SamplerSource source;
			int index;
			QString customKey;
		};
		struct ImageBinding
		{
			QString name;
			GLint location;
			int unit;
			int kind; // 0 = color target, 1 = shadow color, 2 = custom image
			int index;
			GLenum format;
		};
		struct UniformBinding
		{
			QString name;
			GLint location;
			GLenum type;
			int size;
		};
		struct Program
		{
			QString name;
			GLuint id = 0;
			ProgramKind kind = ProgramKind::Composite;
			bool isShadow = false;
			QString stage; // Texture stage: begin, prepare, shadowcomp, gbuffers, deferred, composite
			QVector<int> drawBuffers;
			QSet<int> mipmapped;
			bool hasBlend = false;
			BlendModeSpec blend;
			QHash<int, BlendModeSpec> bufferBlend;
			bool hasAlphaTest = false;
			AlphaTestSpec alphaTest;
			ScaleSpec scale;
			QHash<int, bool> flips;
			QSet<int> deactivatedOverrides; // Buffers whose custom texture overrides no longer apply (flipped earlier in the stage)
			QVector<SamplerBinding> samplers;
			QVector<ImageBinding> images;
			QVector<UniformBinding> uniforms;
			int localSize[3] = { 1, 1, 1 };
			bool hasWorkGroups = false, hasWorkGroupsRender = false;
			int workGroups[3] = { 1, 1, 1 };
			float workGroupsRender[2] = { 1.f, 1.f };
			QHash<QString, GLuint> fbos; // Framebuffer per flip state key
			int uploadedFrame = -2;
		};
		QHash<QString, Program*> programs; // Compiled programs by name
		QSet<int> compileDeactivatedOverrides; // Set while compiling the programs of a pass
		QVector<Program*> allPrograms;

		struct Pass
		{
			Program* program = nullptr;
			QVector<Program*> computes;
		};
		QVector<Pass> beginPasses, shadowcompPasses, preparePasses, deferredPasses, compositePasses;
		QVector<Program*> setupComputes;
		Program* finalProgram = nullptr;
		QVector<Program*> finalComputes;
		QVector<Program*> shadowComputes;

		// Frame state
		FrameState state;
		int frameCounter = 0;
		bool firstFrame = true;
		QSet<int> flipped;
		QSet<int> flippedAfterPrepare, flippedAfterTranslucent;
		bool flippedAfterPrepareValid = false;
		bool beforeTranslucent = true;
		bool inShadowPass = false;
		bool shadowTranslucentCopied = false;
		Program* current = nullptr;
		GeometryPhase currentPhase = GeometryPhase::Basic;
		GLint savedFrontFace = GL_CCW;

		QMatrix4x4 modelView, modelViewInv, projection, projectionInv;
		QMatrix4x4 prevModelView, prevProjection;
		QMatrix4x4 shadowModelView, shadowModelViewInv, shadowProjection, shadowProjectionInv;
		DVec3 prevCameraPosition;
		bool hasPrevious = false;
		float skyAngle = 0.f, sunAngle = 0.f, shadowAngle = 0.f;
		QVector3D sunPosition, moonPosition, shadowLightPosition, upPosition;
		float wetness = 0.f, eyeBrightnessSmooth[2] = { 0.f, 240.f }, centerDepthSmooth = 0.f;
		bool smoothInit = false;

		QHash<QString, UVal> frameUniforms;
		ExprContext exprContext;

		// Block ID lookup
		QVector<int> blockOffsets, blockIds;
		bool blockTableDirty = true;

		// ----------------------------------------------------------------------------------------

		void Log(const QString& msg)
		{
			owner->errors.append(msg);
			LogWarning(msg);
		}

		void CreateTexture(Tex& t, GLenum target, int w, int h, int d, const InternalFormatInfo& format, int levels, const void* data = nullptr,
						   GLenum dataFormat = 0, GLenum dataType = 0)
		{
			if (t.id)
				gl->glDeleteTextures(1, &t.id);
			gl->glGenTextures(1, &t.id);
			t.target = target;
			t.w = w;
			t.h = h;
			t.d = d;
			t.format = format;
			t.levels = levels;
			gl->glBindTexture(target, t.id);

			GLenum fmt = dataFormat ? dataFormat : format.pixelFormat;
			GLenum type = dataType ? dataType : format.pixelType;
			if (format.isDepth)
			{
				fmt = GL_DEPTH_COMPONENT;
				type = GL_FLOAT;
			}

			int lw = w, lh = h;
			for (int l = 0; l < levels; l++)
			{
				if (target == GL_TEXTURE_3D)
					gl->glTexImage3D(target, l, format.internalFormat, lw, lh, d, 0, fmt, type, l == 0 ? data : nullptr);
				else if (target == GL_TEXTURE_1D)
					gl->glTexImage1D(target, l, format.internalFormat, lw, 0, fmt, type, l == 0 ? data : nullptr);
				else
					gl->glTexImage2D(target, l, format.internalFormat, lw, lh, 0, fmt, type, l == 0 ? data : nullptr);
				lw = qMax(1, lw / 2);
				lh = qMax(1, lh / 2);
			}

			gl->glTexParameteri(target, GL_TEXTURE_BASE_LEVEL, 0);
			gl->glTexParameteri(target, GL_TEXTURE_MAX_LEVEL, levels - 1);
			bool nearest = format.isInteger || format.isDepth;
			gl->glTexParameteri(target, GL_TEXTURE_MIN_FILTER, nearest ? GL_NEAREST : GL_LINEAR);
			gl->glTexParameteri(target, GL_TEXTURE_MAG_FILTER, nearest ? GL_NEAREST : GL_LINEAR);
			gl->glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
			gl->glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
			if (target == GL_TEXTURE_3D)
				gl->glTexParameteri(target, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
			gl->glBindTexture(target, 0);
		}

		void DeleteTexture(Tex& t)
		{
			if (t.id)
				gl->glDeleteTextures(1, &t.id);
			t = Tex();
		}

		static int MipLevels(int w, int h)
		{
			int levels = 1;
			while (w > 1 || h > 1)
			{
				w = qMax(1, w / 2);
				h = qMax(1, h / 2);
				levels++;
			}
			return levels;
		}

		// ----------------------------------------------------------------------------------------
		// Initialization

		bool Init(QString* error)
		{
			QOpenGLContext* ctx = QOpenGLContext::currentContext();
			if (!ctx)
			{
				if (error)
					*error = "No current OpenGL context";
				return false;
			}

			QSurfaceFormat format = ctx->format();
			glVersion = format.majorVersion() * 10 + format.minorVersion();
			if (glVersion < 33)
			{
				if (error)
					*error = "OpenGL 3.3 or newer is required for shaderpacks";
				return false;
			}

			gl = ctx->versionFunctions<QOpenGLFunctions_3_3_Core>();
			if (!gl || !gl->initializeOpenGLFunctions())
			{
				if (error)
					*error = "Could not initialize OpenGL 3.3 functions";
				return false;
			}
			ex = ctx->extraFunctions();
			computeSupported = glVersion >= 43;

			CreateSamplers();
			CreateGeometry();
			CreateDefaultTextures();
			CreateNoiseTexture();
			LoadCustomTextures();
			CreateImagesAndBuffers();

			if (!CompilePrograms(error))
				return false;

			DetermineUsedTargets();
			firstFrame = true;
			return true;
		}

		void CreateSamplers()
		{
			auto make = [&](GLuint& s, GLenum minF, GLenum magF, GLenum wrap, bool compare)
			{
				gl->glGenSamplers(1, &s);
				gl->glSamplerParameteri(s, GL_TEXTURE_MIN_FILTER, minF);
				gl->glSamplerParameteri(s, GL_TEXTURE_MAG_FILTER, magF);
				gl->glSamplerParameteri(s, GL_TEXTURE_WRAP_S, wrap);
				gl->glSamplerParameteri(s, GL_TEXTURE_WRAP_T, wrap);
				gl->glSamplerParameteri(s, GL_TEXTURE_WRAP_R, wrap);
				if (compare)
				{
					gl->glSamplerParameteri(s, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
					gl->glSamplerParameteri(s, GL_TEXTURE_COMPARE_FUNC, GL_LEQUAL);
				}
			};
			make(samplerNearest, GL_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, false);
			make(samplerLinear, GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, false);
			make(samplerLinearMip, GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, false);
			make(samplerNearestMip, GL_NEAREST_MIPMAP_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, false);
			make(samplerShadowCompare, GL_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, true);
			make(samplerShadowCompareNearest, GL_NEAREST, GL_NEAREST, GL_CLAMP_TO_EDGE, true);
			make(samplerRepeatLinear, GL_LINEAR, GL_LINEAR, GL_REPEAT, false);
			make(samplerAtlas, GL_NEAREST_MIPMAP_LINEAR, GL_NEAREST, GL_REPEAT, false);
			make(samplerAtlasNoMip, GL_NEAREST, GL_NEAREST, GL_REPEAT, false);
		}

		void CreateGeometry()
		{
			gl->glGenVertexArrays(1, &vao);

			// Fullscreen quad in the host vertex layout (positions 0-1)
			struct V
			{
				float x, y, z;
				uint32_t normal, color;
				float u, v;
				uint32_t data, tangent, block, midTex, light, midBlock;
			};
			static_assert(sizeof(V) == 52, "Vertex layout must match CppProject::Vertex");
			V quad[4] = {
				{ 0, 0, 0, 0, 0xFFFFFFFF, 0, 0, 0, 0, 0, 0xFFFFFFFF, 0x00FFF000, 0 },
				{ 1, 0, 0, 0, 0xFFFFFFFF, 1, 0, 0, 0, 0, 0xFFFFFFFF, 0x00FFF000, 0 },
				{ 1, 1, 0, 0, 0xFFFFFFFF, 1, 1, 0, 0, 0, 0xFFFFFFFF, 0x00FFF000, 0 },
				{ 0, 1, 0, 0, 0xFFFFFFFF, 0, 1, 0, 0, 0, 0xFFFFFFFF, 0x00FFF000, 0 },
			};
			uint32_t idx[6] = { 0, 1, 2, 0, 2, 3 };
			gl->glGenBuffers(1, &quadVbo);
			gl->glBindBuffer(GL_ARRAY_BUFFER, quadVbo);
			gl->glBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);
			gl->glGenBuffers(1, &quadIbo);
			gl->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, quadIbo);
			gl->glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(idx), idx, GL_STATIC_DRAW);

			// Sky geometry (Minecraft LevelRenderer equivalents), positions in blocks relative to the camera
			QVector<V> verts;
			QVector<uint32_t> inds;
			auto packColor = [](float r, float g, float b, float a)
			{
				return (uint32_t)qBound(0, (int)(r * 255), 255) | ((uint32_t)qBound(0, (int)(g * 255), 255) << 8) |
					   ((uint32_t)qBound(0, (int)(b * 255), 255) << 16) | ((uint32_t)qBound(0, (int)(a * 255), 255) << 24);
			};
			auto addVertex = [&](float x, float y, float z, float u, float v, uint32_t color)
			{
				verts.append({ x, y, z, 0x00FF7F7F /* up normal approx */, color, u, v, 0, 0, 0, 0xFFFFFFFF, 0x00FFF000, 0 });
				return (uint32_t)(verts.size() - 1);
			};

			// Top disc (triangle fan at y=16, radius 512)
			auto addDisc = [&](float y, int& offset, int& count)
			{
				offset = inds.size();
				uint32_t center = addVertex(0, y, 0, 0, 0, 0xFFFFFFFF);
				QVector<uint32_t> ring;
				for (int i = -180; i <= 180; i += 45)
				{
					float a = (float)(i * PI / 180.0);
					ring.append(addVertex(512.f * std::cos(a), y, 512.f * std::sin(a), 0, 0, 0xFFFFFFFF));
				}
				for (int i = 0; i + 1 < ring.size(); i++)
				{
					if (y > 0)
						inds << center << ring[i + 1] << ring[i];
					else
						inds << center << ring[i] << ring[i + 1];
				}
				count = inds.size() - offset;
			};
			int topOffset;
			addDisc(16.f, topOffset, skyDiscIndices);
			addDisc(-16.f, skyBottomOffset, skyBottomIndices);

			// Sunrise fan (colored in DrawSky through the color modulator)
			skySunriseOffset = inds.size();
			{
				uint32_t center = addVertex(0, 100, 0, 0, 0, packColor(1, 1, 1, 1));
				QVector<uint32_t> ring;
				for (int i = 0; i <= 16; i++)
				{
					float a = (float)(i * PI * 2.0 / 16.0);
					float s = std::sin(a), c = std::cos(a);
					ring.append(addVertex(s * 120.f, c * 120.f, -c * 40.f, 0, 0, packColor(1, 1, 1, 0)));
				}
				for (int i = 0; i + 1 < ring.size(); i++)
					inds << center << ring[i] << ring[i + 1];
			}
			skySunriseIndices = inds.size() - skySunriseOffset;

			// Stars
			starsOffset = inds.size();
			{
				std::mt19937 rng(10842);
				std::uniform_real_distribution<float> dist(-1.f, 1.f), unit(0.f, 1.f);
				for (int i = 0; i < 1500; i++)
				{
					float x = dist(rng), y = dist(rng), z = dist(rng);
					float size = 0.15f + unit(rng) * 0.1f;
					float len2 = x * x + y * y + z * z;
					if (len2 >= 1.f || len2 <= 0.01f)
						continue;
					float inv = 1.f / std::sqrt(len2);
					x *= inv;
					y *= inv;
					z *= inv;
					float px = x * 100.f, py = y * 100.f, pz = z * 100.f;
					float yaw = std::atan2(x, z);
					float sy = std::sin(yaw), cy = std::cos(yaw);
					float pitch = std::atan2(std::sqrt(x * x + z * z), y);
					float sp = std::sin(pitch), cp = std::cos(pitch);
					float roll = unit(rng) * (float)PI * 2.f;
					float sr = std::sin(roll), cr = std::cos(roll);
					uint32_t base = verts.size();
					for (int c = 0; c < 4; c++)
					{
						float a = (float)((c & 2) - 1) * size;
						float b = (float)(((c + 1) & 2) - 1) * size;
						float ar = a * cr - b * sr;
						float br = b * cr + a * sr;
						float dy = ar * sp;
						float d = -ar * cp;
						float dx = d * sy - br * cy;
						float dz = br * sy + d * cy;
						addVertex(px + dx, py + dy, pz + dz, 0, 0, 0xFFFFFFFF);
					}
					inds << base << base + 1 << base + 2 << base << base + 2 << base + 3;
				}
			}
			starsIndices = inds.size() - starsOffset;

			// Sun and moon quads (y=100 above, size 30 and 20), UVs set per frame through uvRect
			sunOffset = inds.size();
			{
				uint32_t b = verts.size();
				addVertex(-30, 100, -30, 0, 0, 0xFFFFFFFF);
				addVertex(30, 100, -30, 1, 0, 0xFFFFFFFF);
				addVertex(30, 100, 30, 1, 1, 0xFFFFFFFF);
				addVertex(-30, 100, 30, 0, 1, 0xFFFFFFFF);
				inds << b << b + 1 << b + 2 << b << b + 2 << b + 3;
			}
			moonOffset = inds.size();
			{
				uint32_t b = verts.size();
				addVertex(-20, -100, 20, 1, 1, 0xFFFFFFFF);
				addVertex(20, -100, 20, 0, 1, 0xFFFFFFFF);
				addVertex(20, -100, -20, 0, 0, 0xFFFFFFFF);
				addVertex(-20, -100, -20, 1, 0, 0xFFFFFFFF);
				inds << b << b + 1 << b + 2 << b << b + 2 << b + 3;
			}

			gl->glGenBuffers(1, &skyVbo);
			gl->glBindBuffer(GL_ARRAY_BUFFER, skyVbo);
			gl->glBufferData(GL_ARRAY_BUFFER, verts.size() * sizeof(V), verts.constData(), GL_STATIC_DRAW);
			gl->glGenBuffers(1, &skyIbo);
			gl->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, skyIbo);
			gl->glBufferData(GL_ELEMENT_ARRAY_BUFFER, inds.size() * sizeof(uint32_t), inds.constData(), GL_STATIC_DRAW);
			gl->glBindBuffer(GL_ARRAY_BUFFER, 0);
			gl->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		}

		void CreateDefaultTextures()
		{
			uint32_t white = 0xFFFFFFFF;
			CreateTexture(whiteTex, GL_TEXTURE_2D, 1, 1, 1, ParseInternalFormat("RGBA8"), 1, &white, GL_RGBA, GL_UNSIGNED_BYTE);

			// Iris' defaults for objects without PBR textures (flat normal, no specular)
			uint8_t flatNormal[4] = { 127, 127, 255, 255 }, noSpecular[4] = { 0, 0, 0, 0 };
			CreateTexture(defaultNormalsTex, GL_TEXTURE_2D, 1, 1, 1, ParseInternalFormat("RGBA8"), 1, flatNormal, GL_RGBA, GL_UNSIGNED_BYTE);
			CreateTexture(defaultSpecularTex, GL_TEXTURE_2D, 1, 1, 1, ParseInternalFormat("RGBA8"), 1, noSpecular, GL_RGBA, GL_UNSIGNED_BYTE);

			InternalFormatInfo rgba8 = ParseInternalFormat("RGBA8");
			CreateTexture(lightmapTex, GL_TEXTURE_2D, 16, 16, 1, rgba8, 1);

			InternalFormatInfo r32i = ParseInternalFormat("R32I");
			int zero = -1;
			CreateTexture(blockOffsetsTex, GL_TEXTURE_2D, 1, 1, 1, r32i, 1, &zero, GL_RED_INTEGER, GL_INT);
			CreateTexture(blockIdsTex, GL_TEXTURE_2D, 1, 1, 1, r32i, 1, &zero, GL_RED_INTEGER, GL_INT);
		}

		void CreateNoiseTexture()
		{
			QImage image;
			if (!pack->properties.noiseTexture.isEmpty())
			{
				QByteArray data;
				QString path = NormalizePackPath(pack->properties.noiseTexture);
				if (pack->files->Read(path, data))
					image.loadFromData(data);
			}

			if (!image.isNull())
			{
				image = image.convertToFormat(QImage::Format_RGBA8888);
				CreateTexture(noiseTex, GL_TEXTURE_2D, image.width(), image.height(), 1, ParseInternalFormat("RGBA8"), 1,
							  image.constBits(), GL_RGBA, GL_UNSIGNED_BYTE);
				return;
			}

			// OptiFine generates RGB noise with the given resolution
			int res = pack->directives.noiseTextureResolution;
			QVector<uint8_t> data(res * res * 3);
			std::mt19937 rng(0);
			std::uniform_int_distribution<int> dist(0, 255);
			for (uint8_t& b : data)
				b = (uint8_t)dist(rng);
			gl->glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
			CreateTexture(noiseTex, GL_TEXTURE_2D, res, res, 1, ParseInternalFormat("RGB8"), 1, data.constData(), GL_RGB, GL_UNSIGNED_BYTE);
			gl->glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
		}

		bool LoadTextureSpec(const TextureSpec& spec, Tex& tex)
		{
			QString path = spec.path;
			if (path.startsWith("minecraft:") || path.contains(':'))
				return false; // Resolved per frame through the host

			QByteArray data;
			if (!pack->files->Read(NormalizePackPath(path), data))
			{
				Log("Missing custom texture " + path);
				return false;
			}

			if (spec.raw)
			{
				InternalFormatInfo info = ParseInternalFormat("RGBA8");
				info.internalFormat = spec.internalFormat;
				gl->glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
				CreateTexture(tex, spec.target, spec.width, spec.height, spec.depth, info, 1, data.constData(), spec.pixelFormat, spec.pixelType);
				gl->glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
				return true;
			}

			QImage image;
			if (!image.loadFromData(data))
			{
				Log("Could not load custom texture " + path);
				return false;
			}
			image = image.convertToFormat(QImage::Format_RGBA8888);
			CreateTexture(tex, GL_TEXTURE_2D, image.width(), image.height(), 1, ParseInternalFormat("RGBA8"), 1, image.constBits(), GL_RGBA, GL_UNSIGNED_BYTE);

			// Texture properties (.mcmeta-like "blur"/"clamp" through a .properties file are rare, default linear)
			gl->glBindTexture(GL_TEXTURE_2D, tex.id);
			gl->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			gl->glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			gl->glBindTexture(GL_TEXTURE_2D, 0);
			return true;
		}

		void LoadCustomTextures()
		{
			const ShaderProperties& props = pack->properties;
			for (auto stageIt = props.textures.constBegin(); stageIt != props.textures.constEnd(); ++stageIt)
			{
				for (auto it = stageIt.value().constBegin(); it != stageIt.value().constEnd(); ++it)
				{
					Tex tex;
					if (LoadTextureSpec(it.value(), tex))
						customTextures[stageIt.key() + ":" + it.key()] = tex;
				}
			}
			for (auto it = props.customTextures.constBegin(); it != props.customTextures.constEnd(); ++it)
			{
				Tex tex;
				if (LoadTextureSpec(it.value(), tex))
					customTextures["custom:" + it.key()] = tex;
			}
		}

		void CreateImagesAndBuffers()
		{
			for (const ImageSpec& spec : pack->properties.images)
			{
				ImageTarget img;
				img.spec = spec;
				images.append(img);
			}

			if (!computeSupported)
				return;

			for (auto it = pack->properties.bufferObjects.constBegin(); it != pack->properties.bufferObjects.constEnd(); ++it)
			{
				GLuint buffer = 0;
				ex->glGenBuffers(1, &buffer);
				ex->glBindBuffer(GL_SHADER_STORAGE_BUFFER, buffer);
				QByteArray data(qMax<qint64>(it.value().first, 4), 0);
				if (!it.value().second.isEmpty())
				{
					QByteArray file;
					if (pack->files->Read(NormalizePackPath(it.value().second), file))
						memcpy(data.data(), file.constData(), qMin(file.size(), data.size()));
				}
				ex->glBufferData(GL_SHADER_STORAGE_BUFFER, data.size(), data.constData(), GL_DYNAMIC_COPY);
				ex->glBindBufferBase(GL_SHADER_STORAGE_BUFFER, it.key(), buffer);
				ssbos[it.key()] = buffer;
			}
			ex->glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0);
		}

		void ResizeImages()
		{
			for (ImageTarget& img : images)
			{
				int w = img.spec.relative ? qMax(1, (int)(width * img.spec.width)) : (int)img.spec.width;
				int h = img.spec.relative ? qMax(1, (int)(height * img.spec.height)) : (int)img.spec.height;
				int d = (int)img.spec.depth;
				if (img.tex.id && img.tex.w == w && img.tex.h == h)
					continue;

				InternalFormatInfo info = ParseInternalFormat("RGBA8");
				info.internalFormat = img.spec.internalFormat;
				info.pixelFormat = img.spec.pixelFormat;
				info.pixelType = img.spec.pixelType;
				info.isInteger = (img.spec.pixelFormat == GL_RED_INTEGER || img.spec.pixelFormat == GL_RG_INTEGER ||
								  img.spec.pixelFormat == GL_RGB_INTEGER || img.spec.pixelFormat == GL_RGBA_INTEGER);
				CreateTexture(img.tex, d > 0 ? GL_TEXTURE_3D : GL_TEXTURE_2D, qMax(1, w), qMax(1, h), qMax(1, d), info, 1);
			}
		}

		// ----------------------------------------------------------------------------------------
		// Programs

		QString StageOfProgram(const QString& name)
		{
			if (name.startsWith("gbuffers_") || (name.startsWith("shadow") && !name.startsWith("shadowcomp")))
				return "gbuffers";
			if (name.startsWith("begin"))
				return "begin";
			if (name.startsWith("prepare"))
				return "prepare";
			if (name.startsWith("shadowcomp"))
				return "shadowcomp";
			if (name.startsWith("deferred"))
				return "deferred";
			if (name.startsWith("setup"))
				return "setup";
			return "composite"; // composite and final
		}

		Program* Compile(const ProgramSource& source, ProgramKind kind)
		{
			TransformParams params;
			params.kind = kind;
			for (const SamplerPatchSpec& patch : pack->properties.samplerPatches)
				if (patch.stage == StageOfProgram(source.name))
					params.samplerPatches.append(patch);
			params.programName = source.name;

			QString base = source.name;
			bool isShadow = base.startsWith("shadow") && !base.startsWith("shadowcomp");
			AlphaTestSpec alpha;
			bool hasAlpha = false;
			if (kind == ProgramKind::Geometry)
			{
				auto alphaIt = pack->properties.alphaTest.constFind(base);
				if (alphaIt != pack->properties.alphaTest.constEnd())
				{
					hasAlpha = true;
					alpha = alphaIt.value();
				}
				params.alphaTest = true;
			}

			TransformResult tr = TransformProgram(source, params);

			static const GLenum types[STAGE_COUNT] = { GL_VERTEX_SHADER, GL_GEOMETRY_SHADER, GL_TESS_CONTROL_SHADER,
													   GL_TESS_EVALUATION_SHADER, GL_FRAGMENT_SHADER, GL_COMPUTE_SHADER };
			static const char* stageNames[STAGE_COUNT] = { "vsh", "gsh", "tcs", "tes", "fsh", "csh" };

			GLuint program = gl->glCreateProgram();
			QVector<GLuint> shaders;
			QString errorLog;

			for (int s = 0; s < STAGE_COUNT; s++)
			{
				if (tr.sources[s].isEmpty())
					continue;
				if ((s == STAGE_COMPUTE || s == STAGE_TESS_CONTROL || s == STAGE_TESS_EVAL) && glVersion < 43 && s == STAGE_COMPUTE)
					continue;

				GLuint sh = gl->glCreateShader(types[s]);
				QByteArray code = tr.sources[s].toUtf8();
				const char* ptr = code.constData();
				gl->glShaderSource(sh, 1, &ptr, nullptr);
				gl->glCompileShader(sh);
				GLint ok = 0;
				gl->glGetShaderiv(sh, GL_COMPILE_STATUS, &ok);
				if (!ok)
				{
					GLint len = 0;
					gl->glGetShaderiv(sh, GL_INFO_LOG_LENGTH, &len);
					QByteArray log(len + 1, 0);
					gl->glGetShaderInfoLog(sh, len, nullptr, log.data());
					errorLog += QString("%1.%2: %3\n").arg(source.name, stageNames[s], QString::fromUtf8(log).trimmed());
				}
				gl->glAttachShader(program, sh);
				shaders.append(sh);
			}

			if (shaders.isEmpty())
			{
				gl->glDeleteProgram(program);
				return nullptr;
			}

			if (errorLog.isEmpty())
			{
				gl->glLinkProgram(program);
				GLint ok = 0;
				gl->glGetProgramiv(program, GL_LINK_STATUS, &ok);
				if (!ok)
				{
					GLint len = 0;
					gl->glGetProgramiv(program, GL_INFO_LOG_LENGTH, &len);
					QByteArray log(len + 1, 0);
					gl->glGetProgramInfoLog(program, len, nullptr, log.data());
					errorLog = source.name + " (link): " + QString::fromUtf8(log).trimmed();
				}
			}

			for (GLuint sh : shaders)
			{
				gl->glDetachShader(program, sh);
				gl->glDeleteShader(sh);
			}

			if (!errorLog.isEmpty())
			{
				Log("Shader error in " + errorLog.left(2000));
				gl->glDeleteProgram(program);
				return nullptr;
			}

			Program* p = new Program;
			p->name = source.name;
			p->id = program;
			p->kind = kind;
			p->isShadow = isShadow;
			p->stage = StageOfProgram(source.name);
			p->drawBuffers = source.drawBuffers;
			p->mipmapped = source.mipmappedBuffers;
			p->hasAlphaTest = hasAlpha;
			p->alphaTest = alpha;
			p->scale = pack->properties.scale.value(base);
			p->flips = pack->properties.flip.value(base);
			p->deactivatedOverrides = compileDeactivatedOverrides;

			auto blendIt = pack->properties.blend.constFind(base);
			if (blendIt != pack->properties.blend.constEnd())
			{
				p->hasBlend = true;
				p->blend = blendIt.value();
			}
			for (int b = 0; b < 16; b++)
			{
				auto bufIt = pack->properties.blend.constFind(base + "." + QString::number(b));
				if (bufIt != pack->properties.blend.constEnd())
					p->bufferBlend[b] = bufIt.value();
			}

			if (kind == ProgramKind::Compute)
			{
				GLint size[3] = { 1, 1, 1 };
				gl->glGetProgramiv(program, GL_COMPUTE_WORK_GROUP_SIZE, size);
				for (int i = 0; i < 3; i++)
					p->localSize[i] = qMax(1, (int)size[i]);
				p->hasWorkGroups = source.hasWorkGroups;
				p->hasWorkGroupsRender = source.hasWorkGroupsRender;
				for (int i = 0; i < 3; i++)
					p->workGroups[i] = source.workGroups[i];
				p->workGroupsRender[0] = source.workGroupsRender[0];
				p->workGroupsRender[1] = source.workGroupsRender[1];
			}

			// Fewer draw buffers than outputs can't be detected here, but warn on unmatched outputs
			if (kind != ProgramKind::Compute && !source.explicitDrawBuffers && !tr.fragmentOutputs.isEmpty())
			{
				// Without a directive, outputs map to colortex0..n like OptiFine
				QVector<int> buffers;
				int maxOut = 0;
				for (int o : tr.fragmentOutputs)
					maxOut = qMax(maxOut, o);
				for (int i = 0; i <= maxOut; i++)
					buffers.append(i);
				p->drawBuffers = buffers;
			}

			QueryBindings(p);
			allPrograms.append(p);
			return p;
		}

		SamplerSource ResolveSampler(Program* p, const QString& name, int& index, QString& customKey, bool programHasWatershadow)
		{
			index = 0;

			// Custom textures override built-in names, except for color buffers that were already
			// written (flipped) by an earlier pass of the same stage (Iris' CustomTextureSamplerInterceptor)
			QString stageKey = p->stage + ":" + name;
			int overriddenBuffer = ColorBufferIndex(name);
			bool overrideActive = !(overriddenBuffer >= 0 && p->deactivatedOverrides.contains(overriddenBuffer));
			if (overrideActive && (customTextures.contains(stageKey) || pack->properties.textures.value(p->stage).contains(name)))
			{
				customKey = stageKey;
				return SamplerSource::Custom;
			}
			if (p->stage == "gbuffers" && p->isShadow && (customTextures.contains("shadow:" + name)))
			{
				customKey = "shadow:" + name;
				return SamplerSource::Custom;
			}
			if (customTextures.contains("custom:" + name))
			{
				customKey = "custom:" + name;
				return SamplerSource::Custom;
			}

			for (int i = 0; i < images.size(); i++)
			{
				if (images[i].spec.samplerName == name)
				{
					index = i;
					return SamplerSource::Image;
				}
			}

			if (name == "mi_BlockOffsets")
				return SamplerSource::BlockOffsets;
			if (name == "mi_BlockIds")
				return SamplerSource::BlockIds;

			bool gbuffers = (p->kind == ProgramKind::Geometry);
			if (gbuffers)
			{
				if (name == "gtexture" || name == "tex" || name == "texture")
					return SamplerSource::ObjectTexture;
				if (name == "normals")
					return SamplerSource::ObjectNormals;
				if (name == "specular")
					return SamplerSource::ObjectSpecular;
			}
			else if (name == "gtexture")
			{
				index = 0;
				return SamplerSource::ColorTarget;
			}

			if (name == "lightmap")
				return SamplerSource::Lightmap;
			if (name == "noisetex")
				return SamplerSource::Noise;

			int buffer = ColorBufferIndex(name);
			if (buffer >= 0)
			{
				index = buffer;
				return SamplerSource::ColorTarget;
			}

			if (name == "depthtex0" || name == "gdepthtex")
				return index = 0, SamplerSource::DepthTex;
			if (name == "depthtex1")
				return index = 1, SamplerSource::DepthTex;
			if (name == "depthtex2")
				return index = 2, SamplerSource::DepthTex;

			if (name == "shadowtex0" || name == "shadowtex0HW" || name == "watershadow")
				return index = 0, SamplerSource::ShadowDepth;
			if (name == "shadowtex1" || name == "shadowtex1HW")
				return index = 1, SamplerSource::ShadowDepth;
			if (name == "shadow")
				return index = programHasWatershadow ? 1 : 0, SamplerSource::ShadowDepth;
			if (name == "shadowcolor")
				return index = 0, SamplerSource::ShadowColor;
			if (name.startsWith("shadowcolor"))
			{
				bool ok = false;
				int i = name.mid(11).toInt(&ok);
				if (ok && i >= 0 && i < 8)
					return index = i, SamplerSource::ShadowColor;
			}

			return SamplerSource::None;
		}

		void QueryBindings(Program* p)
		{
			GLint count = 0;
			gl->glGetProgramiv(p->id, GL_ACTIVE_UNIFORMS, &count);

			// First pass to know if the program uses watershadow
			bool hasWatershadow = false;
			QVector<QPair<QString, GLenum>> uniforms;
			QVector<GLint> sizes;
			for (GLint u = 0; u < count; u++)
			{
				char name[256];
				GLsizei len = 0;
				GLint size = 0;
				GLenum type = 0;
				gl->glGetActiveUniform(p->id, u, sizeof(name), &len, &size, &type, name);
				QString n = QString::fromLatin1(name, len);
				if (n.endsWith("[0]"))
					n.chop(3);
				if (n.contains('.')) // Uniform block members
					continue;
				uniforms.append({ n, type });
				sizes.append(size);
				if (n == "watershadow")
					hasWatershadow = true;
			}

			gl->glUseProgram(p->id);
			int unit = 0;
			int imageUnit = 0;
			for (int k = 0; k < uniforms.size(); k++)
			{
				const QString& n = uniforms[k].first;
				GLenum type = uniforms[k].second;
				GLint location = gl->glGetUniformLocation(p->id, n.toLatin1().constData());
				if (location < 0)
					continue;

				if (IsSamplerType(type))
				{
					SamplerBinding b;
					b.name = n;
					b.location = location;
					b.type = type;
					b.unit = unit++;
					b.source = ResolveSampler(p, n, b.index, b.customKey, hasWatershadow);
					gl->glUniform1i(location, b.unit);
					p->samplers.append(b);
					continue;
				}

				if (IsImageType(type))
				{
					ImageBinding b;
					b.name = n;
					b.location = location;
					b.unit = imageUnit++;
					b.kind = -1;
					b.index = 0;
					if (n.startsWith("colorimg"))
					{
						b.kind = 0;
						b.index = n.mid(8).toInt();
					}
					else if (n.startsWith("shadowcolorimg"))
					{
						b.kind = 1;
						b.index = n.mid(14).toInt();
					}
					else
					{
						for (int i = 0; i < images.size(); i++)
							if (images[i].spec.name == n)
							{
								b.kind = 2;
								b.index = i;
							}
					}
					gl->glUniform1i(location, b.unit);
					p->images.append(b);
					continue;
				}

				p->uniforms.append({ n, location, type, sizes[k] });
			}
			gl->glUseProgram(0);
		}

		bool CompilePrograms(QString* error)
		{
			QSet<QString> geometryNames;
			for (auto it = pack->programs.constBegin(); it != pack->programs.constEnd(); ++it)
			{
				const QString& name = it.key();
				const ProgramSource& source = it.value();
				if (!source.IsValid() || source.IsCompute())
					continue;
				if (name.startsWith("gbuffers_") || (name.startsWith("shadow") && !name.startsWith("shadowcomp")))
				{
					if (!Pack::FallbackProgram(name).isNull() || name == "shadow" || name == "gbuffers_basic")
						geometryNames.insert(name);
				}
			}

			for (const QString& name : geometryNames)
			{
				if (name == "shadow" || name.startsWith("shadow_"))
				{
					if (!computeSupported && false)
						continue;
				}
				Program* p = Compile(pack->programs[name], ProgramKind::Geometry);
				if (p)
					programs[name] = p;
			}

			// Buffers flipped by an earlier pass of the stage, see ResolveSampler
			QSet<int> flippedAtLeastOnce;
			auto buildPasses = [&](const QString& prefix, QVector<Pass>& passes)
			{
				flippedAtLeastOnce.clear();
				for (int i = 0; i < 100; i++)
				{
					QString name = prefix + (i == 0 ? QString() : QString::number(i));
					Pass pass;
					compileDeactivatedOverrides = flippedAtLeastOnce;
					const ProgramSource* src = pack->Program(name);
					if (src && src->IsValid())
					{
						pass.program = Compile(*src, ProgramKind::Composite);
						if (pass.program)
							programs[name] = pass.program;
					}
					if (computeSupported)
					{
						for (const ProgramSource* c : pack->ComputePrograms(name))
						{
							Program* cp = Compile(*c, ProgramKind::Compute);
							if (cp)
								pass.computes.append(cp);
						}
					}
					if (pass.program || !pass.computes.isEmpty())
						passes.append(pass);

					if (Program* p = pass.program)
					{
						for (int b : p->drawBuffers)
							if (p->flips.value(b, true))
								flippedAtLeastOnce.insert(b);
						for (auto it = p->flips.constBegin(); it != p->flips.constEnd(); ++it)
							if (it.value())
								flippedAtLeastOnce.insert(it.key());
					}
				}
				compileDeactivatedOverrides.clear();
			};

			buildPasses("begin", beginPasses);
			buildPasses("shadowcomp", shadowcompPasses);
			buildPasses("prepare", preparePasses);
			buildPasses("deferred", deferredPasses);
			buildPasses("composite", compositePasses);

			if (computeSupported)
			{
				for (const ProgramSource* c : pack->ComputePrograms("setup"))
					if (Program* cp = Compile(*c, ProgramKind::Compute))
						setupComputes.append(cp);
				for (int i = 1; i < 100; i++)
					for (const ProgramSource* c : pack->ComputePrograms("setup" + QString::number(i)))
						if (Program* cp = Compile(*c, ProgramKind::Compute))
							setupComputes.append(cp);
				compileDeactivatedOverrides = flippedAtLeastOnce;
				for (const ProgramSource* c : pack->ComputePrograms("final"))
					if (Program* cp = Compile(*c, ProgramKind::Compute))
						finalComputes.append(cp);
				compileDeactivatedOverrides.clear();
				for (const ProgramSource* c : pack->ComputePrograms("shadow"))
					if (Program* cp = Compile(*c, ProgramKind::Compute))
						shadowComputes.append(cp);
			}

			// Final uses the overrides state at the end of the composite stage
			compileDeactivatedOverrides = flippedAtLeastOnce;
			if (const ProgramSource* fin = pack->Program("final"))
				if (fin->IsValid())
					finalProgram = Compile(*fin, ProgramKind::Composite);
			compileDeactivatedOverrides.clear();

			// Shadow pass is enabled when a shadow program compiled
			shadowEnabled = false;
			for (const QString& n : { "shadow", "shadow_solid", "shadow_cutout", "shadow_water", "shadow_entities", "shadow_block" })
				if (programs.contains(n))
					shadowEnabled = true;
			if (!shadowEnabled && pack->usesShadowTextures)
				shadowEnabled = true; // Packs may sample empty shadow maps
			if (pack->properties.props.Has("shadow.enabled"))
				shadowEnabled = shadowEnabled && pack->properties.Flag("shadow.enabled", true);

			if (programs.isEmpty() && compositePasses.isEmpty() && !finalProgram)
			{
				if (error)
					*error = "No programs of the shaderpack could be compiled:\n" + owner->errors.join('\n');
				return false;
			}
			return true;
		}

		void DetermineUsedTargets()
		{
			for (int i = 0; i < 16; i++)
				colorTargets[i].settings = pack->directives.colorTargets[i];

			auto markProgram = [&](Program* p)
			{
				if (!p)
					return;
				for (int b : p->drawBuffers)
					if (b >= 0 && b < 16)
						colorTargets[b].used = true;
				for (const SamplerBinding& s : p->samplers)
				{
					if (s.source == SamplerSource::ColorTarget)
						colorTargets[s.index].used = true;
					if (s.source == SamplerSource::ShadowColor)
						shadowColorUsed[s.index] = true;
				}
				for (const ImageBinding& img : p->images)
				{
					if (img.kind == 0 && img.index >= 0 && img.index < 16)
						colorTargets[img.index].used = true;
					if (img.kind == 1 && img.index >= 0 && img.index < 8)
						shadowColorUsed[img.index] = true;
				}
				if (p->isShadow)
					for (int b : p->drawBuffers)
						if (b >= 0 && b < 8)
							shadowColorUsed[b] = true;
			};

			for (Program* p : allPrograms)
				markProgram(p);

			// colortex0 is always needed for the final output
			colorTargets[0].used = true;
		}

		// ----------------------------------------------------------------------------------------
		// Render targets

		void ResizeTargets(int w, int h)
		{
			bool sizeChanged = (w != width || h != height);
			width = w;
			height = h;
			if (!sizeChanged && depthTex[0].id)
				return;

			for (int i = 0; i < 16; i++)
			{
				ColorTarget& t = colorTargets[i];
				if (!t.used)
					continue;

				int tw = w, th = h;
				auto sizeIt = pack->properties.bufferSize.constFind(i);
				if (sizeIt != pack->properties.bufferSize.constEnd())
				{
					if (sizeIt->relative)
					{
						tw = qMax(1, (int)(w * sizeIt->width));
						th = qMax(1, (int)(h * sizeIt->height));
					}
					else
					{
						tw = qMax(1, (int)sizeIt->width);
						th = qMax(1, (int)sizeIt->height);
					}
				}

				int levels = t.settings.format.isInteger ? 1 : MipLevels(tw, th);
				CreateTexture(t.main, GL_TEXTURE_2D, tw, th, 1, t.settings.format, levels);
				CreateTexture(t.alt, GL_TEXTURE_2D, tw, th, 1, t.settings.format, levels);
			}

			InternalFormatInfo depth = ParseInternalFormat("R32F");
			depth.internalFormat = GL_DEPTH_COMPONENT32F;
			depth.isDepth = true;
			for (int i = 0; i < 3; i++)
				CreateTexture(depthTex[i], GL_TEXTURE_2D, w, h, 1, depth, 1);

			for (Program* p : allPrograms)
			{
				for (GLuint fbo : p->fbos)
					gl->glDeleteFramebuffers(1, &fbo);
				p->fbos.clear();
			}

			ResizeImages();
			fullClear = true;
		}

		void CreateShadowTargets()
		{
			int res = pack->directives.shadowMapResolution;
			if (shadowDepth[0].id && shadowResolution == res)
				return;
			shadowResolution = res;

			InternalFormatInfo depth = ParseInternalFormat("R32F");
			depth.internalFormat = GL_DEPTH_COMPONENT32F;
			depth.isDepth = true;
			for (int i = 0; i < 2; i++)
			{
				const ShadowBufferSettings& s = pack->directives.shadowDepth[i];
				CreateTexture(shadowDepth[i], GL_TEXTURE_2D, res, res, 1, depth, s.mipmap ? MipLevels(res, res) : 1);
			}
			for (int i = 0; i < 8; i++)
			{
				if (!shadowColorUsed[i])
					continue;
				const ShadowBufferSettings& s = pack->directives.shadowColor[i];
				CreateTexture(shadowColor[i], GL_TEXTURE_2D, res, res, 1, s.format, s.mipmap && !s.format.isInteger ? MipLevels(res, res) : 1);
			}
		}

		// Returns the texture a color target is read from with the current flip state.
		Tex& ReadTex(int buffer, const QSet<int>& flipState)
		{
			ColorTarget& t = colorTargets[buffer];
			return flipState.contains(buffer) ? t.alt : t.main;
		}

		// Returns the texture a composite pass writes to.
		Tex& WriteTex(int buffer, const QSet<int>& flipState)
		{
			ColorTarget& t = colorTargets[buffer];
			return flipState.contains(buffer) ? t.main : t.alt;
		}

		GLuint GetFramebuffer(Program* p, const QVector<int>& buffers, const QSet<int>& flipState, bool gbuffer, bool shadow)
		{
			QString key = QString(gbuffer ? "g" : "c") + (shadow ? "s" : "");
			for (int b : buffers)
				key += QString::number(b) + (flipState.contains(b) ? "a" : "m") + ",";

			auto it = p->fbos.constFind(key);
			if (it != p->fbos.constEnd())
				return it.value();

			GLuint fbo = 0;
			gl->glGenFramebuffers(1, &fbo);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);

			QVector<GLenum> attachments;
			for (int i = 0; i < buffers.size(); i++)
			{
				int b = buffers[i];
				GLuint tex = 0;
				if (shadow)
				{
					if (b >= 0 && b < 8 && shadowColor[b].id)
						tex = shadowColor[b].id;
				}
				else if (b >= 0 && b < 16 && colorTargets[b].used)
				{
					// Gbuffers write to the texture that is currently read, composites to the other one
					tex = gbuffer ? ReadTex(b, flipState).id : WriteTex(b, flipState).id;
				}

				if (tex)
				{
					gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, tex, 0);
					attachments.append(GL_COLOR_ATTACHMENT0 + i);
				}
				else
					attachments.append(GL_NONE);
			}

			if (gbuffer)
				gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, shadow ? shadowDepth[0].id : depthTex[0].id, 0);

			if (attachments.isEmpty())
				gl->glDrawBuffer(GL_NONE);
			else
				gl->glDrawBuffers(attachments.size(), attachments.constData());

			GLenum status = gl->glCheckFramebufferStatus(GL_FRAMEBUFFER);
			if (status != GL_FRAMEBUFFER_COMPLETE)
				Log(QString("Incomplete framebuffer for %1 (0x%2)").arg(p->name).arg(status, 0, 16));

			p->fbos[key] = fbo;
			return fbo;
		}

		void ClearTargets()
		{
			GLuint fbo = 0;
			gl->glGenFramebuffers(1, &fbo);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
			gl->glDisable(GL_SCISSOR_TEST);
			gl->glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

			for (int i = 0; i < 16; i++)
			{
				ColorTarget& t = colorTargets[i];
				if (!t.used || (!t.settings.clear && !fullClear))
					continue;

				QVector4D color;
				if (t.settings.hasClearColor)
					color = t.settings.clearColor;
				else if (i == 0)
					color = QVector4D(state.fogColor, 1.f);
				else if (i == 1)
					color = QVector4D(1.f, 1.f, 1.f, 1.f);
				else
					color = QVector4D(0.f, 0.f, 0.f, 0.f);

				for (Tex* tex : { &t.main, &t.alt })
				{
					gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex->id, 0);
					gl->glViewport(0, 0, tex->w, tex->h);
					GLenum buf = GL_COLOR_ATTACHMENT0;
					gl->glDrawBuffers(1, &buf);
					if (t.settings.format.isInteger)
					{
						GLint ci[4] = { (int)color.x(), (int)color.y(), (int)color.z(), (int)color.w() };
						gl->glClearBufferiv(GL_COLOR, 0, ci);
					}
					else
					{
						GLfloat cf[4] = { color.x(), color.y(), color.z(), color.w() };
						gl->glClearBufferfv(GL_COLOR, 0, cf);
					}
				}
			}

			// Depth
			gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
			gl->glDrawBuffer(GL_NONE);
			gl->glDepthMask(GL_TRUE);
			for (int i = 0; i < 3; i++)
			{
				gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthTex[i].id, 0);
				gl->glViewport(0, 0, width, height);
				gl->glClearDepth(1.0);
				gl->glClear(GL_DEPTH_BUFFER_BIT);
			}

			// Custom images
			for (ImageTarget& img : images)
			{
				if (!img.spec.clear && !fullClear)
					continue;
				if (img.tex.target != GL_TEXTURE_2D)
					continue;
				gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
				gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, img.tex.id, 0);
				GLenum buf = GL_COLOR_ATTACHMENT0;
				gl->glDrawBuffers(1, &buf);
				gl->glViewport(0, 0, img.tex.w, img.tex.h);
				if (img.tex.format.isInteger)
				{
					GLint zero[4] = { 0, 0, 0, 0 };
					gl->glClearBufferiv(GL_COLOR, 0, zero);
				}
				else
				{
					GLfloat zero[4] = { 0, 0, 0, 0 };
					gl->glClearBufferfv(GL_COLOR, 0, zero);
				}
			}

			gl->glBindFramebuffer(GL_FRAMEBUFFER, 0);
			gl->glDeleteFramebuffers(1, &fbo);
			fullClear = false;
		}

		void CopyDepth(const Tex& src, const Tex& dst)
		{
			GLuint fbos[2];
			gl->glGenFramebuffers(2, fbos);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbos[0]);
			gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, src.id, 0);
			gl->glBindFramebuffer(GL_DRAW_FRAMEBUFFER, fbos[1]);
			gl->glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, dst.id, 0);
			gl->glBlitFramebuffer(0, 0, src.w, src.h, 0, 0, dst.w, dst.h, GL_DEPTH_BUFFER_BIT, GL_NEAREST);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
			gl->glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
			gl->glDeleteFramebuffers(2, fbos);
		}

		// ----------------------------------------------------------------------------------------
		// Uniforms

		void UpdateMatrices()
		{
			// gbufferModelView: rotation of the camera (Minecraft Camera.setRotation)
			QMatrix4x4 view;
			if (state.useViewRotation)
				view = state.viewRotation;
			else
			{
				view.rotate(state.roll, 0, 0, 1);
				view.rotate(state.pitch, 1, 0, 0);
				view.rotate(state.yaw + 180.f, 0, 1, 0);
			}
			modelView = view;
			modelViewInv = modelView.inverted();

			// Minecraft projection: far plane is 4x the render distance
			float aspect = (float)state.width / (float)qMax(1, state.height);
			float far = qMax(state.renderDistance * 4.f, 32.f);
			QMatrix4x4 proj;
			proj.perspective(state.fov, aspect, state.nearPlane, far);
			projection = state.jitter * proj;
			projectionInv = projection.inverted();

			if (!hasPrevious)
			{
				prevModelView = modelView;
				prevProjection = projection;
				prevCameraPosition = state.cameraPosition;
			}
		}

		void UpdateCelestial()
		{
			// Minecraft DimensionType.timeOfDay
			double d = std::fmod(state.worldTime / 24000.0 - 0.25, 1.0);
			if (d < 0)
				d += 1.0;
			double e = 0.5 - std::cos(d * PI) / 2.0;
			skyAngle = (float)((d * 2.0 + e) / 3.0);

			sunAngle = skyAngle < 0.75f ? skyAngle + 0.25f : skyAngle - 0.75f;
			bool isDay = sunAngle <= 0.5f;
			shadowAngle = isDay ? sunAngle : sunAngle - 0.5f;

			float sunPathRotation = pack->directives.sunPathRotation;

			auto celestial = [&](float y)
			{
				QMatrix4x4 m = modelView;
				m.rotate(-90.f, 0, 1, 0);
				m.rotate(sunPathRotation, 0, 0, 1);
				m.rotate(skyAngle * 360.f, 1, 0, 0);
				return (m * QVector4D(0.f, y, 0.f, 0.f)).toVector3D();
			};
			sunPosition = celestial(100.f);
			moonPosition = celestial(-100.f);
			shadowLightPosition = isDay ? sunPosition : moonPosition;

			QMatrix4x4 up = modelView;
			up.rotate(-90.f, 0, 1, 0);
			upPosition = (up * QVector4D(0.f, 100.f, 0.f, 0.f)).toVector3D();
		}

		void UpdateShadowMatrices()
		{
			const PackDirectives& d = pack->directives;
			float skyAngleShadow = shadowAngle < 0.25f ? shadowAngle + 0.75f : shadowAngle - 0.25f;

			QMatrix4x4 mv;
			mv.rotate(90.f, 1, 0, 0);
			mv.rotate(skyAngleShadow * -360.f, 0, 0, 1);
			mv.rotate(d.sunPathRotation, 1, 0, 0);

			// Snap to grid
			if (std::fabs(d.shadowIntervalSize) > 0.f)
			{
				float interval = d.shadowIntervalSize;
				float ox = (float)std::fmod(state.cameraPosition.x, (double)interval) - interval / 2.f;
				float oy = (float)std::fmod(state.cameraPosition.y, (double)interval) - interval / 2.f;
				float oz = (float)std::fmod(state.cameraPosition.z, (double)interval) - interval / 2.f;
				mv.translate(ox, oy, oz);
			}
			shadowModelView = mv;
			shadowModelViewInv = mv.inverted();

			QMatrix4x4 proj;
			if (d.shadowMapFov > 0.f)
			{
				const float nearP = -100.05f, farP = 156.f;
				float yScale = 1.f / std::tan(d.shadowMapFov * (float)PI / 360.f);
				proj = QMatrix4x4(yScale, 0, 0, 0,
								  0, yScale, 0, 0,
								  0, 0, (farP + nearP) / (nearP - farP), (2.f * farP) * nearP / (nearP - farP),
								  0, 0, -1, 1);
			}
			else
			{
				float half = d.shadowDistance;
				proj.ortho(-half, half, -half, half, d.shadowNearPlane, d.shadowFarPlane);
			}
			shadowProjection = proj;
			shadowProjectionInv = proj.inverted();
		}

		void UpdateLightmap()
		{
			// Approximation of Minecraft's LightTexture
			float skyDarken = 1.f - (std::cos(skyAngle * 2.f * (float)PI) * 2.f + 0.2f);
			skyDarken = 1.f - qBound(0.f, skyDarken, 1.f);
			skyDarken = skyDarken * (1.f - state.rainStrength * 5.f / 16.f);
			float skyFactor = skyDarken * 0.95f + 0.05f;

			QVector<uint8_t> data(16 * 16 * 4);
			for (int sky = 0; sky < 16; sky++)
			{
				for (int block = 0; block < 16; block++)
				{
					auto brightness = [](int level)
					{
						float f = level / 15.f;
						return f / (4.f - 3.f * f);
					};
					float s = brightness(sky) * skyFactor;
					float b = brightness(block) * 1.5f;
					QVector3D skyColor = QVector3D(s, s, s) * QVector3D(skyDarken * 0.65f + 0.35f, skyDarken * 0.65f + 0.35f, 1.f);
					QVector3D blockColor(b, b * ((b * 0.6f + 0.4f) * 0.6f + 0.4f), b * (b * b * 0.6f + 0.4f));
					QVector3D c = skyColor + blockColor;
					c = c * 0.96f + QVector3D(0.03f, 0.03f, 0.03f);
					for (int k = 0; k < 3; k++)
						c[k] = qBound(0.f, c[k], 1.f);
					int idx = (sky * 16 + block) * 4;
					data[idx + 0] = (uint8_t)(c.x() * 255);
					data[idx + 1] = (uint8_t)(c.y() * 255);
					data[idx + 2] = (uint8_t)(c.z() * 255);
					data[idx + 3] = 255;
				}
			}
			gl->glBindTexture(GL_TEXTURE_2D, lightmapTex.id);
			gl->glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 16, 16, GL_RGBA, GL_UNSIGNED_BYTE, data.constData());
			gl->glBindTexture(GL_TEXTURE_2D, 0);
		}

		void UpdateFrameUniforms()
		{
			QHash<QString, UVal>& u = frameUniforms;
			u.clear();

			const DVec3& cam = state.cameraPosition;
			u["gbufferModelView"] = UVal::Mat4(modelView);
			u["gbufferModelViewInverse"] = UVal::Mat4(modelViewInv);
			u["gbufferPreviousModelView"] = UVal::Mat4(prevModelView);
			u["gbufferProjection"] = UVal::Mat4(projection);
			u["gbufferProjectionInverse"] = UVal::Mat4(projectionInv);
			u["gbufferPreviousProjection"] = UVal::Mat4(prevProjection);
			u["shadowModelView"] = UVal::Mat4(shadowModelView);
			u["shadowModelViewInverse"] = UVal::Mat4(shadowModelViewInv);
			u["shadowProjection"] = UVal::Mat4(shadowProjection);
			u["shadowProjectionInverse"] = UVal::Mat4(shadowProjectionInv);

			u["cameraPosition"] = UVal::Vec3(QVector3D((float)cam.x, (float)cam.y, (float)cam.z));
			u["previousCameraPosition"] = UVal::Vec3(QVector3D((float)prevCameraPosition.x, (float)prevCameraPosition.y, (float)prevCameraPosition.z));
			auto intPart = [](double v) { return (int)std::floor(v); };
			u["cameraPositionInt"] = UVal::IVec3(intPart(cam.x), intPart(cam.y), intPart(cam.z));
			u["cameraPositionFract"] = UVal::Vec3(QVector3D((float)(cam.x - std::floor(cam.x)), (float)(cam.y - std::floor(cam.y)), (float)(cam.z - std::floor(cam.z))));
			u["previousCameraPositionInt"] = UVal::IVec3(intPart(prevCameraPosition.x), intPart(prevCameraPosition.y), intPart(prevCameraPosition.z));
			u["previousCameraPositionFract"] = UVal::Vec3(QVector3D((float)(prevCameraPosition.x - std::floor(prevCameraPosition.x)),
																   (float)(prevCameraPosition.y - std::floor(prevCameraPosition.y)),
																   (float)(prevCameraPosition.z - std::floor(prevCameraPosition.z))));
			u["eyePosition"] = u["cameraPosition"];
			u["relativeEyePosition"] = UVal::Vec3(QVector3D(0, 0, 0));
			u["eyeAltitude"] = UVal::Float((float)cam.y);
			QVector3D look = (modelViewInv * QVector4D(0, 0, -1, 0)).toVector3D().normalized();
			u["playerLookVector"] = UVal::Vec3(look);
			u["playerBodyVector"] = UVal::Vec3(look);
			u["upPosition"] = UVal::Vec3(upPosition);

			u["sunPosition"] = UVal::Vec3(sunPosition);
			u["moonPosition"] = UVal::Vec3(moonPosition);
			u["shadowLightPosition"] = UVal::Vec3(shadowLightPosition);
			u["sunAngle"] = UVal::Float(sunAngle);
			u["shadowAngle"] = UVal::Float(shadowAngle);

			u["worldTime"] = UVal::Int(state.worldTime);
			u["worldDay"] = UVal::Int(state.worldDay);
			u["moonPhase"] = UVal::Int(state.moonPhase);
			u["frameCounter"] = UVal::Int(frameCounter);
			u["frameTime"] = UVal::Float(state.frameTime);
			u["frameTimeCounter"] = UVal::Float(state.frameTimeCounter);
			QDateTime now = QDateTime::currentDateTime();
			u["currentDate"] = UVal::IVec3(now.date().year(), now.date().month(), now.date().day());
			u["currentTime"] = UVal::IVec3(now.time().hour(), now.time().minute(), now.time().second());
			u["currentYearTime"] = UVal::IVec2(now.date().dayOfYear() * 86400 + now.time().msecsSinceStartOfDay() / 1000,
											   (now.date().daysInYear() - now.date().dayOfYear()) * 86400);

			u["viewWidth"] = UVal::Float((float)width);
			u["viewHeight"] = UVal::Float((float)height);
			u["aspectRatio"] = UVal::Float((float)width / (float)qMax(1, height));
			u["near"] = UVal::Float(state.nearPlane);
			u["far"] = UVal::Float(state.renderDistance);

			u["rainStrength"] = UVal::Float(state.rainStrength);
			u["wetness"] = UVal::Float(wetness);
			u["thunderStrength"] = UVal::Float(state.thunderStrength);
			u["lightningBoltPosition"] = UVal::Vec4(QVector4D(0, 0, 0, 0));

			u["fogColor"] = UVal::Vec3(state.fogColor);
			u["skyColor"] = UVal::Vec3(state.skyColor);
			u["fogDensity"] = UVal::Float(state.fogDensity);
			u["fogStart"] = UVal::Float(state.fogStart);
			u["fogEnd"] = UVal::Float(state.fogEnd);
			u["fogMode"] = UVal::Int(9729); // GL_LINEAR
			u["fogShape"] = UVal::Int(1);	// Cylinder
			u["iris_FogColor"] = UVal::Vec4(QVector4D(state.fogColor, 1.f));
			u["iris_FogStart"] = UVal::Float(state.fogStart);
			u["iris_FogEnd"] = UVal::Float(state.fogEnd);
			u["iris_FogDensity"] = UVal::Float(state.fogDensity);

			u["isEyeInWater"] = UVal::Int(state.isEyeInWater);
			u["eyeBrightness"] = UVal::IVec2(state.eyeBrightnessBlock, state.eyeBrightnessSky);
			u["eyeBrightnessSmooth"] = UVal::IVec2((int)eyeBrightnessSmooth[0], (int)eyeBrightnessSmooth[1]);
			u["nightVision"] = UVal::Float(state.nightVision);
			u["blindness"] = UVal::Float(state.blindness);
			u["darknessFactor"] = UVal::Float(0.f);
			u["darknessLightFactor"] = UVal::Float(0.f);
			u["screenBrightness"] = UVal::Float(state.screenBrightness);
			u["playerMood"] = UVal::Float(0.f);
			u["constantMood"] = UVal::Float(0.f);
			u["heldItemId"] = UVal::Int(-1);
			u["heldItemId2"] = UVal::Int(-1);
			u["heldBlockLightValue"] = UVal::Int(0);
			u["heldBlockLightValue2"] = UVal::Int(0);
			u["hideGUI"] = UVal::Int(1);
			u["isRightHanded"] = UVal::Int(1);
			u["isSpectator"] = UVal::Int(0);
			u["firstPersonCamera"] = UVal::Int(1);
			u["is_sneaking"] = UVal::Int(0);
			u["is_sprinting"] = UVal::Int(0);
			u["is_hurt"] = UVal::Int(0);
			u["is_invisible"] = UVal::Int(0);
			u["is_burning"] = UVal::Int(0);
			u["is_on_ground"] = UVal::Int(1);
			u["hasCeiling"] = UVal::Int(0);
			u["hasSkylight"] = UVal::Int(1);
			u["ambientLight"] = UVal::Float(0.f);
			u["bedrockLevel"] = UVal::Int(-64);
			u["heightLimit"] = UVal::Int(384);
			u["logicalHeightLimit"] = UVal::Int(384);
			u["seaLevel"] = UVal::Int(63);
			u["cloudHeight"] = UVal::Float(192.33f);
			u["bossBattle"] = UVal::Int(0);
			u["dimension"] = UVal::Int(0);
			u["centerDepthSmooth"] = UVal::Float(centerDepthSmooth);
			u["biome"] = UVal::Int(1);
			u["biome_category"] = UVal::Int(state.biomeCategory);
			u["biome_precipitation"] = UVal::Int(state.biomePrecipitation);
			u["temperature"] = UVal::Float(state.temperature);
			u["rainfall"] = UVal::Float(state.rainfall);
			u["textureFilteringMode"] = UVal::Int(0);
			u["pi"] = UVal::Float((float)PI);

			// Iris exclusive uniforms (values of a player in creative mode, like Iris returns outside survival)
			u["currentPlayerHealth"] = UVal::Float(-1.f);
			u["maxPlayerHealth"] = UVal::Float(20.f);
			u["currentPlayerHunger"] = UVal::Float(-1.f);
			u["maxPlayerHunger"] = UVal::Float(20.f);
			u["currentPlayerAir"] = UVal::Float(-1.f);
			u["maxPlayerAir"] = UVal::Float(300.f);
			u["currentPlayerArmor"] = UVal::Float(-1.f);
			u["maxPlayerArmor"] = UVal::Float(50.f);
			u["heavyFog"] = UVal::Int(0);
			u["endFlashIntensity"] = UVal::Float(0.f);
			u["previousEndFlashIntensity"] = UVal::Float(0.f);
			u["feetInWater"] = UVal::Int(0);
			u["inSwimmingAnimation"] = UVal::Int(0);
			u["isRiding"] = UVal::Int(0);
			u["isElytraFlying"] = UVal::Int(0);
			u["vehicleInWater"] = UVal::Int(0);
			u["vehicleId"] = UVal::Int(-1);
			u["currentSelectedBlockId"] = UVal::Int(-1);
			u["currentSelectedBlockPos"] = UVal::Vec3(QVector3D(-256.f, -256.f, -256.f));
			u["cloudTime"] = UVal::Float(state.frameTimeCounter * 20.f);
			u["currentColorSpace"] = UVal::Int(0);
			u["chunkFadeTimeInv"] = UVal::Float(0.f);

			// Hardcoded custom uniforms Iris provides for popular packs (BSL, Complementary, SDV, ...)
			float timeAngle = (float)(((state.worldTime % 24000) + 24000) % 24000) / 24000.f;
			u["timeAngle"] = UVal::Float(timeAngle);
			u["timeBrightness"] = UVal::Float(qMax(0.f, (float)std::sin(timeAngle * PI * 2.0)));
			u["moonBrightness"] = UVal::Float(qMax(0.f, (float)std::sin(timeAngle * PI * -2.0)));
			{
				float a = (sunAngle <= 0.5f) ? sunAngle : sunAngle - 0.5f;
				u["shadowFade"] = UVal::Float(qBound(0.f, 1.f - (std::fabs(std::fabs(a - 0.5f) - 0.25f) - 0.23f) * 100.f, 1.f));
				u["shdFade"] = UVal::Float(qBound(0.f, 1.f - (std::fabs(std::fabs(sunAngle - 0.5f) - 0.25f) - 0.225f) * 40.f, 1.f));
			}
			u["rainStrengthS"] = UVal::Float(state.rainStrength);
			u["rainStrengthShiningStars"] = UVal::Float(state.rainStrength);
			u["rainStrengthS2"] = UVal::Float(state.rainStrength);
			u["rainFactor"] = UVal::Float(state.rainStrength);
			float blindSqrt = qBound(0.f, state.blindness * 2.f - 1.f, 1.f);
			u["blindFactor"] = UVal::Float(blindSqrt * blindSqrt);
			u["isDry"] = UVal::Float(state.biomePrecipitation == 0 ? 1.f : 0.f);
			u["isRainy"] = UVal::Float(state.biomePrecipitation == 1 ? 1.f : 0.f);
			u["isSnowy"] = UVal::Float(state.biomePrecipitation == 2 ? 1.f : 0.f);
			u["isPrecipitationRain"] = UVal::Float(state.biomePrecipitation == 1 && cam.y < 96.0 ? 1.f : 0.f);
			u["isEyeInCave"] = UVal::Float(state.isEyeInWater == 0 && cam.y < 5.0 ? 1.f - state.eyeBrightnessSky / 240.f : 0.f);
			u["eyeBrightnessM"] = UVal::Float(state.eyeBrightnessSky / 240.f);
			double dx = cam.x - prevCameraPosition.x, dy = cam.y - prevCameraPosition.y, dz = cam.z - prevCameraPosition.z;
			u["velocity"] = UVal::Float((float)std::sqrt(dx * dx + dy * dy + dz * dz));
			u["starter"] = UVal::Float(1.f);
			u["frameTimeSmooth"] = UVal::Float(state.frameTime);
			u["BiomeTemp"] = UVal::Float(state.temperature);
			{
				float adj = std::fabs(std::fmod(state.worldTime / 1000.f + 6.f, 24.f) - 12.f);
				float day = qBound(0.f, 5.4f - adj, 1.f);
				float night = qBound(0.f, adj - 6.f, 1.f);
				u["day"] = UVal::Float(day);
				u["night"] = UVal::Float(night);
				u["dawnDusk"] = UVal::Float(1.f - day - night);
			}
			u["touchmybody"] = UVal::Float(0.f);
			u["sneakSmooth"] = UVal::Float(0.f);
			u["burningSmooth"] = UVal::Float(0.f);
			u["effectStrength"] = UVal::Float(0.f);

			// Custom variables and uniforms, evaluated in definition order
			exprContext.frameTime = state.frameTime;
			exprContext.lookup = [this](const QString& name, ExprValue& out)
			{
				auto it = frameUniforms.constFind(name);
				if (it == frameUniforms.constEnd())
					return false;
				const UVal& v = it.value();
				if (v.components == 16)
				{
					out = ExprValue::Mat(4, v.f);
					return true;
				}
				if (v.components == 9)
				{
					out = ExprValue::Mat(3, v.f);
					return true;
				}
				if (v.components == 1)
				{
					out = (v.type == UVal::INT) ? ExprValue::Int(v.i[0]) : ExprValue::Float(v.f[0]);
					return true;
				}
				out = ExprValue::Vec(v.components, v.f);
				return true;
			};

			for (const CustomUniformSpec& cu : pack->properties.uniforms)
			{
				ExprValue r = cu.expression->Evaluate(exprContext).Cast(cu.type);
				UVal v;
				switch (cu.type)
				{
					case ExprValue::BOOL:
					case ExprValue::INT:
						v = UVal::Int((int)r.v[0]);
						break;
					case ExprValue::FLOAT:
						v = UVal::Float(r.v[0]);
						break;
					case ExprValue::VEC2:
						v = UVal::Vec2(r.v[0], r.v[1]);
						break;
					case ExprValue::VEC3:
						v = UVal::Vec3(QVector3D(r.v[0], r.v[1], r.v[2]));
						break;
					default:
						v = UVal::Vec4(QVector4D(r.v[0], r.v[1], r.v[2], r.v[3]));
						break;
				}
				u[cu.name] = v;
				if (frameCounter == 0 && qEnvironmentVariableIsSet("SP_PRINT_UNIFORMS"))
					LogInfo(QString("custom %1 = %2 %3 %4 %5 (%6)").arg(cu.name).arg(v.f[0]).arg(v.f[1]).arg(v.f[2]).arg(v.f[3]).arg(cu.source));
			}
		}

		void UploadUniform(const UniformBinding& b, const UVal& v)
		{
			GLint loc = b.location;
			switch (b.type)
			{
				case GL_FLOAT: gl->glUniform1f(loc, v.f[0]); break;
				case GL_FLOAT_VEC2: gl->glUniform2f(loc, v.f[0], v.f[1]); break;
				case GL_FLOAT_VEC3: gl->glUniform3f(loc, v.f[0], v.f[1], v.f[2]); break;
				case GL_FLOAT_VEC4: gl->glUniform4f(loc, v.f[0], v.f[1], v.f[2], v.f[3]); break;
				case GL_INT:
				case GL_BOOL:
					gl->glUniform1i(loc, v.type == UVal::INT ? v.i[0] : (int)v.f[0]);
					break;
				case GL_INT_VEC2:
				case GL_BOOL_VEC2:
					gl->glUniform2i(loc, v.type == UVal::INT ? v.i[0] : (int)v.f[0], v.type == UVal::INT ? v.i[1] : (int)v.f[1]);
					break;
				case GL_INT_VEC3:
				case GL_BOOL_VEC3:
					gl->glUniform3i(loc, (int)v.f[0], (int)v.f[1], (int)v.f[2]);
					break;
				case GL_INT_VEC4:
				case GL_BOOL_VEC4:
					gl->glUniform4i(loc, (int)v.f[0], (int)v.f[1], (int)v.f[2], (int)v.f[3]);
					break;
				case GL_UNSIGNED_INT: gl->glUniform1ui(loc, (GLuint)qMax(0.f, v.f[0])); break;
				case GL_FLOAT_MAT3:
					if (v.components == 9)
						gl->glUniformMatrix3fv(loc, 1, GL_FALSE, v.f);
					else if (v.components == 16)
					{
						float m3[9] = { v.f[0], v.f[1], v.f[2], v.f[4], v.f[5], v.f[6], v.f[8], v.f[9], v.f[10] };
						gl->glUniformMatrix3fv(loc, 1, GL_FALSE, m3);
					}
					break;
				case GL_FLOAT_MAT4:
					if (v.components == 16)
						gl->glUniformMatrix4fv(loc, 1, GL_FALSE, v.f);
					break;
				default:
					break;
			}
		}

		void UploadFrameUniforms(Program* p)
		{
			if (p->uploadedFrame == frameCounter)
				return;
			bool first = (p->uploadedFrame == -2);
			p->uploadedFrame = frameCounter;

			static const QSet<QString> objectUniforms = {
				"mi_ModelMat", "mi_ModelNormalMat", "mi_ColorModulator", "mi_UvRect", "mi_ModelViewMat", "mi_ModelViewMatInverse",
				"mi_ProjMat", "mi_ProjMatInverse", "mi_NormalMat", "mi_AmbientOcclusionLevel", "mi_SeparateAo", "mi_OldLighting", "mi_AlphaTestRef", "entityColor",
				"entityId", "blockEntityId", "currentRenderedItemId", "atlasSize", "renderStage"
			};
			QStringList missing;
			for (const UniformBinding& b : p->uniforms)
			{
				auto it = frameUniforms.constFind(b.name);
				if (it != frameUniforms.constEnd())
					UploadUniform(b, it.value());
				else if (first && !objectUniforms.contains(b.name))
					missing.append(b.name);
			}
			if (first && !missing.isEmpty())
				LogInfo("Uniforms without values in " + p->name + ": " + missing.join(", "));
		}

		void SetUniform(Program* p, const QString& name, const UVal& v)
		{
			for (const UniformBinding& b : p->uniforms)
				if (b.name == name)
				{
					UploadUniform(b, v);
					return;
				}
		}

		// ----------------------------------------------------------------------------------------
		// Binding textures

		GLuint ResolveTexture(const SamplerBinding& s, const QSet<int>& flipState, const ObjectState* object, GLuint& sampler, QVector4D* uvRect = nullptr)
		{
			sampler = samplerLinear;
			switch (s.source)
			{
				case SamplerSource::ColorTarget:
				{
					ColorTarget& t = colorTargets[s.index];
					if (!t.used)
						return 0;
					bool mip = current && current->mipmapped.contains(s.index);
					sampler = t.settings.format.isInteger ? samplerNearest : (mip ? samplerLinearMip : samplerLinear);
					return ReadTex(s.index, flipState).id;
				}
				case SamplerSource::DepthTex:
					sampler = samplerNearest;
					return depthTex[s.index].id;
				case SamplerSource::ShadowDepth:
				{
					const ShadowBufferSettings& set = pack->directives.shadowDepth[s.index];
					if (IsShadowSamplerType(s.type) || s.name.endsWith("HW"))
						sampler = set.nearest ? samplerShadowCompareNearest : samplerShadowCompare;
					else
						sampler = set.nearest ? samplerNearest : (set.mipmap ? samplerLinearMip : samplerLinear);
					if (set.hardwareFiltering && IsShadowSamplerType(s.type))
						sampler = set.nearest ? samplerShadowCompareNearest : samplerShadowCompare;
					return shadowDepth[s.index].id;
				}
				case SamplerSource::ShadowColor:
				{
					const ShadowBufferSettings& set = pack->directives.shadowColor[s.index];
					sampler = (set.nearest || set.format.isInteger) ? samplerNearest : (set.mipmap ? samplerLinearMip : samplerLinear);
					return shadowColor[s.index].id;
				}
				case SamplerSource::Noise:
					sampler = samplerRepeatLinear;
					return noiseTex.id;
				case SamplerSource::Lightmap:
					sampler = samplerLinear;
					return lightmapTex.id;
				case SamplerSource::ObjectTexture:
				case SamplerSource::ObjectNormals:
				case SamplerSource::ObjectSpecular:
				{
					sampler = samplerAtlas;
					GLuint fallback = (s.source == SamplerSource::ObjectNormals) ? defaultNormalsTex.id :
									  (s.source == SamplerSource::ObjectSpecular) ? defaultSpecularTex.id : whiteTex.id;
					if (!object)
						return fallback;
					const HostTexture& t = (s.source == SamplerSource::ObjectTexture) ? object->texture :
										   (s.source == SamplerSource::ObjectNormals) ? object->normals : object->specular;
					if (uvRect)
						*uvRect = t.uvRect;
					if (!t.id)
						return fallback;
					if (!t.mipmapped) // A mipmap filter would make the texture incomplete
						sampler = samplerAtlasNoMip;
					return t.id;
				}
				case SamplerSource::Custom:
				{
					auto it = customTextures.constFind(s.customKey);
					if (it != customTextures.constEnd())
					{
						sampler = 0; // Use texture parameters
						return it->id;
					}
					// Resource textures from the host
					QString stage = s.customKey.left(s.customKey.indexOf(':'));
					QString name = s.customKey.mid(s.customKey.indexOf(':') + 1);
					const TextureSpec spec = stage == "custom" ? pack->properties.customTextures.value(name) : pack->properties.textures.value(stage).value(name);
					if (resourceProvider && !spec.path.isEmpty())
					{
						HostTexture t = resourceProvider(spec.path);
						sampler = t.mipmapped ? samplerAtlas : samplerAtlasNoMip;
						return t.id;
					}
					return 0;
				}
				case SamplerSource::Image:
					sampler = images[s.index].tex.format.isInteger ? samplerNearest : samplerLinear;
					return images[s.index].tex.id;
				case SamplerSource::BlockOffsets:
					sampler = samplerNearest;
					return blockOffsetsTex.id;
				case SamplerSource::BlockIds:
					sampler = samplerNearest;
					return blockIdsTex.id;
				default:
					return 0;
			}
		}

		std::function<HostTexture(const QString&)> resourceProvider;

		void BindSamplers(Program* p, const QSet<int>& flipState, const ObjectState* object, bool objectOnly)
		{
			for (const SamplerBinding& s : p->samplers)
			{
				bool isObject = (s.source == SamplerSource::ObjectTexture || s.source == SamplerSource::ObjectNormals || s.source == SamplerSource::ObjectSpecular);
				if (objectOnly != isObject)
					continue;

				GLuint sampler = 0;
				GLuint tex = ResolveTexture(s, flipState, object, sampler);
				gl->glActiveTexture(GL_TEXTURE0 + s.unit);

				GLenum target = GL_TEXTURE_2D;
				if (s.type == GL_SAMPLER_3D || s.type == GL_INT_SAMPLER_3D || s.type == GL_UNSIGNED_INT_SAMPLER_3D)
					target = GL_TEXTURE_3D;
				else if (s.type == GL_SAMPLER_1D || s.type == GL_INT_SAMPLER_1D || s.type == GL_UNSIGNED_INT_SAMPLER_1D)
					target = GL_TEXTURE_1D;
				else if (s.type == GL_SAMPLER_2D_RECT || s.type == GL_SAMPLER_2D_RECT_SHADOW)
					target = GL_TEXTURE_RECTANGLE;
				gl->glBindTexture(target, tex);
				gl->glBindSampler(s.unit, sampler);
			}
			gl->glActiveTexture(GL_TEXTURE0);
		}

		void BindImages(Program* p, const QSet<int>& flipState)
		{
			if (!computeSupported)
				return;
			for (const ImageBinding& img : p->images)
			{
				GLuint tex = 0;
				GLenum format = GL_RGBA8;
				bool layered = false;
				if (img.kind == 0 && img.index >= 0 && img.index < 16 && colorTargets[img.index].used)
				{
					tex = ReadTex(img.index, flipState).id;
					format = colorTargets[img.index].settings.format.internalFormat;
				}
				else if (img.kind == 1 && img.index >= 0 && img.index < 8)
				{
					tex = shadowColor[img.index].id;
					format = pack->directives.shadowColor[img.index].format.internalFormat;
				}
				else if (img.kind == 2)
				{
					tex = images[img.index].tex.id;
					format = images[img.index].tex.format.internalFormat;
					layered = images[img.index].tex.target == GL_TEXTURE_3D;
				}
				if (tex)
					ex->glBindImageTexture(img.unit, tex, 0, layered ? GL_TRUE : GL_FALSE, 0, GL_READ_WRITE, format);
			}
		}

		// ----------------------------------------------------------------------------------------
		// Drawing

		void SetupVertexAttribs(GLuint vbo, GLuint ibo, int stride)
		{
			gl->glBindVertexArray(vao);
			gl->glBindBuffer(GL_ARRAY_BUFFER, vbo);
			gl->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);

			const int offsets[ATTR_COUNT] = { 0, 12, 16, 20, 28, 32, 36, 40, 44, 48 };
			for (int a = 0; a < ATTR_COUNT; a++)
			{
				if (offsets[a] + 4 > stride && a != ATTR_POSITION)
				{
					gl->glDisableVertexAttribArray(a);
					continue;
				}
				gl->glEnableVertexAttribArray(a);
				if (a == ATTR_POSITION)
					gl->glVertexAttribPointer(a, 3, GL_FLOAT, GL_FALSE, stride, (void*)(intptr_t)offsets[a]);
				else if (a == ATTR_UV)
					gl->glVertexAttribPointer(a, 2, GL_FLOAT, GL_FALSE, stride, (void*)(intptr_t)offsets[a]);
				else
					gl->glVertexAttribIPointer(a, 1, GL_UNSIGNED_INT, stride, (void*)(intptr_t)offsets[a]);
			}
		}

		void DrawFullscreen()
		{
			SetupVertexAttribs(quadVbo, quadIbo, 52);
			gl->glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nullptr);
		}

		void ApplyBlend(Program* p, const BlendModeSpec* defaultBlend)
		{
			const BlendModeSpec* blend = p->hasBlend ? &p->blend : defaultBlend;
			if (!blend || blend->off)
				gl->glDisable(GL_BLEND);
			else
			{
				gl->glEnable(GL_BLEND);
				gl->glBlendFuncSeparate(blend->src, blend->dst, blend->srcAlpha, blend->dstAlpha);
			}

			// Per buffer overrides
			if (!p->bufferBlend.isEmpty() && glVersion >= 40)
			{
				for (int i = 0; i < p->drawBuffers.size(); i++)
				{
					auto it = p->bufferBlend.constFind(p->drawBuffers[i]);
					if (it == p->bufferBlend.constEnd())
						continue;
					if (it->off)
						ex->glDisablei(GL_BLEND, i);
					else
					{
						ex->glEnablei(GL_BLEND, i);
						ex->glBlendFuncSeparatei(i, it->src, it->dst, it->srcAlpha, it->dstAlpha);
					}
				}
			}
		}

		void GenerateMipmaps(Program* p, const QSet<int>& flipState)
		{
			for (int b : p->mipmapped)
			{
				if (b < 0 || b >= 16 || !colorTargets[b].used || colorTargets[b].settings.format.isInteger)
					continue;
				Tex& t = ReadTex(b, flipState);
				gl->glBindTexture(GL_TEXTURE_2D, t.id);
				gl->glGenerateMipmap(GL_TEXTURE_2D);
			}
			gl->glBindTexture(GL_TEXTURE_2D, 0);
		}

		void DispatchCompute(Program* c, const QSet<int>& flipState)
		{
			if (!c || !computeSupported)
				return;
			gl->glUseProgram(c->id);
			UploadFrameUniforms(c);
			BindSamplers(c, flipState, nullptr, false);
			BindImages(c, flipState);

			int gx, gy, gz;
			if (c->hasWorkGroups)
			{
				gx = c->workGroups[0];
				gy = c->workGroups[1];
				gz = c->workGroups[2];
			}
			else
			{
				float sx = c->hasWorkGroupsRender ? c->workGroupsRender[0] : 1.f;
				float sy = c->hasWorkGroupsRender ? c->workGroupsRender[1] : 1.f;
				gx = (int)std::ceil(std::ceil(width * sx) / c->localSize[0]);
				gy = (int)std::ceil(std::ceil(height * sy) / c->localSize[1]);
				gz = 1;
			}
			ex->glDispatchCompute(qMax(1, gx), qMax(1, gy), qMax(1, gz));
			ex->glMemoryBarrier(GL_ALL_BARRIER_BITS);
		}

		// Debugging (SP_TRACE=<frame>): logs statistics of the buffers written by a pass.
		int traceFrame = qEnvironmentVariableIsSet("SP_TRACE") ? qEnvironmentVariableIntValue("SP_TRACE") : -1;

		void TracePass(Program* p, const QSet<int>& writeState)
		{
			if (traceFrame != frameCounter)
				return;

			GLuint fbo = 0;
			gl->glGenFramebuffers(1, &fbo);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
			QStringList out;
			for (int b : p->drawBuffers)
			{
				if (b < 0 || b >= 16 || !colorTargets[b].used)
					continue;
				Tex& t = WriteTex(b, writeState);
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, t.id, 0);
				gl->glReadBuffer(GL_COLOR_ATTACHMENT0);
				QVector<float> px(t.w * t.h * 4);
				if (t.format.isInteger)
				{
					QVector<int> ipx(t.w * t.h * 4);
					gl->glReadPixels(0, 0, t.w, t.h, GL_RGBA_INTEGER, GL_INT, ipx.data());
					for (int i = 0; i < ipx.size(); i++)
						px[i] = ipx[i];
				}
				else
					gl->glReadPixels(0, 0, t.w, t.h, GL_RGBA, GL_FLOAT, px.data());

				double sum[4] = { 0, 0, 0, 0 };
				int nans = 0;
				for (int i = 0; i < t.w * t.h; i++)
					for (int c = 0; c < 4; c++)
					{
						float v = px[i * 4 + c];
						if (std::isnan(v) || std::isinf(v))
							nans++;
						else
							sum[c] += v;
					}
				int n = t.w * t.h;
				static QString traceDir = qEnvironmentVariable("SP_TRACE_DIR");
				if (!traceDir.isEmpty())
				{
					QImage img(t.w, t.h, QImage::Format_RGBA8888);
					for (int y = 0; y < t.h; y++)
						for (int x = 0; x < t.w; x++)
						{
							const float* px4 = &px[((t.h - 1 - y) * t.w + x) * 4];
							auto c = [](float v) { return std::isnan(v) ? 255 : qBound(0, (int)(v * 255.f), 255); };
							img.setPixel(x, y, qRgba(c(px4[0]), c(px4[1]), c(px4[2]), 255));
						}
					img.save(QString("%1/%2_colortex%3.png").arg(traceDir, p->name).arg(b));
				}
				out << QString("%1%2 mean(%3 %4 %5 %6) nan=%7").arg(b).arg(&t == &colorTargets[b].alt ? "a" : "m")
						   .arg(sum[0] / n, 0, 'g', 4).arg(sum[1] / n, 0, 'g', 4).arg(sum[2] / n, 0, 'g', 4).arg(sum[3] / n, 0, 'g', 4).arg(nans);
			}
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
			gl->glDeleteFramebuffers(1, &fbo);
			Log(QString("Trace %1: %2").arg(p->name, out.join(" | ")));

			QStringList samplers;
			for (const SamplerBinding& s : p->samplers)
			{
				GLint bound = 0, unitValue = -1;
				gl->glActiveTexture(GL_TEXTURE0 + s.unit);
				gl->glGetIntegerv(GL_TEXTURE_BINDING_2D, &bound);
				gl->glGetUniformiv(p->id, s.location, &unitValue);
				samplers << QString("%1@%2/%3=%4").arg(s.name).arg(s.unit).arg(unitValue).arg(bound);
			}
			gl->glActiveTexture(GL_TEXTURE0);
			Log(QString("Trace samplers %1: %2").arg(p->name, samplers.join(" ")));
		}

		// Runs a list of composite passes, updating the flip state like Iris' CompositeRenderer.
		void RunPasses(const QVector<Pass>& passes)
		{
			gl->glDisable(GL_DEPTH_TEST);
			gl->glDepthMask(GL_FALSE);
			gl->glDisable(GL_CULL_FACE);

			for (const Pass& pass : passes)
			{
				for (Program* c : pass.computes)
					DispatchCompute(c, flipped);

				Program* p = pass.program;
				if (!p)
					continue;

				current = p;
				QSet<int> readState = flipped;
				GenerateMipmaps(p, readState);

				GLuint fbo = GetFramebuffer(p, p->drawBuffers, readState, false, false);
				gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);

				int pw = width, ph = height;
				if (!p->drawBuffers.isEmpty())
				{
					int b = p->drawBuffers[0];
					if (b >= 0 && b < 16 && colorTargets[b].used)
					{
						pw = colorTargets[b].main.w;
						ph = colorTargets[b].main.h;
					}
				}
				float sc = p->scale.scale;
				gl->glViewport((int)(p->scale.offsetX * pw), (int)(p->scale.offsetY * ph), qMax(1, (int)(pw * sc)), qMax(1, (int)(ph * sc)));

				// viewWidth/viewHeight stay the main framebuffer size like in Iris
				gl->glUseProgram(p->id);
				UploadFrameUniforms(p);
				BindSamplers(p, readState, nullptr, false);
				BindImages(p, readState);
				ApplyBlend(p, nullptr);

				DrawFullscreen();
				TracePass(p, readState);

				// Flip written buffers
				for (int b : p->drawBuffers)
				{
					if (p->flips.value(b, true) == false)
						continue;
					if (flipped.contains(b))
						flipped.remove(b);
					else
						flipped.insert(b);
				}
				for (auto it = p->flips.constBegin(); it != p->flips.constEnd(); ++it)
				{
					if (!it.value() || p->drawBuffers.contains(it.key()))
						continue;
					if (flipped.contains(it.key()))
						flipped.remove(it.key());
					else
						flipped.insert(it.key());
				}
			}

			gl->glDisable(GL_BLEND);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, 0);
			current = nullptr;
		}

		// ----------------------------------------------------------------------------------------
		// Geometry phases

		QString PhaseProgramName(GeometryPhase phase, bool shadow)
		{
			if (shadow)
			{
				switch (phase)
				{
					case GeometryPhase::TerrainSolid: return "shadow_solid";
					case GeometryPhase::TerrainCutout: return "shadow_cutout";
					case GeometryPhase::Water: return "shadow_water";
					case GeometryPhase::Entities:
					case GeometryPhase::EntitiesTranslucent: return "shadow_entities";
					case GeometryPhase::Block:
					case GeometryPhase::BlockTranslucent: return "shadow_block";
					case GeometryPhase::Hand: return QString();
					default: return QString();
				}
			}
			switch (phase)
			{
				case GeometryPhase::SkyBasic: return "gbuffers_skybasic";
				case GeometryPhase::SkyTextured: return "gbuffers_skytextured";
				case GeometryPhase::Clouds: return "gbuffers_clouds";
				case GeometryPhase::TerrainSolid: return "gbuffers_terrain_solid";
				case GeometryPhase::TerrainCutout: return "gbuffers_terrain_cutout";
				case GeometryPhase::Water: return "gbuffers_water";
				case GeometryPhase::Entities: return "gbuffers_entities";
				case GeometryPhase::EntitiesTranslucent: return "gbuffers_entities_translucent";
				case GeometryPhase::Block: return "gbuffers_block";
				case GeometryPhase::BlockTranslucent: return "gbuffers_block_translucent";
				case GeometryPhase::Particles: return "gbuffers_particles";
				case GeometryPhase::ParticlesTranslucent: return "gbuffers_particles_translucent";
				case GeometryPhase::Weather: return "gbuffers_weather";
				case GeometryPhase::Textured: return "gbuffers_textured";
				case GeometryPhase::TexturedLit: return "gbuffers_textured_lit";
				case GeometryPhase::Basic: return "gbuffers_basic";
				case GeometryPhase::Hand: return "gbuffers_hand";
				default: return QString();
			}
		}

		Program* FindProgram(const QString& name)
		{
			QString n = name;
			int guard = 0;
			while (!n.isEmpty() && guard++ < 16)
			{
				auto it = programs.constFind(n);
				if (it != programs.constEnd())
					return it.value();
				n = Pack::FallbackProgram(n);
			}
			return nullptr;
		}

		int RenderStage(GeometryPhase phase)
		{
			switch (phase)
			{
				case GeometryPhase::SkyBasic: return 1;
				case GeometryPhase::SkyTextured: return 4;
				case GeometryPhase::Clouds: return 20;
				case GeometryPhase::TerrainSolid: return 8;
				case GeometryPhase::TerrainCutout: return 10;
				case GeometryPhase::Water: return 17;
				case GeometryPhase::Entities:
				case GeometryPhase::EntitiesTranslucent: return 11;
				case GeometryPhase::Block:
				case GeometryPhase::BlockTranslucent: return 12;
				case GeometryPhase::Particles:
				case GeometryPhase::ParticlesTranslucent: return 19;
				case GeometryPhase::Weather: return 21;
				case GeometryPhase::Hand: return 16;
				default: return 0;
			}
		}

		bool PhaseIsTranslucent(GeometryPhase phase)
		{
			return phase == GeometryPhase::Water || phase == GeometryPhase::EntitiesTranslucent || phase == GeometryPhase::BlockTranslucent ||
				   phase == GeometryPhase::ParticlesTranslucent || phase == GeometryPhase::Weather || phase == GeometryPhase::Clouds ||
				   phase == GeometryPhase::Textured;
		}

		bool BeginPhase(GeometryPhase phase)
		{
			Program* p = FindProgram(PhaseProgramName(phase, inShadowPass));
			if (!p)
				return false;

			// shadowtex1 holds the depth without translucent geometry
			if (inShadowPass && PhaseIsTranslucent(phase) && !shadowTranslucentCopied)
			{
				CopyDepth(shadowDepth[0], shadowDepth[1]);
				shadowTranslucentCopied = true;
			}

			current = p;
			currentPhase = phase;

			const QSet<int>& gbufferFlip = beforeTranslucent ? flippedAfterPrepare : flippedAfterTranslucent;
			GLuint fbo = GetFramebuffer(p, p->drawBuffers, inShadowPass ? QSet<int>() : gbufferFlip, true, inShadowPass);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
			if (inShadowPass)
				gl->glViewport(0, 0, shadowResolution, shadowResolution);
			else
				gl->glViewport(0, 0, width, height);

			gl->glUseProgram(p->id);
			UploadFrameUniforms(p);
			BindSamplers(p, gbufferFlip, nullptr, false);
			BindImages(p, gbufferFlip);

			QMatrix4x4 mv = inShadowPass ? shadowModelView : modelView;
			QMatrix4x4 proj = inShadowPass ? shadowProjection : projection;
			SetUniform(p, "mi_ModelViewMat", UVal::Mat4(mv));
			SetUniform(p, "mi_ModelViewMatInverse", UVal::Mat4(mv.inverted()));
			SetUniform(p, "mi_ProjMat", UVal::Mat4(proj));
			SetUniform(p, "mi_ProjMatInverse", UVal::Mat4(proj.inverted()));
			SetUniform(p, "mi_NormalMat", UVal::Mat3(QMatrix4x4(mv.normalMatrix())));
			SetUniform(p, "mi_AmbientOcclusionLevel", UVal::Float(pack->directives.ambientOcclusionLevel));
			SetUniform(p, "mi_SeparateAo", UVal::Float(pack->properties.Flag("separateAo", false) ? 1.f : 0.f));
			SetUniform(p, "mi_OldLighting", UVal::Float(pack->properties.Flag("oldLighting", false) ? 1.f : 0.f));
			SetUniform(p, "renderStage", UVal::Int(RenderStage(phase)));

			// Alpha test
			float alphaRef = 0.1f;
			if (p->hasAlphaTest)
				alphaRef = p->alphaTest.off ? -1.f : p->alphaTest.ref;
			else if (phase == GeometryPhase::SkyBasic || phase == GeometryPhase::TerrainSolid || phase == GeometryPhase::Water ||
					 phase == GeometryPhase::Clouds)
				alphaRef = -1.f;
			SetUniform(p, "mi_AlphaTestRef", UVal::Float(alphaRef));

			// Default render state, Minecraft uses counter-clockwise front faces
			gl->glGetIntegerv(GL_FRONT_FACE, &savedFrontFace);
			gl->glFrontFace(state.clockwiseFrontFaces ? GL_CW : GL_CCW);
			gl->glEnable(GL_DEPTH_TEST);
			gl->glDepthFunc(GL_LEQUAL);
			bool sky = (phase == GeometryPhase::SkyBasic || phase == GeometryPhase::SkyTextured);
			gl->glDepthMask(sky ? GL_FALSE : GL_TRUE);

			static BlendModeSpec translucentBlend = { false, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA };
			static BlendModeSpec additiveBlend = { false, GL_SRC_ALPHA, GL_ONE, GL_ONE, GL_ZERO };
			const BlendModeSpec* defaultBlend = nullptr;
			if (!inShadowPass)
			{
				if (phase == GeometryPhase::SkyTextured)
					defaultBlend = &additiveBlend;
				else if (PhaseIsTranslucent(phase) || phase == GeometryPhase::SkyBasic || phase == GeometryPhase::Particles)
					defaultBlend = &translucentBlend;
			}
			ApplyBlend(p, defaultBlend);
			return true;
		}

		void Draw(const HostMesh& mesh, const ObjectState& object)
		{
			if (!current || !mesh.vbo || !mesh.ibo || mesh.indexCount <= 0)
				return;

			Program* p = current;
			const QSet<int>& gbufferFlip = beforeTranslucent ? flippedAfterPrepare : flippedAfterTranslucent;

			// Model matrix relative to the camera
			QMatrix4x4 model = object.model;
			QMatrix4x4 toCamera;
			toCamera.translate((float)-state.cameraPosition.x, (float)-state.cameraPosition.y, (float)-state.cameraPosition.z);
			QMatrix4x4 relative = toCamera * model;
			SetUniform(p, "mi_ModelMat", UVal::Mat4(relative));
			SetUniform(p, "mi_ModelNormalMat", UVal::Mat3(QMatrix4x4(model.normalMatrix())));
			SetUniform(p, "mi_ColorModulator", UVal::Vec4(object.colorModulator));
			SetUniform(p, "mi_UvRect", UVal::Vec4(object.texture.uvRect));
			SetUniform(p, "entityColor", UVal::Vec4(object.entityColor));
			SetUniform(p, "entityId", UVal::Int(object.entityId));
			SetUniform(p, "blockEntityId", UVal::Int(object.blockEntityId));
			SetUniform(p, "currentRenderedItemId", UVal::Int(object.itemId));
			if (object.texture.size.isValid())
				SetUniform(p, "atlasSize", UVal::IVec2(object.texture.size.width(), object.texture.size.height()));
			else
				SetUniform(p, "atlasSize", UVal::IVec2(0, 0));

			BindSamplers(p, gbufferFlip, &object, true);

			// Iris renders terrain without face culling in the shadow pass
			bool terrain = (currentPhase == GeometryPhase::TerrainSolid || currentPhase == GeometryPhase::TerrainCutout ||
							currentPhase == GeometryPhase::Water);
			if (object.cullBackFaces && !(inShadowPass && terrain))
				gl->glEnable(GL_CULL_FACE);
			else
				gl->glDisable(GL_CULL_FACE);

			SetupVertexAttribs(mesh.vbo, mesh.ibo, mesh.vertexStride);
			gl->glDrawElements(GL_TRIANGLES, mesh.indexCount, GL_UNSIGNED_INT, nullptr);
		}

		void EndPhase()
		{
			gl->glFrontFace((GLenum)savedFrontFace);
			gl->glBindVertexArray(0);
			gl->glUseProgram(0);
			gl->glDisable(GL_BLEND);
			gl->glDisable(GL_CULL_FACE);
			gl->glDepthMask(GL_TRUE);
			current = nullptr;
		}

		void ReadCenterDepth()
		{
			GLuint fbo = 0;
			gl->glGenFramebuffers(1, &fbo);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
			gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthTex[0].id, 0);
			float depth = 1.f;
			gl->glReadPixels(width / 2, height / 2, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &depth);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
			gl->glDeleteFramebuffers(1, &fbo);

			float halfLife = pack->directives.centerDepthHalflife;
			if (!smoothInit || halfLife <= 0.f)
				centerDepthSmooth = depth;
			else
			{
				float decay = (float)(std::log(2.0) / (halfLife * 0.1));
				float factor = 1.f - std::exp(-decay * state.frameTime);
				centerDepthSmooth += (depth - centerDepthSmooth) * factor;
			}
		}

		void UploadBlockTable()
		{
			if (!blockTableDirty)
				return;
			blockTableDirty = false;

			InternalFormatInfo r32i = ParseInternalFormat("R32I");
			QVector<int> offsets = blockOffsets;
			if (offsets.isEmpty())
				offsets.append(-1);
			int ow = qMin(1024, offsets.size());
			int oh = (offsets.size() + 1023) / 1024;
			offsets.resize(ow * oh);
			CreateTexture(blockOffsetsTex, GL_TEXTURE_2D, ow, oh, 1, r32i, 1, offsets.constData(), GL_RED_INTEGER, GL_INT);

			QVector<int> ids = blockIds;
			if (ids.isEmpty())
				ids.append(-1);
			int iw = qMin(4096, ids.size());
			int ih = (ids.size() + 4095) / 4096;
			ids.resize(iw * ih);
			for (int i = blockIds.size(); i < ids.size(); i++)
				ids[i] = -1;
			CreateTexture(blockIdsTex, GL_TEXTURE_2D, iw, ih, 1, r32i, 1, ids.constData(), GL_RED_INTEGER, GL_INT);
		}

		void Destroy()
		{
			if (!gl)
				return;
			for (Program* p : allPrograms)
			{
				for (GLuint fbo : p->fbos)
					gl->glDeleteFramebuffers(1, &fbo);
				gl->glDeleteProgram(p->id);
				delete p;
			}
			allPrograms.clear();
			programs.clear();

			for (ColorTarget& t : colorTargets)
			{
				DeleteTexture(t.main);
				DeleteTexture(t.alt);
			}
			for (Tex& t : depthTex)
				DeleteTexture(t);
			for (Tex& t : shadowDepth)
				DeleteTexture(t);
			for (Tex& t : shadowColor)
				DeleteTexture(t);
			for (Tex* t : { &noiseTex, &lightmapTex, &whiteTex, &defaultNormalsTex, &defaultSpecularTex, &blockOffsetsTex, &blockIdsTex })
				DeleteTexture(*t);
			for (Tex& t : customTextures)
				DeleteTexture(t);
			for (ImageTarget& img : images)
				DeleteTexture(img.tex);
			for (GLuint b : ssbos)
				gl->glDeleteBuffers(1, &b);

			GLuint samplers[] = { samplerNearest, samplerLinear, samplerLinearMip, samplerNearestMip, samplerShadowCompare,
								  samplerShadowCompareNearest, samplerRepeatLinear, samplerAtlas, samplerAtlasNoMip };
			gl->glDeleteSamplers(8, samplers);
			GLuint buffers[] = { quadVbo, quadIbo, skyVbo, skyIbo };
			gl->glDeleteBuffers(4, buffers);
			gl->glDeleteVertexArrays(1, &vao);
			gl = nullptr;
		}
	};

	Renderer::Renderer() : impl(new Impl)
	{
		impl->owner = this;
	}

	Renderer::~Renderer()
	{
		if (QOpenGLContext::currentContext())
			impl->Destroy();
	}

	bool Renderer::Init(Pack* pack, QString* error)
	{
		errors.clear();
		impl->pack = pack;
		ready = impl->Init(error);
		return ready;
	}

	void Renderer::Destroy()
	{
		impl->Destroy();
		ready = false;
	}

	void Renderer::SetBlockIdTable(const QVector<int>& offsets, const QVector<int>& ids)
	{
		impl->blockOffsets = offsets;
		impl->blockIds = ids;
		impl->blockTableDirty = true;
	}

	void Renderer::BeginFrame(const FrameState& state)
	{
		Impl& d = *impl;
		d.resourceProvider = resourceTextureProvider;
		d.state = state;
		d.state.width = qMax(1, state.width);
		d.state.height = qMax(1, state.height);

		d.UploadBlockTable();
		d.ResizeTargets(d.state.width, d.state.height);
		if (d.shadowEnabled)
			d.CreateShadowTargets();

		d.UpdateMatrices();
		d.UpdateCelestial();
		d.UpdateShadowMatrices();
		d.UpdateLightmap();

		// Smoothed values
		float wetTarget = state.rainStrength;
		float halfLife = wetTarget > d.wetness ? d.pack->directives.wetnessHalflife : d.pack->directives.drynessHalflife;
		if (!d.smoothInit)
		{
			d.wetness = wetTarget;
			d.eyeBrightnessSmooth[0] = state.eyeBrightnessBlock;
			d.eyeBrightnessSmooth[1] = state.eyeBrightnessSky;
		}
		else
		{
			float decay = (float)(std::log(2.0) / qMax(0.001, halfLife * 0.1 / 20.0));
			d.wetness += (wetTarget - d.wetness) * (1.f - std::exp(-decay * state.frameTime));
			float ebDecay = (float)(std::log(2.0) / qMax(0.001, d.pack->directives.eyeBrightnessHalflife * 0.1 / 20.0));
			float f = 1.f - std::exp(-ebDecay * state.frameTime);
			d.eyeBrightnessSmooth[0] += (state.eyeBrightnessBlock - d.eyeBrightnessSmooth[0]) * f;
			d.eyeBrightnessSmooth[1] += (state.eyeBrightnessSky - d.eyeBrightnessSmooth[1]) * f;
		}

		d.UpdateFrameUniforms();
		d.ClearTargets();

		// Setup compute shaders run once (and after resizes)
		if (d.firstFrame)
			for (Impl::Program* c : d.setupComputes)
				d.DispatchCompute(c, QSet<int>());

		d.flipped.clear();
		d.beforeTranslucent = true;
		d.flippedAfterPrepareValid = false;
		d.RunPasses(d.beginPasses);
		d.firstFrame = false;
	}

	bool Renderer::BeginShadow()
	{
		Impl& d = *impl;
		if (!d.shadowEnabled)
			return false;

		d.inShadowPass = true;
		d.shadowTranslucentCopied = false;

		// Clear shadow buffers
		GLuint fbo = 0;
		auto* gl = d.gl;
		gl->glGenFramebuffers(1, &fbo);
		gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
		gl->glViewport(0, 0, d.shadowResolution, d.shadowResolution);
		gl->glDepthMask(GL_TRUE);
		for (int i = 0; i < 2; i++)
		{
			gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, d.shadowDepth[i].id, 0);
			gl->glDrawBuffer(GL_NONE);
			gl->glClearDepth(1.0);
			gl->glClear(GL_DEPTH_BUFFER_BIT);
		}
		gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
		for (int i = 0; i < 8; i++)
		{
			if (!d.shadowColor[i].id)
				continue;
			const ShadowBufferSettings& s = d.pack->directives.shadowColor[i];
			if (!s.clear && !d.fullClear)
				continue;
			gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, d.shadowColor[i].id, 0);
			GLenum buf = GL_COLOR_ATTACHMENT0;
			gl->glDrawBuffers(1, &buf);
			if (s.format.isInteger)
			{
				GLint c[4] = { (int)s.clearColor.x(), (int)s.clearColor.y(), (int)s.clearColor.z(), (int)s.clearColor.w() };
				gl->glClearBufferiv(GL_COLOR, 0, c);
			}
			else
			{
				GLfloat c[4] = { s.clearColor.x(), s.clearColor.y(), s.clearColor.z(), s.clearColor.w() };
				gl->glClearBufferfv(GL_COLOR, 0, c);
			}
		}
		gl->glBindFramebuffer(GL_FRAMEBUFFER, 0);
		gl->glDeleteFramebuffers(1, &fbo);

		for (Impl::Program* c : d.shadowComputes)
			d.DispatchCompute(c, d.flipped);
		return true;
	}

	void Renderer::EndShadow()
	{
		Impl& d = *impl;
		if (!d.inShadowPass)
			return;
		d.inShadowPass = false;

		if (!d.shadowTranslucentCopied)
			d.CopyDepth(d.shadowDepth[0], d.shadowDepth[1]);

		// Mipmaps
		for (int i = 0; i < 2; i++)
			if (d.pack->directives.shadowDepth[i].mipmap)
			{
				d.gl->glBindTexture(GL_TEXTURE_2D, d.shadowDepth[i].id);
				d.gl->glGenerateMipmap(GL_TEXTURE_2D);
			}
		for (int i = 0; i < 8; i++)
			if (d.shadowColor[i].id && d.pack->directives.shadowColor[i].mipmap && !d.pack->directives.shadowColor[i].format.isInteger)
			{
				d.gl->glBindTexture(GL_TEXTURE_2D, d.shadowColor[i].id);
				d.gl->glGenerateMipmap(GL_TEXTURE_2D);
			}
		d.gl->glBindTexture(GL_TEXTURE_2D, 0);

		// Shadow composite passes write to shadow color buffers
		if (!d.shadowcompPasses.isEmpty())
		{
			d.gl->glDisable(GL_DEPTH_TEST);
			for (const Impl::Pass& pass : d.shadowcompPasses)
			{
				for (Impl::Program* c : pass.computes)
					d.DispatchCompute(c, d.flipped);
				Impl::Program* p = pass.program;
				if (!p)
					continue;
				GLuint fbo = d.GetFramebuffer(p, p->drawBuffers, QSet<int>(), false, true);
				d.gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
				d.gl->glViewport(0, 0, d.shadowResolution, d.shadowResolution);
				d.gl->glUseProgram(p->id);
				d.current = p;
				d.UploadFrameUniforms(p);
				d.BindSamplers(p, d.flipped, nullptr, false);
				d.BindImages(p, d.flipped);
				d.ApplyBlend(p, nullptr);
				d.DrawFullscreen();
			}
			d.current = nullptr;
			d.gl->glBindFramebuffer(GL_FRAMEBUFFER, 0);
		}
	}

	bool Renderer::BeginPhase(GeometryPhase phase)
	{
		Impl& d = *impl;

		// Prepare passes run after the shadow pass, before the first gbuffers program
		if (!d.inShadowPass && d.beforeTranslucent && !d.flippedAfterPrepareValid)
		{
			d.RunPasses(d.preparePasses);
			d.flippedAfterPrepare = d.flipped;
			d.flippedAfterPrepareValid = true;
		}
		return d.BeginPhase(phase);
	}

	void Renderer::EndPhase()
	{
		impl->EndPhase();
	}

	void Renderer::Draw(const HostMesh& mesh, const ObjectState& object)
	{
		impl->Draw(mesh, object);
	}

	void Renderer::BeginTranslucent()
	{
		Impl& d = *impl;
		if (!d.beforeTranslucent)
			return;
		if (!d.flippedAfterPrepareValid)
		{
			d.RunPasses(d.preparePasses);
			d.flippedAfterPrepare = d.flipped;
			d.flippedAfterPrepareValid = true;
		}

		d.ReadCenterDepth();
		d.CopyDepth(d.depthTex[0], d.depthTex[1]);
		d.CopyDepth(d.depthTex[0], d.depthTex[2]);

		d.flipped = d.flippedAfterPrepare;
		d.RunPasses(d.deferredPasses);
		d.flippedAfterTranslucent = d.flipped;
		d.beforeTranslucent = false;
	}

	void Renderer::EndFrame(unsigned int targetFbo, const QRect& viewport)
	{
		Impl& d = *impl;
		BeginTranslucent();

		d.RunPasses(d.compositePasses);

		for (Impl::Program* c : d.finalComputes)
			d.DispatchCompute(c, d.flipped);

		auto* gl = d.gl;
		gl->glBindFramebuffer(GL_FRAMEBUFFER, targetFbo);
		if (targetFbo)
		{
			GLenum buf = GL_COLOR_ATTACHMENT0;
			gl->glDrawBuffers(1, &buf);
		}
		gl->glViewport(viewport.x(), viewport.y(), viewport.width(), viewport.height());
		gl->glDisable(GL_DEPTH_TEST);
		gl->glDepthMask(GL_FALSE);
		gl->glDisable(GL_BLEND);
		gl->glDisable(GL_CULL_FACE);

		if (d.finalProgram)
		{
			Impl::Program* p = d.finalProgram;
			d.current = p;
			d.GenerateMipmaps(p, d.flipped);
			gl->glBindFramebuffer(GL_FRAMEBUFFER, targetFbo);
			gl->glUseProgram(p->id);
			d.UploadFrameUniforms(p);
			d.BindSamplers(p, d.flipped, nullptr, false);
			d.BindImages(p, d.flipped);
			d.ApplyBlend(p, nullptr);
			d.DrawFullscreen();
			d.current = nullptr;
		}
		else
		{
			// No final program: copy colortex0
			GLuint fbo = 0;
			gl->glGenFramebuffers(1, &fbo);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
			gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, d.ReadTex(0, d.flipped).id, 0);
			gl->glBindFramebuffer(GL_DRAW_FRAMEBUFFER, targetFbo);
			gl->glBlitFramebuffer(0, 0, d.width, d.height, viewport.x(), viewport.y(), viewport.right() + 1, viewport.bottom() + 1,
								  GL_COLOR_BUFFER_BIT, GL_LINEAR);
			gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
			gl->glDeleteFramebuffers(1, &fbo);
		}

		// The game ignores the alpha of the final pass, make the output opaque
		gl->glBindFramebuffer(GL_FRAMEBUFFER, targetFbo);
		gl->glEnable(GL_SCISSOR_TEST);
		gl->glScissor(viewport.x(), viewport.y(), viewport.width(), viewport.height());
		gl->glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_TRUE);
		gl->glClearColor(0.f, 0.f, 0.f, 1.f);
		gl->glClear(GL_COLOR_BUFFER_BIT);
		gl->glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
		gl->glDisable(GL_SCISSOR_TEST);

		gl->glUseProgram(0);
		gl->glBindVertexArray(0);
		for (int u = 0; u < 32; u++)
			gl->glBindSampler(u, 0);
		gl->glDepthMask(GL_TRUE);
		gl->glBindFramebuffer(GL_FRAMEBUFFER, targetFbo);

		// Previous frame values
		d.prevModelView = d.modelView;
		d.prevProjection = d.projection;
		d.prevCameraPosition = d.state.cameraPosition;
		d.hasPrevious = true;
		d.smoothInit = true;
		d.frameCounter = (d.frameCounter + 1) % 720720;
		d.flippedAfterPrepareValid = false;
	}

	QMatrix4x4 Renderer::GbufferModelView() const
	{
		return impl->modelView;
	}

	QMatrix4x4 Renderer::GbufferProjection() const
	{
		return impl->projection;
	}

	void Renderer::DrawSky(const HostTexture& sun, const HostTexture& moon, bool moonPhaseGrid)
	{
		Impl& d = *impl;
		const FrameState& st = d.state;

		// Sky color dims at night like vanilla
		float dayFactor = qBound(0.f, std::cos(d.skyAngle * 2.f * (float)PI) * 2.f + 0.5f, 1.f);
		QVector3D skyColor = st.skyColor * dayFactor;

		HostMesh sky;
		sky.vbo = d.skyVbo;
		sky.ibo = d.skyIbo;

		if (BeginPhase(GeometryPhase::SkyBasic))
		{
			ObjectState obj;
			obj.cullBackFaces = false;
			obj.model.translate((float)st.cameraPosition.x, (float)st.cameraPosition.y, (float)st.cameraPosition.z);

			// Top disc
			obj.colorModulator = QVector4D(skyColor, 1.f);
			d.SetUniform(d.current, "renderStage", UVal::Int(1));
			auto drawRange = [&](int offset, int count)
			{
				HostMesh m = sky;
				m.indexCount = count;
				d.Draw(m, obj);
				// Offset draws through the index buffer start
				Q_UNUSED(offset);
			};

			auto drawRangeOffset = [&](int offset, int count)
			{
				if (!d.current)
					return;
				Impl::Program* p = d.current;
				QMatrix4x4 toCamera;
				toCamera.translate((float)-st.cameraPosition.x, (float)-st.cameraPosition.y, (float)-st.cameraPosition.z);
				d.SetUniform(p, "mi_ModelMat", UVal::Mat4(toCamera * obj.model));
				d.SetUniform(p, "mi_ModelNormalMat", UVal::Mat3(QMatrix4x4(obj.model.normalMatrix())));
				d.SetUniform(p, "mi_ColorModulator", UVal::Vec4(obj.colorModulator));
				d.SetUniform(p, "mi_UvRect", UVal::Vec4(obj.texture.uvRect));
				d.BindSamplers(p, d.beforeTranslucent ? d.flippedAfterPrepare : d.flippedAfterTranslucent, &obj, true);
				d.gl->glDisable(GL_CULL_FACE);
				d.SetupVertexAttribs(sky.vbo, sky.ibo, 52);
				d.gl->glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, (void*)(intptr_t)(offset * sizeof(uint32_t)));
			};
			Q_UNUSED(drawRange);

			drawRangeOffset(0, d.skyDiscIndices);

			// Sunrise/sunset glow
			float sunsetAngle = std::cos(d.skyAngle * 2.f * (float)PI);
			if (sunsetAngle >= -0.4f && sunsetAngle <= 0.4f)
			{
				float f = (sunsetAngle / 0.4f) * 0.5f + 0.5f;
				float alpha = 1.f - (1.f - std::sin(f * (float)PI)) * 0.99f;
				alpha *= alpha;
				QMatrix4x4 m;
				m.translate((float)st.cameraPosition.x, (float)st.cameraPosition.y, (float)st.cameraPosition.z);
				m.rotate(90.f, 1, 0, 0);
				m.rotate(std::sin(d.skyAngle * 2.f * (float)PI) < 0.f ? 180.f : 0.f, 0, 0, 1);
				m.rotate(90.f, 0, 0, 1);
				obj.model = m;
				obj.colorModulator = QVector4D(f * 0.3f + 0.7f, f * f * 0.7f + 0.2f, 0.2f, alpha);
				d.SetUniform(d.current, "renderStage", UVal::Int(2));
				drawRangeOffset(d.skySunriseOffset, d.skySunriseIndices);
			}

			// Stars
			float starBrightness = qBound(0.f, 1.f - (std::cos(d.skyAngle * 2.f * (float)PI) * 2.f + 0.25f), 1.f);
			starBrightness = starBrightness * starBrightness * 0.5f * (1.f - st.rainStrength);
			if (starBrightness > 0.f)
			{
				QMatrix4x4 m;
				m.translate((float)st.cameraPosition.x, (float)st.cameraPosition.y, (float)st.cameraPosition.z);
				m.rotate(-90.f, 0, 1, 0);
				m.rotate(d.skyAngle * 360.f, 1, 0, 0);
				obj.model = m;
				obj.colorModulator = QVector4D(starBrightness, starBrightness, starBrightness, starBrightness);
				d.SetUniform(d.current, "renderStage", UVal::Int(6));
				drawRangeOffset(d.starsOffset, d.starsIndices);
			}

			// Bottom (void) disc
			obj.model = QMatrix4x4();
			obj.model.translate((float)st.cameraPosition.x, (float)st.cameraPosition.y, (float)st.cameraPosition.z);
			obj.colorModulator = QVector4D(skyColor * 0.2f, 1.f);
			d.SetUniform(d.current, "renderStage", UVal::Int(7));
			drawRangeOffset(d.skyBottomOffset, d.skyBottomIndices);

			EndPhase();
		}

		if (BeginPhase(GeometryPhase::SkyTextured))
		{
			QMatrix4x4 m;
			m.translate((float)st.cameraPosition.x, (float)st.cameraPosition.y, (float)st.cameraPosition.z);
			m.rotate(-90.f, 0, 1, 0);
			m.rotate(d.pack->directives.sunPathRotation, 0, 0, 1);
			m.rotate(d.skyAngle * 360.f, 1, 0, 0);

			ObjectState obj;
			obj.cullBackFaces = false;
			obj.model = m;
			float alpha = 1.f - st.rainStrength;
			obj.colorModulator = QVector4D(1.f, 1.f, 1.f, alpha);

			Impl::Program* p = d.current;
			auto drawQuad = [&](int offset, const HostTexture& tex, int stage)
			{
				obj.texture = tex;
				QMatrix4x4 toCamera;
				toCamera.translate((float)-st.cameraPosition.x, (float)-st.cameraPosition.y, (float)-st.cameraPosition.z);
				d.SetUniform(p, "mi_ModelMat", UVal::Mat4(toCamera * obj.model));
				d.SetUniform(p, "mi_ModelNormalMat", UVal::Mat3(QMatrix4x4(obj.model.normalMatrix())));
				d.SetUniform(p, "mi_ColorModulator", UVal::Vec4(obj.colorModulator));
				d.SetUniform(p, "mi_UvRect", UVal::Vec4(tex.uvRect));
				d.SetUniform(p, "renderStage", UVal::Int(stage));
				d.BindSamplers(p, d.beforeTranslucent ? d.flippedAfterPrepare : d.flippedAfterTranslucent, &obj, true);
				d.SetupVertexAttribs(sky.vbo, sky.ibo, 52);
				d.gl->glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, (void*)(intptr_t)(offset * sizeof(uint32_t)));
			};

			if (sun.id)
				drawQuad(d.sunOffset, sun, 4);

			if (moon.id && !moonPhaseGrid)
				drawQuad(d.moonOffset, moon, 5);
			else if (moon.id)
			{
				// Moon phases texture has 4x2 phases
				HostTexture m2 = moon;
				int phase = st.moonPhase % 8;
				float pu = (phase % 4) / 4.f, pv = (phase / 4) / 2.f;
				m2.uvRect = QVector4D(moon.uvRect.x() + pu * moon.uvRect.z(), moon.uvRect.y() + pv * moon.uvRect.w(),
									  moon.uvRect.z() / 4.f, moon.uvRect.w() / 2.f);
				drawQuad(d.moonOffset, m2, 5);
			}
			EndPhase();
		}
	}
}

namespace ShaderPacks
{
	QVector4D Renderer::ReadTargetPixel(int buffer, int x, int y)
	{
		Impl& d = *impl;
		if (buffer < 0 || buffer >= 16 || !d.colorTargets[buffer].used)
			return QVector4D();
		auto* gl = d.gl;
		GLuint fbo = 0;
		gl->glGenFramebuffers(1, &fbo);
		gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);
		gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, d.ReadTex(buffer, d.flipped).id, 0);
		gl->glReadBuffer(GL_COLOR_ATTACHMENT0);
		float px[4] = { 0, 0, 0, 0 };
		if (d.colorTargets[buffer].settings.format.isInteger)
		{
			int ipx[4] = { 0, 0, 0, 0 };
			gl->glReadPixels(x, y, 1, 1, GL_RGBA_INTEGER, GL_INT, ipx);
			for (int i = 0; i < 4; i++)
				px[i] = ipx[i];
		}
		else
			gl->glReadPixels(x, y, 1, 1, GL_RGBA, GL_FLOAT, px);
		gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
		gl->glDeleteFramebuffers(1, &fbo);
		return QVector4D(px[0], px[1], px[2], px[3]);
	}

	QStringList Renderer::DumpTargets(const QString& folder)
	{
		Impl& d = *impl;
		QStringList stats;
		auto* gl = d.gl;
		GLuint fbo = 0;
		gl->glGenFramebuffers(1, &fbo);
		gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, fbo);

		auto dump = [&](const QString& name, GLuint tex, int w, int h, bool depth, bool integer)
		{
			if (!tex)
				return;
			QVector<float> px(w * h * 4);
			if (depth)
			{
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, tex, 0);
				QVector<float> dpx(w * h);
				gl->glReadPixels(0, 0, w, h, GL_DEPTH_COMPONENT, GL_FLOAT, dpx.data());
				for (int i = 0; i < w * h; i++)
					px[i * 4] = px[i * 4 + 1] = px[i * 4 + 2] = dpx[i], px[i * 4 + 3] = 1.f;
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
			}
			else
			{
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, 0, 0);
				gl->glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, 0);
				gl->glReadBuffer(GL_COLOR_ATTACHMENT0);
				if (integer)
				{
					QVector<int> ipx(w * h * 4);
					gl->glReadPixels(0, 0, w, h, GL_RGBA_INTEGER, GL_INT, ipx.data());
					for (int i = 0; i < w * h * 4; i++)
						px[i] = ipx[i];
				}
				else
					gl->glReadPixels(0, 0, w, h, GL_RGBA, GL_FLOAT, px.data());
			}

			float mn[4] = { 1e30f, 1e30f, 1e30f, 1e30f }, mx[4] = { -1e30f, -1e30f, -1e30f, -1e30f };
			double sum[4] = { 0, 0, 0, 0 };
			int nans = 0;
			for (int i = 0; i < w * h; i++)
				for (int c = 0; c < 4; c++)
				{
					float v = px[i * 4 + c];
					if (std::isnan(v) || std::isinf(v))
					{
						nans++;
						continue;
					}
					mn[c] = qMin(mn[c], v);
					mx[c] = qMax(mx[c], v);
					sum[c] += v;
				}
			stats.append(QString("%1 %2x%3 min(%4 %5 %6 %7) max(%8 %9 %10 %11) mean(%12 %13 %14 %15) nan=%16")
							 .arg(name).arg(w).arg(h).arg(mn[0]).arg(mn[1]).arg(mn[2]).arg(mn[3]).arg(mx[0]).arg(mx[1]).arg(mx[2]).arg(mx[3])
							 .arg(sum[0] / (w * h), 0, 'g', 4).arg(sum[1] / (w * h), 0, 'g', 4).arg(sum[2] / (w * h), 0, 'g', 4).arg(sum[3] / (w * h), 0, 'g', 4)
							 .arg(nans));

			QImage img(w, h, QImage::Format_RGBA8888);
			for (int y = 0; y < h; y++)
				for (int x = 0; x < w; x++)
				{
					const float* p = &px[((h - 1 - y) * w + x) * 4];
					auto c = [](float v) { return std::isnan(v) ? 255 : qBound(0, (int)(v * 255.f), 255); };
					img.setPixel(x, y, qRgba(c(p[0]), c(p[1]), c(p[2]), 255));
				}
			img.save(folder + "/" + name + ".png");
		};

		for (int i = 0; i < 16; i++)
		{
			if (!d.colorTargets[i].used)
				continue;
			bool integer = d.colorTargets[i].settings.format.isInteger;
			dump(QString("colortex%1_main").arg(i), d.colorTargets[i].main.id, d.colorTargets[i].main.w, d.colorTargets[i].main.h, false, integer);
			dump(QString("colortex%1_alt").arg(i), d.colorTargets[i].alt.id, d.colorTargets[i].alt.w, d.colorTargets[i].alt.h, false, integer);
		}
		for (int i = 0; i < 3; i++)
			dump(QString("depthtex%1").arg(i), d.depthTex[i].id, d.depthTex[i].w, d.depthTex[i].h, true, false);
		for (int i = 0; i < 2; i++)
			dump(QString("shadowtex%1").arg(i), d.shadowDepth[i].id, d.shadowDepth[i].w, d.shadowDepth[i].h, true, false);
		for (int i = 0; i < 8; i++)
			dump(QString("shadowcolor%1").arg(i), d.shadowColor[i].id, d.shadowColor[i].w, d.shadowColor[i].h, false, d.pack->directives.shadowColor[i].format.isInteger);

		QStringList flips;
		for (int b : d.flipped)
			flips << QString::number(b);
		stats.append("Final flip state: " + flips.join(','));

		gl->glBindFramebuffer(GL_READ_FRAMEBUFFER, 0);
		gl->glDeleteFramebuffers(1, &fbo);
		return stats;
	}
}
