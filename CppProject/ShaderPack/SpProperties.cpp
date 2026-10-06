#include "SpProperties.hpp"
#include "SpFormats.hpp"
#include "SpPreprocessor.hpp"

#include <QRegularExpression>
#include <qopengl.h>

namespace ShaderPacks
{
	int ColorBufferIndex(const QString& name)
	{
		static const QStringList legacy = { "gcolor", "gdepth", "gnormal", "composite", "gaux1", "gaux2", "gaux3", "gaux4" };
		int legacyIndex = legacy.indexOf(name);
		if (legacyIndex >= 0)
			return legacyIndex;

		if (name.startsWith("colortex"))
		{
			bool ok = false;
			int index = name.mid(8).toInt(&ok);
			if (ok && index >= 0 && index < 16)
				return index;
		}
		return -1;
	}

	namespace
	{
		QStringList SplitWs(const QString& s)
		{
			return s.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
		}

		bool ParseBlend(const QString& value, BlendModeSpec& out)
		{
			QStringList parts = SplitWs(value);
			if (parts.size() == 1 && parts[0].toLower() == "off")
			{
				out.off = true;
				return true;
			}
			if (parts.size() != 4)
				return false;
			int f[4];
			for (int i = 0; i < 4; i++)
			{
				f[i] = ParseBlendFactor(parts[i]);
				if (f[i] < 0)
					return false;
			}
			out.off = false;
			out.src = f[0];
			out.dst = f[1];
			out.srcAlpha = f[2];
			out.dstAlpha = f[3];
			return true;
		}

		bool ParseTexture(const QString& value, TextureSpec& out)
		{
			QStringList parts = SplitWs(value);
			if (parts.isEmpty())
				return false;

			out.path = parts[0];
			if (parts.size() == 1)
				return true;

			// Raw texture: <path> <target> <internalFormat> <dims...> <pixelFormat> <pixelType>
			out.raw = true;
			out.target = ParseTextureTarget(parts.value(1));
			if (!out.target)
				return false;

			InternalFormatInfo info = ParseInternalFormat(parts.value(2));
			out.internalFormat = info.internalFormat;

			int dims = (out.target == GL_TEXTURE_1D) ? 1 : (out.target == GL_TEXTURE_3D) ? 3 : 2;
			if (parts.size() < 3 + dims + 2)
				return false;

			out.width = parts[3].toInt();
			out.height = dims > 1 ? parts[4].toInt() : 1;
			out.depth = dims > 2 ? parts[5].toInt() : 1;
			out.pixelFormat = ParsePixelFormat(parts[3 + dims]);
			out.pixelType = ParsePixelType(parts[4 + dims]);
			return out.pixelFormat && out.pixelType;
		}
	}

