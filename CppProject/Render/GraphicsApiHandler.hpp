#pragma once

#include "Common.hpp"
#include "Type/VecType.hpp"
#include "Matrix.hpp"
#include "Bounds.hpp"

#define GFX GraphicsApiHandler::handler

#if API_OPENGL
#include <QOpenGLFunctions_3_1>
#include <QOffscreenSurface>

#if DEBUG_MODE
#define GL_CHECK_ERROR() GFX->CheckGLError(__FUNCTION__, __LINE__)
#else
#define GL_CHECK_ERROR() false
#endif
#else
#include <windows.h>
#include <d3d11.h>
#if DEBUG_MODE
#include <d3dcompiler.h>
#endif
#undef max
#undef min

#define D3DDevice GFX->d3dDevice
#define D3DContext GFX->d3dContext
#define DXGIFactory GFX->dxgiFactory
#define D3DCheckError(hResult) GFX->CheckD3DError(hResult, __FUNCTION__, __LINE__)
#endif

namespace CppProject
{
	struct Shader;
	struct Surface;
	struct FrameBuffer;

	struct GraphicsApiHandler
	#if API_OPENGL
		: QOpenGLFunctions_3_1
	#endif
	{
		// Runs before QApp creation.
		GraphicsApiHandler();

		// Initialize graphics API and load application resources, runs after QApp creation.
		void Init();

		// Sets a world/view/projection matrix
		void SetMatrix(IntType type, Matrix matrix);

		// Update frustum points from view * projection matrix.
		void UpdateFrustum();

		// Returns whether the given bounding box in world space is visible.
		BoolType IsVisible(const Bounds& worldBounds) const;

		// Submits the last batch of primitives/vertices to the GPU.
		void SubmitBatch();

		// Returns the maximum width/height of an image or framebuffer.
		IntType GetMaxSize();

	#if API_D3D11
		// Returns whether a Direct3D error has occurred.
		BoolType CheckD3DError(HRESULT result, QString func, IntType line);
	#else
		// Returns whether an OpenGL error has occurred.
		BoolType CheckGLError(QString func, IntType line);
	#endif

		// Starts rendering off-screen, returns whether successful.
		BoolType StartOffScreenRender();

		// Starts using a clipping rectangle.
		void ClipBegin(QRect rect);

		// Stops using a clipping rectangle.
		void ClipEnd();

		// Sets a framebuffer as render target at an index.
		void SetMRTIndex(IntType index, FrameBuffer* frameBuffer);

		// Resets the bound MRTs.
		void ResetMRT();

		// Clears the color buffer.
		void ClearColor(QColor color);

		// Clears the depth buffer.
		void ClearDepth();

		// Sets whether backface culling is enabled.
		void SetCulling(BoolType enabled);

		// Sets whether front faces are culled rather than back faces.
		void SetCullFrontFace(BoolType enabled);

		// Sets whether depth testing is enabled.
		void SetDepthTest(BoolType enabled);

		// Sets whether depth writing is enabled.
		void SetDepthWrite(BoolType enabled);

		// Sets the blending functions.
		void SetBlendingFuncs(IntType src, IntType dest, IntType alphasrc, IntType alphadest);

		// Set bias level for mipmapping.
		void SetLODBias(IntType value);

		// Converts an integer to a QColor
		static QColor IntToQColor(IntType in, RealType alpha = 1.0);

		// Convers a QColor to an integer.
		static IntType QColorToInt(const QColor& col);

		// Assets
		Shader* shader = nullptr;
		Surface* surface = nullptr;
		BoolType clipEnabled = false;
		QRect clipRect;

		// Matrix
		Matrix matrixM, matrixV, matrixP, matrixVP;
		Matrix frustumV, frustumP;
		VecType frustum[6];
		BoolType frustumUpdate = true;

		// Current GPU settings
		BoolType depthMask = false;
		BoolType depthTest = false;
		BoolType culling = false;
		BoolType cullFront = false;
		BoolType blend = false;
		IntType blendSrcFactor = 0;
		IntType blendDstFactor = 0;
		IntType blendAlphaSrcFactor = 0;
		IntType blendAlphaDstFactor = 0;
		BoolType texFilter = false;
		BoolType texRepeat = true;
		IntType lodBias = 0;
		BoolType mipMap = true;

	#if API_D3D11
		ID3D11Device* d3dDevice = nullptr;
		ID3D11DeviceContext* d3dContext = nullptr;
		QHash<D3D11_FILTER, ID3D11SamplerState*> d3dSamplerStateMap;
		QHash<D3D11_CULL_MODE, ID3D11RasterizerState*> d3dRasterizerStateMap;
		enum DepthStencilState
		{
			DEPTH_TEST_WRITE,
			DEPTH_TEST_NO_WRITE,
			DEPTH_NO_TEST_NO_WRITE,
			STENCIL_WRITE,
			STENCIL_TEST
		};
		QHash<DepthStencilState, ID3D11DepthStencilState*> d3dDepthStencilStateMap;

		struct BlendState
		{
			IntType src, dst, srcAlpha, dstAlpha;
			ID3D11BlendState* state = nullptr;
		};
		QVector<BlendState> d3dBlendStates;
		IntType d3dBlendStateIndex = -1;
		ID3D11BlendState* d3dNoBlendState = nullptr;
		ID3D11BlendState* d3dNoColorState = nullptr;
		QHash<IntType, D3D11_BLEND> d3dBlendColorMap;
		QHash<IntType, D3D11_BLEND> d3dBlendAlphaMap;
		IDXGIFactory* dxgiFactory = nullptr;
		QVector<ID3D11RenderTargetView*> d3dMrtRTVs;
		ID3D11DepthStencilView* d3dMrtDSV = nullptr;
	#else
		QOpenGLContext* glContext = nullptr;
		QOffscreenSurface* glOffScreenSurface = nullptr;
		GLuint glCurrentVboId = 0;
		QString glVersion = "";
		QHash<IntType, IntType> glBlendMap;
		IntType glMrtCount = 0;
	#endif

		static GraphicsApiHandler* handler;
	};
}