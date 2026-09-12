#if API_D3D11
#include "Shader.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/Vertex.hpp"

namespace CppProject
{
    ID3D11InputLayout* Shader::d3dInputLayout[4] = { nullptr, nullptr, nullptr, nullptr };

    QMap<Shader::DataType, QString> Shader::dataTypeD3D11Map = {
        { Shader::INT, "int" },
        { Shader::FLOAT, "float" },
        { Shader::VEC2, "float2" },
        { Shader::VEC3, "float3" },
        { Shader::VEC4, "float4" },
        { Shader::MAT4, "float4x4" },
    };

	void Shader::LoadCode(QString vsCode, QString fsCode, BoolType useCache)
	{
        // Free resources
        releaseAndReset(d3dVertexShader);
        releaseAndReset(d3dPixelShader);
        releaseAndReset(d3dObjectBuffer);
        releaseAndReset(d3dStaticBuffer);
        deleteAndReset(samplerRepeatData);
        samplerRepeatDataSize = 0;

        // Find varyings, create Vars struct
        QString varsDecl = "struct Vars\n{\n\tfloat4 gl_Position : SV_POSITION;\n";
        auto varIt = QRegularExpression("(flat )?varying (.*?) (.*?)(\\[.*?\\])?;").globalMatch(vsCode);
        IntType varId = 0;
        while (varIt.hasNext())
        {
            QRegularExpressionMatch match = varIt.next();
            QString interMod = match.captured(1);
            if (!interMod.isEmpty())
                interMod = "nointerpolation ";
            QString typeName = match.captured(2);
            QString name = match.captured(3);
            QString arr = match.captured(4);
            varsDecl += "\t" + interMod + typeName + " " + name + arr + " : " + QString((char)('A' + varId++)) + ";\n";

            vsCode.replace(match.captured(0) + "\n", "");
            fsCode.replace(match.captured(0) + "\n", "");
            vsCode.replace(QRegularExpression("\\b" + name + "\\b"), "_vars." + name);
            fsCode.replace(QRegularExpression("\\b" + name + "\\b"), "_vars." + name);
        }
        vsCode.replace("gl_Position", "_vars.gl_Position");

        // Erase remaining unused varyings in fragment shader
        fsCode.replace(QRegularExpression("(flat )?varying .*? .*?;"), "");

        // Remove attributes, replace with Attrs struct
        vsCode.replace(QRegularExpression("attribute (.*?) (.*?);"), "");

        QString setAttrs = "", inputDecl = "", attrsDecl = "";
        switch (vertexFormat)
        {
            case PRIMITIVE:
                inputDecl += "\tfloat3 Position : A;\n";
                inputDecl += "\tfloat4 Color : B;\n";
                inputDecl += "\tfloat2 TextureCoord : C;\n";
                attrsDecl = inputDecl;

                setAttrs += "\n\t_attrs.Position = _input.Position;";
                setAttrs += "\n\t_attrs.Color = _input.Color;";
                setAttrs += "\n\t_attrs.TextureCoord = _input.TextureCoord;";

                vsCode.replace(QRegularExpression("\\bin_Position\\b"), "_attrs.Position");
                vsCode.replace(QRegularExpression("\\bin_Colour\\b"), "_attrs.Color");
                vsCode.replace(QRegularExpression("\\bin_TextureCoord\\b"), "_attrs.TextureCoord");
                break;

            case VERTEX_BUFFER:
                inputDecl += "\tfloat3 Position : A;\n";
                inputDecl += "\tuint Normal : B;\n";
                inputDecl += "\tuint Color : C;\n";
                inputDecl += "\tfloat2 TextureCoord: D;\n";
                inputDecl += "\tuint Data: E;\n";
                inputDecl += "\tuint Tangent: F;\n";
                attrsDecl += "\tfloat3 Position: A;\n";
                attrsDecl += "\tfloat3 Normal: B;\n";
                attrsDecl += "\tfloat4 Color: C;\n";
                attrsDecl += "\tfloat2 TextureCoord: D;\n";
                attrsDecl += "\tfloat4 Wave: E;\n";
                attrsDecl += "\tfloat3 Tangent: F;\n";
                varsDecl += "\tnointerpolation uint _vObjIndex: " + QString((char)('A' + varId++)) + ";\n";

                setAttrs += "\n\t_attrs.Position = _input.Position;";
                setAttrs += "\n\t_attrs.Normal = " UNPACK_VERTEX_NORMAL("_input.Normal") ";";
                setAttrs += "\n\t_attrs.Color = " UNPACK_VERTEX_COLOR("_input.Color") ";";
                setAttrs += "\n\t_attrs.TextureCoord = _input.TextureCoord;";
                setAttrs += "\n\t_attrs.Wave = " UNPACK_VERTEX_WAVE("_input.Data") ";";
                setAttrs += "\n\t_attrs.Tangent = " UNPACK_VERTEX_NORMAL("_input.Tangent") ";";
                setAttrs += "\n\t_vars._vObjIndex = _input.Data >> 16;";

                vsCode.replace(QRegularExpression("\\bin_Position\\b"), "_attrs.Position");
                vsCode.replace(QRegularExpression("\\bin_Normal\\b"), "_attrs.Normal");
                vsCode.replace(QRegularExpression("\\bin_Colour\\b"), "_attrs.Color");
                vsCode.replace(QRegularExpression("\\bin_TextureCoord\\b"), "_attrs.TextureCoord");
                vsCode.replace(QRegularExpression("\\bin_Wave\\b"), "_attrs.Wave");
                vsCode.replace(QRegularExpression("\\bin_Tangent\\b"), "_attrs.Tangent");
                break;

            case WORLD:
                inputDecl += "\tuint Pos : A;\n";
                inputDecl += "\tuint Data : B;\n";
                attrsDecl = inputDecl;
                setAttrs += "\n\t_attrs.Pos = _input.Pos;";
                setAttrs += "\n\t_attrs.Data = _input.Data;";

                vsCode.replace(QRegularExpression("\\bin_Pos\\b"), "_attrs.Pos");
                vsCode.replace(QRegularExpression("\\bin_Data\\b"), "_attrs.Data");
                break;
        }

        inputDecl = "struct Input\n{\n" + inputDecl + "};\n\n";
        attrsDecl = "struct Attrs\n{\n" + attrsDecl + "};\n\n";
        varsDecl += "};\n\n";

        vsCode = varsDecl + inputDecl + attrsDecl + vsCode;
        fsCode = varsDecl + fsCode;

        // Replace main signature and add return value
        QRegularExpression mainMatch("void main\\(\\).*?\\n{(.*)}", QRegularExpression::DotMatchesEverythingOption);
        vsCode.replace(mainMatch, "Vars main(Input _input)\n{\n\tVars _vars;\n\tAttrs _attrs;" + setAttrs + "\\1\treturn _vars; \n }");
        fsCode.replace(mainMatch, "PSOut main(Vars _vars)\n{\n\tPSOut _out;\\1\n\treturn _out;\n}");

        // Create fragment shader output
        numOutputs = 1;
        fsCode.replace("gl_FragColor", "_out.Color0");
        auto fragDataIt = QRegularExpression("gl_FragData\\[(\\d)\\]").globalMatch(fsCode);
        while (fragDataIt.hasNext())
        {
            QRegularExpressionMatch match = fragDataIt.next();
            IntType num = (IntType)match.captured(1).toInt();
            numOutputs = std::max(numOutputs, num + 1);
            fsCode.replace(match.captured(0), "_out.Color" + NumStr(num));
        }

        QString poutDecl = "struct PSOut\n{\n";
        for (IntType i = 0; i < numOutputs; i++)
            poutDecl += "\tfloat4 Color" + NumStr(i) + " : SV_Target" + NumStr(i) + ";\n";
        poutDecl += "};\n\n";
        fsCode = poutDecl + fsCode;

        // Process code
        auto processCode = [&](QString code, BoolType isVertex)
        {
            // Texture2D function to sample using UvRect uniform
            if (code.contains("texture2D("))
                code = "\n"
                    "float4 _sampleUvRect(Texture2D tex, SamplerState s, float4 uvRect, bool repeat, float2 uv)\n"
                    "{\n"
                    "\tfloat2 lodUv = uvRect.xy + uv * uvRect.zw;\n"
                    "\tfloat2 derivX = ddx(lodUv);\n"
                    "\tfloat2 derivY = ddy(lodUv);\n"
                    "\tif (repeat) uv = mod(uv, float2(1.0, 1.0));\n"
                    "\tuv = uvRect.xy + uv * uvRect.zw;\n"
                    "\treturn tex.SampleGrad(s, uv, derivX, derivY);\n"
                    "}\n\n" + code;

            // Pro RegEx hacker way to replace M * expr with mul(M, expr), beats writing a GLSL parser
            QStringList matrices = gmMatrixUniformName;
            auto matIt = QRegularExpression("mat\\d ([a-zA-Z0-9]*)(\\[.*?\\])?.*;").globalMatch(code);
            while (matIt.hasNext())
            {
                QRegularExpressionMatch match = matIt.next();
                QString name = match.captured(1);
                if (!match.captured(2).isEmpty()) // Array
                    name += "[.*?]";
                if (varsDecl.contains(name))
                    name = "_vars." + name;
                matrices.append(name);
            }

            for (QString mat : matrices)
            {
                mat.replace("[", "\\[");
                mat.replace("]", "\\]");
                auto mulIt = QRegularExpression("((" + mat + ")|([a-zA-Z0-9]+\\((.*?, )?" + mat + "\\)))( *\\* *)(.*?);").globalMatch(code);
                while (mulIt.hasNext())
                {
                    QRegularExpressionMatch match = mulIt.next();
                    QString left = match.captured(1);
                    QString mul = match.captured(5);
                    QString right = match.captured(6);

                    // Truncate right by skipping trailing )
                    IntType len, parLevel = 0;
                    for (len = 0; len < right.length(); len++)
                    {
                        if (right.at(len) == '(')
                            parLevel++;
                        else if (right.at(len) == ')')
                            parLevel--;
                        if (parLevel < 0)
                            break;
                    }
                    right = right.left(len);

                    code = code.replace(left + mul + right, "mul(" + left + ", " + right + ")");
                }
            }

            // Find uniforms/matrices
            LoadCodeCommon(code);

            // Find user functions, send in attributes/varyings
            auto funcIt = QRegularExpression("^([a-zA-Z0-9]+?) ([a-zA-Z0-9]+?)\\((.*?)\\)\\n", QRegularExpression::MultilineOption).globalMatch(code);
            while (funcIt.hasNext())
            {
                QRegularExpressionMatch match = funcIt.next();
                QString typeName = match.captured(1);
                QString name = match.captured(2);
                QString args = match.captured(3);
                if (name == "main")
                    continue;

                if (isVertex)
                {
                    code.replace(match.captured(0), typeName + " " + name + " (Attrs _attrs, Vars _vars" + (args.isEmpty() ? "" : ", " + args) + ")\n");
                    code.replace(QRegularExpression("\\b" + name + "\\("), name + "(_attrs, _vars, ");
                }
                else
                {
                    code.replace(match.captured(0), typeName + " " + name + " (Vars _vars" + (args.isEmpty() ? "" : ", " + args) + ")\n");
                    code.replace(QRegularExpression("\\b" + name + "\\("), name + "(_vars, ");
                }
                code.replace(", )", ")");
                code.replace(typeName + " " + name + " (", typeName + " " + name + "(");
            }

            // Replace type/functions
            code.replace(QRegularExpression("\\bvec2\\("), "float2_(");
            code.replace(QRegularExpression("\\bvec3\\("), "float3_(");
            code.replace(QRegularExpression("\\bvec4\\("), "float4_(");
            code.replace(QRegularExpression("\\bmat3\\("), "float3x3_(");
            code.replace(QRegularExpression("\\bvec2\\b"), "float2");
            code.replace(QRegularExpression("\\bvec3\\b"), "float3");
            code.replace(QRegularExpression("\\bvec4\\b"), "float4");
            code.replace(QRegularExpression("\\bmat3\\b"), "float3x3");
            code.replace(QRegularExpression("\\bmat4\\b"), "float4x4");
            code.replace(QRegularExpression("\\bmix\\b"), "lerp");
            code.replace(QRegularExpression("\\bfract\\b"), "frac");
            code.replace(QRegularExpression("\\bpow\\b"), "power");
            code.replace(QRegularExpression("\\batan\\b"), "atan2");

            // Replace for with while
            code.replace(QRegularExpression("for \\((.*?); ?([a-zA-Z]+)(.*?); ?.*?\\)"), "\\1-1; [loop] while (++\\2\\3)");

            return code;
        };

        vsCode = processCode(vsCode, true);
        fsCode = processCode(fsCode, false);

        // Generate CBuffers and sampler declarations
        QString staticBufferDecl = "{\n";
        QString bufferDecl = "{\n\tstruct {\n";
        QString samplersDecl = "";
        for (IntType i = 0, s = 0; i < numUniforms; i++)
        {
            const UniformState& uni = uniforms[i];
            if (uni.type == Shader::SAMPLER2D)
            {
                samplersDecl += "Texture2D " + uni.name + " : register(t" + NumStr(s) + ");\n";
                samplersDecl += "SamplerState " + uni.name + "_s : register(s" + NumStr(s) + ");\n";
                s++;
            }
            else
            {
                QString decl = "\t" + dataTypeD3D11Map.value(uni.type) + " " + uni.name;
                if (uni.isArray)
                    decl += "[" + NumStr(uni.arrayMaxSize) + "]";
                decl += ";\n";
                if (uni.isStatic)
                    staticBufferDecl += decl;
                else
                {
                    bufferDecl += "\t" + decl;
                    QRegularExpression uniFind("\\b" + uni.name + "\\b");
                    QString uniRepl = "_obj[_vars._vObjIndex]." + uni.name;
                    vsCode.replace(uniFind, uniRepl);
                    fsCode.replace(uniFind, uniRepl);
                }
            }
        }

        // Add UvRect & TexRepeat uniform
        if (numSamplers > 0)
        {
            AddUniform("_uUvRect", "vec4", true, true, numSamplers);
            AddUniform("_uTexRepeat", "int", true, true, numSamplers);
            staticBufferDecl += "\tfloat4 _uUvRect[" + NumStr(numSamplers) + "];\n";
            staticBufferDecl += "\tint _uTexRepeat[" + NumStr(numSamplers) + "];\n";
        }

        // Finalize buffer declarations
        IntType bufId = 0;
        if (staticBufferSize)
            staticBufferDecl = "cbuffer StaticBuffer : register(b" + NumStr(bufId++) + ")\n" + staticBufferDecl + "}\n\n";
        else
            staticBufferDecl = "";

        if (useBatching)
        {
            // Get maximum objects allowed
            batchBufferObjectSize = ceil(batchBufferObjectSize / 16.0) * 16;
            batchBufferMaxObjects = MAX_BATCH_BUFFER_SIZE / batchBufferObjectSize;
            bufferDecl = "cbuffer ObjectBuffer : register(b" + NumStr(bufId++) + ")\n" + bufferDecl + "\t} _obj[" + NumStr(batchBufferMaxObjects) + "];\n}\n";
        }
        else
            bufferDecl = "";

        if (!samplersDecl.isEmpty())
            samplersDecl += "\n";

        // Functions
        QString funcsDecl = "float mod(float a, float b) { return a - b * floor(a / b); }\n";
        funcsDecl += "float2 mod(float2 a, float2 b) { return float2(mod(a.x, b.x), mod(a.y, b.y)); }\n";
        funcsDecl += "float power(float x, float y) { return pow(abs(x), y); };\n";
        funcsDecl += "float3 power(float3 x, float3 y) { return pow(abs(x), y); };\n";
        funcsDecl += "float2 float2_(float x) { return float2(x, x); };\n";
        funcsDecl += "float2 float2_(float x, float y) { return float2(x, y); };\n";
        funcsDecl += "float2 float2_(float2 x) { return x; };\n";
        funcsDecl += "float3 float3_(float x) { return float3(x, x, x); };\n";
        funcsDecl += "float3 float3_(float x, float y, float z) { return float3(x, y, z); };\n";
        funcsDecl += "float3 float3_(float2 x, float y) { return float3(x.x, x.y, y); };\n";
        funcsDecl += "float3 float3_(float3 x) { return x; };\n";
        funcsDecl += "float4 float4_(float x) { return float4(x, x, x, x); };\n";
        funcsDecl += "float4 float4_(float3 x, float y) { return float4(x, y); };\n";
        funcsDecl += "float4 float4_(float x, float3 y) { return float4(x, y); };\n";
        funcsDecl += "float4 float4_(float2 x, float2 y) { return float4(x, y); };\n";
        funcsDecl += "float4 float4_(float2 x, float y, float z) { return float4(x.x, x.y, y, z); };\n";
        funcsDecl += "float4 float4_(float x, float y, float z, float w) { return float4(x, y, z, w); };\n";
        funcsDecl += "float4 float4_(float4 x) { return x; };\n";
        funcsDecl += "float3x3 float3x3_(float3 x, float3 y, float3 z) { return transpose(float3x3(x, y, z)); };\n";
        funcsDecl += "float3x3 float3x3_(float x, float y, float z, float w, float v, float u, float t, float s, float r) { return transpose(float3x3(x, y, z, w, v, u, t, s, r)); };\n";
        funcsDecl += "float3x3 float3x3_(float3x3 x) { return x; };\n";

        vsCode = staticBufferDecl + bufferDecl + samplersDecl + funcsDecl + vsCode;
        fsCode = staticBufferDecl + bufferDecl + samplersDecl + funcsDecl + fsCode;

        Heap<char> vsData, fsData;
        QString vsCacheName, fsCacheName;
    #if DEBUG_MODE
        vsCacheName = ASSETS_DIR"/Shaders/Compiled/" + name + ".vsh.d3d";
        fsCacheName = ASSETS_DIR"/Shaders/Compiled/" + name + ".fsh.d3d";
    #else
        vsCacheName = ":/Shaders/Compiled/" + name + ".vsh.d3d";
        fsCacheName = ":/Shaders/Compiled/" + name + ".fsh.d3d";
    #endif

        if (!useCache || !QFile::exists(vsCacheName) || !QFile::exists(fsCacheName))
        {
        #if DEBUG_MODE
            // Compile code and store in assets
            auto compileCode = [&](QString code, BoolType isVertex, Heap<char>& dst)
            {
                ID3DBlob* data;
                ID3DBlob* errMsgs;
                DWORD flags = D3DCOMPILE_PACK_MATRIX_COLUMN_MAJOR | D3DCOMPILE_ENABLE_STRICTNESS;
            #if 0
                flags |= D3DCOMPILE_DEBUG;
            #else
                flags |= D3DCOMPILE_OPTIMIZATION_LEVEL3;
            #endif
                std::string codeStd = code.toStdString();
                std::string target = isVertex ? "vs_4_0" : "ps_4_0";
                if (FAILED(D3DCompile(codeStd.c_str(), code.length(), nullptr, nullptr, nullptr, "main", target.c_str(), flags, 0, &data, &errMsgs)))
                {
                    std::string errMsg((const char*)errMsgs->GetBufferPointer(), errMsgs->GetBufferSize());
                    WARNING("Loading " + name + (isVertex ? " vertex" : " fragment") + " shader failed\n\t" + QString(errMsg.c_str()));
                    DEBUG(code);
                    errMsgs->Release();
                    return false;
                }

                // Write to output heap
                dst.Alloc(data->GetBufferSize());
                memcpy(dst.data, data->GetBufferPointer(), data->GetBufferSize());
                data->Release();

                // Write to file
                QFile file(isVertex ? vsCacheName : fsCacheName);
                AddPerms(file);
                if (!file.open(QFile::WriteOnly))
                {
                    WARNING("Could not open file: " + file.errorString());
                    return false;
                }
                file.write(dst.Data(), dst.Size());

                return true;
            };

            if (!compileCode(vsCode, true, vsData))
                return;
            if (!compileCode(fsCode, false, fsData))
                return;
        #else
            WARNING("No cache found for shader: " + name);
        #endif
        }
        else
        {
            // Read compiled data
            QFile vsFile(vsCacheName);
            if (!vsFile.open(QFile::ReadOnly))
            {
                WARNING("Could not open vertex shader");
                return;
            }
            vsData = vsFile.readAll();

            QFile fsFile(fsCacheName);
            if (!fsFile.open(QFile::ReadOnly))
            {
                WARNING("Could not open fragment shader");
                return;
            }
            fsData = fsFile.readAll();
        }

        D3DCheckError(D3DDevice->CreateVertexShader(vsData.Data(), vsData.Size(), nullptr, &d3dVertexShader));
        D3DCheckError(D3DDevice->CreatePixelShader(fsData.Data(), fsData.Size(), nullptr, &d3dPixelShader));

        // Create layout if needed
        if (!d3dInputLayout[vertexFormat])
        {
            QVector<D3D11_INPUT_ELEMENT_DESC> elements;
            IntType offset = 0;
            auto addElement = [&](DXGI_FORMAT format, IntType size)
            {
                char* name = new char[2]{ (char)((int)'A' + elements.size()), '\0'};
                elements.append({ name, 0, format, 0, (UINT)offset, D3D11_INPUT_PER_VERTEX_DATA, 0});
                offset += size;
            };

            switch (vertexFormat)
            {
                case PRIMITIVE:
                    addElement(DXGI_FORMAT_R32G32B32_FLOAT, sizeof(float) * 3);
                    addElement(DXGI_FORMAT_R32G32B32A32_FLOAT, sizeof(float) * 4);
                    addElement(DXGI_FORMAT_R32G32_FLOAT, sizeof(float) * 2);
                    break;

                case VERTEX_BUFFER:
                    addElement(DXGI_FORMAT_R32G32B32_FLOAT, sizeof(float) * 3);
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    addElement(DXGI_FORMAT_R32G32_FLOAT, sizeof(float) * 2);
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    break;

                case WORLD:
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    addElement(DXGI_FORMAT_R32_UINT, sizeof(uint32_t));
                    break;
            }

            D3DCheckError(D3DDevice->CreateInputLayout(elements.data(), elements.size(), vsData.Data(), vsData.Size(), &d3dInputLayout[vertexFormat]));
            for (D3D11_INPUT_ELEMENT_DESC& el : elements)
                delete el.SemanticName;
        }

        // Create constant buffers
        D3D11_BUFFER_DESC cBufferDesc = {};
        cBufferDesc.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
        cBufferDesc.CPUAccessFlags = 0;
        cBufferDesc.Usage = D3D11_USAGE_DEFAULT;

        if (useBatching)
        {
            batchBufferSize = ceil((batchBufferMaxObjects * batchBufferObjectSize) / 16.0) * 16;
            batchBufferData = new char[batchBufferSize];
            cBufferDesc.ByteWidth = batchBufferSize;
            D3DCheckError(D3DDevice->CreateBuffer(&cBufferDesc, nullptr, &d3dObjectBuffer));
        }

        if (staticBufferSize)
        {
            staticBufferSize = ceil(staticBufferSize / 16.0) * 16;
            staticBufferData = new char[staticBufferSize];
            cBufferDesc.ByteWidth = staticBufferSize;
            D3DCheckError(D3DDevice->CreateBuffer(&cBufferDesc, nullptr, &d3dStaticBuffer));
        }

        if (numSamplers)
        {
            samplerRepeatDataSize = (numSamplers - 1) * 4 + 1;
            samplerRepeatData = new int32_t[samplerRepeatDataSize];
        }
	}
}
#endif