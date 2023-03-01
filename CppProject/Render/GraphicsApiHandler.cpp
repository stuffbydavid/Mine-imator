#include "GraphicsApiHandler.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/Surface.hpp"
#include "Generated/GmlFunc.hpp"
#include "GLWidget.hpp"
#include "PrimitiveRenderer.hpp"
#include "VertexBufferRenderer.hpp"

#if API_D3D11
#include <comdef.h>
#else
#include <QOpenGLDebugLogger>
#endif

namespace CppProject
{
	GraphicsApiHandler* GraphicsApiHandler::handler = nullptr;

#if API_D3D11
	GraphicsApiHandler::GraphicsApiHandler()
	{
		handler = this;
	}

	void GraphicsApiHandler::Init()
	{
		// Create device
		D3D_FEATURE_LEVEL featureLevels[] = { D3D_FEATURE_LEVEL_11_0, D3D_FEATURE_LEVEL_10_0 };
		UINT creationFlags = D3D11_CREATE_DEVICE_BGRA_SUPPORT;
	#if DEBUG_MODE
		creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
	#endif

		D3DCheckError(D3D11CreateDevice(
			0, D3D_DRIVER_TYPE_HARDWARE,
			0, creationFlags,
			featureLevels, ARRAYSIZE(featureLevels),
			D3D11_SDK_VERSION, &d3dDevice,
			0, &d3dContext
		));

		// Enable debugger
	#if DEBUG_MODE
		ID3D11Debug* debugger = nullptr;
		D3DCheckError(d3dDevice->QueryInterface(__uuidof(ID3D11Debug), (void**)&debugger));
		if (debugger)
		{
			ID3D11InfoQueue* d3dInfoQueue = nullptr;
			if (SUCCEEDED(debugger->QueryInterface(__uuidof(ID3D11InfoQueue), (void**)&d3dInfoQueue)))
			{
				//d3dInfoQueue->SetBreakOnSeverity(D3D11_MESSAGE_SEVERITY_WARNING, true);
				d3dInfoQueue->SetBreakOnSeverity(D3D11_MESSAGE_SEVERITY_CORRUPTION, true);
				d3dInfoQueue->SetBreakOnSeverity(D3D11_MESSAGE_SEVERITY_ERROR, true);
				d3dInfoQueue->Release();
			}
			debugger->Release();
		}
	#endif

		// Get DXGI factory
		IDXGIDevice* dxgiDevice;
		D3DCheckError(d3dDevice->QueryInterface(__uuidof(IDXGIDevice), (void**)&dxgiDevice));
		IDXGIAdapter* dxgiAdapter;
		D3DCheckError(dxgiDevice->GetAdapter(&dxgiAdapter));
		dxgiDevice->Release();
		DXGI_ADAPTER_DESC adapterDesc;
		dxgiAdapter->GetDesc(&adapterDesc);
		DEBUG("Graphics device: " + QString::fromStdWString(adapterDesc.Description));
		D3DCheckError(dxgiAdapter->GetParent(__uuidof(IDXGIFactory), (void**)&dxgiFactory));
		dxgiAdapter->Release();

		// Create sampler states
		D3D11_SAMPLER_DESC sampDesc = {};
		sampDesc.AddressU = D3D11_TEXTURE_ADDRESS_CLAMP;
		sampDesc.AddressV = D3D11_TEXTURE_ADDRESS_CLAMP;
		sampDesc.AddressW = D3D11_TEXTURE_ADDRESS_CLAMP;
		sampDesc.ComparisonFunc = D3D11_COMPARISON_NEVER;

		for (D3D11_FILTER filter : {
			D3D11_FILTER_MIN_MAG_MIP_POINT,
			D3D11_FILTER_MIN_MAG_POINT_MIP_LINEAR,
			D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT,
			D3D11_FILTER_MIN_POINT_MAG_MIP_LINEAR
		})
		{
			sampDesc.Filter = filter;
			sampDesc.MaxLOD = (filter == D3D11_FILTER_MIN_MAG_MIP_POINT || filter == D3D11_FILTER_MIN_POINT_MAG_LINEAR_MIP_POINT) ? 0 : D3D11_FLOAT32_MAX; // Mip point = disable mipmapping
			D3DCheckError(d3dDevice->CreateSamplerState(&sampDesc, &d3dSamplerStateMap[filter]));
		} 

		// Create rasterizer states for each cull mode
		D3D11_RASTERIZER_DESC rastDesc = {};
		rastDesc.FillMode = D3D11_FILL_SOLID;
		
		for (D3D11_CULL_MODE mode : { D3D11_CULL_NONE, D3D11_CULL_FRONT, D3D11_CULL_BACK })
		{
			rastDesc.CullMode = mode;
			D3DCheckError(D3DDevice->CreateRasterizerState(&rastDesc, &d3dRasterizerStateMap[mode]));
		}
		D3DContext->RSSetState(d3dRasterizerStateMap[D3D11_CULL_BACK]);

		// Create depth states
		D3D11_DEPTH_STENCIL_DESC depthStencilDesc = {};
		depthStencilDesc.DepthEnable = TRUE;
		depthStencilDesc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ALL;
		depthStencilDesc.DepthFunc = D3D11_COMPARISON_LESS_EQUAL;
		depthStencilDesc.StencilEnable = FALSE;
		D3DCheckError(D3DDevice->CreateDepthStencilState(&depthStencilDesc, &d3dDepthStencilStateMap[DEPTH_TEST_WRITE]));
		depthStencilDesc.DepthWriteMask = D3D11_DEPTH_WRITE_MASK_ZERO;
		D3DCheckError(D3DDevice->CreateDepthStencilState(&depthStencilDesc, &d3dDepthStencilStateMap[DEPTH_TEST_NO_WRITE]));
		depthStencilDesc.DepthEnable = FALSE;
		D3DCheckError(D3DDevice->CreateDepthStencilState(&depthStencilDesc, &d3dDepthStencilStateMap[DEPTH_NO_TEST_NO_WRITE]));
		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[DEPTH_NO_TEST_NO_WRITE], 1);

