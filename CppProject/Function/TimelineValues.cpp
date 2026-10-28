#include "Generated/Scripts.hpp"

namespace CppProject
{
	// Mirror the GML interpolation rules without owning argument copies
	VarType tl_value_interpolate(IntType vid, const VarType& p, const VarType& val1, const VarType& val2)
	{
		switch ((IntType)(vid))
		{
			case e_value_RGB_ADD:
			case e_value_RGB_SUB:
			case e_value_RGB_MUL:
			case e_value_HSB_ADD:
			case e_value_HSB_SUB:
			case e_value_HSB_MUL:
			case e_value_MIX_COLOR:
			case e_value_GLOW_COLOR:
			case e_value_SUBSURFACE_COLOR:
			case e_value_LIGHT_COLOR:
			case e_value_CAM_FX_BLOOM_BLEND:
			case e_value_CAM_FX_COLOR_BURN:
			case e_value_CAM_FX_VIGNETTE_COLOR:
			case e_value_ENV_SKY_COLOR:
			case e_value_ENV_SKY_CLOUDS_COLOR:
			case e_value_ENV_SUNLIGHT_COLOR:
			case e_value_ENV_AMBIENT_COLOR:
			case e_value_ENV_NIGHT_SKY_COLOR:
			case e_value_ENV_NIGHT_SKY_CLOUDS_COLOR:
			case e_value_ENV_NIGHT_SKY_STARS_COLOR:
			case e_value_ENV_NIGHT_COLOR:
			case e_value_ENV_GRASS_COLOR:
			case e_value_ENV_FOLIAGE_COLOR:
			case e_value_ENV_DRY_FOLIAGE_COLOR:
			case e_value_ENV_WATER_COLOR:
			case e_value_ENV_LEAVES_OAK_COLOR:
			case e_value_ENV_LEAVES_SPRUCE_COLOR:
			case e_value_ENV_LEAVES_BIRCH_COLOR:
			case e_value_ENV_LEAVES_JUNGLE_COLOR:
			case e_value_ENV_LEAVES_ACACIA_COLOR:
			case e_value_ENV_LEAVES_DARK_OAK_COLOR:
			case e_value_ENV_LEAVES_MANGROVE_COLOR:
			case e_value_ENV_FOG_COLOR:
			case e_value_ENV_FOG_OBJECT_COLOR:
			case e_value_TEXT_OUTLINE_COLOR:
			{
				return merge_color((IntType)(val1), (IntType)(val2), clamp(p, IntType(0), IntType(1)));
			}
			case e_value_CAM_WIDTH:
			case e_value_CAM_HEIGHT:
			case e_value_CAM_FX_BLADE_AMOUNT:
			case e_value_ITEM_SLOT:
			{
				return floor(val1 + p * (val2 - val1));
			}
			case e_value_SPAWN:
			case e_value_FREEZE:
			case e_value_CLEAR:
			case e_value_CUSTOM_SEED:
			case e_value_SEED:
			case e_value_PATH_OBJ:
			case e_value_IK_TARGET:
			case e_value_IK_TARGET_ANGLE:
			case e_value_ATTRACTOR:
			case e_value_CAM_SIZE_USE_PROJECT:
			case e_value_CAM_SIZE_KEEP_ASPECT_RATIO:
			case e_value_CAM_ROTATE:
			case e_value_CAM_FX_TONEMAPPER:
			case e_value_CAM_FX_SHAKE_MODE:
			case e_value_CAM_FX_DOF_FRINGE:
			case e_value_CAM_FX_LENS_DIRT_BLOOM:
			case e_value_CAM_FX_LENS_DIRT_GLOW:
			case e_value_CAM_FX_CA_DISTORT_CHANNELS:
			case e_value_CAM_FX_DISTORT_REPEAT:
			case e_value_ENV_IMAGE_SHOW:
			case e_value_ENV_SKY_MOON_PHASE:
			case e_value_ENV_TWILIGHT:
			case e_value_ENV_SKY_CLOUDS_SHOW:
			case e_value_ENV_GROUND_SHOW:
			case e_value_ENV_GROUND_SLOT:
			case e_value_ENV_BIOME:
			case e_value_ENV_FOG_SHOW:
			case e_value_ENV_WIND:
			case e_value_VISIBLE:
			case e_value_TEXTURE_OBJ:
			case e_value_TEXTURE_MATERIAL_OBJ:
			case e_value_TEXTURE_NORMAL_OBJ:
			case e_value_SOUND_OBJ:
			case e_value_SOUND_VOLUME:
			case e_value_SOUND_PITCH:
			case e_value_SOUND_START:
			case e_value_SOUND_END:
			case e_value_TEXT:
			case e_value_TEXT_FONT:
			case e_value_TEXT_HALIGN:
			case e_value_TEXT_VALIGN:
			case e_value_TEXT_CUSTOM_ALIGNMENT:
			case e_value_TEXT_OUTLINE:
			case e_value_TEXT_CUSTOM_OUTLINE:
			case e_value_CUSTOM_ITEM_SLOT:
			case e_value_TRANSITION:
			case e_value_EASE_IN_X:
			case e_value_EASE_IN_Y:
			case e_value_EASE_OUT_X:
			case e_value_EASE_OUT_Y:
			{
				return val1;
			}
		}

		return val1 + p * (val2 - val1);
	}

