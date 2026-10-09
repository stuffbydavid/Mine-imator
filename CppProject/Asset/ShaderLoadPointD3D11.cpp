#if OS_WINDOWS
#include "Shader.hpp"
#include "Heap.hpp"

namespace CppProject
{
	QString Shader::LoadPointD3D11(const QString& varsDecl, BoolType useCache)
	{
		if (!pointShader)
			return "";

		pointMultiviewUniform = uniformNameMap.value("_pointMultiview", -1);
		
		QString code = LoadGeometryCode("hlsl");
		auto fallback = [&](const QString& reason)
		{
			releaseAndReset(d3dPointShader);
			releaseAndReset(d3dPointBuffer);

			WARNING("Using six-pass point shadows for " + name + ": " + reason);

			return code;
		};

		if (code.isEmpty())
			return fallback("Geometry source unavailable");
		
		QString pointVars = varsDecl;
		pointVars.replace("struct Vars", "struct PointVars");
		pointVars.replace("};", "\tuint _viewport : SV_ViewportArrayIndex;\n};");
		code.prepend(varsDecl + pointVars);
		code.replace("vec2", "float2").replace("vec3", "float3").replace("vec4", "float4");
		
		Heap<char> data;
	#if !RELEASE_MODE
		QString cacheName = ASSETS_DIR "/Shaders/Compiled/" + name + ".gsh.d3d";
		if (useCache && QFile::exists(cacheName))
		{
			QDateTime cacheModified = QFileInfo(cacheName).lastModified();
			if (QFileInfo(__FILE__).lastModified() >= cacheModified)
				useCache = false;

			for (const QString& sourceName : sourceDependencies)
				if (QFileInfo(sourceName).lastModified() >= cacheModified)
					useCache = false;
		}

		if (!useCache || !QFile::exists(cacheName))
		{
			if (!CompileCodeD3D11(code, "gs_4_0", cacheName, data))
				return fallback("Geometry compilation failed");
		}
		else
	#else
		QString cacheName = ":/Shaders/Compiled/" + name + ".gsh.d3d";
	#endif
		{
			QFile file(cacheName);
			if (!file.open(QFile::ReadOnly))
				return fallback("Geometry cache unavailable");
			
			data = file.readAll();
		}

		HRESULT result = D3DDevice->CreateGeometryShader(data.Data(), data.Size(), nullptr, &d3dPointShader);
		if (FAILED(result))
			return fallback("Geometry creation failed: " + NumStr(result));
		
		D3D11_BUFFER_DESC desc = {};
		desc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
		desc.Usage = D3D11_USAGE_DEFAULT;
		desc.ByteWidth = sizeof(GFX->pointParameters);
		result = D3DDevice->CreateBuffer(&desc, nullptr, &d3dPointBuffer);
		if (FAILED(result))
			return fallback("Geometry buffer creation failed: " + NumStr(result));
		
		return code;
	}
}
#endif
