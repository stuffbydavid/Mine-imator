#include "SpPack.hpp"
#include "SpPreprocessor.hpp"

#include <QRegularExpression>

namespace ShaderPacks
{
	namespace
	{
		const char* stageExtensions[STAGE_COUNT] = { "vsh", "gsh", "tcs", "tes", "fsh", "csh" };

		// Gbuffers/shadow programs and their fallbacks (OptiFine/Iris program list)
		const QHash<QString, QString>& FallbackTable()
		{
			static QHash<QString, QString> table = {
				{ "shadow", "" },
				{ "shadow_solid", "shadow" },
				{ "shadow_cutout", "shadow" },
				{ "shadow_water", "shadow" },
				{ "shadow_entities", "shadow" },
				{ "shadow_lightning", "shadow_entities" },
				{ "shadow_block", "shadow" },
				{ "gbuffers_basic", "" },
				{ "gbuffers_line", "gbuffers_basic" },
				{ "gbuffers_textured", "gbuffers_basic" },
				{ "gbuffers_textured_lit", "gbuffers_textured" },
				{ "gbuffers_skybasic", "gbuffers_basic" },
				{ "gbuffers_skytextured", "gbuffers_textured" },
				{ "gbuffers_clouds", "gbuffers_textured" },
				{ "gbuffers_terrain", "gbuffers_textured_lit" },
				{ "gbuffers_terrain_solid", "gbuffers_terrain" },
				{ "gbuffers_terrain_cutout", "gbuffers_terrain" },
				{ "gbuffers_damagedblock", "gbuffers_terrain" },
				{ "gbuffers_block", "gbuffers_terrain" },
				{ "gbuffers_block_translucent", "gbuffers_block" },
				{ "gbuffers_beaconbeam", "gbuffers_textured" },
				{ "gbuffers_item", "gbuffers_textured_lit" },
				{ "gbuffers_entities", "gbuffers_textured_lit" },
				{ "gbuffers_entities_translucent", "gbuffers_entities" },
				{ "gbuffers_lightning", "gbuffers_entities" },
				{ "gbuffers_particles", "gbuffers_textured_lit" },
				{ "gbuffers_particles_translucent", "gbuffers_particles" },
				{ "gbuffers_entities_glowing", "gbuffers_entities" },
				{ "gbuffers_armor_glint", "gbuffers_textured" },
				{ "gbuffers_spidereyes", "gbuffers_textured" },
				{ "gbuffers_hand", "gbuffers_textured_lit" },
				{ "gbuffers_weather", "gbuffers_textured_lit" },
				{ "gbuffers_water", "gbuffers_terrain" },
				{ "gbuffers_hand_water", "gbuffers_hand" },
			};
			return table;
		}

		// Used when a pack has a fragment shader but no vertex shader (very old packs)
		const char* legacyVertexShader =
			"#version 120\n"
			"varying vec4 irs_texCoords[3];\n"
			"varying vec4 irs_Color;\n"
			"void main() {\n"
			"	gl_Position = ftransform();\n"
			"	irs_texCoords[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;\n"
			"	irs_texCoords[1] = gl_TextureMatrix[1] * gl_MultiTexCoord1;\n"
			"	irs_texCoords[2] = gl_TextureMatrix[1] * gl_MultiTexCoord2;\n"
			"	irs_Color = gl_Color;\n"
			"}\n";

		struct ConstDirective
		{
			QString type, key, value;
		};

		bool FindConstDirective(const QString& rawLine, ConstDirective& out)
		{
			if (!rawLine.contains("const") || !rawLine.contains('=') || !rawLine.contains(';'))
				return false;

			QString line = rawLine.trimmed();

			// Directives may be written inside block comments
			if (line.startsWith("/*"))
				line = line.mid(2).trimmed();
			if (line.startsWith("//"))
				return false;

			if (!line.startsWith("const"))
				return false;
			line = line.mid(5);
			if (line.isEmpty() || !line[0].isSpace())
				return false;
			line = line.trimmed();

			static const char* types[] = { "int", "float", "vec2", "ivec3", "vec4", "bool" };
			QString type;
			for (const char* t : types)
			{
				if (line.startsWith(QLatin1String(t)))
				{
					type = t;
					break;
				}
			}
			if (type.isEmpty())
				return false;
			line = line.mid(type.size());
			if (line.isEmpty() || !line[0].isSpace())
				return false;

			int eq = line.indexOf('=');
			if (eq < 0)
				return false;
			QString key = line.left(eq).trimmed();
			static QRegularExpression word("^[A-Za-z0-9_]+$");
			if (!word.match(key).hasMatch())
				return false;

			QString rest = line.mid(eq + 1);
			int semi = rest.indexOf(';');
			if (semi < 0)
				return false;

			out.type = type;
			out.key = key;
			out.value = rest.left(semi).trimmed();
			return true;
		}

