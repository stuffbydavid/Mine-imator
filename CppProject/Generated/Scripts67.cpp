/*
	NOTE:
	This file was autogenerated by CppGen, changes may be overwritten and forever lost!
	Modify at your own risk!
	
	[ Generated on 2023.08.26 14:40:23 ]
*/

#include "Scripts.hpp"

namespace CppProject
{
	void tl_event_destroy(ScopeAny self)
	{
		if (!sBool(delete_ready))
			tl_remove_clean(self);
	}
	
	void tl_filter_draw(ScopeAny self)
	{
		draw_set_font(sInt(font_label));
		IntType switchwid;
		RealType colorwid;
		VarType px;
		switchwid = text_max_width({ /*"timelinehideghosts"*/ STR(3841) }) + IntType(16) + IntType(24);
		colorwid = max({ text_max_width({ /*"timelinefiltertags"*/ STR(3842) }), (IntType(24) * IntType(9)) - IntType(4) });
		draw_label(self, { text_get({ /*"timelinefiltertags"*/ STR(3842) }), sVar(dx), sVar(dy) + IntType(9), fa_left, fa_middle, global::c_text_secondary, global::a_text_secondary, sInt(font_label) });
		sVar(dy) += IntType(20);
		tab_control(self, IntType(20));
		for (IntType i = IntType(0); i <= IntType(8); i++)
		{
			px = sVar(dx) + (IntType(24) * i);
			draw_box(px, sVar(dy), IntType(20), IntType(20), false, ObjType(obj_theme, sInt(setting_theme))->accent_list.Value(i), IntType(1));
			microani_set(/*"hidecolortag"*/ STR(3843) + string(i), null_, false, false, sVar(timeline_hide_color_tag).Value(i));
			microani_update({ false, false, sVar(timeline_hide_color_tag).Value(i) });
			if (sVar(timeline_hide_color_tag).Value(i) > 0)
			{
				draw_box(px, sVar(dy), IntType(20), IntType(20), false, global::c_text_tertiary, global::a_text_tertiary * global::microani_arr.Value(e_microani_ACTIVE));
				draw_image({ ID_spr_icons, icons_CLOSE_SMALL, px + IntType(10), sVar(dy) + IntType(10), IntType(1), IntType(1), global::c_level_middle, global::microani_arr.Value(e_microani_ACTIVE) });
			}
			if (app_mouse_box(self, px, sVar(dy), IntType(20), IntType(20)))
			{
				sInt(mouse_cursor) = cr_handpoint;
				if (sBool(mouse_left_pressed))
				{
					sVar(timeline_hide_color_tag)[i] = !(sVar(timeline_hide_color_tag).Value(i) > 0);
					tl_update_list(self);
				}
			}
		}
		tab_next(self);
		tab_control_switch(self);
		draw_switch(self, /*"timelinehideghosts"*/ STR(3841), sVar(dx), sVar(dy), sVar(setting_timeline_hide_ghosts), ID_action_setting_timeline_hide_ghosts, /*"timelinehideghoststip"*/ STR(3844));
		tab_next(self);
		sVar(settings_menu_w) = max({ switchwid, colorwid }) + IntType(24);
	}
	
	void tl_find_save_ids(Scope<obj_timeline> self)
	{
		self->temp = save_id_find(self->temp);
		self->parent = save_id_find(self->parent);
		self->part_of = save_id_find(self->part_of);
		self->glint_tex = save_id_find(self->glint_tex);
	}
	
	void tl_get_save_ids(Scope<obj_history_save> self)
	{
		self->temp = save_id_get(self->temp);
		self->parent = save_id_get(self->parent);
		self->part_of = save_id_get(self->part_of);
		self->glint_tex = save_id_get(self->glint_tex);
	}
	
	BoolType tl_get_visible(ScopeAny self)
	{
		if (global::render_view_current == null_)
			return true;
		if (!sArr(value_inherit).Value(e_value_VISIBLE) || (sVar(hide) > 0 && !global::render_hidden))
			return false;
		if (global::render_active == /*"image"*/ STR(94))
		{
			if (ObjType(obj_popup, global::_app->popup_exportimage)->high_quality > 0 && sVar(hq_hiding) > 0)
				return false;
			if (!(ObjType(obj_popup, global::_app->popup_exportimage)->high_quality > 0) && sVar(lq_hiding) > 0)
				return false;
		}
		else
			if (global::render_active == /*"movie"*/ STR(1107))
			{
				if (global::_app->exportmovie_high_quality > 0 && sVar(hq_hiding) > 0)
					return false;
				if (!(global::_app->exportmovie_high_quality > 0) && sVar(lq_hiding) > 0)
					return false;
			}
			else
				if (global::render_view_current != null_)
				{
					if (ObjType(obj_view, global::render_view_current)->quality == e_view_mode_RENDER && sVar(hq_hiding) > 0)
						return false;
					if (ObjType(obj_view, global::render_view_current)->quality != e_view_mode_RENDER && sVar(lq_hiding) > 0)
						return false;
				}
		
		
		return true;
	}
	
	BoolType tl_has_child(ScopeAny self, VarType tl)
	{
		if (tl == global::_app->id)
			return false;
		for (IntType i = IntType(0); i < ds_list_size(sInt(tree_list)); i++)
			withOne (Object, DsList(sInt(tree_list)).Value(i), self->id)
				if (self->id == tl || tl_has_child(self, tl))
					return true;
		
		return false;
	}
	
	void tl_interval_settings_draw(ScopeAny self)
	{
		draw_set_font(sInt(font_label));
		tab_control_dragger(self);
		draw_dragger(self, /*"timelineintervalssize"*/ STR(3845), sVar(dx), sVar(dy), dragger_width, sVar(timeline_interval_size), .1, IntType(1), no_limit, sVar(project_tempo), IntType(1), idInt(sVar(timeline), tbx_interval_size), ID_action_tl_interval_size);
		tab_next(self);
		tab_control_dragger(self);
		draw_dragger(self, /*"timelineintervalsoffset"*/ STR(3846), sVar(dx), sVar(dy), dragger_width, sVar(timeline_interval_offset), .1, -no_limit, no_limit, IntType(0), IntType(1), idInt(sVar(timeline), tbx_interval_offset), ID_action_tl_interval_offset);
		tab_next(self);
		sVar(settings_menu_w) = (text_max_width({ /*"timelineintervalssize"*/ STR(3845), /*"timelineintervalsoffset"*/ STR(3846) }) + IntType(16) + dragger_width) + IntType(24);
	}
	
