/// bench_draw_settings(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var height, type, buttony;
dx = argument0
dy = argument1
dw = argument2
dh = argument3

content_x = dx
content_y = dy
content_width = dw
content_height = dh

height = 0
type = bench_settings.type

if (type_is_timeline(type))
{
    buttony = dy + dh / 2-16
}
else
{
    buttony = dy + dh - 35
    dh -= 40
    
    // Preview
    preview_draw(bench_settings.preview, dx + floor(dw / 2) - 80, dy, 160)
    dy += 160 + 10
    dh -= 160 + 10
    
    // Settings
    switch (type)
	{
        case "char":
		{
            var text, texture, listh;
            height = 540
            
            // Model
            draw_label(text_get("benchcharmodel") + ":", dx, dy + 8, fa_left, fa_middle)
            dy += 22
            listh = dh - 102
            sortlist_draw(bench_settings.char_list, dx, dy, dw, listh, bench_settings.char_model)
            dy += listh + 30
            
            // Skin
            text = bench_settings.char_skin.display_name
			with (bench_settings.char_skin)
				texture = res_model_texture(other.bench_settings.char_model)
            draw_button_menu("benchcharskin", e_menu.LIST, dx, dy, dw, 40, bench_settings.char_skin, text, action_bench_char_skin, texture)
            break
        }
		
        case "scenery":
		{
            var capwid, text, tex;
            height = 355
            capwid = text_caption_width("benchschematic", "benchblocktex")
            
            // Schematic
            text = text_get("listnone")
            if (bench_settings.scenery)
                text = bench_settings.scenery.display_name
            draw_button_menu("benchschematic", e_menu.LIST, dx, dy, dw, 32, bench_settings.scenery, text, action_bench_scenery, null, null, capwid)
            dy += 32 + 8

            // Texture
            draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
            break
        }
		
        case "item":
		{
            var capwid, res, text, sprite;
            height = 550
            capwid = text_caption_width("typeitem", "benchitemtex")
            res = bench_settings.item_tex
            if (!res.ready)
                res = res_def
            
            // Preview
            draw_label(text_get("typeitem") + ":", dx, dy + 8, fa_left, fa_middle)
            if (bench_settings.item_sheet)
                draw_texture_slot(res.item_texture, bench_settings.item_n, dx + capwid, dy, 16, 16)
            else
                draw_texture(res.item_texture, dx + capwid, dy, 16 / texture_width(res.item_texture), 16 / texture_height(res.item_texture))
            dy += 22
            
            // Item select
            if (bench_settings.item_sheet)
			{
                var boxh = dh - 105;
                draw_texture_picker(res.item_texture, dx, dy, dw, boxh, bench_settings.item_n, null, 16, 16, bench_settings.item_scroll, action_bench_item_n)
                dy += boxh + 8
            }
            
            // Image
            draw_button_menu("benchitemtex", e_menu.LIST, dx, dy, dw, 40, bench_settings.item_tex, bench_settings.item_tex.display_name, action_bench_item_tex, bench_settings.item_tex.block_preview_texture, null, capwid)
            dy += 40 + 8
            
            // Settings
            draw_checkbox("benchitem3d", dx, dy, bench_settings.item_3d, action_bench_item_3d)
            draw_checkbox("benchitemfacecamera", dx + floor(dw * 0.3), dy, bench_settings.item_face_camera, action_bench_item_face_camera)
            draw_checkbox("benchitembounce", dx + floor(dw * 0.7), dy, bench_settings.item_bounce, action_bench_item_bounce)
            break
        }
		
        case "block":
		{
            var capwid, text, sprite, listh;
            height = 578
            capwid = text_caption_width("benchblockdata", "benchblocktex")
            
            // Block
            draw_label(text_get("benchblock") + ":", dx, dy + 8, fa_left, fa_middle)
            dy += 22
            listh = dh - 140
            bench_settings.block_list.block_data = bench_settings.block_data
            sortlist_draw(bench_settings.block_list, dx, dy, dw, listh, bench_settings.block_id)
            dy += listh + 30
            
            // Data
            draw_meter("benchblockdata", dx, dy, dw, bench_settings.block_data, 50, 0, 15, 0, 1, bench_settings.block_tbx_data, action_bench_block_data, capwid)
            dy += 30 + 8
        
            // Texture
            draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
            break
        }
		
        case "spblock":
		{
            height = 540
            
            // Model
            draw_label(text_get("benchspblockmodel") + ":", dx, dy + 8, fa_left, fa_middle)
            dy += 22
            var listh = dh - 102;
            sortlist_draw(bench_settings.spblock_list, dx, dy, dw, listh, bench_settings.char_model)
            dy += listh + 30
            
            // Texture
            //draw_button_menu("benchspblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.char_skin, bench_settings.char_skin.display_name, action_bench_char_skin, bench_settings.char_skin.mob_texture[bench_settings.char_model.index])
            break
        }
		
        case "bodypart":
		{
            var capwid, listh;
            height = 572
            capwid = text_caption_width("benchbodypart", "benchbodypartskin")
            
            // Model
            draw_label(text_get("benchmodel") + ":", dx, dy + 8, fa_left, fa_middle)
            dy += 22
            listh = dh - 134
            sortlist_draw(bench_settings.bodypart_char_list, dx, dy, dw, listh, bench_settings.char_model)
            dy += listh + 30
            
            // Bodypart
            //draw_button_menu("benchbodypart", e_menu.LIST, dx, dy, dw, 24, bench_settings.char_bodypart, text_get(bench_settings.char_model.part_name[bench_settings.char_bodypart]), action_bench_char_bodypart, null, 0, capwid)
            dy += 24 + 8
                    
            // Skin
            //draw_button_menu("benchbodypartskin", e_menu.LIST, dx, dy, dw, 40, bench_settings.char_skin, bench_settings.char_skin.display_name, action_bench_char_skin, bench_settings.char_skin.mob_texture[bench_settings.char_model.index], null, capwid)
            break
        }
		
        case "particles":
		{
            height = 490
            
            // Particles
            draw_label(text_get("benchparticlespreset") + ":", dx, dy + 8, fa_left, fa_middle)
            dy += 22
            sortlist_draw(bench_settings.particles_list, dx, dy, dw, dh - 22 - 30, bench_settings.particle_preset)
            break
        }
		
        case "text":
		{
            height = 330
            
            // Font
            draw_button_menu("benchtextfont", e_menu.LIST, dx, dy, dw, 32, bench_settings.text_font, bench_settings.text_font.display_name, action_bench_text_font)
            dy += 32 + 8
            
            // Face camera
            draw_checkbox("benchtextfacecamera", dx, dy, bench_settings.text_face_camera, action_bench_text_face_camera)
            break
        }
		
        default: // Shapes
		{
            height = 315
        
            // Texture
            var text, tex;
            text = text_get("listnone")
            tex = null
            if (bench_settings.shape_tex)
			{
                text = bench_settings.shape_tex.display_name
                if (bench_settings.shape_tex.type != "camera")
                    tex = bench_settings.shape_tex.texture
            }
            draw_button_menu("benchshapetex", e_menu.LIST, dx, dy, dw, 40, bench_settings.shape_tex, text, action_bench_shape_tex, tex)
            dy += 40 + 8
			
            // Is mapped
            if (bench_settings.type = "cube" || 
                bench_settings.type = "cylinder" || 
                bench_settings.type = "cone")
			{
                draw_checkbox("benchshapetexmap", dx, dy, bench_settings.shape_tex_mapped, action_bench_shape_tex_map)
                height += 16
            }
			else if (bench_settings.type = "surface")
			{
                draw_checkbox("benchshapefacecamera", dx, dy, bench_settings.shape_face_camera, action_bench_shape_face_camera)
                height += 16
            }
            
            break
		}
    }
}

if (draw_button_normal("benchcreate", dx + floor(dw / 2) - 50, floor(buttony), 100, 32))
{
    action_bench_create()
    bench_show_ani_type = "hide"
}

bench_settings.width_goal = bench_settings.width_custom + 370
bench_settings.height_goal = bench_settings.height_custom + max(bench_height, height)