		bool ParseVec(const QString& value, int count, float* out)
		{
			QString v = value.trimmed();
			int open = v.indexOf('('), close = v.lastIndexOf(')');
			if (open < 0 || close < open)
				return false;
			QStringList parts = v.mid(open + 1, close - open - 1).split(',');
			if (parts.size() == 1)
			{
				bool ok = false;
				float f = parts[0].trimmed().remove('f').remove('F').toFloat(&ok);
				for (int i = 0; i < count; i++)
					out[i] = f;
				return ok;
			}
			if (parts.size() < count)
				return false;
			for (int i = 0; i < count; i++)
			{
				QString p = parts[i].trimmed();
				if (p.endsWith('f') || p.endsWith('F'))
					p.chop(1);
				out[i] = p.toFloat();
			}
			return true;
		}

		float ParseFloat(const QString& value, float def)
		{
			QString v = value.trimmed();
			if (v.endsWith('f') || v.endsWith('F'))
				v.chop(1);
			bool ok = false;
			float f = v.toFloat(&ok);
			return ok ? f : def;
		}

		// Finds the last DRAWBUFFERS or RENDERTARGETS comment directive in a source.
		bool FindDrawBuffers(const QString& source, QVector<int>& out)
		{
			auto find = [&](const QString& name, int& index, QString& value)
			{
				QString prefix = name + ":";
				int search = -1;
				while (true)
				{
					int i = source.lastIndexOf(prefix, search);
					if (i < 0)
						return false;
					QString before = source.left(i).trimmed();
					if (before.endsWith("/*"))
					{
						int end = source.indexOf("*/", i);
						if (end < 0)
							return false;
						index = i;
						value = source.mid(i + prefix.size(), end - i - prefix.size()).trimmed();
						return true;
					}
					if (i == 0)
						return false;
					search = i - 1;
				}
			};

			int dbIndex = -1, rtIndex = -1;
			QString dbValue, rtValue;
			bool hasDb = find("DRAWBUFFERS", dbIndex, dbValue);
			bool hasRt = find("RENDERTARGETS", rtIndex, rtValue);

			if (!hasDb && !hasRt)
				return false;

			out.clear();
			if (hasRt && (!hasDb || rtIndex > dbIndex))
			{
				for (const QString& part : rtValue.split(','))
				{
					bool ok = false;
					int b = part.trimmed().toInt(&ok);
					if (ok)
						out.append(b);
				}
			}
			else
			{
				for (QChar c : dbValue)
				{
					if (c.isSpace())
						continue;
					int b = c.digitValue();
					if (b < 0 && c.toUpper() >= 'A' && c.toUpper() <= 'F')
						b = 10 + (c.toUpper().unicode() - 'A');
					if (b >= 0)
						out.append(b);
				}
			}
			return true;
		}

		QString FormatVersionString(const QString& version)
		{
			QStringList parts = version.split('.');
			if (parts.size() < 2)
				return QString();
			QString minor = parts[1].size() == 1 ? "0" + parts[1] : parts[1];
			QString bugfix = parts.size() < 3 ? "00" : (parts[2].size() == 1 ? "0" + parts[2] : parts[2]);
			return parts[0] + minor + bugfix;
		}
	}