		// Create stencil states
		depthStencilDesc.StencilEnable = TRUE;
		depthStencilDesc.StencilWriteMask = 255;
		depthStencilDesc.FrontFace = depthStencilDesc.BackFace = { D3D11_STENCIL_OP_KEEP, D3D11_STENCIL_OP_KEEP, D3D11_STENCIL_OP_REPLACE, D3D11_COMPARISON_ALWAYS };
		D3DCheckError(D3DDevice->CreateDepthStencilState(&depthStencilDesc, &d3dDepthStencilStateMap[STENCIL_WRITE]));
		depthStencilDesc.StencilWriteMask = 0;
		depthStencilDesc.StencilReadMask = 255;
		depthStencilDesc.FrontFace.StencilFunc = depthStencilDesc.BackFace.StencilFunc = D3D11_COMPARISON_EQUAL;
		D3DCheckError(D3DDevice->CreateDepthStencilState(&depthStencilDesc, &d3dDepthStencilStateMap[STENCIL_TEST]));

		// Map source/dest modes
		d3dBlendColorMap[bm_zero] = D3D11_BLEND_ZERO;
		d3dBlendColorMap[bm_one] = D3D11_BLEND_ONE;
		d3dBlendColorMap[bm_src_color] = D3D11_BLEND_SRC_COLOR;
		d3dBlendColorMap[bm_inv_src_color] = D3D11_BLEND_INV_SRC_COLOR;
		d3dBlendColorMap[bm_src_alpha] = D3D11_BLEND_SRC_ALPHA;
		d3dBlendColorMap[bm_inv_src_alpha] = D3D11_BLEND_INV_SRC_ALPHA;
		d3dBlendColorMap[bm_dest_alpha] = D3D11_BLEND_DEST_ALPHA;
		d3dBlendColorMap[bm_inv_dest_alpha] = D3D11_BLEND_INV_DEST_ALPHA;
		d3dBlendColorMap[bm_dest_color] = D3D11_BLEND_DEST_COLOR;
		d3dBlendColorMap[bm_inv_dest_color] = D3D11_BLEND_INV_DEST_COLOR;
		d3dBlendColorMap[bm_src_alpha_sat] = D3D11_BLEND_SRC_ALPHA_SAT;