	void ShaderProperties::Load(const QString& source, Preprocessor& pp)
	{
		original = ParseProperties(source);
		props = ParseProperties(pp.ProcessProperties(source));

		for (const QString& key : props.keys)
		{
			QString value = props.Get(key);

			if (key == "clouds")
				clouds = value.trimmed().toLower();
			else if (key == "texture.noise")
				noiseTexture = value.trimmed();
			else if (key.startsWith("program.") && key.endsWith(".enabled"))
				programEnabled[key.mid(8, key.size() - 8 - 8)] = value;
			else if (key.startsWith("blend."))
			{
				QString target = key.mid(6);
				BlendModeSpec spec;
				if (!ParseBlend(value, spec))
				{
					LogWarning("Invalid blend mode " + key + "=" + value);
					continue;
				}

				// blend.<program>.<buffer>
				int dot = target.lastIndexOf('.');
				if (dot > 0)
				{
					int buffer = ColorBufferIndex(target.mid(dot + 1));
					if (buffer >= 0)
						target = target.left(dot) + "." + QString::number(buffer);
				}
				blend[target] = spec;
			}
			else if (key.startsWith("alphaTest."))
			{
				AlphaTestSpec spec;
				QStringList parts = SplitWs(value);
				if (parts.size() == 1 && parts[0].toLower() == "off")
					spec.off = true;
				else if (parts.size() == 2)
				{
					spec.func = ParseCompareFunc(parts[0]);
					spec.ref = parts[1].toFloat();
					if (!spec.func)
						continue;
				}
				else
					continue;
				alphaTest[key.mid(10)] = spec;
			}
			else if (key.startsWith("scale."))
			{
				QStringList parts = SplitWs(value);
				ScaleSpec spec;
				spec.scale = parts.value(0, "1").toFloat();
				spec.offsetX = parts.value(1, "0").toFloat();
				spec.offsetY = parts.value(2, "0").toFloat();
				scale[key.mid(6)] = spec;
			}
			else if (key.startsWith("flip."))
			{
				QString rest = key.mid(5);
				int dot = rest.lastIndexOf('.');
				if (dot < 0)
					continue;
				int buffer = ColorBufferIndex(rest.mid(dot + 1));
				if (buffer < 0)
					continue;
				flip[rest.left(dot)][buffer] = ParseBool(value, true);
			}
			else if (key.startsWith("size.buffer."))
			{
				int buffer = ColorBufferIndex(key.mid(12));
				QStringList parts = SplitWs(value);
				if (buffer < 0 || parts.size() < 2)
					continue;
				BufferSizeSpec spec;
				spec.relative = parts[0].contains('.') || parts[1].contains('.');
				spec.width = parts[0].toFloat();
				spec.height = parts[1].toFloat();
				bufferSize[buffer] = spec;
			}
			else if (key.startsWith("texture."))
			{
				QString rest = key.mid(8);
				int dot = rest.indexOf('.');
				if (dot < 0)
					continue;
				TextureSpec spec;
				if (!ParseTexture(value, spec))
				{
					LogWarning("Invalid texture definition " + key + "=" + value);
					continue;
				}
				textures[rest.left(dot)][rest.mid(dot + 1)] = spec;
			}
			else if (key.startsWith("customTexture."))
			{
				TextureSpec spec;
				if (ParseTexture(value, spec))
					customTextures[key.mid(14)] = spec;
			}
			else if (key.startsWith("image."))
			{
				// image.<name>=<sampler> <format> <internalFormat> <pixelType> <clear> <relative> <w> <h> [<d>]
				QStringList parts = SplitWs(value);
				if (parts.size() < 8)
					continue;
				ImageSpec spec;
				spec.name = key.mid(6);
				spec.samplerName = parts[0];
				spec.pixelFormat = ParsePixelFormat(parts[1]);
				spec.internalFormat = ParseInternalFormat(parts[2]).internalFormat;
				spec.pixelType = ParsePixelType(parts[3]);
				spec.clear = ParseBool(parts[4], true);
				spec.relative = ParseBool(parts[5], false);
				spec.width = parts[6].toFloat();
				spec.height = parts[7].toFloat();
				spec.depth = parts.size() > 8 ? parts[8].toFloat() : 0.f;
				images.append(spec);
			}
			else if (key.startsWith("bufferObject."))
			{
				bool ok = false;
				int index = key.mid(13).toInt(&ok);
				QStringList parts = SplitWs(value);
				if (!ok || parts.isEmpty())
					continue;
				bufferObjects[index] = { parts[0].toLongLong(), parts.value(1) };
			}
			else if (key.startsWith("uniform.") || key.startsWith("variable."))
			{
				bool isVariable = key.startsWith("variable.");
				QString rest = key.mid(isVariable ? 9 : 8);
				int dot = rest.indexOf('.');
				if (dot < 0)
					continue;

				CustomUniformSpec spec;
				bool ok = false;
				spec.type = ExprValue::TypeFromName(rest.left(dot), &ok);
				if (!ok)
					continue;
				spec.name = rest.mid(dot + 1);
				spec.source = value;
				spec.isVariable = isVariable;

				QString error;
				spec.expression = Expression::Parse(value, &error);
				if (!spec.expression)
				{
					LogWarning("Could not parse " + key + "=" + value + ": " + error);
					continue;
				}
				uniforms.append(spec);
			}
		}

		// Screens, sliders and profiles use the unprocessed source
		for (const QString& key : original.keys)
		{
			QString value = original.Get(key);
			if (key == "iris.features.required")
				requiredFeatures = SplitWs(value);
			else if (key == "iris.features.optional")
				optionalFeatures = SplitWs(value);
			else if (key == "screen")
				screens[""] = value;
			else if (key == "screen.columns")
				screenColumns[""] = value.toInt();
			else if (key.startsWith("screen.") && key.endsWith(".columns"))
				screenColumns[key.mid(7, key.size() - 7 - 8)] = value.toInt();
			else if (key.startsWith("screen."))
				screens[key.mid(7)] = value;
			else if (key == "sliders")
				sliders = SplitWs(value);
			else if (key.startsWith("profile."))
				profiles[key.mid(8)] = value;
		}
	}

	bool ShaderProperties::Flag(const QString& key, bool def) const
	{
		if (!props.Has(key))
			return def;
		return ParseBool(props.Get(key), def);
	}