	QList<QPair<QString, QString>> CreateStandardMacros(const QString& mcVersion, int glVersion, int glslVersion,
														const QString& vendor, const QString& renderer, const QStringList& glExtensions)
	{
		QList<QPair<QString, QString>> d;
		auto add = [&](const QString& key, const QString& value) { d.append(QPair<QString, QString>(key, value)); };
		add("MC_VERSION", FormatVersionString(mcVersion));
		add("MC_MIPMAP_LEVEL", "4");
		add("IRIS_VERSION", "11000");
		add("MC_GL_VERSION", QString::number(glVersion));
		add("MC_GLSL_VERSION", QString::number(glslVersion));

#if defined(Q_OS_WIN)
		add("MC_OS_WINDOWS", "");
#elif defined(Q_OS_MACOS)
		add("MC_OS_MAC", "");
#elif defined(Q_OS_LINUX)
		add("MC_OS_LINUX", "");
#else
		add("MC_OS_UNKNOWN", "");
#endif

		QString v = vendor.toLower();
		if (v.startsWith("ati"))
			add("MC_GL_VENDOR_ATI", "");
		else if (v.startsWith("intel"))
			add("MC_GL_VENDOR_INTEL", "");
		else if (v.startsWith("nvidia"))
			add("MC_GL_VENDOR_NVIDIA", "");
		else if (v.startsWith("amd"))
			add("MC_GL_VENDOR_AMD", "");
		else if (v.startsWith("x.org"))
			add("MC_GL_VENDOR_XORG", "");
		else
			add("MC_GL_VENDOR_OTHER", "");

		QString r = renderer.toLower();
		if (r.startsWith("amd") || r.startsWith("ati") || r.startsWith("radeon"))
			add("MC_GL_RENDERER_RADEON", "");
		else if (r.startsWith("gallium"))
			add("MC_GL_RENDERER_GALLIUM", "");
		else if (r.startsWith("intel"))
			add("MC_GL_RENDERER_INTEL", "");
		else if (r.startsWith("geforce") || r.startsWith("nvidia"))
			add("MC_GL_RENDERER_GEFORCE", "");
		else if (r.startsWith("quadro") || r.startsWith("nvs"))
			add("MC_GL_RENDERER_QUADRO", "");
		else if (r.startsWith("mesa") || r.startsWith("llvmpipe"))
			add("MC_GL_RENDERER_MESA", "");
		else if (r.startsWith("apple"))
			add("MC_GL_RENDERER_APPLE", "");
		else
			add("MC_GL_RENDERER_OTHER", "");

		add("IS_IRIS", "");
		add("IRIS_REQUIRES_SEPARATE_ENTITY_DRAWS", "");
		add("MAX_COLOR_BUFFERS", "16");
		add("IRIS_HAS_TRANSLUCENCY_SORTING", "");
		add("IRIS_TAG_SUPPORT", "2");
		add("IS_MINE_IMATOR", "");

		static const char* dhBlocks[] = { "UNKNOWN", "LEAVES", "STONE", "WOOD", "METAL", "DIRT", "LAVA", "DEEPSLATE",
										  "SNOW", "SAND", "TERRACOTTA", "NETHER_STONE", "WATER", "GRASS", "AIR", "ILLUMINATED" };
		for (int i = 0; i < 16; i++)
			add(QString("DH_BLOCK_") + dhBlocks[i], QString::number(i));

		for (const QString& ext : glExtensions)
			add("MC_" + ext, "");

		add("MC_NORMAL_MAP", "");
		add("MC_SPECULAR_MAP", "");
		add("MC_RENDER_QUALITY", "1.0");
		add("MC_SHADOW_QUALITY", "1.0");
		add("MC_HAND_DEPTH", "0.125");

		static const char* stages[] = { "NONE", "SKY", "SUNSET", "CUSTOM_SKY", "SUN", "MOON", "STARS", "VOID", "TERRAIN_SOLID",
										"TERRAIN_CUTOUT_MIPPED", "TERRAIN_CUTOUT", "ENTITIES", "BLOCK_ENTITIES", "DESTROY", "OUTLINE",
										"DEBUG", "HAND_SOLID", "TERRAIN_TRANSLUCENT", "TRIPWIRE", "PARTICLES", "CLOUDS", "RAIN_SNOW",
										"WORLD_BORDER", "HAND_TRANSLUCENT" };
		for (int i = 0; i < (int)(sizeof(stages) / sizeof(stages[0])); i++)
			add(QString("MC_RENDER_STAGE_") + stages[i], QString::number(i));

		// Biome categories and precipitation types
		static const char* categories[] = { "NONE", "TAIGA", "EXTREME_HILLS", "JUNGLE", "MESA", "PLAINS", "SAVANNA", "ICY", "THE_END",
											"BEACH", "FOREST", "OCEAN", "DESERT", "RIVER", "SWAMP", "MUSHROOM", "NETHER", "MOUNTAIN", "UNDERGROUND" };
		for (int i = 0; i < (int)(sizeof(categories) / sizeof(categories[0])); i++)
			add(QString("CAT_") + categories[i], QString::number(i));
		add("PPT_NONE", "0");
		add("PPT_RAIN", "1");
		add("PPT_SNOW", "2");

		return d;
	}