	void tl_jump(VarType tl)
	{
		IntType pos;
		for (pos = IntType(0); pos < ds_list_size(global::_app->tree_visible_list); pos++)
			if (DsList(global::_app->tree_visible_list).Value(pos) == tl)
				break;
		if (pos < global::_app->timeline_list_first || pos >= global::_app->timeline_list_first + global::_app->timeline_list_visible)
		{
			RealType newval = pos - floor(global::_app->timeline_list_visible / 2.0);
			newval = min({ newval, ds_list_size(global::_app->tree_visible_list) - global::_app->timeline_list_visible });
			newval = max({ IntType(0), newval });
			ObjType(obj_scrollbar, idInt(global::_app->timeline, ver_scroll))->value_goal = newval * ObjType(obj_scrollbar, idInt(global::_app->timeline, ver_scroll))->snap_value;
		}
	}
	
	void tl_keyframes_copy(ScopeAny self)
	{
		VarType minpos = null_;
		sInt(copy_kf_amount) = IntType(0);
		withAll (obj_keyframe, self->id)
		{
			if (!(self->selected > 0))
				continue;
			global::_app->copy_kf_tl_save_id[global::_app->copy_kf_amount] = save_id_get(self->timeline);
			global::_app->copy_kf_pos[global::_app->copy_kf_amount] = self->position;
			if (idVar(self->timeline, part_of) != null_)
				global::_app->copy_kf_tl_part_of_save_id[global::_app->copy_kf_amount] = save_id_get(idVar(self->timeline, part_of));
			else
				global::_app->copy_kf_tl_part_of_save_id[global::_app->copy_kf_amount] = save_id_get(self->timeline);
			
			global::_app->copy_kf_tl_model_part_name[global::_app->copy_kf_amount] = idVar(self->timeline, model_part_name);
			for (IntType v = IntType(0); v < e_value_amount; v++)
				global::_app->copy_kf_value[global::_app->copy_kf_amount][v] = tl_value_get_save_id(v, self->value.Value(v));
			if (minpos == null_ || self->position < minpos)
				minpos = self->position;
			global::_app->copy_kf_amount++;
		}
		
		for (IntType k = IntType(0); k < sInt(copy_kf_amount); k++)
			sArr(copy_kf_pos)[k] -= minpos;
	}
	
	void tl_keyframes_deselect_all()
	{
		withAll (obj_timeline, noone)
		{
			self->keyframe_select = null_;
			self->keyframe_select_amount = IntType(0);
		}
		
		withAll (obj_keyframe, noone)
			self->selected = false;
		
	}
	
	void tl_keyframes_paste(ScopeAny self, VarType pos)
	{
		StringType pastemode;
		VarType tllast, tlpaste;
		pastemode = /*"free"*/ STR(3847);
		tlpaste = global::tl_edit;
		tl_keyframes_deselect_all();
		tllast = null_;
		for (IntType k = IntType(0); k < sInt(copy_kf_amount); k++)
		{
			if (tllast != null_ && sArr(copy_kf_tl_save_id).Value(k) != tllast)
			{
				pastemode = /*"fixed"*/ STR(3848);
				break;
			}
			tllast = sArr(copy_kf_tl_save_id).Value(k);
		}
		if (pastemode == /*"fixed"*/ STR(3848))
		{
			pastemode = /*"model"*/ STR(8);
			tllast = null_;
			for (IntType k = IntType(0); k < sInt(copy_kf_amount); k++)
			{
				if (tllast != null_ && sArr(copy_kf_tl_part_of_save_id).Value(k) != tllast)
				{
					pastemode = /*"fixed"*/ STR(3848);
					break;
				}
				tllast = sArr(copy_kf_tl_part_of_save_id).Value(k);
			}
		}
		if (pastemode == /*"free"*/ STR(3847))
		{
			if (global::tl_edit_amount != IntType(1))
				pastemode = /*"fixed"*/ STR(3848);
		}
		else
			if (pastemode == /*"model"*/ STR(8))
			{
				pastemode = /*"fixed"*/ STR(3848);
				withAll (obj_timeline, self->id)
				{
					if (!(self->selected > 0))
						continue;
					if (self->part_of != null_)
					{
						tlpaste = self->part_of;
						pastemode = /*"model"*/ STR(8);
						break;
					}
					if (self->part_list != null_)
					{
						tlpaste = self->id;
						pastemode = /*"model"*/ STR(8);
						break;
					}
				}
				
			}
		
		for (IntType k = IntType(0); k < sInt(copy_kf_amount); k++)
		{
			VarType tladd;
			if (pastemode == /*"fixed"*/ STR(3848))
				tladd = save_id_find(sArr(copy_kf_tl_part_of_save_id).Value(k));
			else
				tladd = tlpaste;
			
			if (tladd == null_)
				continue;
			if (pastemode != /*"free"*/ STR(3847) && idInt(tladd, part_list) != null_ && sArr(copy_kf_tl_model_part_name).Value(k) != /*""*/ STR(0))
			{
				VarType part;
				withOne (Object, tladd, self->id)
					part = tl_part_find(self, global::_app->copy_kf_tl_model_part_name.Value(k));
				
				if (part != null_)
					tladd = part;
				else
					continue;
				
			}
			IntType newkf;
			withOne (Object, tladd, self->id)
				newkf = tl_keyframe_add(self, pos + global::_app->copy_kf_pos.Value(k));
			
			for (IntType v = IntType(0); v < e_value_amount; v++)
				ObjType(obj_keyframe, newkf)->value[v] = tl_value_find_save_id(v, null_, sArr(copy_kf_value)[k][v]);
			tl_keyframe_select(newkf);
		}
	}
	
