#include "Generated/Scripts.hpp"
#include <QSet>

namespace CppProject
{
	void tl_update_ik(VarType parts)
	{
		if (!parts.IsArray() || !parts.Arr().Size())
			return;
		const ArrType& ids = parts.Arr();
		for (int pass = 0; pass < 2; pass++)
		{
			for (IntType i = 0; i < ids.Size(); i++)
			{
				obj_timeline* timeline = ObjTypeOpt(obj_timeline, ids.IntValue(i));
				if (!timeline)
					continue;
				if (timeline->value.Arr().ValueRef(e_value_IK_TARGET) == null_ &&
					!(global::debug_show_bones && timeline->selected) && timeline->ik_target_prev == null_ &&
					!timeline->part_joints_matrix.Size() && !timeline->part_joints_pos.Size() && !timeline->part_joints_bone_matrix.Size())
					continue;
				tl_update_ik_calculate(Scope<obj_timeline>(timeline));
			}

			QSet<IntType> pending;
			for (IntType i = 0; i < ids.Size(); i++)
				if (obj_timeline* timeline = ObjTypeOpt(obj_timeline, ids.IntValue(i)))
					if (timeline->update_matrix)
						pending.insert(timeline->id);
			if (pending.isEmpty())
				break;

			// Start at the earliest pending part so parents precede children regardless of creation order
			const List& timelines = DsList(global::_app->project_timeline_list);
			for (IntType i = 0; i < timelines.vec.size(); i++)
			{
				IntType id = timelines.Value(i).ToInt();
				if (pending.contains(id))
				{
					tl_update_matrix(ScopeAny(id), false, false);
					break;
				}
			}
		}
	}

	static bool SameTransformVector(const VecType& a, const VecType& b)
	{
		return a.x == b.x && a.y == b.y && a.z == b.z;
	}