	QString Pack::FallbackProgram(const QString& name)
	{
		return FallbackTable().value(name);
	}

	const ProgramSource* Pack::Program(const QString& name) const
	{
		auto it = programs.constFind(name);
		if (it == programs.constEnd())
			return nullptr;
		return &it.value();
	}

	const ProgramSource* Pack::ResolveProgram(const QString& name) const
	{
		QString current = name;
		int guard = 0;
		while (!current.isEmpty() && guard++ < 16)
		{
			const ProgramSource* p = Program(current);
			if (p && p->IsValid())
				return p;
			current = FallbackProgram(current);
		}
		return nullptr;
	}

	QVector<const ProgramSource*> Pack::ComputePrograms(const QString& passName) const
	{
		QVector<const ProgramSource*> result;
		if (const ProgramSource* p = Program(passName))
			if (p->IsCompute())
				result.append(p);
		for (char c = 'a'; c <= 'z'; c++)
		{
			const ProgramSource* p = Program(passName + "_" + c);
			if (!p || !p->IsCompute())
				break;
			result.append(p);
		}
		return result;
	}

	bool Pack::HasShadowPass() const
	{
		for (const QString& name : { "shadow", "shadow_solid", "shadow_cutout", "shadow_water", "shadow_entities", "shadow_block" })
			if (const ProgramSource* p = Program(name))
				if (p->IsValid())
					return true;
		return usesShadowTextures;
	}