		d3dBlendAlphaMap = d3dBlendColorMap;
		d3dBlendAlphaMap[bm_src_color] = D3D11_BLEND_SRC_ALPHA;
		d3dBlendAlphaMap[bm_dest_color] = D3D11_BLEND_DEST_ALPHA;
		d3dBlendAlphaMap[bm_inv_src_color] = D3D11_BLEND_INV_SRC_ALPHA;
		d3dBlendAlphaMap[bm_inv_dest_color] = D3D11_BLEND_INV_DEST_ALPHA;

		// Create blend state for no blending
		D3D11_BLEND_DESC blendState = {};
		ZeroMemory(&blendState, sizeof(D3D11_BLEND_DESC));
		blendState.RenderTarget[0].BlendEnable = FALSE;
		blendState.RenderTarget[0].RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;
		D3DDevice->CreateBlendState(&blendState, &d3dNoBlendState);
		blendState.RenderTarget[0].RenderTargetWriteMask = 0;
		D3DDevice->CreateBlendState(&blendState, &d3dNoColorState);

		// Load application resources
		App->LoadResources();
	}

	BoolType GraphicsApiHandler::CheckD3DError(HRESULT result, QString func, IntType line)
	{
		if (SUCCEEDED(result))
			return false;

		_com_error err(result);
		QString errMsg(err.ErrorMessage());
		if (errMsg.contains("GetDeviceRemovedReason"))
		{
			_com_error removedErr(D3DDevice->GetDeviceRemovedReason());
			errMsg = "GPU device instance suspended: " + QString(removedErr.ErrorMessage());
		}
		Printer::Fatal("Direct3D error: " + errMsg + "\nin " + func + ":" + NumStr(line));

		return true;
	}

	BoolType GraphicsApiHandler::StartOffScreenRender()
	{
		return true;
	}

	void GraphicsApiHandler::SetMRTIndex(IntType index, FrameBuffer* frameBuffer)
	{
		if (!d3dMrtDSV)
			d3dMrtDSV = frameBuffer->d3dDSV;

		// Update list of RTVs
		if (index >= d3dMrtRTVs.size())
			d3dMrtRTVs.resize(index + 1);
		d3dMrtRTVs[index] = frameBuffer->d3dRTV;

		if (index == 0)
			return;

		// Bind list and first submitted framebuffer DSV
		D3DContext->OMSetRenderTargets(d3dMrtRTVs.size(), d3dMrtRTVs.data(), d3dMrtDSV);

		// Set viewport
		D3D11_VIEWPORT viewport = { 0, 0, (float)frameBuffer->size.width(), (float)frameBuffer->size.height(), 0.0, 1.0 };
		D3DContext->RSSetViewports(1, &viewport);

		// Clear RTV
		float rgba[4] = { 0.f, 0.f, 0.f, 0.f };
		D3DContext->ClearRenderTargetView(frameBuffer->d3dRTV, rgba);
	}

	void GraphicsApiHandler::ResetMRT()
	{
		if (!d3dMrtRTVs.size())
			return;

		d3dMrtDSV = nullptr;
		d3dMrtRTVs.clear();

		ID3D11RenderTargetView* nullViews[] = { nullptr };
		D3DContext->OMSetRenderTargets(1, nullViews, 0);
	}

	void GraphicsApiHandler::ClearColor(QColor color)
	{
		if (!surface->frameBuffer->d3dRTV)
			return;

		float rgba[4] = { (float)color.redF(), (float)color.greenF(), (float)color.blueF(), (float)color.alphaF() };
		D3DContext->ClearRenderTargetView(surface->frameBuffer->d3dRTV, rgba);
	}

	void GraphicsApiHandler::ClearDepth()
	{
		if (surface->frameBuffer->d3dDSV)
			D3DContext->ClearDepthStencilView(surface->frameBuffer->d3dDSV, D3D11_CLEAR_DEPTH, 1.0, 0);
	}

	void GraphicsApiHandler::SetCulling(BoolType enabled)
	{
		if (culling == enabled)
			return;

		SubmitBatch();
		culling = enabled;
		D3DContext->RSSetState(d3dRasterizerStateMap[culling ? D3D11_CULL_BACK : D3D11_CULL_NONE]);
	}

	void GraphicsApiHandler::SetCullFrontFace(BoolType enabled)
	{
		if (cullFront == enabled)
			return;

		SubmitBatch();
		cullFront = enabled;
		D3DContext->RSSetState(d3dRasterizerStateMap[cullFront ? D3D11_CULL_FRONT : D3D11_CULL_BACK]);
	}

	void GraphicsApiHandler::SetDepthTest(BoolType enabled)
	{
		if (depthTest == enabled)
			return;

		SubmitBatch();
		depthTest = enabled;
		DepthStencilState dss = depthTest ? (depthMask ? DEPTH_TEST_WRITE : DEPTH_TEST_NO_WRITE) : DEPTH_NO_TEST_NO_WRITE;
		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[dss], 1);

	}

	void GraphicsApiHandler::SetDepthWrite(BoolType enabled)
	{
		if (depthMask == enabled)
			return;

		SubmitBatch();
		depthMask = enabled;
		DepthStencilState dss = depthTest ? (depthMask ? DEPTH_TEST_WRITE : DEPTH_TEST_NO_WRITE) : DEPTH_NO_TEST_NO_WRITE;
		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[dss], 1);
	}

	void GraphicsApiHandler::SetBlendingFuncs(IntType src, IntType dest, IntType alphasrc, IntType alphadest)
	{
		if (blendSrcFactor == src && blendDstFactor == dest &&
			blendAlphaSrcFactor == alphasrc && blendAlphaDstFactor == alphadest)
			return;

		SubmitBatch();
		blendSrcFactor = src;
		blendDstFactor = dest;
		blendAlphaSrcFactor = alphasrc;
		blendAlphaDstFactor = alphadest;

		// Find previously created state
		ID3D11BlendState* state = nullptr;
		d3dBlendStateIndex = 0;
		for (BlendState& prevState : d3dBlendStates)
		{
			if (prevState.src == src && prevState.dst == dest && prevState.srcAlpha == alphasrc && prevState.dstAlpha == alphadest)
			{
				state = prevState.state;
				break;
			}
			d3dBlendStateIndex++;
		}

		// Create blend state
		if (!state)
		{
			D3D11_BLEND_DESC blendDesc = {};
			D3D11_RENDER_TARGET_BLEND_DESC rtbd = {};
			rtbd.BlendEnable = TRUE;
			rtbd.SrcBlend = d3dBlendColorMap[src];
			rtbd.DestBlend = d3dBlendColorMap[dest];
			rtbd.SrcBlendAlpha = d3dBlendAlphaMap[alphasrc];
			rtbd.DestBlendAlpha = d3dBlendAlphaMap[alphadest];
			rtbd.BlendOp = rtbd.BlendOpAlpha = D3D11_BLEND_OP_ADD;
			rtbd.RenderTargetWriteMask = D3D11_COLOR_WRITE_ENABLE_ALL;

			blendDesc.AlphaToCoverageEnable = false;
			blendDesc.RenderTarget[0] = rtbd;
			D3DCheckError(D3DDevice->CreateBlendState(&blendDesc, &state));
			d3dBlendStates.append({ src, dest, alphasrc, alphadest, state });
		}

		D3DContext->OMSetBlendState(state, nullptr, 0xFFFFFFFF);
	}

	void GraphicsApiHandler::SetLODBias(IntType bias)
	{
		if (lodBias == bias)
			return;

		SubmitBatch();
		lodBias = bias;

		for (D3D11_FILTER filter : d3dSamplerStateMap.keys())
		{
			D3D11_SAMPLER_DESC desc;
			d3dSamplerStateMap[filter]->GetDesc(&desc);
			desc.MipLODBias = lodBias;
			d3dSamplerStateMap[filter]->Release();
			D3DCheckError(D3DDevice->CreateSamplerState(&desc, &d3dSamplerStateMap[filter]));
		}
	}

	IntType GraphicsApiHandler::GetMaxSize()
	{
		if (d3dDevice->GetFeatureLevel() < D3D_FEATURE_LEVEL_11_0)
			return D3D10_REQ_TEXTURE2D_U_OR_V_DIMENSION;

		return D3D11_REQ_TEXTURE2D_U_OR_V_DIMENSION;
	}

	void GraphicsApiHandler::ClipBegin(QRect rect)
	{
		SubmitBatch();

		D3DContext->ClearDepthStencilView(surface->frameBuffer->d3dDSV, D3D11_CLEAR_STENCIL, 1.0, 0);
		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[STENCIL_WRITE], 1);
		D3DContext->OMSetBlendState(d3dNoColorState, nullptr, 0xFFFFFFFF);

		clipEnabled = true;
		clipRect = rect;
		draw_rectangle(rect.x(), rect.y(), rect.right() + 1, rect.bottom() + 1, false);
		SubmitBatch();

		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[STENCIL_TEST], 1);
		D3DContext->OMSetBlendState(d3dBlendStates[d3dBlendStateIndex].state, nullptr, 0xFFFFFFFF);
	}

	void GraphicsApiHandler::ClipEnd()
	{
		SubmitBatch();

		clipEnabled = false;
		D3DContext->OMSetDepthStencilState(d3dDepthStencilStateMap[DEPTH_NO_TEST_NO_WRITE], 1);
	}