	void IdMap::LoadBlocks(const QString& source)
	{
		OrderedProperties p = ParseProperties(source);
		int order = 0;

		for (const QString& key : p.keys)
		{
			if (key.startsWith("layer."))
			{
				QString layer = key.mid(6);
				for (const QString& part : p.Get(key).split(QRegularExpression("\\s+"), Qt::SkipEmptyParts))
					layers[Namespaced(part)] = layer;
				continue;
			}

			if (!key.startsWith("block."))
				continue;

			bool ok = false;
			int id = key.mid(6).toInt(&ok);
			if (!ok)
				continue;

			for (const QString& part : p.Get(key).split(QRegularExpression("\\s+"), Qt::SkipEmptyParts))
			{
				BlockEntry entry;
				QString text = part;

				if (text.startsWith('#'))
				{
					entry.isTag = true;
					text = text.mid(1);
				}

				QStringList split = text.split(':');
				if (split.isEmpty() || split[0].isEmpty())
					continue;

				// Skip legacy numeric IDs
				bool numeric = false;
				split[0].toInt(&numeric);
				if (numeric)
					continue;

				int statesStart;
				if (split.size() == 1)
				{
					entry.ns = "minecraft";
					entry.name = split[0];
					statesStart = 1;
				}
				else if (split[1].contains('='))
				{
					entry.ns = "minecraft";
					entry.name = split[0];
					statesStart = 1;
				}
				else
				{
					entry.ns = split[0];
					entry.name = split[1];
					statesStart = 2;
				}

				for (int s = statesStart; s < split.size(); s++)
				{
					int eq = split[s].indexOf('=');
					if (eq <= 0)
						continue;
					entry.properties[split[s].left(eq)] = split[s].mid(eq + 1).split(',');
				}

				QString full = entry.ns + ":" + entry.name;
				if (entry.isTag)
					blocksByTag[full].append({ order++, id, entry });
				else
					blocksByName[full].append({ order++, id, entry });
				hasBlocks = true;
			}
		}
	}

	static void LoadSimpleMap(const QString& source, const QString& prefix, QHash<QString, int>& out)
	{
		OrderedProperties p = ParseProperties(source);
		for (const QString& key : p.keys)
		{
			if (!key.startsWith(prefix))
				continue;
			bool ok = false;
			int id = key.mid(prefix.size()).toInt(&ok);
			if (!ok)
				continue;
			for (const QString& part : p.Get(key).split(QRegularExpression("\\s+"), Qt::SkipEmptyParts))
			{
				QString name = IdMap::Namespaced(part);
				if (!out.contains(name)) // First mapping takes precedence
					out[name] = id;
			}
		}
	}

	void IdMap::LoadItems(const QString& source)
	{
		LoadSimpleMap(source, "item.", items);
	}

	void IdMap::LoadEntities(const QString& source)
	{
		LoadSimpleMap(source, "entity.", entities);
	}

	void IdMap::LoadDimensions(const QString& source)
	{
		OrderedProperties p = ParseProperties(source);
		for (const QString& key : p.keys)
		{
			if (!key.startsWith("dimension."))
				continue;
			QString folder = key.mid(10);
			for (const QString& part : p.Get(key).split(QRegularExpression("\\s+"), Qt::SkipEmptyParts))
				dimensions[part == "*" ? "*" : Namespaced(part)] = folder;
		}
	}

	int IdMap::BlockId(const QString& id, const QHash<QString, QString>& state, const QStringList& tags) const
	{
		int bestOrder = INT_MAX, bestId = -1;

		auto check = [&](const QVector<IndexedEntry>& entries)
		{
			for (const IndexedEntry& e : entries)
			{
				if (e.order >= bestOrder)
					continue;

				bool match = true;
				for (auto it = e.entry.properties.constBegin(); it != e.entry.properties.constEnd(); ++it)
				{
					auto st = state.constFind(it.key());
					if (st == state.constEnd() || !it.value().contains(st.value()))
					{
						match = false;
						break;
					}
				}

				if (match)
				{
					bestOrder = e.order;
					bestId = e.id;
				}
			}
		};

		auto it = blocksByName.constFind(Namespaced(id));
		if (it != blocksByName.constEnd())
			check(it.value());

		// Like Iris, tag entries only apply to states without a direct block entry
		if (bestId >= 0)
			return bestId;

		for (const QString& tag : tags)
		{
			auto tagIt = blocksByTag.constFind(Namespaced(tag));
			if (tagIt != blocksByTag.constEnd())
				check(tagIt.value());
		}

		return bestId;
	}
}