	std::unique_ptr<Pack> Pack::Load(const QString& path, const LoadSettings& settings, QString* error)
	{
		auto pack = std::make_unique<Pack>();
		pack->files = PackFiles::Open(path, error);
		if (!pack->files)
			return nullptr;

		const PackFiles& files = *pack->files;
		QStringList allFiles = files.Files();

		// Find the dimension folder to load programs from
		QHash<QString, QString> dimensionMap;
		QString dimensionSource = files.ReadText("dimension.properties");
		if (!dimensionSource.isNull())
		{
			Preprocessor pp;
			for (const auto& d : settings.environmentDefines)
				pp.Define(d.first, d.second);
			IdMap dims;
			dims.LoadDimensions(pp.ProcessProperties(dimensionSource));
			dimensionMap = dims.dimensions;
		}
		else
		{
			if (files.DirExists("world0"))
			{
				dimensionMap["minecraft:overworld"] = "world0";
				dimensionMap["*"] = "world0";
			}
			if (files.DirExists("world-1"))
				dimensionMap["minecraft:the_nether"] = "world-1";
			if (files.DirExists("world1"))
				dimensionMap["minecraft:the_end"] = "world1";
		}

		pack->dimensionFolder = dimensionMap.value(settings.dimension, dimensionMap.value("*"));
		if (!pack->dimensionFolder.isEmpty() && !files.DirExists(pack->dimensionFolder))
			pack->dimensionFolder.clear();

		// Collect program files in the program folder
		QString programDir = pack->dimensionFolder.isEmpty() ? QString() : pack->dimensionFolder + "/";
		static QRegularExpression programFile("^([A-Za-z0-9_]+)\\.(vsh|gsh|fsh|tcs|tes|csh)$");
		QStringList programFiles;
		QStringList allStarts;
		for (const QString& f : allFiles)
		{
			QString dir = PackPathDir(f);
			QString fileName = f.mid(dir.isEmpty() ? 0 : dir.size() + 1);
			if (!programFile.match(fileName).hasMatch())
				continue;

			// Starts of the include graph include all dimension folders for option discovery
			if (dir.isEmpty() || dir == "world0" || dir == "world-1" || dir == "world1" || dimensionMap.values().contains(dir))
				allStarts.append(f);

			if (dir + (dir.isEmpty() ? "" : "/") == programDir)
				programFiles.append(f);
		}

		if (programFiles.isEmpty())
		{
			if (error)
				*error = "No shader programs found in " + path;
			return nullptr;
		}

		IncludeResolver includes(files);

		// Discover and apply options
		QStringList reachable = includes.Reachable(allStarts);
		pack->options.Discover(includes, reachable);

		// Environment defines used for properties files
		QList<QPair<QString, QString>> propertyDefines = settings.environmentDefines;
		static const QStringList features = { "SEPARATE_HARDWARE_SAMPLERS", "HIGHER_SHADOWCOLOR", "CUSTOM_IMAGES", "PER_BUFFER_BLENDING",
											  "COMPUTE_SHADERS", "TESSELLATION_SHADERS", "ENTITY_TRANSLUCENT", "REVERSED_CULLING",
											  "BLOCK_EMISSION_ATTRIBUTE", "CAN_DISABLE_WEATHER", "SSBO", "FADE_VARIABLE", "TEXTURE_FILTERING" };
		auto featureSupported = [&](const QString& f)
		{
			QString u = f.toUpper();
			if (!features.contains(u))
				return false;
			if (u == "COMPUTE_SHADERS" || u == "CUSTOM_IMAGES" || u == "SSBO")
				return settings.computeSupported;
			if (u == "TESSELLATION_SHADERS")
				return settings.tessellationSupported;
			return true;
		};
		for (const QString& f : features)
			if (featureSupported(f))
				propertyDefines.append(QPair<QString, QString>("IRIS_FEATURE_" + f, ""));

		// Like Iris (JCPP addMacro), macros without a value are defined as 1 in properties files
		auto makeOptionPreprocessor = [&](const QList<QPair<QString, QString>>& defines, Preprocessor& pp)
		{
			for (const auto& d : defines)
				pp.Define(d.first, d.second.isEmpty() ? "1" : d.second);
			for (const QString& name : pack->options.order)
			{
				const Option& opt = pack->options.options[name];
				if (opt.kind == Option::BOOLEAN)
				{
					if (pack->options.BoolValue(name))
						pp.Define(name, "1");
				}
				else
					pp.Define(name, pack->options.Value(name));
			}
		};

		// Apply profile, then user values
		QString propertiesSource = files.ReadText("shaders.properties");
		if (!propertiesSource.isNull())
		{
			// Profiles need to be known before option values are final, parse the raw file for them
			OrderedProperties raw = ParseProperties(propertiesSource);
			QHash<QString, QString> profiles;
			for (const QString& key : raw.keys)
				if (key.startsWith("profile."))
					profiles[key.mid(8)] = raw.Get(key);
			if (!settings.profile.isEmpty())
				pack->disabledPrograms += pack->options.ApplyProfile(settings.profile, profiles);
		}

		for (auto it = settings.optionValues.constBegin(); it != settings.optionValues.constEnd(); ++it)
			pack->options.SetValue(it.key(), it.value());

		// shaders.properties
		if (!propertiesSource.isNull())
		{
			Preprocessor pp;
			makeOptionPreprocessor(propertyDefines, pp);
			pack->properties.Load(propertiesSource, pp);
		}

		// Required features
		for (const QString& f : pack->properties.requiredFeatures)
		{
			if (!featureSupported(f))
			{
				if (error)
					*error = "The shaderpack requires an unsupported feature: " + f;
				return nullptr;
			}
		}

		// Final defines for program sources
		pack->environmentDefines = settings.environmentDefines;
		for (const QString& f : pack->properties.optionalFeatures)
			if (featureSupported(f))
				pack->environmentDefines.append(QPair<QString, QString>("IRIS_FEATURE_" + f.toUpper(), ""));

		// Programs disabled through program.<name>.enabled
		for (auto it = pack->properties.programEnabled.constBegin(); it != pack->properties.programEnabled.constEnd(); ++it)
		{
			bool enabled = EvaluateBooleanOptionExpression(it.value(), [&](const QString& name)
			{
				if (pack->options.Has(name))
					return pack->options.BoolValue(name);
				for (const auto& d : pack->environmentDefines)
					if (d.first == name)
						return true;
				return false;
			});
			if (!enabled)
			{
				QString program = it.key();
				if (program.contains('/'))
				{
					// Dimension specific
					if (program.left(program.indexOf('/')) != pack->dimensionFolder)
						continue;
					program = program.mid(program.indexOf('/') + 1);
				}
				pack->disabledPrograms.append(program);
			}
		}

		// ID maps
		auto loadIdProperties = [&](const QString& name) -> QString
		{
			QString source = files.ReadText(name);
			if (source.isNull())
				return QString();
			Preprocessor pp;
			makeOptionPreprocessor(pack->environmentDefines, pp);
			return pp.ProcessProperties(source);
		};

		QString blocks = loadIdProperties("block.properties");
		if (!blocks.isNull())
			pack->idMap.LoadBlocks(blocks);
		QString items = loadIdProperties("item.properties");
		if (!items.isNull())
			pack->idMap.LoadItems(items);
		QString entities = loadIdProperties("entity.properties");
		if (!entities.isNull())
			pack->idMap.LoadEntities(entities);

		// Language
		for (const QString& lang : { "lang/en_us.lang", "lang/en_US.lang", "lang/en_Us.lang" })
		{
			QString text = files.ReadText(lang);
			if (!text.isNull())
			{
				pack->language.Load(text);
				break;
			}
		}

		pack->LoadPrograms(includes, programFiles);
		pack->ParseDirectives();

		LogInfo("Loaded shaderpack " + files.name + " (" + QString::number(pack->programs.size()) + " programs, " +
				QString::number(pack->options.options.size()) + " options" +
				(pack->dimensionFolder.isEmpty() ? QString() : ", folder " + pack->dimensionFolder) + ")");
		return pack;
	}