	void tl_keyframes_remove()
	{
		withAll (obj_keyframe, noone)
			if (self->selected > 0)
				instance_destroy(ScopeAny(self));
		
		withAll (obj_timeline, noone)
		{
			if (!(self->selected > 0) || self->keyframe_select == null_)
				continue;
			tl_deselect(ScopeAny(self));
			self->update_matrix = true;
		}
		
	}
	
	IntType tl_keyframe_add(ScopeAny self, VarType pos, IntType kf)
	{
		IntType i;
		for (i = IntType(0); i < ds_list_size(sInt(keyframe_list)); i++)
		{
			if (ObjType(obj_keyframe, DsList(sInt(keyframe_list)).Value(i))->position == pos)
			{
				while (i < ds_list_size(sInt(keyframe_list)))
				{
					if (ObjType(obj_keyframe, DsList(sInt(keyframe_list)).Value(i))->position != pos)
						break;
					i++;
					pos++;
				}
				
				break;
			}
			if (ObjType(obj_keyframe, DsList(sInt(keyframe_list)).Value(i))->position > pos)
				break;
		}
		global::_app->timeline_length = max({ global::_app->timeline_length, pos });
		if (kf < IntType(0))
		{
			kf = (new obj_keyframe)->id;
			ObjType(obj_keyframe, kf)->selected = false;
			for (IntType v = IntType(0); v < e_value_amount; v++)
				ObjType(obj_keyframe, kf)->value[v] = sVar(value).Value(v);
			if (ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ) != null_)
				idInt(ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ), count)++;
		}
		ObjType(obj_keyframe, kf)->position = pos;
		ObjType(obj_keyframe, kf)->timeline = self->id;
		ObjType(obj_keyframe, kf)->sound_play_index = null_;
		ds_list_insert(sInt(keyframe_list), i, kf);
		sInt(keyframe_next) = sInt(keyframe_current);
		sInt(keyframe_current) = kf;
		return kf;
	}
	
	RealType tl_keyframe_deselect(IntType kf)
	{
		if (!(ObjType(obj_keyframe, kf)->selected > 0))
			return IntType(0);
		ObjType(obj_keyframe, kf)->selected = false;
		withOne (Object, ObjType(obj_keyframe, kf)->timeline, noone)
		{
			sInt(keyframe_select_amount)--;
			if (sVar(keyframe_select) == kf)
			{
				sVar(keyframe_select) = null_;
				withAll (obj_keyframe, self->id)
					if (self->selected > 0 && self->timeline == self.otherId)
						idVar(self.otherId, keyframe_select) = self->id;
				
			}
			if (!(sVar(keyframe_select) > 0))
				tl_deselect(self);
		}
		
		return 0.0;
	}
	
	RealType tl_keyframe_length(IntType kf)
	{
		if (idVar(ObjType(obj_keyframe, kf)->timeline, type) == e_tl_type_AUDIO && ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ) != null_ && idBool(ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ), ready))
			return max({ IntType(0), (ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_PITCH) == IntType(0) ? VarType(0.0) : ((((idReal(ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ), sound_samples) / sample_rate_) / ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_PITCH)) + ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_END) - ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_START)) * global::_app->project_tempo)) });
		return IntType(0);
	}
	
	void tl_keyframe_save(VarType kf)
	{
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_PATH_OBJ) != null_)
			withOne (Object, ObjType(obj_keyframe, kf)->value.Value(e_value_PATH_OBJ), noone)
				tl_save(self);
		
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_ATTRACTOR) != null_)
			withOne (Object, ObjType(obj_keyframe, kf)->value.Value(e_value_ATTRACTOR), noone)
				tl_save(self);
		
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_IK_TARGET) != null_)
			withOne (Object, ObjType(obj_keyframe, kf)->value.Value(e_value_IK_TARGET), noone)
				tl_save(self);
		
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_IK_TARGET_ANGLE) != null_)
			withOne (Object, ObjType(obj_keyframe, kf)->value.Value(e_value_IK_TARGET_ANGLE), noone)
				tl_save(self);
		
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_TEXTURE_OBJ) > IntType(0))
		{
			idBool(ObjType(obj_keyframe, kf)->value[e_value_TEXTURE_OBJ], save) = true;
			if (idVar(ObjType(obj_keyframe, kf)->value.Value(e_value_TEXTURE_OBJ), type) == e_tl_type_CAMERA)
				withOne (Object, ObjType(obj_keyframe, kf)->value.Value(e_value_TEXTURE_OBJ), noone)
					tl_save(self);
			
		}
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_TEXTURE_MATERIAL_OBJ) > IntType(0))
			idBool(ObjType(obj_keyframe, kf)->value[e_value_TEXTURE_MATERIAL_OBJ], save) = true;
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_TEXTURE_NORMAL_OBJ) > IntType(0))
			idBool(ObjType(obj_keyframe, kf)->value[e_value_TEXTURE_NORMAL_OBJ], save) = true;
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_SOUND_OBJ) != null_)
			idBool(ObjType(obj_keyframe, kf)->value[e_value_SOUND_OBJ], save) = true;
		if (ObjType(obj_keyframe, kf)->value.Value(e_value_TEXT_FONT) != null_)
			idBool(ObjType(obj_keyframe, kf)->value[e_value_TEXT_FONT], save) = true;
	}
	
	RealType tl_keyframe_select(VarType kf)
	{
		if (idReal(kf, selected) > 0)
			return IntType(0);
		idReal(kf, selected) = true;
		withOne (Object, idVar(kf, timeline), noone)
		{
			sVar(keyframe_select) = kf;
			sInt(keyframe_select_amount)++;
			tl_update_recursive_select(self);
			tl_select(self);
		}
		
		return 0.0;
	}
	
	IntType tl_new_part(Scope<obj_timeline> self, VarType part)
	{
		withOne (obj_timeline, (new obj_timeline)->id, self->id)
		{
			self->type = e_tl_type_BODYPART;
			self->temp = ObjType(obj_timeline, self.otherId)->temp;
			self->model_part = part;
			self->model_part_name = ObjType(obj_model_part, part)->name;
			self->part_of = self.otherId;
			self->inherit_alpha = true;
			self->inherit_color = true;
			self->inherit_texture = true;
			self->inherit_surface = true;
			self->inherit_subsurface = true;
			self->inherit_rot_point = true;
			self->scale_resize = false;
			self->lock_bend = ObjType(obj_model_part, part)->lock_bend;
			self->part_mixing_shapes = ObjType(obj_model_part, part)->part_mixing_shapes;
			self->colors_ext = self->part_mixing_shapes;
			self->backfaces = ObjType(obj_model_part, part)->backfaces;
			self->part_parent_save_id = /*""*/ STR(0);
			self->show_tool_position = ObjType(obj_model_part, part)->show_position;
			self->depth = ObjType(obj_model_part, part)->depth;
			tl_set_parent(ScopeAny(self), { self.otherId });
			tl_update_depth(ScopeAny(self));
			tl_value_spawn(ScopeAny(self));
			return self->id;
		}
		
		return IntType(0);
	}
	
	VarType tl_part_find(ScopeAny self, VarType name)
	{
		if (sInt(part_list) != null_)
			for (IntType p = IntType(0); p < ds_list_size(sInt(part_list)); p++)
				if (idVar(DsList(sInt(part_list)).Value(p), model_part_name) == name)
					return DsList(sInt(part_list)).Value(p);
		return null_;
	}
	
	VarType tl_path_offset_get_position(VarType path, VarType offset)
	{
		RealType t, points;
		points = array_length(VarType::CreateRef(idArr(path, path_table))) - IntType(1);
		t = ((RealType)offset / idReal(path, path_length)) * points;
		return spline_get_point(t, idArr(path, path_table), idVar(path, path_closed), idVar(path, path_smooth), (idVar(path, path_closed) > 0) ? points : 0.0);
	}
	
	void tl_remove_clean(ScopeAny self, VarArgs argument)
	{
		IntType argument_count = argument.Size();
		VarType tl = (argument_count > IntType(0) ? argument[IntType(0)] : VarType(self->id));
		withOne (obj_timeline, tl, self->id)
		{
			tl_deselect(ScopeAny(self));
			ds_list_delete_value(global::render_list, self->id);
			ds_list_delete_value(idInt(self->parent, tree_list), self->id);
			if (self->part_of != null_)
				ds_list_delete_value(idInt(self->part_of, part_list), self->id);
			while (ds_list_size(self->tree_list) > IntType(0))
				withOne (Object, DsList(self->tree_list).Value(IntType(0)), self->id)
					tl_remove_clean(self);
			
			
			ds_list_destroy(self->tree_list);
			if (self->part_list != null_)
				ds_list_destroy(self->part_list);
			if (self->part_of == null_ && self->temp != null_)
				idInt(self->temp, count)--;
			if (self->type == e_tl_type_PATH_POINT)
				idBool(self->parent, path_update) = true;
			withAll (obj_template, self->id)
			{
				if (self->shape_tex == self.otherId)
					self->shape_tex = null_;
				if (self->shape_tex_material == self.otherId)
					self->shape_tex_material = null_;
				if (self->shape_tex_normal == self.otherId)
					self->shape_tex_normal = null_;
				if (self->type == e_temp_type_PARTICLE_SPAWNER && self->pc_spawn_region_path == self.otherId)
					self->pc_spawn_region_path = null_;
			}
			
			withAll (obj_bench_settings, self->id)
			{
				if (self->shape_tex == self.otherId)
					self->shape_tex = null_;
				if (self->shape_tex_material == self.otherId)
					self->shape_tex_material = null_;
				if (self->shape_tex_normal == self.otherId)
					self->shape_tex_normal = null_;
			}
			
			withAll (obj_timeline, self->id)
			{
				if (self->value.Value(e_value_TEXTURE_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_OBJ] = null_;
				if (self->value.Value(e_value_TEXTURE_MATERIAL_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_MATERIAL_OBJ] = null_;
				if (self->value.Value(e_value_TEXTURE_NORMAL_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_NORMAL_OBJ] = null_;
				if (self->value.Value(e_value_PATH_OBJ) == self.otherId)
					self->value[e_value_PATH_OBJ] = null_;
				if (self->value.Value(e_value_IK_TARGET) == self.otherId)
					self->value[e_value_IK_TARGET] = null_;
				if (self->value.Value(e_value_IK_TARGET_ANGLE) == self.otherId)
					self->value[e_value_IK_TARGET_ANGLE] = null_;
				if (self->value.Value(e_value_ATTRACTOR) == self.otherId)
					self->value[e_value_ATTRACTOR] = null_;
				if (self->value_inherit.Value(e_value_PATH_OBJ) == self.otherId)
					self->update_matrix = true;
				if (self->value.Value(e_value_IK_TARGET) == self.otherId)
					self->update_matrix = true;
				if (self->value.Value(e_value_IK_TARGET_ANGLE) == self.otherId)
					self->update_matrix = true;
				if (self->value_inherit.Value(e_value_ATTRACTOR) == self.otherId)
					self->update_matrix = true;
				if (self->value_inherit.Value(e_value_TEXTURE_OBJ) == self.otherId)
					self->update_matrix = true;
				if (self->value_inherit.Value(e_value_TEXTURE_MATERIAL_OBJ) == self.otherId)
					self->update_matrix = true;
				if (self->value_inherit.Value(e_value_TEXTURE_NORMAL_OBJ) == self.otherId)
					self->update_matrix = true;
			}
			
			withAll (obj_keyframe, self->id)
			{
				if (self->value.Value(e_value_PATH_OBJ) == self.otherId)
					self->value[e_value_PATH_OBJ] = null_;
				if (self->value.Value(e_value_IK_TARGET) == self.otherId)
					self->value[e_value_IK_TARGET] = null_;
				if (self->value.Value(e_value_IK_TARGET_ANGLE) == self.otherId)
					self->value[e_value_IK_TARGET_ANGLE] = null_;
				if (self->value.Value(e_value_ATTRACTOR) == self.otherId)
					self->value[e_value_ATTRACTOR] = null_;
				if (self->value.Value(e_value_TEXTURE_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_OBJ] = null_;
				if (self->value.Value(e_value_TEXTURE_MATERIAL_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_MATERIAL_OBJ] = null_;
				if (self->value.Value(e_value_TEXTURE_NORMAL_OBJ) == self.otherId)
					self->value[e_value_TEXTURE_NORMAL_OBJ] = null_;
			}
			
			if (global::_app->timeline_camera == self->id)
				global::_app->timeline_camera = null_;
			while (ds_list_size(self->keyframe_list))
				withOne (obj_keyframe, DsList(self->keyframe_list).Value(IntType(0)), self->id)
					instance_destroy(ScopeAny(self));
			
			
			ds_list_destroy(self->keyframe_list);
			withAll (obj_particle, self->id)
				if (self->creator == self.otherId)
					instance_destroy(ScopeAny(self));
			
			if (self->particle_list > 0)
				ds_list_destroy(self->particle_list);
			if (self->temp == self->id)
			{
				if (self->type == e_tl_type_SPECIAL_BLOCK)
				{
					if (self->model_texture_name_map != null_)
						ds_map_destroy(self->model_texture_name_map);
					if (self->model_texture_material_name_map != null_)
						ds_map_destroy(self->model_texture_material_name_map);
					if (self->model_tex_normal_name_map != null_)
						ds_map_destroy(self->model_tex_normal_name_map);
					if (self->model_hide_list != null_)
						ds_list_destroy(self->model_hide_list);
					if (self->model_color_name_map != null_)
						ds_map_destroy(self->model_color_name_map);
					if (self->model_color_map != null_)
						ds_map_destroy(self->model_color_map);
				}
				else
					if (self->type == e_tl_type_BLOCK)
						block_vbuffer_destroy(ScopeAny(self));
				
			}
			if (self->model_shape_vbuffer_map != null_)
			{
				VarType key = ds_map_find_first(self->model_shape_vbuffer_map);
				while (!is_undefined(key))
				{
					if (instance_exists(key) && idVar(key, vbuffer_default) != DsMap(self->model_shape_vbuffer_map).Value(key))
						vbuffer_destroy(DsMap(self->model_shape_vbuffer_map).Value(key));
					key = ds_map_find_next(self->model_shape_vbuffer_map, key);
				}
				
				ds_map_destroy(self->model_shape_vbuffer_map);
			}
			if (self->model_shape_alpha_map != null_)
				ds_map_destroy(self->model_shape_alpha_map);
			if (surface_exists((IntType)(self->cam_surf)))
				surface_free((IntType)(self->cam_surf));
			if (surface_exists((IntType)(self->cam_surf_tmp)))
				surface_free((IntType)(self->cam_surf_tmp));
			idInt(self->glint_tex, count)--;
			self->delete_ready = true;
		}
		
	}
	
	RealType tl_save(ScopeAny self)
	{
		if (sBool(save))
			return IntType(0);
		sBool(save) = true;
		if (sVar(temp) > 0)
		{
			idBool(sVar(temp), save) = true;
			if (idVar(sVar(temp), type) == e_temp_type_PARTICLE_SPAWNER)
			{
				withAll (obj_particle_type, self->id)
				{
					if (self->creator != idVar(self.otherId, temp))
						continue;
					if (self->temp > 0)
						idBool(self->temp, save) = true;
					idBool(self->sprite_tex, save) = true;
					idBool(self->sprite_template_tex, save) = true;
				}
				
			}
		}
		for (IntType k = IntType(0); k < ds_list_size(sInt(keyframe_list)); k++)
			tl_keyframe_save(DsList(sInt(keyframe_list)).Value(k));
		for (IntType t = IntType(0); t < ds_list_size(sInt(tree_list)); t++)
			withOne (Object, DsList(sInt(tree_list)).Value(t), self->id)
				tl_save(self);
		
		return 0.0;
	}
	
	RealType tl_select(ScopeAny self)
	{
		if (sReal(selected) > 0)
			return IntType(0);
		sReal(selected) = true;
		global::tl_edit_amount++;
		global::tl_edit = self->id;
		tl_update_parent_is_selected(self);
		return 0.0;
	}
	
	void tl_select_single(ScopeAny self)
	{
		withAll (obj_timeline, self->id)
		{
			if (self->id == self.otherId)
				continue;
			self->selected = false;
			self->keyframe_select = null_;
			self->keyframe_select_amount = IntType(0);
			self->parent_is_selected = false;
		}
		
		withAll (obj_keyframe, self->id)
		{
			if (ObjType(obj_keyframe, self->id)->timeline == self.otherId)
				continue;
			self->selected = false;
		}
		
		global::tl_edit_amount = IntType(1);
		global::tl_edit = self->id;
		sReal(selected) = true;
		tl_update_parent_is_selected(self);
	}
	
	void tl_set_parent(ScopeAny self, VarArgs argument)
	{
		IntType argument_count = argument.Size();
		if (sVar(parent) != null_)
			ds_list_delete_value(idInt(sVar(parent), tree_list), self->id);
		sVar(parent) = argument[IntType(0)];
		VarType index;
		if (argument_count > IntType(1) && argument[IntType(1)] >= IntType(0))
			index = argument[IntType(1)];
		else
			index = ds_list_size(idInt(sVar(parent), tree_list));
		
		ds_list_insert(idInt(sVar(parent), tree_list), (IntType)(index), self->id);
		sBool(update_matrix) = true;
	}
	
	void tl_set_parent_root(ScopeAny self)
	{
		tl_set_parent(self, { global::_app->id });
	}
	
	BoolType tl_supports_ik(ScopeAny self, BoolType typeinit)
	{
		if (!typeinit)
		{
			return ((sVar(bend_end_offset) > IntType(0)) && ((sInt(bend_part) == e_part_LOWER) && (sVec(bend_axis).Real(X_) && !sVec(bend_axis).Real(Y_) && !sVec(bend_axis).Real(Z_))));
		}
		return ((sVar(type) == e_tl_type_BODYPART && sVar(model_part) != null_ && idInt(sVar(model_part), bend_part) != null_ && idVar(sVar(model_part), bend_end_offset) > IntType(0)) && ((idInt(sVar(model_part), bend_part) == e_part_LOWER) && (idVec(sVar(model_part), bend_axis).Real(X_) && !idVec(sVar(model_part), bend_axis).Real(Y_) && !idVec(sVar(model_part), bend_axis).Real(Z_))));
	}
	
	void tl_update(ScopeAny self)
	{
		tl_update_value_types(self);
		tl_update_rot_point(self);
		tl_update_type_name(self);
		tl_update_display_name(self);
		tl_update_depth(self);
		tl_update_model_shape(self);
		if (sVar(type) == e_tl_type_PARTICLE_SPAWNER)
			particle_spawner_init(self);
	}
	
	void tl_update_depth(ScopeAny self)
	{
		ds_list_delete_value(global::render_list, self->id);
		IntType pos;
		for (pos = IntType(0); pos < ds_list_size(global::render_list); pos++)
			if (idVar(DsList(global::render_list).Value(pos), depth) > sVar(depth))
				break;
		ds_list_insert(global::render_list, pos, self->id);
	}
	
	void tl_update_display_name(ScopeAny self)
	{
		if (sVar(name) == /*""*/ STR(0))
		{
			sVar(display_name) = text_get({ /*"type"*/ STR(775) + DsList(global::tl_type_name_list).Value(sVar(type)) });
			if (sVar(part_of) != null_)
			{
				if (sVar(type) == e_tl_type_BODYPART)
				{
					if (sVar(model_part) != null_)
						sVar(display_name) = minecraft_asset_get_name(/*"modelpart"*/ STR(748), idVar(sVar(model_part), name));
					else
						sVar(display_name) = text_get({ /*"timelineunusedbodypart"*/ STR(3849) });
					
				}
				else
					if (sVar(type) == e_tl_type_SPECIAL_BLOCK)
					{
						if (sVar(model_file) != null_)
							sVar(display_name) = minecraft_asset_get_name(/*"model"*/ STR(8), idVar(sVar(model_file), name));
					}
					else
						if (sVar(type) == e_tl_type_BLOCK)
						{
							sVar(display_name) = minecraft_asset_get_name(/*"block"*/ STR(4), ObjType(obj_block, DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_name_map).Value(sVar(block_name)))->name);
						}
				
				
			}
			else
				if (sVar(temp) != null_)
					sVar(display_name) = idVar(sVar(temp), display_name);
			
		}
		else
			sVar(display_name) = sVar(name);
		
		if (sInt(part_list) != null_)
		{
			for (IntType p = IntType(0); p < ds_list_size(sInt(part_list)); p++)
			{
				withOne (Object, DsList(sInt(part_list)).Value(p), self->id)
				{
					tl_update_type_name(self);
					tl_update_display_name(self);
				}
				
			}
		}
	}
	
	RealType tl_update_hide(ScopeAny self)
	{
		if (!(sVar(hide) > 0))
			return IntType(0);
		for (IntType t = IntType(0); t < ds_list_size(sInt(tree_list)); t++)
		{
			withOne (Object, DsList(sInt(tree_list)).Value(t), self->id)
			{
				if (sVar(inherit_visibility) > 0)
				{
					sVar(hide) = true;
					tl_update_hide(self);
				}
			}
			
		}
		return 0.0;
	}
	
	RealType tl_update_ik(ScopeAny self, VarType parts)
	{
		if (array_length(VarType::CreateRef(parts)) == IntType(0))
			return IntType(0);
		for (IntType _it = 0, _it_max = IntType(2); _it < _it_max; _it++)
		{
			BoolType update = false;
			for (IntType i = IntType(0); i < array_length(VarType::CreateRef(parts)); i++)
				do_ik(self, parts.Value(i));
			for (IntType i = IntType(0); i < array_length(VarType::CreateRef(parts)); i++)
			{
				withOne (obj_timeline, parts.Value(i), self->id)
				{
					if (self->update_matrix)
					{
						update = true;
						tl_update_matrix(ScopeAny(self), false, false);
					}
				}
				
			}
			if (!update)
				break;
		}
		return 0.0;
	}
	
	RealType do_ik(ScopeAny self, IntType tl)
	{
		if (tl == null_)
			return IntType(0);
		ArrType jointpos, jointlength, offsetpos;
		VecType bend;
		MatrixType bendmat, mat;
		VarType offset, endpos, polepos;
		BoolType nobend, haspole;
		jointpos = ArrType::From({});
		jointlength = ArrType::From({});
		offset = idVar(ObjType(obj_timeline, tl)->model_part, bend_end_offset);
		offsetpos = ArrType::From({ IntType(0), IntType(0), IntType(0) });
		nobend = true;
		endpos = ArrType::From({ IntType(0), IntType(0), IntType(0) });
		mat = ObjType(obj_timeline, tl)->matrix_parent_pre_ik;
		BoolType targetupdate, poleupdate, matupdate, blendupdate;
		targetupdate = false;
		poleupdate = false;
		matupdate = false;
		blendupdate = false;
		if (ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET) != null_ && ObjType(obj_timeline, tl)->ik_target_pos != null_)
			targetupdate = !array_equals(VarType::CreateRef(ObjType(obj_timeline, tl)->ik_target_pos), VarType::CreateRef(idVar(ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET), world_pos)));
		targetupdate = (targetupdate || (ObjType(obj_timeline, tl)->ik_target_prev != ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET)));
		ObjType(obj_timeline, tl)->ik_target_prev = ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET);
		if (ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE) != null_)
			if (ObjType(obj_timeline, tl)->ik_target_angle_pos != null_)
				poleupdate = !array_equals(VarType::CreateRef(ObjType(obj_timeline, tl)->ik_target_angle_pos), VarType::CreateRef(idVar(ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE), world_pos)));
		poleupdate = (poleupdate || (ObjType(obj_timeline, tl)->ik_target_angle_prev != ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE)));
		ObjType(obj_timeline, tl)->ik_target_angle_prev = ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE);
		if (ObjType(obj_timeline, tl)->ik_matrix_prev != null_)
			matupdate = !array_equals(VarType::CreateRef(ObjType(obj_timeline, tl)->ik_matrix_prev), VarType::CreateRef(ObjType(obj_timeline, tl)->matrix));
		blendupdate = (ObjType(obj_timeline, tl)->ik_blend_prev != ObjType(obj_timeline, tl)->value.Value(e_value_IK_BLEND));
		ObjType(obj_timeline, tl)->ik_blend_prev = ObjType(obj_timeline, tl)->value.Value(e_value_IK_BLEND);
		if (!blendupdate && !targetupdate && !poleupdate && !matupdate && (ObjType(obj_timeline, tl)->value.Value(e_value_IK_ANGLE_OFFSET) == ObjType(obj_timeline, tl)->ik_angle_offset_prev))
			return IntType(0);
		ObjType(obj_timeline, tl)->ik_angle_offset_prev = ObjType(obj_timeline, tl)->value.Value(e_value_IK_ANGLE_OFFSET);
		ObjType(obj_timeline, tl)->ik_matrix_prev = ObjType(obj_timeline, tl)->matrix;
		haspole = (ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE) != null_ && ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET) != null_);
		if (haspole)
		{
			polepos = idVar(ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET_ANGLE), world_pos);
			ObjType(obj_timeline, tl)->ik_target_angle_pos = polepos;
			if (polepos.Value(X_) == ObjType(obj_timeline, tl)->world_pos.Value(X_))
				polepos[X_] += 0.0001;
			if (polepos.Value(Y_) == ObjType(obj_timeline, tl)->world_pos.Value(Y_))
				polepos[Y_] += 0.0001;
			if (polepos.Value(Z_) == ObjType(obj_timeline, tl)->world_pos.Value(Z_))
				polepos[Z_] += 0.0001;
			endpos = idVar(ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET), world_pos);
			if (polepos.Value(X_) == endpos.Value(X_))
				polepos[X_] += 0.0001;
			if (polepos.Value(Y_) == endpos.Value(Y_))
				polepos[Y_] += 0.0001;
			if (polepos.Value(Z_) == endpos.Value(Z_))
				polepos[Z_] += 0.0001;
		}
		withOne (obj_timeline, tl, self->id)
		{
			bend = vec3(IntType(0));
			jointpos[IntType(0)] = matrix_position(mat);
			bendmat = matrix_multiply(model_part_get_bend_matrix(ScopeAny(self), { self->model_part, bend, point3D(IntType(0), IntType(0), IntType(0)) }), mat);
			jointpos[IntType(1)] = matrix_position(bendmat);
			switch ((IntType)idInt(self->model_part, bend_part))
			{
				case e_part_UPPER:
				{
					offsetpos = ArrType::From({ IntType(0), IntType(0), offset });
					break;
				}
				case e_part_LOWER:
				{
					offsetpos = ArrType::From({ IntType(0), IntType(0), -offset });
					break;
				}
				case e_part_RIGHT:
				{
					offsetpos = ArrType::From({ offset, IntType(0), IntType(0) });
					break;
				}
				case e_part_LEFT:
				{
					offsetpos = ArrType::From({ -offset, IntType(0), IntType(0) });
					break;
				}
				case e_part_FRONT:
				{
					offsetpos = ArrType::From({ IntType(0), offset, IntType(0) });
					break;
				}
				case e_part_BACK:
				{
					offsetpos = ArrType::From({ IntType(0), -offset, IntType(0) });
					break;
				}
			}
			
			bendmat = matrix_multiply(matrix_create(offsetpos, vec3(IntType(0)), vec3(IntType(1))), matrix_multiply(model_part_get_bend_matrix(ScopeAny(self), { self->model_part, bend, point3D(IntType(0), IntType(0), IntType(0)) }), mat));
			jointpos[IntType(2)] = matrix_position(bendmat);
		}
		
		if (ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET) != null_)
		{
			endpos = idVar(ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET), world_pos);
			for (IntType i = IntType(0); i <= Z_; i++)
				endpos[i] = lerp(jointpos[IntType(2)][i], endpos.Value(i), ObjType(obj_timeline, tl)->value.Value(e_value_IK_BLEND));
			ObjType(obj_timeline, tl)->ik_target_pos = endpos;
			jointlength[IntType(0)] = point3D_distance(jointpos.Value(IntType(0)), jointpos.Value(IntType(1)));
			jointlength[IntType(1)] = point3D_distance(jointpos.Value(IntType(1)), jointpos.Value(IntType(2)));
			jointlength[IntType(2)] = IntType(0);
			if (!idVec(ObjType(obj_timeline, tl)->model_part, bend_invert).Real(X_))
			{
				jointpos[IntType(1)] = point3D_add(jointpos.Value(IntType(0)), vec3_mul(point3D_sub(jointpos.Value(IntType(0)), jointpos.Value(IntType(1))), IntType(1)));
				jointpos[IntType(2)] = point3D_add(jointpos.Value(IntType(0)), vec3_mul(point3D_sub(jointpos.Value(IntType(0)), jointpos.Value(IntType(2))), IntType(1)));
			}
			if (point3D_distance(jointpos.Value(IntType(0)), endpos) > (jointlength.Value(IntType(0)) + jointlength.Value(IntType(1))))
			{
				VarType dir = vec3_direction(jointpos.Value(IntType(0)), endpos);
				for (sInt(i) = IntType(1); sInt(i) < array_length(VarType::CreateRef(jointpos)); sInt(i)++)
					jointpos[sInt(i)] = point3D_add(jointpos.Value(sInt(i) - IntType(1)), vec3_mul(dir, jointlength.Value(sInt(i) - IntType(1))));
			}
			else
			{
				VarType dir1, dir2;
				dir1 = vec3_direction(jointpos.Value(IntType(0)), endpos);
				dir2 = vec3_direction(jointpos.Value(IntType(0)), jointpos.Value(IntType(1)));
				if (abs(dir1.Value(X_)) == abs(dir2.Value(X_)) && abs(dir1.Value(Y_)) == abs(dir2.Value(Y_)) && abs(dir1.Value(Z_)) == abs(dir2.Value(Z_)))
					endpos = point3D_add(endpos, vec3_mul(vec3_normalize(vec3_cross(dir1, vec3(-IntType(1), IntType(0), IntType(0)))), 0.0001));
				RealType dis = point3D_distance(jointpos.Value(IntType(0)), endpos);
				for (IntType t = IntType(0); t < IntType(30) && (dis > 0.01); t++)
				{
					for (RealType i = array_length(VarType::CreateRef(jointpos)) - IntType(1); i > IntType(0); i--)
					{
						if (i == array_length(VarType::CreateRef(jointpos)) - IntType(1))
							jointpos[i] = endpos;
						else
							jointpos[i] = point3D_add(jointpos.Value(i + IntType(1)), vec3_mul(vec3_direction(jointpos.Value(i + IntType(1)), jointpos.Value(i)), jointlength.Value(i)));
						
					}
					for (IntType i = IntType(1); i < array_length(VarType::CreateRef(jointpos)); i++)
						jointpos[i] = point3D_add(jointpos.Value(i - IntType(1)), vec3_mul(vec3_direction(jointpos.Value(i - IntType(1)), jointpos.Value(i)), jointlength.Value(i - IntType(1))));
					dis = point3D_distance(jointpos.Value(IntType(0)), endpos);
				}
				nobend = false;
			}
			
		}
		VarType p0, p1, p2, ab, bc, ac, n;
		VecType p0proj, p1proj, p2proj;
		p0 = jointpos.Value(IntType(0));
		p1 = jointpos.Value(IntType(1));
		p2 = jointpos.Value(IntType(2));
		if (ObjType(obj_timeline, tl)->value.Value(e_value_IK_TARGET) != null_)
		{
			MatrixType matinv = matrix_inverse(mat);
			p0 = point3D_mul_matrix(jointpos.Value(IntType(0)), matinv);
			p1 = point3D_mul_matrix(jointpos.Value(IntType(1)), matinv);
			p2 = point3D_mul_matrix(jointpos.Value(IntType(2)), matinv);
			if (haspole)
				polepos = point3D_mul_matrix(polepos, matinv);
		}
		ab = vec3_direction(p0, p1);
		bc = vec3_direction(p1, p2);
		ac = vec3_direction(p0, p2);
		if (haspole && !nobend)
		{
			VecType poleproj;
			RealType angle;
			poleproj = point3D_project_plane(polepos, p0, ac);
			p1proj = point3D_project_plane(p1, p0, ac);
			angle = point3D_angle_signed(point3D_sub(p1proj, p0), point3D_sub(poleproj, p0), ac);
			p1 = point3D_add(p0, vec3_rotate_axis_angle(point3D_sub(p1, p0), ac, degtorad(angle + ObjType(obj_timeline, tl)->value.Value(e_value_IK_ANGLE_OFFSET))));
			ab = vec3_direction(p0, p1);
			bc = vec3_direction(p1, p2);
		}
		if (!haspole && nobend)
		{
			if (ab.Value(X_) == IntType(0) && ab.Value(Y_) == IntType(0))
				n = vec3_normal(ab, -IntType(90));
			else
				n = vec3_normal(ab, IntType(0));
			
		}
		else
		{
			if (haspole && nobend)
				p2proj = point3D_project_plane(polepos, p0, ab);
			else
				p2proj = point3D_project_plane(p2, p0, ab);
			
			n = vec3_direction(p2proj, p0);
			if (haspole && nobend)
				n = vec3_rotate_axis_angle(n, ac, degtorad(ObjType(obj_timeline, tl)->value.Value(e_value_IK_ANGLE_OFFSET)));
			if (idVec(ObjType(obj_timeline, tl)->model_part, bend_invert).Real(X_))
				n = vec3_mul(n, -IntType(1));
			if (haspole && nobend)
				n = vec3_mul(n, -IntType(1));
		}
		
		ObjType(obj_timeline, tl)->part_joints_pos[IntType(0)] = p0;
		ObjType(obj_timeline, tl)->part_joints_matrix[IntType(0)] = matrix_create_rotate_to(n, vec3_mul(ab, -IntType(1)));
		ObjType(obj_timeline, tl)->part_joints_bone_matrix[IntType(0)] = matrix_create_rotate_to(n, ab);
		if (!nobend)
		{
			p0proj = point3D_project_plane(p0, p1, bc);
			n = vec3_direction(p1, p0proj);
		}
		ObjType(obj_timeline, tl)->part_joints_pos[IntType(1)] = p1;
		ObjType(obj_timeline, tl)->part_joints_matrix[IntType(1)] = matrix_create_rotate_to(n, vec3_mul(bc, -IntType(1)));
		ObjType(obj_timeline, tl)->part_joints_bone_matrix[IntType(1)] = matrix_create_rotate_to(n, bc);
		ObjType(obj_timeline, tl)->part_joints_pos[IntType(2)] = p2;
		ObjType(obj_timeline, tl)->part_joints_matrix[IntType(2)] = ObjType(obj_timeline, tl)->part_joints_matrix.Value(IntType(1));
		ObjType(obj_timeline, tl)->part_joints_bone_matrix[IntType(2)] = ObjType(obj_timeline, tl)->part_joints_bone_matrix.Value(IntType(1));
		ObjType(obj_timeline, tl)->part_joint_bend_angle = radtodeg(arccos(vec3_dot(ab, bc)));
		ObjType(obj_timeline, tl)->update_matrix = true;
		return IntType(0);
	}
	
}
