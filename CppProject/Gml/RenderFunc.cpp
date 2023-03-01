#include "Generated/GmlFunc.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/Buffer.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Surface.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Render/GLWidget.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/VertexBufferRenderer.hpp"

namespace CppProject
{
	IntType gpu_get_blendmode()
	{
		if (GFX->blendSrcFactor == bm_src_alpha && GFX->blendDstFactor == bm_one)
			return bm_add;
		if (GFX->blendSrcFactor == bm_zero && GFX->blendDstFactor == bm_inv_src_color)
			return bm_subtract;
		if (GFX->blendSrcFactor == bm_src_alpha && GFX->blendDstFactor == bm_inv_src_color)
			return bm_max;

		return bm_normal;
	}

	IntType gpu_get_cullmode()
	{
		return (GFX->culling ? cull_counterclockwise : cull_noculling);
	}

	BoolType gpu_get_tex_filter()
	{
		return GFX->texFilter;
	}

	IntType gpu_get_tex_mip_bias()
	{
		return GFX->lodBias;
	}

	IntType gpu_get_tex_mip_enable()
	{
		return GFX->mipMap ? mip_on : mip_off;
	}

	BoolType gpu_get_texfilter_ext(IntType sampler)
	{
		return GFX->shader->samplerState[sampler].filter;
	}

	void gpu_set_alphatestenable(BoolType)
	{
		// Do nothing
	}

	void gpu_set_alphatestref(IntType)
	{
		// Do nothing
	}

	void gpu_set_blendenable(BoolType enabled)
	{
		// Blending always enabled
	}

	void gpu_set_blendmode_ext_sepalpha(IntType src, IntType dest, IntType alphasrc, IntType alphadest)
	{
		GFX->SetBlendingFuncs(src, dest, alphasrc, alphadest);
	}

	void gpu_set_blendmode_ext(IntType src, IntType dest)
	{
		gpu_set_blendmode_ext_sepalpha(src, dest, src, dest);
	}