	static const VarType& ReadTimelineValue(const ArrType& values, IntType index)
	{
		return index >= 0 && index < values.Size() ? values.vec.Value(index) : VarArgs::outOfBounds;
	}

	// Keep categories aligned with tl_update_values_ease
	static IntType TimelineValueDirtyFlags(IntType vid)
	{
		if (vid >= e_value_POS_X && vid <= e_value_BEND_ANGLE_Z)
		{
			if (vid >= e_value_SCA_X && vid <= e_value_SCA_Z)
				return e_tl_dirty_TRANSFORM | e_tl_dirty_SCALE;
			if (vid >= e_value_BEND_ANGLE_LEGACY)
				return e_tl_dirty_BEND;
			return e_tl_dirty_TRANSFORM;
		}
		if (vid >= e_value_PATH_OBJ && vid <= e_value_IK_ANGLE_OFFSET)
			return vid >= e_value_IK_TARGET ? e_tl_dirty_TRANSFORM | e_tl_dirty_BEND : e_tl_dirty_TRANSFORM;
		if (vid >= e_value_CAM_ROTATE && vid <= e_value_CAM_ROTATE_ANGLE_Z)
			return e_tl_dirty_TRANSFORM;
		if ((vid >= e_value_ALPHA && vid <= e_value_WIND_INFLUENCE) ||
			(vid >= e_value_TEXTURE_OBJ && vid <= e_value_TEXTURE_NORMAL_OBJ) || vid == e_value_VISIBLE)
			return e_tl_dirty_APPEARANCE;
		if (!((vid >= e_value_SPAWN && vid <= e_value_CAM_HEIGHT) ||
			(vid >= e_value_CAM_FX_SHAKE_MODE && vid <= e_value_ENV_BRIGHTNESS) ||
			(vid >= e_value_SOUND_OBJ && vid <= e_value_ITEM_NAME) ||
			(vid >= e_value_TRANSITION && vid <= e_value_EASE_OUT_Y)))
			return e_tl_dirty_ALL;
		return e_tl_dirty_LOCAL;
	}