	VecType tl_update_transform(Scope<obj_timeline> self, BoolType usepaths, BoolType updatepose, BoolType hasik)
	{
		// Keep intermediate transforms native and resolve objects only within their valid scope
		auto& values = self->value;
		MatrixType& parentMatrix = self->matrix_parent;
		if (self->parent != global::_app->id)
		{
			obj_timeline* parent = ObjType(obj_timeline, self->parent);
			if (self->inherit_rot_point > 0)
				parentMatrix = parent->matrix_render;
			else
				parentMatrix = parent->matrix.ToMat();

			if (parent->type == e_tl_type_MODEL_PART && self->lock_bend > 0 && parent->model_part != null_)
			{
				obj_model_part* part = ObjType(obj_model_part, parent->model_part);
				if (part->bend_part != null_)
				{
					VecType bend(parent->value_inherit.Value(e_value_BEND_ANGLE_X),
								 parent->value_inherit.Value(e_value_BEND_ANGLE_Y),
								 parent->value_inherit.Value(e_value_BEND_ANGLE_Z));
					parentMatrix = matrix_multiply(model_part_get_bend_matrix(self, part->id, bend, point3D(0.0)), parentMatrix);
				}
			}
		}
		else
			parentMatrix = MAT_IDENTITY;

		if (usepaths)
		{
			VarType pathId = values.Value(e_value_PATH_OBJ);
			if (pathId != null_)
			{
				obj_timeline* path = ObjType(obj_timeline, pathId);
				if (path->path_table.Size() > 0)
				{
					RealType offset = values.Value(e_value_PATH_OFFSET);
					ArrType curpos = tl_path_offset_get_position(pathId, offset);
					VecType normal = vec3_normalize(VecType(curpos.Value(PATH_NORMAL_X), curpos.Value(PATH_NORMAL_Y), curpos.Value(PATH_NORMAL_Z)));
					VecType tangent = vec3_normalize(VecType(curpos.Value(PATH_TANGENT_X), curpos.Value(PATH_TANGENT_Y), curpos.Value(PATH_TANGENT_Z)));
					MatrixType mat = matrix_create_rotate_to(tangent, normal);

					// Use the sampled tangent before clamping open-path positions, as in GML
					if (!(path->path_closed > 0))
					{
						if (offset <= 0.0)
							curpos = tl_path_offset_get_position(pathId, 0.0);
						else if (offset >= path->path_length)
							curpos = tl_path_offset_get_position(pathId, path->path_length);
					}

					mat = matrix_multiply(mat, matrix_create(curpos, vec3(0.0), vec3(1.0)));
					parentMatrix = matrix_multiply(parentMatrix, mat);
					if (path->matrix.IsContainer())
						parentMatrix = matrix_multiply(parentMatrix, path->matrix.ToMat());
				}
			}
		}

		if (self->type == e_tl_type_MODEL_PART && self->model_part != null_)
		{
			obj_model_part* part = ObjType(obj_model_part, self->model_part);
			VecType position = self->part_of != null_ ? part->position.ToVec() : point3D(0.0);
			VecType rotation = part->rotation.ToVec();
			if (!self->transform_part_cache_valid || self->transform_part_cache_id != self->model_part ||
				!SameTransformVector(position, self->transform_part_cache_pos) || !SameTransformVector(rotation, self->transform_part_cache_rot))
			{
				self->transform_part_cache_matrix = matrix_create(position, rotation, vec3(1.0));
				self->transform_part_cache_pos = position;
				self->transform_part_cache_rot = rotation;
				self->transform_part_cache_id = self->model_part;
				self->transform_part_cache_valid = true;
			}
			parentMatrix = matrix_multiply(self->transform_part_cache_matrix, parentMatrix);
		}

		VecType pos(values.Value(e_value_POS_X), values.Value(e_value_POS_Y), values.Value(e_value_POS_Z));
		VecType rot(values.Value(e_value_ROT_X), values.Value(e_value_ROT_Y), values.Value(e_value_ROT_Z));
		VecType sca(values.Value(e_value_SCA_X), values.Value(e_value_SCA_Y), values.Value(e_value_SCA_Z));
		if (!self->transform_local_cache_valid || !SameTransformVector(pos, self->transform_local_pos) ||
			!SameTransformVector(rot, self->transform_local_rot) || !SameTransformVector(sca, self->transform_local_scale))
		{
			self->matrix_local = matrix_create(pos, rot, sca);
			self->transform_local_pos = pos;
			self->transform_local_rot = rot;
			self->transform_local_scale = sca;
			self->transform_local_cache_valid = true;
		}
		MatrixType transform = matrix_multiply(self->matrix_local, parentMatrix);

		if (!(self->inherit_rotation > 0))
		{
			matrix_remove_rotation(transform);
			transform = matrix_multiply(matrix_create(point3D(0.0), rot, vec3(1.0)), transform);
		}

		self->matrix_parent_pre_ik = transform;
		if (hasik)
			transform = matrix_multiply(self->part_joints_matrix.ValueRef(0).ToMat(), transform);

		VecType posebend(0.0, 0.0, 0.0);
		if (updatepose && self->part_of != null_)
		{
			obj_timeline* model = ObjType(obj_timeline, self->part_of);
			if (model->inherit_pose > 0 && model->parent != global::_app->id)
			{
				VarType poseId = tl_part_find(ScopeAny(model->parent, self->id), self->model_part_name);
				if (poseId != null_)
				{
					obj_timeline* pose = ObjType(obj_timeline, poseId);
					transform = matrix_multiply(pose->matrix_local, transform);
					for (IntType j = X_; j <= Z_; j++)
						posebend.Real(j) = pose->value_inherit.Value(e_value_BEND_ANGLE_X + j);
					if (pose->part_joints_matrix.Size() > 0 && pose->value.Value(e_value_IK_TARGET) != null_)
						transform = matrix_multiply(pose->part_joints_matrix.ValueRef(0).ToMat(), transform);
				}
			}
		}

		if (self->scale_resize > 0 || !(self->inherit_scale > 0) || self->type == e_tl_type_PARTICLE_SPAWNER)
		{
			obj_timeline* timeline = self.object;
			while (true)
			{
				if (!(timeline->inherit_scale > 0) || timeline->parent == global::_app->id)
					break;
				obj_timeline* parent = ObjType(obj_timeline, timeline->parent);
				sca = vec3_mul(sca, VecType(parent->value.Value(e_value_SCA_X), parent->value.Value(e_value_SCA_Y), parent->value.Value(e_value_SCA_Z)));
				timeline = parent;
			}

			matrix_remove_scale(parentMatrix);
			MatrixType parmat = parentMatrix;
			if (!(self->inherit_rotation > 0))
				matrix_remove_rotation(parmat);
			MatrixType matrixnoscale = matrix_multiply(matrix_create(pos, rot, vec3(1.0)), parmat);
			if (hasik)
				matrixnoscale = matrix_multiply(self->part_joints_matrix.ValueRef(0).ToMat(), matrixnoscale);

			// Preserve the original partial replacement and multiplication order
			for (IntType p = 0; p < 11; p++)
				transform.matrix.m[p] = matrixnoscale.matrix.m[p];
			if (self->inherit_scale > 0)
				transform = matrix_multiply(matrix_create(point3D(0.0), vec3(0.0), sca), transform);
			else
				transform = matrix_multiply(matrix_create(point3D(0.0), vec3(0.0), VecType(values.Value(e_value_SCA_X), values.Value(e_value_SCA_Y), values.Value(e_value_SCA_Z))), transform);
		}

		if (!(self->inherit_position > 0))
		{
			matrix_remove_rotation(parentMatrix);
			transform.matrix.m[MAT_X] = values.Value(e_value_POS_X);
			transform.matrix.m[MAT_Y] = values.Value(e_value_POS_Y);
			transform.matrix.m[MAT_Z] = values.Value(e_value_POS_Z);
		}

		if (self->type == e_tl_type_CAMERA && values.Value(e_value_CAM_ROTATE) > 0)
		{
			self->world_pos_rotate = matrix_position(transform);
			transform.matrix.m[MAT_X] += lengthdir_x(values.Value(e_value_CAM_ROTATE_DISTANCE), values.Value(e_value_CAM_ROTATE_ANGLE_XY) + 90) * lengthdir_x(1.0, values.Value(e_value_CAM_ROTATE_ANGLE_Z));
			transform.matrix.m[MAT_Y] += lengthdir_y(values.Value(e_value_CAM_ROTATE_DISTANCE), values.Value(e_value_CAM_ROTATE_ANGLE_XY) + 90) * lengthdir_x(1.0, values.Value(e_value_CAM_ROTATE_ANGLE_Z));
			transform.matrix.m[MAT_Z] += lengthdir_z(values.Value(e_value_CAM_ROTATE_DISTANCE), values.Value(e_value_CAM_ROTATE_ANGLE_Z));
		}

		self->world_pos = matrix_position(transform);
		self->matrix = transform;
		self->matrix_render = matrix_multiply(matrix_create(point3D_mul(self->rot_point_render, -1.0), vec3(0.0), vec3(1.0)), transform);
		return posebend;
	}
}
