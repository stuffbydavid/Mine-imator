#include "Shader.hpp"

namespace CppProject
{
	BoolType Shader::LoadPointOpenGL(const QString& vsCode, const QString& fsCode)
	{
		if (!pointShader || !gl43Supported)
			return false;
		
		QString gsCode = LoadGeometryCode("glsl");
		if (!gsCode.isEmpty())
		{
			QString pointVsCode = vsCode;
			const QStringList varyings = { "vPosition", "vTexCoord", "vColor", "_vObjIndex" };
			for (const QString& varying : varyings)
				pointVsCode.replace(QRegularExpression("\\b" + varying + "\\b"), "_point_" + (varying.startsWith("_") ? varying.mid(1) : varying));
			
			gsCode.prepend("#version 430\n");
			
			if (LoadProgramOpenGL(pointVsCode, fsCode, gsCode))
			{
				pointMultiviewUniform = uniformNameMap.value("_pointMultiview", -1);
				glPointEye = program->uniformLocation("_pointEye");
				glPointProjection = program->uniformLocation("_pointProjection");
				glPointVertical = program->uniformLocation("_pointVertical");

			#if !RELEASE_MODE
				SaveConvertedCode(pointVsCode, fsCode, "glsl", gsCode);
			#endif

				return true;
			}
		}

		WARNING("Using six-pass point shadows for " + name);

		return false;
	}
}