	void Pack::LoadPrograms(const IncludeResolver& includes, const QStringList& programFiles)
	{
		IncludeResolver::LineTransform transform;
		if (!options.values.isEmpty())
		{
			transform = [this](const QString& file, int line, const QString& text)
			{
				return options.ApplyToLine(file, line, text);
			};
		}

		QHash<QString, QStringList> filesByProgram;
		for (const QString& f : programFiles)
		{
			QString fileName = f.mid(f.lastIndexOf('/') + 1);
			QString programName = fileName.left(fileName.lastIndexOf('.'));
			filesByProgram[programName].append(f);
		}

		for (auto it = filesByProgram.constBegin(); it != filesByProgram.constEnd(); ++it)
		{
			const QString& programName = it.key();
			if (disabledPrograms.contains(programName))
				continue;

			// Programs for other mods (Distant Horizons, Colorwheel, Voxy) are never used
			if (programName.startsWith("dh_") || programName.startsWith("clrwl_") || programName.startsWith("voxy"))
				continue;

			ProgramSource program;
			program.name = programName;

			for (const QString& file : it.value())
			{
				QString ext = file.mid(file.lastIndexOf('.') + 1);
				int stage = -1;
				for (int s = 0; s < STAGE_COUNT; s++)
					if (ext == stageExtensions[s])
						stage = s;
				if (stage < 0)
					continue;

				QStringList errors;
				QString flat = includes.Flatten(file, transform, &errors);
				if (flat.isNull())
					continue;

				Preprocessor pp;
				for (const auto& d : environmentDefines)
					pp.Define(d.first, d.second);
				Preprocessor::Result result = pp.ProcessGlsl(flat);

				StageSource& src = program.stages[stage];
				src.version = result.version;
				src.extensions = result.extensions;
				src.body = result.source;
				src.errors = errors + result.errors;

				for (const QString& e : src.errors)
					warnings.append(file + ": " + e);
			}

			// Legacy packs without vertex shaders
			if (!program.stages[STAGE_VERTEX].IsValid() && program.stages[STAGE_FRAGMENT].IsValid())
			{
				Preprocessor pp;
				Preprocessor::Result result = pp.ProcessGlsl(legacyVertexShader);
				program.stages[STAGE_VERTEX].version = result.version;
				program.stages[STAGE_VERTEX].body = result.source;
			}

			// Program directives from the fragment shader
			if (program.stages[STAGE_FRAGMENT].IsValid())
			{
				const QString& fsh = program.stages[STAGE_FRAGMENT].body;
				program.explicitDrawBuffers = FindDrawBuffers(fsh, program.drawBuffers);

				for (const QString& line : fsh.split('\n'))
				{
					ConstDirective d;
					if (!FindConstDirective(line, d) || d.type != "bool" || !d.key.endsWith("MipmapEnabled"))
						continue;
					int buffer = ColorBufferIndex(d.key.left(d.key.size() - 13));
					if (buffer >= 0 && d.value == "true")
						program.mipmappedBuffers.insert(buffer);
				}
			}

			// Compute work groups
			if (program.stages[STAGE_COMPUTE].IsValid())
			{
				for (const QString& line : program.stages[STAGE_COMPUTE].body.split('\n'))
				{
					ConstDirective d;
					if (!FindConstDirective(line, d))
						continue;
					if (d.type == "ivec3" && d.key == "workGroups")
					{
						float v[3];
						if (ParseVec(d.value, 3, v))
						{
							program.hasWorkGroups = true;
							for (int i = 0; i < 3; i++)
								program.workGroups[i] = (int)v[i];
						}
					}
					else if (d.type == "vec2" && d.key == "workGroupsRender")
					{
						float v[2];
						if (ParseVec(d.value, 2, v))
						{
							program.hasWorkGroupsRender = true;
							program.workGroupsRender[0] = v[0];
							program.workGroupsRender[1] = v[1];
						}
					}
				}
			}

			programs[programName] = program;
		}
	}