	void gpu_set_blendmode(IntType mode)
	{
		switch (mode)
		{
			case bm_normal: gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_alpha); break;
			case bm_add: gpu_set_blendmode_ext(bm_src_alpha, bm_one); break;
			case bm_subtract: gpu_set_blendmode_ext(bm_zero, bm_inv_src_color); break;
			case bm_max: gpu_set_blendmode_ext(bm_src_alpha, bm_inv_src_color); break;
		}
	}

	void gpu_set_cullmode(IntType mode)
	{
		GFX->SetCulling(mode == cull_counterclockwise);
	}

	void gpu_set_tex_filter(BoolType enabled)
	{
		for (IntType s = 0; s < GFX->shader->numSamplers; s++)
		{
			Shader::SamplerState& state = GFX->shader->samplerState[s];
			if (state.filter == enabled)
				continue;

			GFX->SubmitBatch();
			state.filter = enabled;
			state.changed = true;
		}

		GFX->texFilter = enabled;
	}

	void gpu_set_tex_filter_ext(IntType sampler, BoolType enabled)
	{
		Shader::SamplerState& state = GFX->shader->samplerState[sampler];
		if (state.filter == enabled)
			return;

		GFX->SubmitBatch();
		state.filter = enabled;
		state.changed = true;
	}

	void gpu_set_texrepeat(BoolType enabled)
	{
		IntType enabledInt = enabled ? 1 : 0;
		for (IntType s = 0; s < GFX->shader->numSamplers; s++)
		{
			if (GFX->shader->samplerRepeat[s] == enabledInt)
				continue;

			GFX->SubmitBatch();
			GFX->shader->samplerRepeat[s] = enabledInt;
		}

		GFX->texRepeat = enabled;
	}

	void gpu_set_texrepeat_ext(IntType sampler, BoolType enabled)
	{
		IntType enabledInt = enabled ? 1 : 0;
		if (GFX->shader->samplerRepeat[sampler] == enabledInt)
			return;

		GFX->SubmitBatch();
		GFX->shader->samplerRepeat[sampler] = enabledInt;
	}

	void gpu_set_tex_max_mip(IntType maxmip)
	{
		// Do nothing
	}

	void gpu_set_tex_mip_bias(IntType bias)
	{
		GFX->SetLODBias(bias);

		for (IntType s = 0; s < GFX->shader->numSamplers; s++)
			GFX->shader->samplerState[s].changed = true;
	}

	void gpu_set_tex_mip_enable(IntType mode)
	{
		BoolType enabled = (mode == mip_on);
		if (GFX->mipMap == enabled)
			return;

		GFX->SubmitBatch();
		GFX->mipMap = enabled;

		for (IntType s = 0; s < GFX->shader->numSamplers; s++)
			GFX->shader->samplerState[s].changed = true;
	}

	void gpu_set_tex_mip_filter_ext(IntType sampler, IntType filter)
	{
		// Always linear
	}

	void gpu_set_tex_mip_filter(IntType filter)
	{
		// Always linear
	}

	void gpu_set_tex_repeat(BoolType enabled)
	{
		gpu_set_texrepeat(enabled);
	}

	void gpu_set_texfilter_ext(IntType sampler, BoolType enabled)
	{
		gpu_set_tex_filter_ext(sampler, enabled);
	}

	void gpu_set_texfilter(BoolType enabled)
	{
		return gpu_set_tex_filter(enabled);
	}

	void gpu_set_ztestenable(BoolType enabled)
	{
		GFX->SetDepthTest(enabled);
	}

	void gpu_set_zwriteenable(BoolType enabled)
	{
		GFX->SetDepthWrite(enabled);
	}

	MatrixType matrix_build_lookat(RealType xfrom, RealType yfrom, RealType zfrom, RealType xto, RealType yto, RealType zto, RealType xup, RealType yup, RealType zup)
	{
		return Matrix::LookAt(
			{ xfrom, yfrom, zfrom },
			{ xto, yto, zto },
			{ xup, yup, zup }
		);
	}

	MatrixType matrix_build_projection_ortho(RealType width, RealType height, RealType znear, RealType zfar)
	{
		return Matrix::Ortho(0, width, 0, height, znear, zfar);
	}

	MatrixType matrix_build_projection_perspective_fov(RealType fov, RealType aspect, RealType znear, RealType zfar)
	{
		return Matrix::Perspective(fov, aspect, znear, zfar);
	}

	MatrixType matrix_build(RealType posX, RealType posY, RealType posZ, RealType rotX, RealType rotY, RealType rotZ, RealType scaleX, RealType scaleY, RealType scaleZ)
	{
		BoolType noPos = (posX == 0.0 && posY == 0.0 && posZ == 0.0);
		BoolType noRot = (rotX == 0.0 && rotY == 0.0 && rotZ == 0.0);
		BoolType noScale = (scaleX == 1.0 && scaleY == 1.0 && scaleZ == 1.0);

		if (noPos && noRot && noScale)
			return Matrix::Identity();

		if (!noPos && noRot && noScale)
			return Matrix::Translation(posX, posY, posZ);

		if (noPos && noRot && !noScale)
			return Matrix::Scale(scaleX, scaleY, scaleZ);

		if (noPos && !noRot && noScale)
			return Matrix::Rotation(rotX, rotY, rotZ).GetTransposed();

		return (Matrix::Scale(scaleX, scaleY, scaleZ) *
			   Matrix::Rotation(rotX, rotY, rotZ)).GetTransposed() *
			   Matrix::Translation(posX, posY, posZ);
	}

	MatrixType matrix_get(IntType type)
	{
		switch (type)
		{
			case matrix_world: return GFX->matrixM;
			case matrix_view: return GFX->matrixV;
			case matrix_projection: return GFX->matrixP;
		}
		return MatrixType();
	}

	MatrixType matrix_multiply(MatrixType m1, MatrixType m2)
	{
		return m1.matrix * m2.matrix;
	}

	void matrix_set(IntType type, MatrixType mat)
	{
		if (type == matrix_projection)
		{
			// Flip 2nd column
			mat.matrix.m[1] *= -1;
			mat.matrix.m[5] *= -1;
			mat.matrix.m[9] *= -1;
			mat.matrix.m[13] *= -1;
		}
		GFX->SetMatrix(type, mat.matrix);
	}

	VecType matrix_transform_vertex(MatrixType m, RealType x, RealType y, RealType z)
	{
		return m.matrix * VecType(x, y, z);
	}

	IntType shader_get_sampler_index(IntType id, StringType name)
	{
		if (Shader* shader = FindShader(id))
			return shader->GetSamplerIndex(name);
		return -1;
	}

	IntType shader_get_uniform(IntType id, StringType name)
	{
		if (Shader* shader = FindShader(id))
			return shader->GetUniformIndex(name);
		return -1;
	}

	BoolType shader_is_compiled(IntType id)
	{
		if (Shader* shader = FindShader(id))
			return shader->IsLoaded();
		return false;
	}

	void shader_reset()
	{
		if (GFX->shader == PR->GetShader())
			WARNING("shader_reset on default shader");

		GFX->SubmitBatch();
		GFX->shader->EndUse();
		GFX->shader = PR->GetShader();
		GFX->shader->BeginUse();
	}

	void shader_set_uniform_f_array(IntType handle, VarType arr)
	{
		// Unused
	}

	void shader_set_uniform_f(VarType args)
	{
		// Unused
	}

	void shader_set_uniform_i_array(IntType, ArrType)
	{
		// Unused
	}

	void shader_set_uniform_i(VarType args)
	{
		// Unused
	}

	void shader_set(IntType id)
	{
		if (Shader* shader = FindShader(id))
		{
			GFX->SubmitBatch();
			GFX->shader->EndUse();
			GFX->shader = shader;
			GFX->shader->BeginUse();

			// Update shader with latest matrices
			GFX->shader->SubmitMatrix(Shader::M, GFX->matrixM);
			GFX->shader->SubmitMatrix(Shader::V, GFX->matrixV);
			GFX->shader->SubmitMatrix(Shader::P, GFX->matrixP);
		}
	}

	BoolType shaders_are_supported()
	{
		return true;
	}

	void surface_copy(IntType dest, IntType x, IntType y, IntType src)
	{
		surface_set_target(dest);
		draw_clear_alpha(0, 0);
		draw_surface(src, x, y);
		surface_reset_target();
	}

	IntType surface_create(IntType width, IntType height)
	{
		return (new Surface({ (int)width, (int)height }))->id;
	}

	IntType surface_create_ext2(IntType width, IntType height, BoolType depthBuffer, BoolType hdr)
	{
		return (new Surface({ (int)width, (int)height }, depthBuffer, hdr))->id;
	}

	BoolType surface_exists(IntType id)
	{
		return (FindSurface(id) != nullptr);
	}

	void surface_free(IntType id)
	{
		if (Surface* surf = FindSurface(id))
		{
			GFX->SubmitBatch();
			delete surf;
		}
	}

	IntType surface_get_height(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			return surf->size.height();
		return -1;
	}

	IntType surface_get_texture(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			return surf->frameBuffer->GetColorTexId();
		return -1;
	}

	IntType surface_get_width(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			return surf->size.width();
		return -1;
	}

	IntType surface_getpixel(IntType id, IntType x, IntType y)
	{
		if (Surface* surf = FindSurface(id))
		{
			GFX->SubmitBatch();
			return GFX->QColorToInt(surf->GetColor(QPoint(x, y), false));
		}
		return -1;
	}

	void surface_clear_depth_cache(IntType id)
	{
		if (Surface* surf = FindSurface(id))
			surf->ClearDepthCache();
	}

	RealType surface_get_depth(IntType id, IntType x, IntType y)
	{
		if (Surface* surf = FindSurface(id))
			return surf->GetDepth(QPoint(x, y));
		return 0.0;
	}

	IntType surface_get_max_size()
	{
		return GFX->GetMaxSize();
	}

	void surface_reset_target()
	{
		if (GFX->surface == AppWin->GetSurface())
		{
			WARNING("Invalid surface_reset_target");
			return;
		}

		GFX->SubmitBatch();
		GFX->ResetMRT();
		GFX->surface->EndUse();
		GFX->surface = AppWin->GetSurface();
		GFX->surface->BeginUse();
	}

	void surface_resize(IntType id, IntType width, IntType height)
	{
		if (Surface* surf = FindSurface(id))
			surf->Resize({ (int)width, (int)height });
	}

	void surface_save(IntType id, StringType filename)
	{
		if (Surface* surf = FindSurface(id))
		{
			GFX->SubmitBatch();
			surf->ToImage().save(filename);
		}
	}

	IntType surface_set_target_ext(IntType index, IntType id)
	{
		if (index == 0)
			surface_set_target(id);
		
		if (Surface* surf = FindSurface(id))
		{
			GFX->SetMRTIndex(index, surf->frameBuffer);
			return 1;
		}

		return -1;
	}

	IntType surface_set_target(IntType id)
	{
		if (Surface* surf = FindSurface(id))
		{
			GFX->SubmitBatch();
			GFX->ClipEnd();
			GFX->ResetMRT();
			GFX->surface->EndUse();
			GFX->surface = surf;
			if (GFX->surface->BeginUse())
				return 1;
		}
		WARNING("surface_set_target failed for id " + NumStr(id));
		return -1;
	}

	void texture_set_stage(IntType stage, IntType tex)
	{
		if (tex > 0 && GFX->shader->IsLoaded())
			GFX->shader->SubmitTexture(stage, tex);
	}

	void vertex_begin(IntType buffer, IntType format)
	{
		// Do nothing
	}

	void vertex_color(IntType buffer, IntType color, RealType alpha)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
			buf->GetCurrentVertex(2).SetColor(color, alpha);
	}

	IntType vertex_create_buffer()
	{
		return (new VertexBuffer)->id;
	}

	IntType vertex_create_buffer_from_buffer(IntType, IntType)
	{
		// Unused
		return 0;
	}

	void vertex_delete_buffer(IntType id)
	{
		if (VertexBuffer* buffer = FindVertexBuffer(id))
			delete buffer;
	}

	void vertex_end(IntType buffer)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
			buf->Complete();
	}

	void vertex_float3(IntType buffer, RealType x, RealType y, RealType z)
	{
		// Do nothing
	}

	void vertex_float4(IntType buffer, RealType x, RealType y, RealType z, RealType w)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
		{
			Vertex& vertex = buf->GetCurrentVertex(4);
			if (x > 0.0)
				vertex.EnableFlag(Vertex::WAVE_XY);
			if (y > 0.0)
				vertex.EnableFlag(Vertex::WAVE_Z);
			vertex.SetEmissive(z);
			if (w > 0.0)
				vertex.EnableFlag(Vertex::SUBSURFACE);
		}
	}

	void vertex_format_add_colour()
	{
		// Do nothing
	}

	void vertex_format_add_custom(IntType type, IntType usage)
	{
		// Do nothing
	}

	void vertex_format_add_normal()
	{
		// Do nothing
	}

	void vertex_format_add_position_3d()
	{
		// Do nothing
	}

	void vertex_format_add_texcoord()
	{
		// Do nothing
	}

	void vertex_format_begin()
	{
		// Do nothing
	}

	IntType vertex_format_end()
	{
		// Do nothing
		return 0;
	}

	void vertex_freeze(IntType buffer)
	{
		// Do nothing
	}

	IntType vertex_get_number(IntType buffer)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
			return buf->numIndices;
		return 0;
	}

	void vertex_normal(IntType buffer, RealType nx, RealType ny, RealType nz)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
			buf->GetCurrentVertex(1).SetNormal(nx, ny, nz);
	}

	void vertex_position_3d(IntType buffer, RealType x, RealType y, RealType z)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
		{
			Vertex& vertex = buf->GetCurrentVertex(0);
			vertex.x = x;
			vertex.y = y;
			vertex.z = z;
		}
	}

	void vertex_submit(IntType buffer, IntType primitive, IntType texture)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
			VB->Add(buf);
	}

	void vertex_texcoord(IntType buffer, RealType u, RealType v)
	{
		if (VertexBuffer* buf = FindVertexBuffer(buffer))
		{
			Vertex& vertex = buf->GetCurrentVertex(3);
			vertex.u = u;
			vertex.v = v;
		}
	}

	IntType get_vertex_buffer_triangles()
	{
		IntType num = VB->trianglesSubmitted;
		VB->trianglesSubmitted = 0;
		return num;
	}

	IntType get_vertex_buffer_render_calls()
	{
		IntType num = VB->renderCalls;
		VB->renderCalls = 0;
		return num;
	}

	IntType get_primitive_lines()
	{
		IntType num = PR->linesSubmitted;
		PR->linesSubmitted = 0;
		return num;
	}

	IntType get_primitive_triangles()
	{
		IntType num = PR->trianglesSubmitted;
		PR->trianglesSubmitted = 0;
		return num;
	}

	IntType get_primitive_render_calls()
	{
		IntType num = PR->renderCalls;
		PR->renderCalls = 0;
		return num;
	}

	void vertex_buffer_set_save_data(IntType id, BoolType save)
	{
		if (VertexBuffer* buf = FindVertexBuffer(id))
			buf->saveData = save;
	}

	void submit_batch()
	{
		GFX->SubmitBatch();
	}

	void shader_submit_int(IntType index, IntType value)
	{
		GFX->shader->SubmitInt(index, value);
	}

	void shader_submit_float(IntType index, RealType value)
	{
		GFX->shader->SubmitFloat(index, value);
	}

	void shader_submit_vec2(IntType index, RealType x, RealType y)
	{
		GFX->shader->SubmitVec2(index, x, y);
	}

	void shader_submit_vec3(IntType index, RealType x, RealType y, RealType z)
	{
		GFX->shader->SubmitVec3(index, x, y, z);
	}

	void shader_submit_vec4(IntType index, RealType x, RealType y, RealType z, RealType w)
	{
		GFX->shader->SubmitVec4(index, x, y, z, w);
	}

	void shader_submit_float_array(IntType index, VarType array)
	{
		GFX->shader->SubmitFloatArray(index, array);
	}

	void shader_submit_mat4_array(IntType index, ArrType array)
	{
		GFX->shader->SubmitMat4Array(index, array);
	}

	void update_frustum()
	{
		GFX->UpdateFrustum();
	}
}