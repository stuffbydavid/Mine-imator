// Standalone test harness for the shaderpack engine.
// Usage:
//   ShaderPackTest load <pack>                     Load a pack and print a summary
//   ShaderPackTest dump <pack> <program> <stage>   Print a preprocessed program stage

#include "SpPack.hpp"
#include "SpRenderer.hpp"
#include "SpTransformer.hpp"

#include <QOpenGLFunctions_3_3_Core>
#include <cmath>

#include <QDir>
#include <QFile>
#include <QGuiApplication>
#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QOpenGLExtraFunctions>
#include <QOpenGLFunctions_4_3_Core>
#include <QElapsedTimer>
#include <QTextStream>
#include <random>

#include <cstdio>

using namespace ShaderPacks;

static QTextStream out(stdout);

static LoadSettings DefaultSettings()
{
	LoadSettings settings;
	settings.environmentDefines = CreateStandardMacros("26.3", 430, 430, "Mesa", "llvmpipe", {});
	return settings;
}

static int CmdLoad(const QString& path)
{
	QString error;
	std::unique_ptr<Pack> pack = Pack::Load(path, DefaultSettings(), &error);
	if (!pack)
	{
		out << "FAILED: " << error << "\n";
		return 1;
	}

	out << "Pack: " << pack->files->name << "\n";
	out << "Dimension folder: " << (pack->dimensionFolder.isEmpty() ? "<root>" : pack->dimensionFolder) << "\n";
	out << "Options: " << pack->options.options.size() << "\n";
	out << "Programs: " << pack->programs.size() << "\n";
	QStringList names = pack->programs.keys();
	names.sort();
	for (const QString& name : names)
	{
		const ProgramSource& p = pack->programs[name];
		QStringList stages;
		const char* stageNames[] = { "vsh", "gsh", "tcs", "tes", "fsh", "csh" };
		for (int s = 0; s < STAGE_COUNT; s++)
			if (p.stages[s].IsValid())
				stages << QString("%1(%2)").arg(stageNames[s]).arg(p.stages[s].version);
		QStringList db;
		for (int b : p.drawBuffers)
			db << QString::number(b);
		out << "  " << name << ": " << stages.join(' ') << " drawbuffers=" << db.join(',') << "\n";
	}

	const PackDirectives& d = pack->directives;
	out << "Shadow: enabled=" << pack->HasShadowPass() << " res=" << d.shadowMapResolution << " dist=" << d.shadowDistance
		<< " interval=" << d.shadowIntervalSize << " sunPathRotation=" << d.sunPathRotation << "\n";
	for (int i = 0; i < 16; i++)
		if (d.colorTargets[i].formatName != "RGBA8" || !d.colorTargets[i].clear)
			out << "  colortex" << i << " format=" << d.colorTargets[i].formatName << " clear=" << d.colorTargets[i].clear << "\n";
	out << "Custom uniforms: " << pack->properties.uniforms.size() << "\n";
	out << "Block ID entries: " << pack->idMap.blocksByName.size() << " names, " << pack->idMap.blocksByTag.size() << " tags\n";
	out << "Disabled programs: " << pack->disabledPrograms.join(' ') << "\n";
	out << "Warnings: " << pack->warnings.size() << "\n";
	for (const QString& w : pack->warnings.mid(0, 20))
		out << "  " << w << "\n";
	return 0;
}

static int CmdDump(const QString& path, const QString& program, const QString& stage)
{
	QString error;
	std::unique_ptr<Pack> pack = Pack::Load(path, DefaultSettings(), &error);
	if (!pack)
	{
		out << "FAILED: " << error << "\n";
		return 1;
	}
	const ProgramSource* p = pack->Program(program);
	if (!p)
	{
		out << "No program " << program << "\n";
		return 1;
	}
	const char* stageNames[] = { "vsh", "gsh", "tcs", "tes", "fsh", "csh" };
	for (int s = 0; s < STAGE_COUNT; s++)
	{
		if (stage != stageNames[s])
			continue;
		out << p->stages[s].version << "\n";
		for (const QString& e : p->stages[s].extensions)
			out << e << "\n";
		out << p->stages[s].body << "\n";
	}
	return 0;
}