	void Pack::ParseDirectives()
	{
		PackDirectives& d = directives;
		for (int i = 0; i < 16; i++)
			d.colorTargets[i].format = ParseInternalFormat("RGBA8");
		for (int i = 0; i < 8; i++)
			d.shadowColor[i].format = ParseInternalFormat("RGBA8");

		// Gather directives, fragment shaders first
		QVector<ConstDirective> found;
		QSet<QString> seenKeys;
		for (int pass = 0; pass < 2; pass++)
		{
			int stage = (pass == 0) ? STAGE_FRAGMENT : STAGE_VERTEX;
			QStringList names = programs.keys();
			names.sort();
			for (const QString& name : names)
			{
				const ProgramSource& p = programs[name];
				if (!p.stages[stage].IsValid())
					continue;

				const QString& body = p.stages[stage].body;
				if (body.contains("shadowtex") || body.contains("shadowcolor") || body.contains("watershadow") ||
					QRegularExpression("\\bshadow\\b").match(body).hasMatch())
					usesShadowTextures = true;

				for (int pos = body.indexOf("const"); pos >= 0; pos = body.indexOf("const", pos + 1))
				{
					int lineStart = body.lastIndexOf('\n', pos) + 1;
					int lineEnd = body.indexOf('\n', pos);
					if (lineEnd < 0)
						lineEnd = body.size();
					QString line = body.mid(lineStart, lineEnd - lineStart);
					pos = lineEnd;
					ConstDirective cd;
					if (!FindConstDirective(line, cd))
						continue;
					if (pass == 1 && seenKeys.contains(cd.key))
						continue;
					if (pass == 0)
						seenKeys.insert(cd.key);
					found.append(cd);
				}
			}
		}

		auto bufferName = [](const QString& key, const QString& suffix, int& index) -> bool
		{
			if (!key.endsWith(suffix))
				return false;
			index = ColorBufferIndex(key.left(key.size() - suffix.size()));
			return index >= 0;
		};

		auto shadowColorIndex = [](const QString& key, const QString& suffix, int& index) -> bool
		{
			if (!key.endsWith(suffix))
				return false;
			QString name = key.left(key.size() - suffix.size());
			if (name == "shadowcolor")
			{
				index = 0;
				return true;
			}
			if (name.startsWith("shadowcolor") || name.startsWith("shadowColor"))
			{
				bool ok = false;
				index = name.mid(11).toInt(&ok);
				return ok && index >= 0 && index < 8;
			}
			return false;
		};

		for (const ConstDirective& cd : found)
		{
			int idx;
			const QString& k = cd.key;
			const QString& v = cd.value;

			if (cd.type == "int" && bufferName(k, "Format", idx))
			{
				bool ok = false;
				InternalFormatInfo info = ParseInternalFormat(v, &ok);
				if (ok)
				{
					d.colorTargets[idx].formatName = v;
					d.colorTargets[idx].format = info;
				}
				else
					warnings.append("Unknown format " + v + " for " + k);
			}
			else if (cd.type == "bool" && bufferName(k, "Clear", idx))
				d.colorTargets[idx].clear = (v == "true");
			else if (cd.type == "vec4" && bufferName(k, "ClearColor", idx))
			{
				float c[4];
				if (ParseVec(v, 4, c))
				{
					d.colorTargets[idx].hasClearColor = true;
					d.colorTargets[idx].clearColor = QVector4D(c[0], c[1], c[2], c[3]);
				}
			}
			else if (cd.type == "int" && shadowColorIndex(k, "Format", idx))
			{
				bool ok = false;
				InternalFormatInfo info = ParseInternalFormat(v, &ok);
				if (ok)
				{
					d.shadowColor[idx].formatName = v;
					d.shadowColor[idx].format = info;
				}
			}
			else if (cd.type == "bool" && shadowColorIndex(k, "Clear", idx))
				d.shadowColor[idx].clear = (v == "true");
			else if (cd.type == "vec4" && shadowColorIndex(k, "ClearColor", idx))
			{
				float c[4];
				if (ParseVec(v, 4, c))
					d.shadowColor[idx].clearColor = QVector4D(c[0], c[1], c[2], c[3]);
			}
			else if (cd.type == "bool" && (shadowColorIndex(k, "Nearest", idx) || shadowColorIndex(k, "MinMagNearest", idx)))
				d.shadowColor[idx].nearest = (v == "true");
			else if (cd.type == "bool" && shadowColorIndex(k, "Mipmap", idx))
				d.shadowColor[idx].mipmap = (v == "true");
			else if (k == "shadowMapResolution")
				d.shadowMapResolution = qBound(16, (int)ParseFloat(v, 1024), 16384);
			else if (k == "shadowDistance")
				d.shadowDistance = ParseFloat(v, 160.f);
			else if (k == "shadowDistanceRenderMul")
				d.shadowDistanceRenderMul = ParseFloat(v, -1.f);
			else if (k == "entityShadowDistanceMul")
				d.entityShadowDistanceMul = ParseFloat(v, 1.f);
			else if (k == "shadowIntervalSize")
				d.shadowIntervalSize = ParseFloat(v, 2.f);
			else if (k == "shadowNearPlane")
				d.shadowNearPlane = ParseFloat(v, -100.05f);
			else if (k == "shadowFarPlane")
				d.shadowFarPlane = ParseFloat(v, 156.f);
			else if (k == "shadowMapFov")
				d.shadowMapFov = ParseFloat(v, -1.f);
			else if (k == "voxelDistance")
				d.voxelDistance = ParseFloat(v, 0.f);
			else if (k == "sunPathRotation")
				d.sunPathRotation = ParseFloat(v, 0.f);
			else if (k == "ambientOcclusionLevel")
				d.ambientOcclusionLevel = qBound(0.f, ParseFloat(v, 1.f), 1.f);
			else if (k == "wetnessHalflife")
				d.wetnessHalflife = ParseFloat(v, 600.f);
			else if (k == "drynessHalflife")
				d.drynessHalflife = ParseFloat(v, 200.f);
			else if (k == "eyeBrightnessHalflife")
				d.eyeBrightnessHalflife = ParseFloat(v, 10.f);
			else if (k == "centerDepthHalflife")
				d.centerDepthHalflife = ParseFloat(v, 1.f);
			else if (k == "noiseTextureResolution")
				d.noiseTextureResolution = qBound(1, (int)ParseFloat(v, 256), 8192);
			else if (cd.type == "bool")
			{
				bool b = (v == "true");
				if (k == "shadowHardwareFiltering")
					d.shadowDepth[0].hardwareFiltering = d.shadowDepth[1].hardwareFiltering = b;
				else if (k == "shadowHardwareFiltering0")
					d.shadowDepth[0].hardwareFiltering = b;
				else if (k == "shadowHardwareFiltering1")
					d.shadowDepth[1].hardwareFiltering = b;
				else if (k == "shadowtexNearest" || k == "shadowMinMagNearest")
					d.shadowDepth[0].nearest = d.shadowDepth[1].nearest = b;
				else if (k == "shadowtex0Nearest" || k == "shadow0MinMagNearest")
					d.shadowDepth[0].nearest = b;
				else if (k == "shadowtex1Nearest" || k == "shadow1MinMagNearest")
					d.shadowDepth[1].nearest = b;
				else if (k == "generateShadowMipmap" || k == "shadowtexMipmap")
					d.shadowDepth[0].mipmap = d.shadowDepth[1].mipmap = b;
				else if (k == "shadowtex0Mipmap")
					d.shadowDepth[0].mipmap = b;
				else if (k == "shadowtex1Mipmap")
					d.shadowDepth[1].mipmap = b;
				else if (k == "generateShadowColorMipmap")
					for (int i = 0; i < 8; i++)
						d.shadowColor[i].mipmap = b;
			}
		}
	}
}
