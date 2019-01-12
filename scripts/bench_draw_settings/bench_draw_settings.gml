/// bench_draw_settings(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var padding = 5;

dx = argument0
dy = argument1
dw = argument2
dh = argument3
content_x = dx
content_y = dy
content_width = dw
content_height = dh

// Header
draw_set_font(setting_font_bold)
draw_text(dx + padding, dy + padding, text_get("type" + tl_type_name_list[|bench_settings.type]))
draw_set_font(setting_font)
draw_separator_horizontal(dx + padding, dy + padding + 20, dw - padding * 2)

// Settings
var sdy, listh, buttony;
sdy = dy
listh = 0

dx += padding + 5
dy += padding + 20 + 15
dw -= padding * 2 + 10
dh -= padding + 20 + 30

if (type_is_timeline(bench_settings.type))
{
	buttony = dy + dh / 2 - 16
}
else
{
	dh -= 32 + 5
	
	// Preview
	preview_draw(bench_settings.preview, dx + floor(dw / 2) - 80, dy, 160)
	dy += 160 + 10
	dh -= 160 + 10
	
	// Settings
	switch (bench_settings.type)
	{
		case e_temp_type.CHARACTER:
		case e_temp_type.SPECIAL_BLOCK:
		case e_temp_type.BODYPART:
		{
			var labeltext, list, texcap, capwid, part;
			if (bench_settings.type = e_temp_type.CHARACTER)
			{
				labeltext = text_get("benchmodel")
				list = bench_settings.char_list
				texcap = "benchskin"
				capwid  = text_caption_width(texcap)
				part = bench_settings.model_file
			}
			else if (bench_settings.type = e_temp_type.SPECIAL_BLOCK)
			{
				labeltext = text_get("benchblock")
				list = bench_settings.special_block_list
				texcap = "benchspblocktex"
				capwid  = text_caption_width(texcap)
				part = bench_settings.model_file
			}
			else if (bench_settings.type = e_temp_type.BODYPART)
			{
				labeltext = text_get("benchmodel")
				list = bench_settings.bodypart_model_list
				texcap = "benchbodypartskin"
				capwid  = text_caption_width("benchbodypart", texcap)
				part = bench_settings.model_part
			}
			
			// Model
			if (draw_button_normal(labeltext + ":", dx, dy, 16, 16, e_button.LABEL, bench_settings.list_extend, false, true, test(bench_settings.list_extend, icons.ARROW_DOWN, icons.ARROW_RIGHT)))
				bench_settings.list_extend = !bench_settings.list_extend
			
			//draw_label(labeltext + ":", dx + 24, dy + 8, fa_left, fa_middle)
			dy += 22
			
			if (bench_settings.list_extend)
			{
				listh = 200 + bench_settings.height_custom
				sortlist_draw(list, dx, dy, dw, listh, bench_settings.model_name)
				dy += listh + 30
			}
			
			// States
			var model, statelen;
			model = mc_assets.model_name_map[?bench_settings.model_name];
			statelen = array_length_1d(bench_settings.model_state)
			
			for (var i = 0; i < statelen; i += 2)
			{
				var state = bench_settings.model_state[i];
				capwid = max(capwid, string_width(minecraft_asset_get_name("modelstate", state) + ":") + 20)
			}
			
			for (var i = 0; i < statelen; i += 2)
			{
				var state = bench_settings.model_state[i];
				menu_model_current = model
				menu_model_state_current = model.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", bench_settings.model_state[i + 1]), action_bench_model_state, null, null, capwid, text_get("benchmodelstatetip"))
				dy += 24 + 8
			}
			menu_model_current = null
			
			// Bodypart
			if (bench_settings.type = e_temp_type.BODYPART && bench_settings.model_file != null)
			{
				draw_button_menu("benchbodypart", e_menu.LIST, dx, dy, dw, 24, bench_settings.model_part_name, minecraft_asset_get_name("modelpart", bench_settings.model_part_name), action_bench_model_part_name, null, null, capwid)
				dy += 24 + 8
			}
			
			// Skin
			var text, tex;
			text = bench_settings.model_tex.display_name
			with (bench_settings.model_tex)
				tex = res_get_model_texture(model_part_get_texture_name(part, app.bench_settings.model_texture_name_map))
			draw_button_menu(texcap, e_menu.LIST, dx, dy, dw, 40, bench_settings.model_tex, text, action_bench_model_tex, tex, null, capwid)
			dy += 40
			
			// Banner editor
			if (bench_settings.model_name = "banner")
			{
				dy += 8
				
				var wid = text_max_width("benchopeneditor") + 20;
				if (draw_button_normal("benchopeneditor", dx, dy, wid, 24, e_button.TEXT, popup = popup_bannereditor, true, true))
					popup_bannereditor_show(bench_settings)
				
				dy += 24
			}
			
			break
		}
		
		case e_temp_type.SCENERY:
		{
			var capwid, text, tex;
			capwid = text_caption_width("benchschematic", "benchblocktex")
			
			// Schematic
			text = text_get("listnone")
			if (bench_settings.scenery != null)
				text = bench_settings.scenery.display_name
			draw_button_menu("benchscenery", e_menu.LIST, dx, dy, dw, 32, bench_settings.scenery, text, action_bench_scenery, null, null, capwid)
			dy += 32 + 8

			// Texture
			draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
			dy += 40
			break
		}
		
		case e_temp_type.ITEM:
		{
			var capwid, res, text, sprite;
			capwid = text_caption_width("typeitem", "benchitemtex")
			res = bench_settings.item_tex
			if (!res.ready)
				res = mc_res
			
			// Preview
			if (draw_button_normal(text_get("typeitem") + ":", dx, dy, 16, 16, e_button.LABEL, bench_settings.list_extend, false, true, test(bench_settings.list_extend, icons.ARROW_DOWN, icons.ARROW_RIGHT)))
				bench_settings.list_extend = !bench_settings.list_extend
			
			if (res.item_sheet_texture != null)
				draw_texture_slot(res.item_sheet_texture, bench_settings.item_slot, dx + (capwid + 24), dy, 16, 16, res.item_sheet_size[X], res.item_sheet_size[Y])
			else
			{
				var scale = min(16 / texture_width(res.texture), 16 / texture_height(res.texture));
				draw_texture(res.texture, dx + capwid, dy, scale, scale)
			}
			dy += 22
			
			// Item select
			if (res.item_sheet_texture != null && bench_settings.list_extend)
			{
				var slots = test((res.type = e_res_type.PACK), ds_list_size(mc_assets.item_texture_list), (res.item_sheet_size[X] * res.item_sheet_size[Y]));
				listh = 200 + bench_settings.height_custom
				draw_texture_picker(bench_settings.item_slot, res.item_sheet_texture, dx, dy, dw, listh, slots, res.item_sheet_size[X], res.item_sheet_size[Y], bench_settings.item_scroll, action_bench_item_slot)
				dy += listh + 8
			}
			
			// Image
			var tex = res.block_preview_texture;
			if (tex = null)
				tex = res.texture
			draw_button_menu("benchitemtex", e_menu.LIST, dx, dy, dw, 40, bench_settings.item_tex, bench_settings.item_tex.display_name, action_bench_item_tex, bench_settings.item_tex.block_preview_texture, null, capwid)
			dy += 40 + 8
			
			// Settings
			draw_checkbox("benchitem3d", dx, dy, bench_settings.item_3d, action_bench_item_3d)
			draw_checkbox("benchitemfacecamera", dx + floor(dw * 0.3), dy, bench_settings.item_face_camera, action_bench_item_face_camera)
			dy += 16 + 8
			
			draw_checkbox("benchitembounce", dx, dy, bench_settings.item_bounce, action_bench_item_bounce)
			draw_checkbox("benchitemspin", dx + floor(dw * 0.3), dy, bench_settings.item_spin, action_bench_item_spin)
			dy += 16
			break
		}
		
		case e_temp_type.BLOCK:
		{
			var capwid, text, sprite;
			capwid = text_caption_width("benchblocktex")
			
			// Block
			if (draw_button_normal(text_get("benchblock") + ":", dx, dy, 16, 16, e_button.LABEL, bench_settings.list_extend, false, true, test(bench_settings.list_extend, icons.ARROW_DOWN, icons.ARROW_RIGHT)))
				bench_settings.list_extend = !bench_settings.list_extend
			dy += 22
			
			if (bench_settings.list_extend)
			{
				listh = 200 + bench_settings.height_custom
				sortlist_draw(bench_settings.block_list, dx, dy, dw, listh, bench_settings.block_name)
				dy += listh + 30
			}
			
			// States
			var block, statelen;
			block = mc_assets.block_name_map[?bench_settings.block_name]
			statelen = array_length_1d(bench_settings.block_state)
			
			for (var i = 0; i < statelen; i += 2)
			{
				var state = bench_settings.block_state[i];
				capwid = max(capwid, string_width(minecraft_asset_get_name("blockstate", state) + ":") + 20)
			}
			
			for (var i = 0; i < statelen; i += 2)
			{
				var state = bench_settings.block_state[i];
				menu_block_current = block
				menu_block_state_current = block.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", bench_settings.block_state[i + 1]), action_bench_block_state, null, null, capwid, text_get("benchblockstatetip"))
				dy += 24 + 8
			}
			menu_block_current = null
			
			// Texture
			draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
			dy += 40
			break
		}
		
		case e_temp_type.PARTICLE_SPAWNER:
		{
			// Particles
			draw_label(text_get("benchparticlespreset") + ":", dx, dy + 8, fa_left, fa_middle)
			dy += 22
			listh = 200 + bench_settings.height_custom
			sortlist_draw(bench_settings.particles_list, dx, dy, dw, listh, bench_settings.particle_preset)
			dy += listh + 20
			break
		}
		
		case e_temp_type.TEXT:
		{
			// Font
			draw_button_menu("benchtextfont", e_menu.LIST, dx, dy, dw, 32, bench_settings.text_font, bench_settings.text_font.display_name, action_bench_text_font)
			dy += 32 + 8
			
			// 3D / Face camera
			draw_checkbox("benchtext3d", dx, dy, bench_settings.text_3d, action_bench_text_3d)
			draw_checkbox("benchtextfacecamera", dx + floor(dw / 4), dy, bench_settings.text_face_camera, action_bench_text_face_camera)
			dy += 16
			break
		}
		
		case e_temp_type.CUBE: 
		case e_temp_type.CONE: 
		case e_temp_type.CYLINDER: 
		case e_temp_type.SPHERE: 
		case e_temp_type.SURFACE: // Shapes
		{
			// Texture
			var text, tex;
			text = text_get("listnone")
			tex = null
			if (bench_settings.shape_tex)
			{
				text = bench_settings.shape_tex.display_name
				if (bench_settings.shape_tex.type != e_tl_type.CAMERA)
					tex = bench_settings.shape_tex.texture
			}
			draw_button_menu("benchshapetex", e_menu.LIST, dx, dy, dw, 40, bench_settings.shape_tex, text, action_bench_shape_tex, tex)
			dy += 40 + 8
			
			// Is mapped
			if (bench_settings.type = e_temp_type.CUBE || 
				bench_settings.type = e_temp_type.CYLINDER || 
				bench_settings.type = e_temp_type.CONE)
			{
				draw_checkbox("benchshapetexmap", dx, dy, bench_settings.shape_tex_mapped, action_bench_shape_tex_map)
				dy += 16
			}
			else if (bench_settings.type = e_temp_type.SURFACE)
			{
				draw_checkbox("benchshapefacecamera", dx, dy, bench_settings.shape_face_camera, action_bench_shape_face_camera)
				dy += 16
			}
			
			break
		}
		
		case e_temp_type.MODEL:
		{
			var capwid = text_caption_width("benchmodel", "benchmodeltex");
			
			// Model
			var text;
			if (bench_settings.model != null)
				text = bench_settings.model.display_name
			else
				text = text_get("listnone")
			draw_button_menu("benchmodel", e_menu.LIST, dx, dy, dw, 32, bench_settings.model, text, action_bench_model, null, null, capwid)
			dy += 32 + 8

			// Texture
			var texobj, tex;
			with (bench_settings)
			{
				texobj = temp_get_model_texobj(null)
				tex = temp_get_model_tex_preview(texobj, model_file)
			}
		
			if (texobj != null)
				text = texobj.display_name
			else
				text = text_get("listnone")
			
			// Default
			if (bench_settings.model_tex = null)
				text = text_get("listdefault", text)
		
			draw_button_menu("benchmodeltex", e_menu.LIST, dx, dy, dw, 40, bench_settings.model_tex, text, action_bench_model_tex, tex, null, capwid)
			dy += 40
			break
		}
	}
	
	dy += 10
	buttony = dy
	dy += 32 + padding * 2 - 1
}

if (draw_button_normal("benchcreate", dx + floor(dw / 2) - 50, floor(buttony), 100, 32))
{
	action_bench_create()
	bench_show_ani_type = "hide"
}

bench_settings.width_goal = bench_settings.width_custom + 370
bench_settings.height_goal = bench_settings.height_custom + max(bench_height, dy - sdy - bench_settings.height_custom * (listh > 0))