static QOpenGLContext* glContext = nullptr;
static QOffscreenSurface* glSurface = nullptr;

static bool InitGL()
{
	QSurfaceFormat format;
	format.setVersion(4, 3);
	format.setProfile(QSurfaceFormat::CoreProfile);
	format.setDepthBufferSize(24);
	glContext = new QOpenGLContext;
	glContext->setFormat(format);
	if (!glContext->create())
	{
		out << "Could not create OpenGL context\n";
		return false;
	}
	glSurface = new QOffscreenSurface;
	glSurface->setFormat(glContext->format());
	glSurface->create();
	if (!glContext->makeCurrent(glSurface))
	{
		out << "Could not make context current\n";
		return false;
	}
	auto* f = glContext->functions();
	out << "GL: " << (const char*)f->glGetString(GL_VERSION) << " / " << (const char*)f->glGetString(GL_RENDERER) << "\n";
	return true;
}

static QString CompileStage(QOpenGLFunctions_4_3_Core* gl, GLenum type, const QString& source, GLuint& shader)
{
	shader = gl->glCreateShader(type);
	QByteArray data = source.toUtf8();
	const char* ptr = data.constData();
	gl->glShaderSource(shader, 1, &ptr, nullptr);
	gl->glCompileShader(shader);
	GLint ok = 0;
	gl->glGetShaderiv(shader, GL_COMPILE_STATUS, &ok);
	if (ok)
		return QString();
	GLint len = 0;
	gl->glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);
	QByteArray log(len + 1, 0);
	gl->glGetShaderInfoLog(shader, len, nullptr, log.data());
	return QString::fromUtf8(log);
}

static ProgramKind KindOf(const QString& name)
{
	if (name.startsWith("gbuffers_") || name.startsWith("shadow") && !name.startsWith("shadowcomp"))
		return ProgramKind::Geometry;
	return ProgramKind::Composite;
}

static int CmdCompile(const QString& path, const QString& only, const QString& dumpDir)
{
	if (!InitGL())
		return 1;
	auto* gl = glContext->versionFunctions<QOpenGLFunctions_4_3_Core>();
	gl->initializeOpenGLFunctions();

	QString error;
	std::unique_ptr<Pack> pack = Pack::Load(path, DefaultSettings(), &error);
	if (!pack)
	{
		out << "FAILED: " << error << "\n";
		return 1;
	}

	QStringList names = pack->programs.keys();
	names.sort();
	int okCount = 0, failCount = 0;
	const GLenum types[STAGE_COUNT] = { GL_VERTEX_SHADER, GL_GEOMETRY_SHADER, GL_TESS_CONTROL_SHADER, GL_TESS_EVALUATION_SHADER, GL_FRAGMENT_SHADER, GL_COMPUTE_SHADER };
	const char* stageNames[] = { "vsh", "gsh", "tcs", "tes", "fsh", "csh" };

	for (const QString& name : names)
	{
		if (!only.isEmpty() && name != only)
			continue;
		const ProgramSource& p = pack->programs[name];
		if (!p.IsValid() && !p.IsCompute())
			continue;

		TransformParams params;
		params.programName = name;
		params.kind = p.IsCompute() ? ProgramKind::Compute : KindOf(name);
		params.alphaTest = params.kind == ProgramKind::Geometry;
		TransformResult tr = TransformProgram(p, params);

		GLuint program = gl->glCreateProgram();
		QString errors;
		QVector<GLuint> shaders;
		for (int s = 0; s < STAGE_COUNT; s++)
		{
			if (tr.sources[s].isEmpty())
				continue;
			if (!dumpDir.isEmpty())
			{
				QFile f(dumpDir + "/" + name + "." + stageNames[s]);
				if (f.open(QFile::WriteOnly))
					f.write(tr.sources[s].toUtf8());
			}
			GLuint sh;
			QString e = CompileStage(gl, types[s], tr.sources[s], sh);
			if (!e.isEmpty())
				errors += QString("[%1] %2").arg(stageNames[s]).arg(e);
			gl->glAttachShader(program, sh);
			shaders.append(sh);
		}

		if (errors.isEmpty())
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
				errors = "[link] " + QString::fromUtf8(log);
			}
		}

		for (GLuint sh : shaders)
			gl->glDeleteShader(sh);
		gl->glDeleteProgram(program);

		if (errors.isEmpty())
			okCount++;
		else
		{
			failCount++;
			QStringList lines = errors.split('\n', Qt::SkipEmptyParts);
			out << "FAIL " << name << ":\n";
			for (const QString& l : lines.mid(0, 6))
				out << "    " << l << "\n";
		}
	}

	out << "Compiled " << okCount << " programs, " << failCount << " failed\n";
	return failCount ? 2 : 0;
}