	void tl_update_values_batch(Scope<obj_timeline> self, BoolType transitions)
	{
		const bool reuse = self->keyframe_value_cache_reuse;
		ArrType& changing = self->keyframe_value_cache_channels;

		if (reuse && (transitions || changing.Size() == 0))
			return;

		// Borrow endpoint values only for this call
		ArrType& values = self->value.Arr();
		obj_keyframe* current = self->keyframe_animate ? ObjType(obj_keyframe, self->keyframe_current) : nullptr;
		obj_keyframe* next = self->keyframe_next > 0 ? ObjType(obj_keyframe, self->keyframe_next) : nullptr;
		const ArrType* currentValues = current ? &current->value.Arr() : nullptr;
		const ArrType* nextValues = next ? &next->value.Arr() : nullptr;

		auto assign = [&](IntType vid, const VarType& oldValue, const VarType& result)
		{
			if (oldValue != result)
			{
				self->update_value_flags |= TimelineValueDirtyFlags(vid);
				values[vid] = result;
			}
		};
		auto evaluate = [&](IntType vid)
		{
			const VarType& oldValue = ReadTimelineValue(values, vid);
			if (self->keyframe_animate)
			{
				const VarType& currentValue = ReadTimelineValue(*currentValues, vid);
				const VarType& nextValue = ReadTimelineValue(*nextValues, vid);
				if (!reuse && !transitions && currentValue != nextValue)
					changing.Append(vid);
				if (oldValue == currentValue && oldValue == nextValue)
					return;
				assign(vid, oldValue, tl_value_interpolate(vid, self->keyframe_progress_ease, currentValue, nextValue));
			}
			else
			{
				const VarType& source = ReadTimelineValue(nextValues ? *nextValues : self->value_default, vid);
				assign(vid, oldValue, source);
			}
		};
		if (reuse)
		{
			for (IntType i = 0; i < changing.Size(); i++)
				evaluate(changing.IntValue(i));
			return;
		}
		auto range = [&](IntType first, IntType last)
		{
			for (IntType vid = first; vid <= last; vid++)
				evaluate(vid);
		};
		auto enabled = [&](IntType type) { return self->value_type.BoolValue(type); };

		if (transitions)
		{
			range(e_value_TRANSITION, e_value_EASE_OUT_Y);
			return;
		}

		IntType type = self->type.ToInt();
		if (enabled(e_value_type_TRANSFORM_POS))
		{
			range(e_value_POS_X, e_value_POS_Z);
			if (type != e_tl_type_PATH && type != e_tl_type_PATH_POINT)
				range(e_value_PATH_OBJ, e_value_PATH_OFFSET);
		}
		if (enabled(e_value_type_TRANSFORM_ROT))
			range(e_value_ROT_X, e_value_ROT_Z);
		if (enabled(e_value_type_TRANSFORM_SCA))
			range(e_value_SCA_X, e_value_SCA_Z);
		if (enabled(e_value_type_TRANSFORM_BEND))
		{
			range(e_value_BEND_ANGLE_X, e_value_BEND_ANGLE_Z);
			range(e_value_IK_TARGET, e_value_IK_ANGLE_OFFSET);
		}
		if (enabled(e_value_type_TRANSFORM_PATH_POINT))
			range(e_value_PATH_POINT_ANGLE, e_value_PATH_POINT_SCALE);
		if (enabled(e_value_type_MATERIAL_COLOR))
			range(e_value_ALPHA, e_value_WIND_INFLUENCE);
		if (enabled(e_value_type_PARTICLES))
			range(e_value_SPAWN, e_value_FORCE_VORTEX);
		if (enabled(e_value_type_LIGHT))
		{
			range(e_value_LIGHT_COLOR, e_value_LIGHT_FADE_SIZE);
			if (enabled(e_value_type_SPOTLIGHT))
				range(e_value_LIGHT_SPOT_RADIUS, e_value_LIGHT_SPOT_SHARPNESS);
		}
		if (enabled(e_value_type_CAMERA))
			range(e_value_CAM_FOV, e_value_CAM_ROTATE_ANGLE_Z);
		if (enabled(e_value_type_CAMERA_EFFECT))
		{
			IntType effect = self->camera_effect_type.ToInt();
			VarType effectRange = DsList(global::camera_effect_value_range_list).Value(effect);
			for (IntType vid = effectRange.Value(0).ToInt(); vid <= effectRange.Value(1).ToInt(); vid++)
				if (effect != e_cam_fx_FADE || vid != e_value_GLOW_COLOR)
					evaluate(vid);
			if (camera_effect_type_use_aperture(effect))
				range(e_value_CAM_FX_BLADE_AMOUNT, e_value_CAM_FX_BLADE_STRETCH);
			if (effect == e_cam_fx_COLOR_CORRECTION)
				range(e_value_RGB_ADD, e_value_HSB_MUL);
			if (effect == e_cam_fx_LENS_DIRT)
				evaluate(e_value_TEXTURE_OBJ);
		}
		if (enabled(e_value_type_ENVIRONMENT))
			range(e_value_ENV_IMAGE_SHOW, e_value_ENV_BRIGHTNESS);
		if (enabled(e_value_type_MATERIAL_TEXTURE) || enabled(e_value_type_ITEM))
			range(e_value_TEXTURE_OBJ, e_value_TEXTURE_NORMAL_OBJ);
		if (enabled(e_value_type_SOUND))
			range(e_value_SOUND_OBJ, e_value_SOUND_END);
		if (enabled(e_value_type_TEXT))
			range(e_value_TEXT, e_value_TEXT_CUSTOM_OUTLINE);
		if (enabled(e_value_type_ITEM))
			range(e_value_CUSTOM_ITEM_SLOT, e_value_ITEM_SLOT);
		evaluate(e_value_VISIBLE);
	}
}
