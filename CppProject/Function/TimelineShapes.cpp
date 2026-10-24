#include "Generated/Scripts.hpp"

namespace CppProject
{
	RealType tl_update_model_shape_render(Scope<obj_timeline> self, BoolType refreshinfo)
	{
		if (self->model_part == null_)
			return 0;
		obj_model_part* part = ObjType(obj_model_part, self->model_part);
		if (part->shape_list == null_)
			return 0;

		const List& shapes = DsList(part->shape_list);
		IntType count = shapes.vec.size();
		ArrType& matrices = self->model_part_shape_render_matrix;
		ArrType& buffers = self->model_part_shape_vbuffer;
		ArrType& hidden = self->model_part_shape_hidden;
		bool rebuild = self->model_part_shape_cache_part != self->model_part ||
			matrices.Size() != count || buffers.Size() != count || hidden.Size() != count;
		bool updateMatrices = rebuild || self->model_part_shape_render_matrix_part != self->model_part;
		bool updateInfo = rebuild || refreshinfo || self->model_part_shape_data_dirty;
		if (rebuild)
		{
			matrices = ArrType();
			buffers = ArrType();
			hidden = ArrType();
			self->model_part_shape_cache_part = self->model_part;
		}
		if (!updateMatrices && !updateInfo)
			return 0;

		// Resolve metadata containers once and only when their contents need refreshing
		bool readInfo = updateInfo && count > 0;
		Map* bufferMap = readInfo && self->model_shape_vbuffer_map != null_ ? &DsMap(self->model_shape_vbuffer_map) : nullptr;
		IntType hideList = readInfo ? idInt(self->temp, model_shape_hide_list) : null_;
		const List* hiddenShapes = hideList != null_ ? &DsList(hideList) : nullptr;
		const MatrixType& world = self->matrix_render;
		for (IntType s = 0; s < count; s++)
		{
			const VarType& shapeId = shapes.Value(s);
			obj_model_shape* shape = ObjType(obj_model_shape, shapeId);
			if (updateInfo)
			{
				VarType buffer = bufferMap ? bufferMap->Value(shapeId) : VarType(null_);
				buffers[s] = buffer.IsUndefined() ? VarType(null_) : buffer;
				bool isHidden = false;
				if (hiddenShapes)
					for (IntType h = 0; h < hiddenShapes->vec.size(); h++)
						if (hiddenShapes->Value(h) == shape->description)
						{
							isHidden = true;
							break;
						}
				hidden[s] = isHidden;
			}
			if (updateMatrices)
			{
				if (shape->item_bounce > 0 || shape->face_camera > 0)
					matrices[s] = null_;
				else
					matrices[s] = matrix_multiply(shape->matrix.ToMat(), world);
			}
		}
		self->model_part_shape_render_matrix_part = self->model_part;
		self->model_part_shape_data_dirty = false;
		return 0;
	}
}