// ---------------------------------------------------------------------------------------------
// Test scene in the CppProject::Vertex layout (52 bytes)

struct TestVertex
{
	float x, y, z;
	uint32_t normal, color;
	float u, v;
	uint32_t data, tangent, block, midTex, light, midBlock;
};
static_assert(sizeof(TestVertex) == 52, "layout");

static uint32_t PackDir(float x, float y, float z)
{
	auto c = [](float v) { return (uint32_t)qBound(0, (int)((v + 1.f) * 0.5f * 255.f + 0.5f), 255); };
	return c(x) | (c(y) << 8) | (c(z) << 16);
}

struct TestScene
{
	QVector<TestVertex> verts;
	QVector<uint32_t> indices;
	GLuint vbo = 0, ibo = 0;

	// Atlas: 4x4 cells of 16px
	static QVector4D Cell(int cell) { return QVector4D((cell % 4) / 4.f, (cell / 4) / 4.f, 0.25f, 0.25f); }

	void AddFace(QVector3D o, QVector3D du, QVector3D dv, QVector3D n, int cell, int blockKey, uint32_t color = 0xFFFFFFFF, int sky = 240)
	{
		QVector4D c = Cell(cell);
		uint32_t base = verts.size();
		QVector3D center = o + du * 0.5f + dv * 0.5f;
		QVector3D blockCenter(std::floor(center.x() - n.x() * 0.01f) + 0.5f, std::floor(center.y() - n.y() * 0.01f) + 0.5f, std::floor(center.z() - n.z() * 0.01f) + 0.5f);
		uint16_t mu = (uint16_t)((c.x() + c.z() * 0.5f) * 65535.f), mv = (uint16_t)((c.y() + c.w() * 0.5f) * 65535.f);
		QVector3D t = du.normalized();
		for (int k = 0; k < 4; k++)
		{
			float a = (k == 1 || k == 2) ? 1.f : 0.f;
			float b = (k >= 2) ? 1.f : 0.f;
			QVector3D p = o + du * a + dv * b;
			QVector3D mb = (blockCenter - p) * 64.f;
			TestVertex v;
			v.x = p.x(); v.y = p.y(); v.z = p.z();
			v.normal = PackDir(n.x(), n.y(), n.z());
			v.color = color;
			v.u = c.x() + a * c.z();
			v.v = c.y() + (1.f - b) * c.w();
			v.data = 0;
			v.tangent = PackDir(t.x(), t.y(), t.z());
			v.block = (uint32_t)blockKey;
			v.midTex = (uint32_t)mu | ((uint32_t)mv << 16);
			v.light = 0 | ((uint32_t)sky << 8) | (255u << 16);
			v.midBlock = ((uint32_t)(int8_t)qBound(-127.f, mb.x(), 127.f) & 255u) | (((uint32_t)(int8_t)qBound(-127.f, mb.y(), 127.f) & 255u) << 8) |
						 (((uint32_t)(int8_t)qBound(-127.f, mb.z(), 127.f) & 255u) << 16);
			verts.append(v);
		}
		indices << base << base + 1 << base + 2 << base << base + 2 << base + 3;
	}