#else
	GraphicsApiHandler::GraphicsApiHandler()
	{
		handler = this;

		QApplication::setAttribute(Qt::AA_UseDesktopOpenGL);
		QApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

		// Enable OpenGL 4.3 Core
		QSurfaceFormat format = QSurfaceFormat::defaultFormat();
		format.setDepthBufferSize(24);
		format.setStencilBufferSize(8);
		format.setVersion(4, 3);
		format.setProfile(QSurfaceFormat::CoreProfile);
	#if DEBUG_MODE
		format.setOption(QSurfaceFormat::DebugContext);
	#endif
		QSurfaceFormat::setDefaultFormat(format);
	}

	void GraphicsApiHandler::Init()
	{
		if (isInitialized())
			return;

		// Find version
		glContext = App->mainWindow->glWidget->context();
		glVersion = NumStr(glContext->format().version().first) + "." + NumStr(glContext->format().version().second);
		DEBUG("OpenGL version: " + glVersion);

		if (!initializeOpenGLFunctions())
			FATAL("Could not initialize OpenGL, version is " + glVersion);

		DEBUG("GL_RENDERER: " + QString((char*)glGetString(GL_RENDERER)));
		DEBUG("GL_VENDOR: " + QString((char*)glGetString(GL_VENDOR)));

		glEnable(GL_BLEND);
		glFrontFace(GL_CW);
		glDepthMask(true);
		glDepthFunc(GL_LEQUAL);
		GL_CHECK_ERROR();

		// Create debugger
	#if DEBUG_MODE
		QOpenGLDebugLogger* logger = new QOpenGLDebugLogger;
		if (logger->initialize())
		{
			logger->connect(logger, &QOpenGLDebugLogger::messageLogged, [&](const QOpenGLDebugMessage& message)
				{
					QString msg = message.message();
					if (msg.contains("error"))
						DEBUG("[OpenGL error] " + msg);
					else if (!msg.startsWith("Buffer detailed info"))
						DEBUG("[OpenGL debug] " + msg);
				});
			logger->startLogging(QOpenGLDebugLogger::SynchronousLogging);
			DEBUG("Started OpenGL debugger");
		}
		else
			DEBUG("Could not initialize OpenGL debugger");
	#endif

		// Create off-screen surface
		glOffScreenSurface = new QOffscreenSurface;
		glOffScreenSurface->create();

		// Map source/dest modes
		glBlendMap[bm_zero] = GL_ZERO;
		glBlendMap[bm_one] = GL_ONE;
		glBlendMap[bm_src_color] = GL_SRC_COLOR;
		glBlendMap[bm_inv_src_color] = GL_ONE_MINUS_SRC_COLOR;
		glBlendMap[bm_src_alpha] = GL_SRC_ALPHA;
		glBlendMap[bm_inv_src_alpha] = GL_ONE_MINUS_SRC_ALPHA;
		glBlendMap[bm_dest_alpha] = GL_DST_ALPHA;
		glBlendMap[bm_inv_dest_alpha] = GL_ONE_MINUS_DST_ALPHA;
		glBlendMap[bm_dest_color] = GL_DST_COLOR;
		glBlendMap[bm_inv_dest_color] = GL_ONE_MINUS_DST_COLOR;
		glBlendMap[bm_src_alpha_sat] = GL_SRC_ALPHA_SATURATE;

		// Load application resources
		App->LoadResources();
	}

	BoolType GraphicsApiHandler::CheckGLError(QString func, IntType line)
	{
		while (true)
		{
			GLenum errorCode = glGetError();
			if (errorCode == GL_NO_ERROR)
				return false;

			QString error;
			switch (errorCode)
			{
				case GL_INVALID_ENUM: error = "INVALID_ENUM"; break;
				case GL_INVALID_VALUE: error = "INVALID_VALUE"; break;
				case GL_INVALID_OPERATION: error = "INVALID_OPERATION"; break;
				case GL_STACK_OVERFLOW: error = "STACK_OVERFLOW"; break;
				case GL_STACK_UNDERFLOW: error = "STACK_UNDERFLOW"; break;
				case GL_OUT_OF_MEMORY: error = "OUT_OF_MEMORY"; break;
				case GL_INVALID_FRAMEBUFFER_OPERATION: error = "INVALID_FRAMEBUFFER_OPERATION"; break;
				default: error = "Unknown OpenGL error " + NumStr(errorCode);
			}
			DEBUG("[OpenGL ERROR] " + error + " in " + func + ":" + NumStr(line));
			return true;
		}
	}

	BoolType GraphicsApiHandler::StartOffScreenRender()
	{
		glCurrentVboId = AppWin->glWidget->glVboId;
		if (!glContext->makeCurrent(glOffScreenSurface))
		{
			WARNING("BeginUse makeCurrent failed");
			return false;
		}
		GL_CHECK_ERROR();
		return true;
	}

	void GraphicsApiHandler::SetMRTIndex(IntType index, FrameBuffer* frameBuffer)
	{
		glMrtCount = index + 1;
		if (index == 0)
			return;

		// Bind texture as color attachment
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + index, GL_TEXTURE_2D, frameBuffer->GetColorTexId(), 0);
		GL_CHECK_ERROR();

		// Select attachments for rendering
		GLenum* buffers = new GLenum[index + 1];
		for (IntType i = 0; i < glMrtCount; i++)
			buffers[i] = GL_COLOR_ATTACHMENT0 + i;
		glDrawBuffers(index + 1, buffers);
		GL_CHECK_ERROR();
		delete[] buffers;
	}

	void GraphicsApiHandler::ResetMRT()
	{
		if (!glMrtCount)
			return;

		// Reset color attachments
		for (IntType i = 1; i < glMrtCount; i++)
			glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0 + i, GL_TEXTURE_2D, 0, 0);
		GL_CHECK_ERROR();

		glMrtCount = 0;
	}

	void GraphicsApiHandler::ClearColor(QColor color)
	{
		glClearColor(color.redF(), color.greenF(), color.blueF(), color.alphaF());
		glClear(GL_COLOR_BUFFER_BIT);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::ClearDepth()
	{
		glClear(GL_DEPTH_BUFFER_BIT);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetCulling(BoolType enabled)
	{
		if (culling == enabled)
			return;

		SubmitBatch();
		culling = enabled;

		if (enabled)
			glEnable(GL_CULL_FACE);
		else
			glDisable(GL_CULL_FACE);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetCullFrontFace(BoolType enabled)
	{
		if (cullFront == enabled)
			return;

		SubmitBatch();
		cullFront = enabled;
		glCullFace(enabled ? GL_FRONT : GL_BACK);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetDepthTest(BoolType enabled)
	{
		if (depthTest == enabled)
			return;

		SubmitBatch();
		depthTest = enabled;

		if (enabled)
			glEnable(GL_DEPTH_TEST);
		else
			glDisable(GL_DEPTH_TEST);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetDepthWrite(BoolType enabled)
	{
		if (depthMask == enabled)
			return;

		SubmitBatch();
		depthMask = enabled;

		glDepthMask(enabled);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetBlendingFuncs(IntType src, IntType dest, IntType alphasrc, IntType alphadest)
	{
		if (blendSrcFactor == src && blendDstFactor == dest &&
			blendAlphaSrcFactor == alphasrc && blendAlphaDstFactor == alphadest)
			return;

		SubmitBatch();
		blendSrcFactor = src;
		blendDstFactor = dest;
		blendAlphaSrcFactor = alphasrc;
		blendAlphaDstFactor = alphadest;

		glBlendFuncSeparate(glBlendMap[src], glBlendMap[dest], glBlendMap[alphasrc], glBlendMap[alphadest]);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::SetLODBias(IntType bias)
	{
		if (lodBias == bias)
			return;

		SubmitBatch();
		lodBias = bias;
	}

	void GraphicsApiHandler::ClipBegin(QRect rect)
	{
		SubmitBatch();

		// Render to stencil mask
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
		glStencilFunc(GL_ALWAYS, 1, 0xFF);

		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
		glStencilMask(0xFF);
		GL_CHECK_ERROR();

		glClear(GL_STENCIL_BUFFER_BIT);
		glEnable(GL_STENCIL_TEST);

		clipEnabled = true;
		clipRect = rect;
		draw_rectangle(rect.x(), rect.y(), rect.right() + 1, rect.bottom() + 1, false);
		SubmitBatch();

		// Render using stencil mask
		glStencilFunc(GL_EQUAL, 1, 0xFF);
		glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
		glStencilMask(0x00);
		GL_CHECK_ERROR();
	}

	void GraphicsApiHandler::ClipEnd()
	{
		if (!clipEnabled)
			return;

		SubmitBatch();

		// Disable stencil mask
		clipEnabled = false;
		glDisable(GL_STENCIL_TEST);
	}

	IntType GraphicsApiHandler::GetMaxSize()
	{
		return 16384;
	}
#endif

	void GraphicsApiHandler::SetMatrix(IntType type, Matrix matrix)
	{
		switch (type)
		{
			case matrix_world:
			{
				matrixM = matrix;
				shader->SubmitMatrix(Shader::M, matrix);
				break;
			}

			case matrix_view:
			{
				matrixV = matrix;
				if (!frustumUpdate && matrixV != frustumV)
					frustumUpdate = true;
				shader->SubmitMatrix(Shader::V, matrix);
				break;
			}

			// Note: Projection must be set after View!
			case matrix_projection:
			{
				matrixP = matrix;
				matrixVP = matrixV * matrixP;

				shader->SubmitMatrix(Shader::P, matrix);
				if (!frustumUpdate && matrixP != frustumP)
					frustumUpdate = true;

				// Update frustum if either V or P changed (ignore ortho matrices)
				if (frustumUpdate && !matrixP.m[15])
					UpdateFrustum();
				break;
			}
		}
	}
	
	void GraphicsApiHandler::UpdateFrustum()
	{
		frustumV = matrixV;
		frustumP = matrixP;

		static VecType frustumBase[6] = {
			VecType(1, 0, 0, 1),
			VecType(-1, 0, 0, 1),
			VecType(0,  1, 0, 1),
			VecType(0, -1, 0, 1),
			VecType(0, 0,  1, 1),
			VecType(0, 0, -1, 1)
		};
		Matrix vpTransposed = (frustumV * frustumP).GetTransposed(); // VP transposed
		for (IntType i = 0; i < 6; i++)
		{
			VecType mul = vpTransposed * frustumBase[i];
			frustum[i] = mul / sqrtf(mul.x * mul.x + mul.y * mul.y + mul.z * mul.z);
		}
		frustumUpdate = false;
	}

	BoolType GraphicsApiHandler::IsVisible(const Bounds& worldBounds) const
	{
		QVector<VecType> points = worldBounds.GetPoints();
		for (const VecType& frustumVec : frustum)
		{
			// If all of the points lie behind one of the planes, the box is not rendered
			bool pointInside = false;
			for (const VecType& point : points)
			{
				if (VecType::DotProduct(frustumVec, point) > 0.0)
				{
					pointInside = true;
					break;
				}
			}

			if (!pointInside)
				return false;
		}

		return true;
	}

	void GraphicsApiHandler::SubmitBatch()
	{
		PR->SubmitBatch();
		VB->SubmitBatch();
	}

	QColor GraphicsApiHandler::IntToQColor(IntType in, RealType alpha)
	{
		if (in < 0)
			return QColor(255, 255, 255, alpha * 255);

		IntType r = in & 0x0ff;
		IntType g = (in >> 8) & 0x0ff;
		IntType b = (in >> 16) & 0x0ff;
		return QColor(r, g, b, alpha * 255);
	}

	IntType GraphicsApiHandler::QColorToInt(const QColor& color)
	{
		return ((color.blue() & 0x0ff) << 16) | ((color.green() & 0x0ff) << 8) | (color.red() & 0x0ff);
	}
}