	void AddCube(int x, int y, int z, int top, int side, int bottom, int blockKey, uint32_t topColor = 0xFFFFFFFF)
	{
		QVector3D p(x, y, z);
		AddFace(p + QVector3D(0, 1, 0), QVector3D(0, 0, 1), QVector3D(1, 0, 0), QVector3D(0, 1, 0), top, blockKey, topColor);
		AddFace(p + QVector3D(0, 0, 1), QVector3D(0, 0, -1), QVector3D(1, 0, 0), QVector3D(0, -1, 0), bottom, blockKey);
		AddFace(p + QVector3D(0, 0, 1), QVector3D(1, 0, 0), QVector3D(0, 1, 0), QVector3D(0, 0, 1), side, blockKey);
		AddFace(p + QVector3D(1, 0, 0), QVector3D(-1, 0, 0), QVector3D(0, 1, 0), QVector3D(0, 0, -1), side, blockKey);
		AddFace(p + QVector3D(0, 0, 0), QVector3D(0, 0, 1), QVector3D(0, 1, 0), QVector3D(-1, 0, 0), side, blockKey);
		AddFace(p + QVector3D(1, 0, 1), QVector3D(0, 0, -1), QVector3D(0, 1, 0), QVector3D(1, 0, 0), side, blockKey);
	}

	void Upload(QOpenGLFunctions_3_3_Core* gl)
	{
		gl->glGenBuffers(1, &vbo);
		gl->glBindBuffer(GL_ARRAY_BUFFER, vbo);
		gl->glBufferData(GL_ARRAY_BUFFER, verts.size() * sizeof(TestVertex), verts.constData(), GL_STATIC_DRAW);
		gl->glGenBuffers(1, &ibo);
		gl->glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
		gl->glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * 4, indices.constData(), GL_STATIC_DRAW);
	}

	HostMesh Mesh() const
	{
		HostMesh m;
		m.vbo = vbo;
		m.ibo = ibo;
		m.indexCount = indices.size();
		return m;
	}
};

static GLuint MakeAtlas(QOpenGLFunctions_3_3_Core* gl)
{
	// 0 grass top, 1 grass side, 2 dirt, 3 stone, 4 leaves, 5 water, 6 log side, 7 log top, 8 sun, 9 moon
	QImage img(64, 64, QImage::Format_RGBA8888);
	std::mt19937 rng(5);
	std::uniform_int_distribution<int> noise(-18, 18);
	auto fill = [&](int cell, QColor base, bool holes = false, int alpha = 255)
	{
		int cx = (cell % 4) * 16, cy = (cell / 4) * 16;
		for (int y = 0; y < 16; y++)
			for (int x = 0; x < 16; x++)
			{
				int n = noise(rng);
				int a = alpha;
				if (holes && (rng() % 4 == 0))
					a = 0;
				img.setPixelColor(cx + x, cy + y, QColor(qBound(0, base.red() + n, 255), qBound(0, base.green() + n, 255), qBound(0, base.blue() + n, 255), a));
			}
	};
	img.fill(Qt::transparent);
	fill(0, QColor(95, 159, 53));
	fill(1, QColor(134, 96, 67));
	for (int x = 0; x < 16; x++)
		for (int y = 0; y < 4; y++)
			img.setPixelColor(16 + x, y, QColor(95, 159, 53));
	fill(2, QColor(134, 96, 67));
	fill(3, QColor(125, 125, 125));
	fill(4, QColor(60, 120, 40), true);
	fill(5, QColor(40, 70, 200), false, 180);
	fill(6, QColor(102, 81, 50));
	fill(7, QColor(160, 130, 80));
	fill(8, QColor(255, 255, 200));
	fill(9, QColor(220, 220, 240));

	GLuint tex;
	gl->glGenTextures(1, &tex);
	gl->glBindTexture(GL_TEXTURE_2D, tex);
	gl->glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 64, 64, 0, GL_RGBA, GL_UNSIGNED_BYTE, img.constBits());
	gl->glGenerateMipmap(GL_TEXTURE_2D);
	gl->glBindTexture(GL_TEXTURE_2D, 0);
	return tex;
}

static int CmdRender(const QString& path, const QString& outFile, int worldTime, const QStringList& optionArgs)
{
	if (!InitGL())
		return 1;
	auto* gl = glContext->versionFunctions<QOpenGLFunctions_3_3_Core>();
	gl->initializeOpenGLFunctions();

	LoadSettings settings = DefaultSettings();
	for (const QString& o : optionArgs)
	{
		int eq = o.indexOf('=');
		if (eq > 0)
			settings.optionValues[o.left(eq)] = o.mid(eq + 1);
	}

	QString error;
	std::unique_ptr<Pack> pack = Pack::Load(path, settings, &error);
	if (!pack)
	{
		out << "FAILED: " << error << "\n";
		return 1;
	}

	Renderer renderer;
	if (!renderer.Init(pack.get(), &error))
	{
		out << "Renderer init failed: " << error << "\n";
		return 1;
	}
	for (const QString& e : renderer.errors)
		out << "  " << e.left(400) << "\n";

	// Block ID table: block keys 1..4 (state 0) = grass_block, stone, oak_leaves, water, oak_log
	QStringList blocks = { "", "minecraft:grass_block", "minecraft:stone", "minecraft:oak_leaves", "minecraft:water", "minecraft:oak_log", "minecraft:dirt" };
	QVector<int> offsets(blocks.size(), -1), ids;
	for (int b = 1; b < blocks.size(); b++)
	{
		offsets[b] = ids.size();
		QHash<QString, QString> state;
		if (blocks[b] == "minecraft:grass_block")
			state["snowy"] = "false";
		if (blocks[b] == "minecraft:oak_leaves")
		{
			state["distance"] = "1";
			state["persistent"] = "false";
		}
		if (blocks[b] == "minecraft:water")
			state["level"] = "0";
		if (blocks[b] == "minecraft:oak_log")
			state["axis"] = "y";
		ids.append(pack->idMap.BlockId(blocks[b], state));
		out << "  block " << blocks[b] << " -> " << ids.last() << "\n";
	}
	renderer.SetBlockIdTable(offsets, ids);

	// Scene
	TestScene solid, cutout, water;
	for (int x = -24; x < 24; x++)
		for (int z = -24; z < 24; z++)
		{
			bool isWater = (x > 4 && x < 14 && z > 6 && z < 16);
			if (isWater)
			{
				solid.AddCube(x, 61, z, 2, 2, 2, 6);
				water.AddFace(QVector3D(x, 62.875f, z), QVector3D(0, 0, 1), QVector3D(1, 0, 0), QVector3D(0, 1, 0), 5, 4, 0xFFC86A3F, 240);
			}
			else
				solid.AddCube(x, 63, z, 0, 1, 2, 1, 0xFF4CBF7C);
		}
	for (int y = 64; y < 68; y++)
		solid.AddCube(0, y, 8, 7, 6, 7, 5);
	for (int x = -2; x <= 2; x++)
		for (int z = 6; z <= 10; z++)
			for (int y = 67; y <= 69; y++)
				if (!(x == 0 && z == 8 && y < 68) && (std::abs(x) + std::abs(z - 8) + (y - 67) < 5))
					cutout.AddCube(x, y, z, 4, 4, 4, 3, 0xFF2E9A48);
	for (int i = 0; i < 6; i++)
		solid.AddCube(-6 + i, 64, 4 + (i % 2), 3, 3, 3, 2);
	solid.Upload(gl);
	cutout.Upload(gl);
	water.Upload(gl);

	GLuint atlas = MakeAtlas(gl);
	HostTexture atlasTex;
	atlasTex.id = atlas;
	atlasTex.size = QSize(64, 64);

	// Output framebuffer
	int w = 960, h = 540;
	GLuint fbo, colorTex;
	gl->glGenTextures(1, &colorTex);
	gl->glBindTexture(GL_TEXTURE_2D, colorTex);
	gl->glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, nullptr);
	gl->glGenFramebuffers(1, &fbo);
	gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	gl->glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, colorTex, 0);

	FrameState state;
	state.width = w;
	state.height = h;
	state.cameraPosition = { 3.5, 68.0, -6.0 };
	state.yaw = 10.f;
	state.pitch = 18.f;
	state.worldTime = worldTime;
	state.renderDistance = 128.f;

	auto drawScene = [&](bool shadow)
	{
		ObjectState obj;
		obj.texture = atlasTex;
		if (renderer.BeginPhase(GeometryPhase::TerrainSolid))
		{
			renderer.Draw(solid.Mesh(), obj);
			renderer.EndPhase();
		}
		if (renderer.BeginPhase(GeometryPhase::TerrainCutout))
		{
			obj.cullBackFaces = false;
			renderer.Draw(cutout.Mesh(), obj);
			renderer.EndPhase();
		}
		if (shadow && renderer.BeginPhase(GeometryPhase::Water))
		{
			renderer.Draw(water.Mesh(), obj);
			renderer.EndPhase();
		}
	};

	QElapsedTimer timer;
	int frames = qEnvironmentVariableIsSet("SP_FRAMES") ? qEnvironmentVariableIntValue("SP_FRAMES") : 3;
	for (int f = 0; f < frames; f++)
	{
		timer.start();
		state.frameTimeCounter = f / 60.f;
		renderer.BeginFrame(state);
		if (renderer.BeginShadow())
		{
			drawScene(true);
			renderer.EndShadow();
		}

		HostTexture sun = atlasTex, moon = atlasTex;
		sun.uvRect = TestScene::Cell(8);
		moon.uvRect = TestScene::Cell(9);
		renderer.DrawSky(sun, moon);
		drawScene(false);
		renderer.BeginTranslucent();
		if (renderer.BeginPhase(GeometryPhase::Water))
		{
			ObjectState obj;
			obj.texture = atlasTex;
			renderer.Draw(water.Mesh(), obj);
			renderer.EndPhase();
		}
		renderer.EndFrame(fbo, QRect(0, 0, w, h));
		gl->glFinish();
		if (f < 3 || f == frames - 1)
			out << "Frame " << f << ": " << timer.elapsed() << " ms\n";
	}

	for (const QString& e : renderer.errors)
		out << "  " << e.left(300) << "\n";

	if (qEnvironmentVariableIsSet("SP_DUMP"))
	{
		QString dir = qEnvironmentVariable("SP_DUMP");
		QDir().mkpath(dir);
		for (const QString& st : renderer.DumpTargets(dir))
			out << "  " << st << "\n";
	}

	QImage img(w, h, QImage::Format_RGBA8888);
	gl->glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	gl->glReadPixels(0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, img.bits());
	img = img.mirrored();
	img.save(outFile);
	out << "Saved " << outFile << "\n";
	out.flush();
	return 0;
}

int main(int argc, char** argv)
{
	QGuiApplication app(argc, argv);
	QStringList args = app.arguments();

	if (args.size() >= 3 && args[1] == "load")
		return CmdLoad(args[2]);
	if (args.size() >= 3 && args[1] == "compile")
		return CmdCompile(args[2], args.value(3) == "-" ? QString() : args.value(3), args.value(4));
	if (args.size() >= 4 && args[1] == "render")
		return CmdRender(args[2], args[3], args.size() > 4 ? args[4].toInt() : 6000, args.mid(5));
	if (args.size() >= 5 && args[1] == "dump")
		return CmdDump(args[2], args[3], args[4]);

	out << "Usage: ShaderPackTest load <pack> | dump <pack> <program> <stage>\n";
	return 1;
}
