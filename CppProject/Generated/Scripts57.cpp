/*
	NOTE:
	This file was autogenerated by CppGen, changes may be overwritten and forever lost!
	Modify at your own risk!
	
	[ Generated on 2023.09.15 16:12:12 ]
*/

#include "Scripts.hpp"

namespace CppProject
{
	RealType sortlist_draw(ScopeAny self, IntType slist, VarType xx, VarType yy, VarType w, RealType h, VarType select, BoolType filter, VarType name)
	{
		if (xx + w < sVar(content_x) || xx > sVar(content_x) + sVar(content_width) || yy + h < sVar(content_y) || yy > sVar(content_y) + sVar(content_height))
		{
			if (sBool(textbox_jump))
				ds_list_add({ sInt(textbox_list), ArrType::From({ idInt(slist, search_tbx), sVar(content_tab), yy, sVar(content_y), sVar(content_height) }) });
			return IntType(0);
		}
		BoolType colmouseon;
		VarType searchx, searchw, dy;
		RealType itemh, colsh;
		searchx = xx;
		searchw = w;
		itemh = sReal(ui_small_height);
		colsh = sReal(ui_small_height);
		if (filter && name == /*""*/ STR(0))
		{
			if (draw_button_icon(self, { /*"listfilter"*/ STR(2974) + string(slist), xx, yy, IntType(24), IntType(24), !ds_list_empty(idInt(slist, filter_list)), icons_FILTER, null_, false, /*"tooltipfilterlist"*/ STR(2975) }))
			{
				menu_settings_set(self, xx, yy, /*"listfilter"*/ STR(2974) + string(slist), IntType(24));
				sInt(settings_menu_script) = ID_sortlist_filters_draw;
				sVar(settings_menu_sortlist) = slist;
				sVar(settings_menu_h_max) = IntType(256);
			}
			if ((sStr(settings_menu_name) == /*"listfilter"*/ STR(2974) + string(slist)) && sStr(settings_menu_ani_type) != /*"hide"*/ STR(720))
				ObjType(value_animation, ObjType(micro_animation, global::current_microani)->active)->value = true;
			searchx += IntType(32);
			searchw -= 32.0;
		}
		if (name != /*""*/ STR(0))
		{
			draw_set_font(sInt(font_label));
			draw_label(self, { string_limit(name, w - IntType(144)), xx, yy + IntType(12), fa_left, fa_middle, global::c_text_secondary, global::a_text_secondary });
			searchx += (w - IntType(144));
			searchw -= (w - IntType(144));
		}
		if (draw_textfield(self, /*"listsearch"*/ STR(2976) + string(slist), searchx, yy, searchw, IntType(24), idInt(slist, search_tbx), null_, text_get({ /*"listsearch"*/ STR(2976) }), /*"none"*/ STR(878)))
		{
			ObjType(obj_scrollbar, idInt(slist, scroll))->value = IntType(0);
			ObjType(obj_scrollbar, idInt(slist, scroll))->value_goal = IntType(0);
			idBool(slist, search) = (ObjType(obj_textbox, idInt(slist, search_tbx))->text != /*""*/ STR(0));
			sortlist_update(self, slist);
			if (string_length(ObjType(obj_textbox, idInt(slist, search_tbx))->text) > IntType(1))
			{
				if (slist == ObjType(obj_bench_settings, sInt(bench_settings))->block_list)
					action_bench_block_name(self, ObjType(obj_bench_settings, sInt(bench_settings))->block_name);
				else
					if (slist == ObjType(obj_bench_settings, sInt(bench_settings))->char_list || slist == ObjType(obj_bench_settings, sInt(bench_settings))->special_block_list || slist == ObjType(obj_bench_settings, sInt(bench_settings))->bodypart_model_list)
						action_bench_model_name(self, ObjType(obj_bench_settings, sInt(bench_settings))->model_name);
				
			}
		}
		h -= 32.0;
		yy += IntType(32);
		if (h < colsh)
			return IntType(0);
		colmouseon = app_mouse_box(self, xx, yy, w, colsh) && sBool(content_mouseon);
		if (sVar(window_busy) == /*"sortlist_resize"*/ STR(2977) && sInt(sortlist_resize) == slist)
		{
			idArr(slist, column_x)[sInt(sortlist_resize_column)] = sReal(sortlist_resize_column_x) + (gmlGlobal::mouse_x - sInt(mouse_click_x)) / w;
			idArr(slist, column_x)[sInt(sortlist_resize_column)] = clamp(IntType(0), idArr(slist, column_x).Value(sInt(sortlist_resize_column)), 0.9);
			if (sInt(sortlist_resize_column) > IntType(0))
				idArr(slist, column_x)[sInt(sortlist_resize_column)] = max({ idArr(slist, column_x).Value(sInt(sortlist_resize_column)), idArr(slist, column_x).Value(sInt(sortlist_resize_column) - IntType(1)) + 0.1 });
			if (sInt(sortlist_resize_column) < idInt(slist, columns) - IntType(1))
				idArr(slist, column_x)[sInt(sortlist_resize_column)] = min({ idArr(slist, column_x).Value(sInt(sortlist_resize_column)), idArr(slist, column_x).Value(sInt(sortlist_resize_column) + IntType(1)) - 0.1 });
			sInt(mouse_cursor) = cr_size_we;
			if (!sBool(mouse_left))
			{
				sVar(window_busy) = /*""*/ STR(0);
				app_mouse_clear(self);
			}
		}
		for (IntType c = IntType(0); c < idInt(slist, columns); c++)
		{
			RealType dx;
			IntType icon;
			dx = floor(idArr(slist, column_x).Value(c) * w);
			if (c == idInt(slist, columns) - IntType(1))
				idArr(slist, column_w)[c] = ceil(w - dx);
			else
				idArr(slist, column_w)[c] = ceil(idArr(slist, column_x).Value(c + IntType(1)) * w) - dx;
			
			if (c > IntType(0) && app_mouse_box(self, xx + dx - IntType(5), yy, IntType(10), colsh) && sBool(content_mouseon))
			{
				sInt(mouse_cursor) = cr_size_we;
				if (sBool(mouse_left_pressed))
				{
					sInt(sortlist_resize) = slist;
					sInt(sortlist_resize_column) = c;
					sReal(sortlist_resize_column_x) = idArr(slist, column_x).Value(c);
					sVar(window_busy) = /*"sortlist_resize"*/ STR(2977);
				}
			}
			icon = null_;
			if (idInt(slist, column_sort) == c)
				icon = ((idReal(slist, sort_asc) > 0) ? icons_SORT_UP : icons_SORT_DOWN);
			if (sortlist_draw_button(self, /*"column"*/ STR(2978) + idArr(slist, column_name).Value(c), xx + dx, yy + IntType(4), idArr(slist, column_w).Value(c), colsh, idInt(slist, column_sort) == c, icon, (c == IntType(0)), (c == idInt(slist, columns) - IntType(1)), colmouseon))
			{
				if (idInt(slist, column_sort) == c)
				{
					if (idReal(slist, sort_asc) > 0)
					{
						idInt(slist, column_sort) = null_;
						idReal(slist, sort_asc) = false;
					}
					else
						idReal(slist, sort_asc) = true;
					
				}
				else
					idInt(slist, column_sort) = c;
				
				sortlist_update(self, slist);
			}
		}
		dy = (yy + colsh) + IntType(10);
		draw_divide(xx + IntType(1), dy - IntType(3), w - IntType(2));
		if (sVar(window_focus) == string(idInt(slist, scroll)))
		{
			draw_outline(xx, yy, w, h, IntType(1), global::c_accent, IntType(1), true);
			sStr(window_scroll_focus) = string(idInt(slist, scroll));
			if (!app_mouse_box(self, xx, yy, w, h) && sBool(content_mouseon) && sBool(mouse_left) && sVar(window_busy) != /*"scrollbar"*/ STR(2639))
				sVar(window_focus) = /*""*/ STR(0);
		}
		else
			draw_outline(xx, yy, w, h, IntType(1), global::c_border, global::a_border, true);
		
		draw_set_font(sInt(font_value));
		for (RealType i = round((RealType)ObjType(obj_scrollbar, idInt(slist, scroll))->value / itemh); i < ds_list_size(idInt(slist, display_list)); i++)
		{
			if (dy + itemh > yy + h)
				break;
			VarType value;
			RealType dw, selected;
			BoolType mouseon;
			value = DsList(idInt(slist, display_list)).Value(i);
			dw = w - IntType(12) * (IntType)ObjType(obj_scrollbar, idInt(slist, scroll))->needed;
			selected = (select == value);
			mouseon = (app_mouse_box(self, xx, dy, dw, itemh) && sBool(content_mouseon));
			if (selected > 0 || mouseon && sBool(mouse_left))
			{
				draw_box(xx, dy, dw, itemh, false, global::c_accent_overlay, global::a_accent_overlay);
				if (mouseon && sBool(mouse_left))
					draw_box_hover({ xx, dy, dw, itemh, IntType(1) });
			}
			else
				if (mouseon)
					draw_box(xx, dy, dw, itemh, false, global::c_overlay, global::a_overlay);
			
			for (IntType c = IntType(0); c < idInt(slist, columns); c++)
			{
				VarType dx, text;
				RealType wid, islast;
				dx = xx + floor(idArr(slist, column_x).Value(c) * w) + IntType(8);
				wid = idArr(slist, column_w).Value(c) - IntType(8);
				if (c == idInt(slist, columns) - IntType(1) && ObjType(obj_scrollbar, idInt(slist, scroll))->needed)
					wid -= 12.0;
				islast = (c == idInt(slist, columns) - IntType(1)) && (c != IntType(0));
				text = string_limit(string(sortlist_column_get(slist, value, c)), wid);
				draw_label(self, { text, dx + ((wid - IntType(8)) * islast), dy + itemh / 2.0, (islast > 0) ? fa_right : fa_left, fa_middle, (selected > 0) ? global::c_accent : global::c_text_main, (selected > 0) ? 1.0 : global::a_text_main });
			}
			if (mouseon)
			{
				sInt(mouse_cursor) = cr_handpoint;
				if (sBool(mouse_left_released))
				{
					if (idBool(slist, can_deselect) && selected > 0)
						script_execute(self, { idVar(slist, script), null_ });
					else
						script_execute(self, { idVar(slist, script), value });
					
					app_mouse_clear(self);
					if (ObjType(obj_scrollbar, idInt(slist, scroll))->needed)
						sVar(window_focus) = string(idInt(slist, scroll));
				}
			}
			dy += itemh;
		}
		ObjType(obj_scrollbar, idInt(slist, scroll))->snap_value = itemh;
		scrollbar_draw(self, idInt(slist, scroll), e_scroll_VERTICAL, xx + w - IntType(12), yy + (colsh + IntType(10)), floor((h - (colsh + IntType(10))) / itemh) * itemh, ds_list_size(idInt(slist, display_list)) * itemh);
		return 0.0;
	}
	
	BoolType sortlist_draw_button(ScopeAny self, StringType name, VarType xx, VarType yy, RealType w, RealType h, BoolType highlight, IntType icon, BoolType isfirst, BoolType islast, BoolType listmouseon)
	{
		BoolType pressed, mouseon;
		RealType wlimit;
		VarType text;
		wlimit = w - IntType(16);
		mouseon = (app_mouse_box(self, xx, yy, w - IntType(5), h) && sBool(content_mouseon) && sInt(mouse_cursor) == cr_default);
		pressed = highlight;
		if (mouseon)
		{
			if (sBool(mouse_left) || sBool(mouse_left_released))
				pressed = true;
			sInt(mouse_cursor) = cr_handpoint;
		}
		if (!isfirst && listmouseon)
			draw_line_ext(xx - IntType(1), yy + IntType(4), xx - IntType(1), yy + h - IntType(4), global::c_text_tertiary, global::a_text_tertiary);
		draw_set_font(sInt(font_label));
		if (icon != null_ && mouseon)
			wlimit -= 28.0;
		wlimit = max({ IntType(0), wlimit });
		text = string_limit(text_get({ name }), wlimit);
		if (icon != null_ && mouseon && wlimit > IntType(28))
			draw_image({ ID_spr_icons, icon, xx + IntType(8) + string_width(text) + IntType(4) + IntType(12), yy + h / 2.0, IntType(1), IntType(1), global::c_text_secondary, global::a_text_secondary });
		if (!islast || isfirst)
		{
			draw_label(self, { text, xx + IntType(8), yy + h / 2.0, fa_left, fa_middle, global::c_text_secondary, global::a_text_secondary });
		}
		else
		{
			RealType textoff;
			if (icon != null_ && mouseon)
				textoff = IntType(28);
			else
				textoff = IntType(0);
			
			draw_label(self, { text, xx + (w - IntType(8)) - textoff, yy + h / 2.0, fa_right, fa_middle, global::c_text_secondary, global::a_text_secondary });
		}
		
		if (mouseon && sBool(mouse_left_released))
		{
			app_mouse_clear(self);
			return true;
		}
		return false;
	}
	
	void sortlist_event_create(Scope<obj_sortlist> self)
	{
		self->list = ds_list_create();
		self->columns = IntType(0);
		self->column_name[IntType(0)] = /*""*/ STR(0);
		self->column_text[IntType(0)] = /*""*/ STR(0);
		self->column_x[IntType(0)] = IntType(0);
		self->column_sort = null_;
		self->sort_asc = false;
		self->search = false;
		self->search_tbx = new_textbox(true, IntType(0), /*""*/ STR(0));
		self->display_list = ds_list_create();
		self->scroll = (new obj_scrollbar)->id;
		self->script = null_;
		self->can_deselect = false;
		self->filter_list = ds_list_create();
	}
	
	RealType sortlist_filters_draw(ScopeAny self)
	{
		IntType typelist, capwid;
		VarType scroll, itemname;
		typelist = null_;
		scroll = IntType(0);
		capwid = IntType(0);
		if (sVar(settings_menu_sortlist) == ObjType(obj_category, ObjType(obj_tab, global::_app->properties)->library)->list)
			typelist = global::temp_type_name_list;
		if (sVar(settings_menu_sortlist) == ObjType(obj_category, ObjType(obj_tab, global::_app->properties)->resources)->list)
			typelist = global::res_type_name_list;
		if (typelist == null_)
			return IntType(0);
		clip_begin(sVar(content_x), sVar(content_y), sVar(settings_menu_w), sVar(settings_menu_h));
		if (ObjType(obj_scrollbar, sInt(settings_menu_scroll))->needed)
			scroll = -ObjType(obj_scrollbar, sInt(settings_menu_scroll))->value;
		else
			scroll = IntType(0);
		
		draw_set_font(sInt(font_label));
		for (IntType i = IntType(0); i < ds_list_size(typelist); i++)
		{
			itemname = DsList(typelist).Value(i);
			if (typelist == global::res_type_name_list)
			{
				if (itemname == /*"packunzipped"*/ STR(537) || itemname == /*"legacyblocksheet"*/ STR(540) || itemname == /*"fromworld"*/ STR(542))
					continue;
			}
			capwid = max({ capwid, string_width(text_get({ /*"type"*/ STR(775) + itemname })) });
			BoolType active = ds_list_find_index(idInt(sVar(settings_menu_sortlist), filter_list), DsList(typelist).Value(i)) != -IntType(1);
			tab_control_checkbox(self);
			if (draw_checkbox(self, /*"type"*/ STR(775) + itemname, sVar(dx), sVar(dy) + scroll, active, null_))
			{
				if (active)
					ds_list_delete_value(idInt(sVar(settings_menu_sortlist), filter_list), DsList(typelist).Value(i));
				else
					ds_list_add({ idInt(sVar(settings_menu_sortlist), filter_list), DsList(typelist).Value(i) });
				
				sortlist_update(self, sVar(settings_menu_sortlist));
			}
			tab_next(self);
		}
		clip_end();
		sVar(settings_menu_w) = (IntType(32) + capwid) + IntType(32) + IntType(24);
		return 0.0;
	}
	
	VarType sortlist_remove(IntType sl, IntType value)
	{
		RealType index = ds_list_find_index(idInt(sl, list), value);
		if (index < IntType(0))
			return null_;
		ds_list_delete(idInt(sl, list), (IntType)(index));
		ds_list_delete(idInt(sl, display_list), ds_list_find_index(idInt(sl, display_list), value));
		index = min({ ds_list_size(idInt(sl, list)) - IntType(1), index });
		if (index < IntType(0))
			return null_;
		return DsList(idInt(sl, list)).Value(index);
	}
	
	void sortlist_update(ScopeAny self, VarType slist)
	{
		ds_list_clear(idInt(slist, display_list));
		if (idInt(slist, column_sort) != null_)
		{
			IntType sortedlist, valuelist;
			sortedlist = ds_list_create();
			valuelist = ds_list_create();
			ds_list_copy(valuelist, idInt(slist, list));
			for (IntType p = IntType(0); p < ds_list_size(valuelist); p++)
				ds_list_add({ sortedlist, string_lower(sortlist_column_get(slist, DsList(valuelist).Value(p), idInt(slist, column_sort))) });
			ds_list_sort(sortedlist, !(idReal(slist, sort_asc) > 0));
			while (ds_list_size(sortedlist) > IntType(0))
			{
				for (IntType p = IntType(0); p < ds_list_size(valuelist); p++)
				{
					VarType val;
					StringType colval;
					val = DsList(valuelist).Value(p);
					colval = string_lower(sortlist_column_get(slist, val, idInt(slist, column_sort)));
					if (DsList(sortedlist).Value(IntType(0)) == colval)
					{
						ds_list_add({ idInt(slist, display_list), val });
						ds_list_delete(valuelist, p);
						ds_list_delete(sortedlist, IntType(0));
						break;
					}
				}
			}
			
			ds_list_destroy(sortedlist);
			ds_list_destroy(valuelist);
		}
		else
			ds_list_copy(idInt(slist, display_list), idInt(slist, list));
		
		StringType check = string_lower(ObjType(obj_textbox, idInt(slist, search_tbx))->text);
		BoolType modellist = (slist == ObjType(obj_bench_settings, sInt(bench_settings))->char_list || slist == ObjType(obj_bench_settings, sInt(bench_settings))->special_block_list || slist == ObjType(obj_bench_settings, sInt(bench_settings))->bodypart_model_list || slist == ObjType(obj_tab, sInt(template_editor))->char_list || slist == ObjType(obj_tab, sInt(template_editor))->special_block_list || slist == ObjType(obj_tab, sInt(template_editor))->bodypart_model_list);
		BoolType blocklist = (slist == ObjType(obj_bench_settings, sInt(bench_settings))->block_list || slist == ObjType(obj_tab, sInt(template_editor))->block_list);
		if (idBool(slist, search) && check != /*""*/ STR(0) && !blocklist && !modellist)
		{
			for (IntType p = IntType(0); p < ds_list_size(idInt(slist, display_list)); p++)
			{
				VarType val;
				BoolType match;
				val = DsList(idInt(slist, display_list)).Value(p);
				match = false;
				for (IntType c = IntType(0); c < idInt(slist, columns); c++)
				{
					if (string_count(check, string_lower(string(sortlist_column_get(slist, val, c)))) > IntType(0))
					{
						match = true;
						break;
					}
				}
				if (!match)
				{
					ds_list_delete(idInt(slist, display_list), p);
					p--;
				}
			}
		}
		else
			if (idBool(slist, search) && check != /*""*/ STR(0) && blocklist)
			{
				for (IntType p = IntType(0); p < ds_list_size(idInt(slist, display_list)); p++)
				{
					VarType name;
					BoolType match;
					name = DsList(idInt(slist, display_list)).Value(p);
					match = false;
					VarType block = DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->block_name_map).Value(name);
					for (IntType i = IntType(0); i < array_length(VarType::CreateRef(ObjType(obj_block, block)->default_state)) && !match; i += IntType(2))
					{
						StringType state = ObjType(obj_block, block)->default_state.Value(i);
						IntType statecurrent = DsMap(ObjType(obj_block, block)->states_map).Value(state);
						for (IntType s = IntType(0); s < idReal(statecurrent, value_amount) && !match; s++)
							if (string_count(check, string_lower(minecraft_asset_get_name(/*"blockstatevalue"*/ STR(5), idVar(statecurrent, value_name).Value(s)))) > IntType(0))
								match = true;
						if (string_count(check, string_lower(text_get({ /*"blockstate"*/ STR(766) + state }))) > IntType(0))
							match = true;
					}
					if (!match && string_count(check, string_lower(minecraft_asset_get_name(/*"block"*/ STR(4), name))) > IntType(0))
						match = true;
					if (!match)
					{
						ds_list_delete(idInt(slist, display_list), p);
						p--;
					}
				}
			}
			else
				if (idBool(slist, search) && check != /*""*/ STR(0) && modellist)
				{
					for (IntType p = IntType(0); p < ds_list_size(idInt(slist, display_list)); p++)
					{
						VarType name;
						BoolType match;
						name = DsList(idInt(slist, display_list)).Value(p);
						match = false;
						VarType model = DsMap(ObjType(obj_minecraft_assets, global::mc_assets)->model_name_map).Value(name);
						for (IntType i = IntType(0); i < array_length(VarType::CreateRef(ObjType(obj_model, model)->default_state)) && !match; i += IntType(2))
						{
							StringType state = ObjType(obj_model, model)->default_state.Value(i);
							IntType statecurrent = DsMap(ObjType(obj_model, model)->states_map).Value(state);
							for (IntType s = IntType(0); s < idReal(statecurrent, value_amount) && !match; s++)
								if (string_count(check, string_lower(minecraft_asset_get_name(/*"modelstatevalue"*/ STR(9), idVar(statecurrent, value_name).Value(s)))) > IntType(0))
									match = true;
							if (string_count(check, string_lower(text_get({ /*"modelstate"*/ STR(745) + state }))) > IntType(0))
								match = true;
						}
						if (!match && string_count(check, string_lower(minecraft_asset_get_name(/*"model"*/ STR(8), name))) > IntType(0))
							match = true;
						if (!match)
						{
							ds_list_delete(idInt(slist, display_list), p);
							p--;
						}
					}
				}
		
		
		if (idInt(slist, column_sort) == null_ && idBool(slist, search) && check != /*""*/ STR(0) && (blocklist || modellist))
		{
			ArrType namelist, variantlist;
			namelist = ArrType::From({});
			variantlist = ArrType::From({});
			for (IntType i = IntType(0); i < ds_list_size(idInt(slist, display_list)); i++)
			{
				if (string_contains(string_lower(string(sortlist_column_get(slist, DsList(idInt(slist, display_list)).Value(i), IntType(0)))), check))
					array_add(VarType::CreateRef(namelist), DsList(idInt(slist, display_list)).Value(i));
				else
					array_add(VarType::CreateRef(variantlist), DsList(idInt(slist, display_list)).Value(i));
				
			}
			ds_list_clear(idInt(slist, display_list));
			for (IntType i = IntType(0); i < array_length(VarType::CreateRef(namelist)); i++)
				ds_list_add({ idInt(slist, display_list), namelist.Value(i) });
			for (IntType i = IntType(0); i < array_length(VarType::CreateRef(variantlist)); i++)
				ds_list_add({ idInt(slist, display_list), variantlist.Value(i) });
		}
		if (!ds_list_empty(idInt(slist, filter_list)))
		{
			for (IntType p = IntType(0); p < ds_list_size(idInt(slist, display_list)); p++)
			{
				VarType item = DsList(idInt(slist, display_list)).Value(p);
				if (sVar(settings_menu_sortlist) == ObjType(obj_category, ObjType(obj_tab, global::_app->properties)->library)->list)
				{
					if (ds_list_find_index(idInt(slist, filter_list), DsList(global::temp_type_name_list).Value(idVar(item, type))) == -IntType(1))
					{
						ds_list_delete(idInt(slist, display_list), p);
						p--;
					}
				}
				if (sVar(settings_menu_sortlist) == ObjType(obj_category, ObjType(obj_tab, global::_app->properties)->resources)->list)
				{
					if (ds_list_find_index(idInt(slist, filter_list), DsList(global::res_type_name_list).Value(idVar(item, type))) == -IntType(1))
					{
						ds_list_delete(idInt(slist, display_list), p);
						p--;
					}
				}
			}
		}
	}
	
	VarType spline_get_point(RealType t, VarType points, VarType closed, VarType smooth, RealType amount)
	{
		RealType p0, p1, p2, seg, curvet;
		seg = floor(t / 2.0) * IntType(2);
		p0 = seg;
		p1 = p0 + IntType(1);
		p2 = p1 + IntType(1);
		curvet = percent(t, p0, p2);
		if (amount == IntType(0))
			amount = array_length(VarType::CreateRef(points));
		if (closed > 0)
		{
			p0 = mod_fix(p0, amount);
			p1 = mod_fix(p1, amount);
			p2 = mod_fix(p2, amount);
		}
		else
		{
			p0 = max({ IntType(0), min({ p0, amount - IntType(1) }) });
			p1 = max({ IntType(0), min({ p1, amount - IntType(1) }) });
			p2 = max({ IntType(0), min({ p2, amount - IntType(1) }) });
		}
		
		if (amount == array_length(VarType::CreateRef(points)))
			curvet = percent(t, p0, p2);
		if (!(closed > 0) && (t <= IntType(0) || t >= amount - IntType(1)))
		{
			RealType i;
			VarType point;
			VecType pos;
			if (t <= IntType(0))
			{
				i = IntType(0);
				pos = vec3_add(points.Value(i), vec3_mul(vec3_normalize(vec3_sub(points.Value(i), points.Value(i + IntType(1)))), abs(t)));
			}
			else
			{
				i = array_length(VarType::CreateRef(points)) - IntType(1);
				pos = vec3_add(points.Value(i), vec3_mul(ArrType::From({ points[i - IntType(1)][PATH_TANGENT_X], points[i - IntType(1)][PATH_TANGENT_Y], points[i - IntType(1)][PATH_TANGENT_Z] }), abs(t - i)));
			}
			
			point = array_copy_1d(points.Value(i));
			point[X_] = pos.Real(X_);
			point[Y_] = pos.Real(Y_);
			point[Z_] = pos.Real(Z_);
			point[PATH_TANGENT_X] = point.Value(PATH_TANGENT_X);
			return point;
		}
		if (smooth > 0)
			return bezier_curve_quad(points.Value(p0), points.Value(p1), points.Value(p2), curvet);
		else
		{
			if (curvet < 0.5)
				return point_lerp(points.Value(p0), points.Value(p1), curvet * IntType(2));
			else
				return point_lerp(points.Value(p1), points.Value(p2), (curvet - 0.5) * IntType(2));
			
		}
		
		return VarType();
	}
	
	void spline_make_frames(VarType points, VarType closed, VarType smooth)
	{
		VarType p, pn, t, tn;
		VecType n, nn, rn;
		IntType j;
		p = spline_get_point(IntType(0), points, closed, smooth);
		pn = spline_get_point(IntType(1), points, closed, smooth);
		t = vec3_direction(p, pn);
		if (t.Value(Z_) == IntType(1) || t.Value(Z_) == -IntType(1))
			n = ArrType::From({ t.Value(Z_), IntType(0), IntType(0) });
		else
			n = vec3_normal(t, IntType(0));
		
		for (j = X_; j <= Z_; j++)
		{
			points.Arr()[IntType(0)][PATH_TANGENT_X + j] = t.Value(j);
			points.Arr()[IntType(0)][PATH_NORMAL_X + j] = n.Real(j);
		}
		p = pn;
		VecType axis;
		RealType angle;
		for (IntType i = IntType(1); i < array_length(VarType::CreateRef(points.Arr())); i++)
		{
			pn = spline_get_point(i + IntType(1), points, closed, smooth);
			tn = vec3_direction(p, pn);
			axis = vec3_normalize(vec3_cross(t, tn));
			angle = vec3_dot(t, tn);
			nn = vec3_normalize(vec3_mul_matrix(n, matrix_create_axis_angle(axis, angle)));
			rn = vec3_rotate_axis_angle(nn, tn, degtorad(pn.Value(W_)));
			for (j = X_; j <= Z_; j++)
			{
				points.Arr()[i][PATH_TANGENT_X + j] = tn.Value(j);
				points.Arr()[i][PATH_NORMAL_X + j] = rn.Real(j);
			}
			p = pn;
			n = nn;
			t = tn;
		}
		if (closed > 0)
		{
			RealType i;
			VarType p, pn;
			VecType t, n;
			i = array_length(VarType::CreateRef(points.Arr())) - IntType(2);
			p = points.Value(i - IntType(1));
			pn = points.Value(IntType(0));
			t = vec3_normalize(ArrType::From({ p.Value(PATH_TANGENT_X) + pn.Value(PATH_TANGENT_X), p.Value(PATH_TANGENT_Y) + pn.Value(PATH_TANGENT_Y), p.Value(PATH_TANGENT_Z) + pn.Value(PATH_TANGENT_Z) }));
			n = vec3_normalize(ArrType::From({ p.Value(PATH_NORMAL_X) + pn.Value(PATH_NORMAL_X), p.Value(PATH_NORMAL_Y) + pn.Value(PATH_NORMAL_Y), p.Value(PATH_NORMAL_Z) + pn.Value(PATH_NORMAL_Z) }));
			for (j = X_; j <= Z_; j++)
			{
				points.Arr()[i][PATH_TANGENT_X + j] = t.Real(j);
				points.Arr()[i][PATH_NORMAL_X + j] = n.Real(j);
			}
			i = array_length(VarType::CreateRef(points.Arr())) - IntType(1);
			for (j = X_; j <= Z_; j++)
			{
				points.Arr()[i][PATH_TANGENT_X + j] = pn.Value(PATH_TANGENT_X + j);
				points.Arr()[i][PATH_NORMAL_X + j] = pn.Value(PATH_NORMAL_X + j);
			}
		}
	}
	
	ArrType spline_subdivide(ArrType points, VarType closed)
	{
		ArrType arr;
		IntType amount;
		arr = ArrType::From({});
		amount = array_length(VarType::CreateRef(points));
		if (closed > 0)
			array_add(VarType::CreateRef(arr), point_lerp(points.Value(IntType(0)), points.Value(amount - IntType(1)), .5), false);
		for (IntType i = IntType(0); i < array_length(VarType::CreateRef(points)); i++)
		{
			RealType next = ((closed > 0) ? mod_fix(i + IntType(1), amount) : clamp(i + IntType(1), IntType(0), amount - IntType(1)));
			array_add(VarType::CreateRef(arr), points.Value(i), false);
			if (i > IntType(0) || closed > 0)
				array_add(VarType::CreateRef(arr), point_lerp(points.Value(i), points.Value(next), .5), false);
		}
		return arr;
	}
	
	IntType sprite_add_lib(VarArgs argument)
	{
		IntType argument_count = argument.Size();
		VarType origin_x, origin_y;
		origin_x = IntType(0);
		origin_y = IntType(0);
		if (argument_count > IntType(1))
		{
			origin_x = argument[IntType(1)];
			origin_y = argument[IntType(2)];
		}
		if (global::file_copy_temp)
		{
			StringType ext;
			VarType tmpfile;
			ext = filename_ext(argument[IntType(0)]);
			tmpfile = filename_new_ext(temp_file, ext);
			file_copy_lib(argument[IntType(0)], tmpfile);
			return sprite_add(tmpfile, IntType(1), false, false, (IntType)(origin_x), (IntType)(origin_y));
		}
		else
			return sprite_add(argument[IntType(0)], IntType(1), false, false, (IntType)(origin_x), (IntType)(origin_y));
		
		return IntType(0);
	}
	
	void sprite_save_lib(VarType spr, IntType subimg, VarType fn)
	{
		IntType surf = surface_create(sprite_get_width((IntType)(spr)), sprite_get_height((IntType)(spr)));
		surface_set_target(surf);
	{
		draw_clear_alpha(c_black, 0.0);
		gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		draw_sprite((IntType)(spr), subimg, IntType(0), IntType(0));
		gpu_set_blendmode(bm_normal);
	}
		surface_reset_target();
		surface_save_lib(surf, fn);
		surface_free(surf);
	}
	
	void state_vars_add(VarType dest, VarType src)
	{
		IntType srclen = array_length(VarType::CreateRef(src));
		for (IntType i = IntType(0); i < srclen; i += IntType(2))
		{
			IntType j;
			for (j = IntType(0); j < array_length(VarType::CreateRef(dest.Arr())); j += IntType(2))
				if (dest.Value(j) == src.Value(i))
					break;
			dest.Arr()[j] = src.Value(i);
			dest.Arr()[j + IntType(1)] = src.Value(i + IntType(1));
		}
	}
	
	VarType state_vars_get_value(VarType vars, VarType name)
	{
		IntType varslen = array_length(VarType::CreateRef(vars));
		for (IntType i = IntType(0); i < varslen; i += IntType(2))
			if (vars.Value(i) == name)
				return vars.Value(i + IntType(1));
		return null_;
	}
	
	BoolType state_vars_match_state_id(VarType vars, IntType block, IntType stateid)
	{
		IntType varslen = array_length(VarType::CreateRef(vars));
		for (IntType i = IntType(0); i < varslen; i += IntType(2))
		{
			VarType name, val, valcomp;
			name = vars.Value(i);
			val = vars.Value(i + IntType(1));
			valcomp = block_get_state_id_value(block, stateid, name);
			if (is_array(val))
			{
				if (!array_contains(val, valcomp))
					return false;
			}
			else
				if (val != valcomp)
					return false;
			
		}
		return true;
	}
	
	RealType state_vars_set_value(VarType vars, VarType name, VarType value)
	{
		IntType varslen = array_length(VarType::CreateRef(vars.Arr()));
		for (IntType i = IntType(0); i < varslen; i += IntType(2))
		{
			if (vars.Value(i) == name)
			{
				vars.Arr()[i + IntType(1)] = value;
				return IntType(0);
			}
		}
		vars.Arr()[varslen] = name;
		vars.Arr()[varslen + IntType(1)] = value;
		return 0.0;
	}
	
	RealType string_contains(VarType str, StringType search)
	{
		return (string_pos(search, str) > IntType(0));
	}
	
	StringType string_decimals(VarType val)
	{
		if (floor(val) == val)
			return string(floor(val));
		StringType str;
		IntType p;
		str = string_format(val, IntType(1), IntType(5));
		for (p = string_length(str); p > IntType(0); p--)
		{
			StringType c = string_char_at(str, p);
			if (c == /*"."*/ STR(1085))
			{
				p--;
				break;
			}
			else
				if (c != /*"0"*/ STR(1048))
					break;
			
		}
		return string_copy(str, IntType(1), p);
	}
	
	StringType string_format_snakecase(VarType str)
	{
		return string_replace_all(string_upper(string_char_at(str, IntType(1))) + string_delete(str, IntType(1), IntType(1)), /*"_"*/ STR(1108), /*" "*/ STR(21));
	}
	
	VarType string_get_real(VarType str, VarType inv)
	{
		if (is_undefined(str))
			return inv;
		IntType len, state;
		len = string_length(str);
		while (len > IntType(1) && string_char_at(str, len) == /*" "*/ STR(21))
			len--;
		
		state = IntType(0);
		for (IntType i = IntType(1); i <= len; i++)
		{
			StringType c = string_char_at(str, i);
			if (c == /*" "*/ STR(21))
			{
				if (state == IntType(0))
					continue;
				else
					return inv;
				
			}
			else
				if (c == /*"-"*/ STR(1087) || c == /*"+"*/ STR(1088))
				{
					if (state == IntType(0) || state == IntType(5))
						state++;
					else
						return inv;
					
				}
				else
					if (ord(c) >= (IntType)'0' && ord(c) <= (IntType)'9')
					{
						if (state <= IntType(2))
							state = IntType(2);
						else
							if (state <= IntType(4))
								state = IntType(4);
							else
								if (state <= IntType(7))
									state = IntType(7);
								else
									return inv;
							
						
						
					}
					else
						if (c == /*"."*/ STR(1085))
						{
							if (state <= IntType(2))
								state = IntType(3);
							else
								return inv;
							
						}
						else
							return inv;
					
				
			
			
		}
		if (string_replace(string_replace(str, /*"-"*/ STR(1087), /*""*/ STR(0)), /*"."*/ STR(1085), /*""*/ STR(0)) == /*""*/ STR(0))
			return inv;
		if (string_contains(str, /*"-."*/ STR(2979)))
			str = string_replace(str, /*"-."*/ STR(2979), /*"-0."*/ STR(2980));
		if (state >= IntType(2))
			return real(str);
		return inv;
	}
	
	VarType string_get_state_vars(VarType argument0)
	{
		VarType str;
		ArrType vars, arr;
		IntType varslen;
		str = argument0;
		vars = string_split(str, /*","*/ STR(1038));
		varslen = array_length(VarType::CreateRef(vars));
		arr = array_create({ varslen * IntType(2) });
		for (IntType i = IntType(0); i < varslen; i++)
		{
			ArrType nameval = string_split(vars.Value(i), /*"="*/ STR(2981));
			arr[i * IntType(2)] = nameval.Value(IntType(0));
			if (array_length(VarType::CreateRef(nameval)) > IntType(1))
				arr[i * IntType(2) + IntType(1)] = nameval.Value(IntType(1));
			else
				return null_;
			
		}
		return arr;
	}
	
	VarType string_limit(VarType str, VarType wid, StringType ellipsis)
	{
		if (string_width(ellipsis) > wid)
			return /*""*/ STR(0);
		if (string_width(str) <= wid)
			return str;
		StringType nstr;
		IntType pos;
		nstr = /*""*/ STR(0);
		pos = IntType(1);
		while (pos <= string_length(str))
		{
			StringType char_ = string_char_at(str, pos);
			if (char_ == /*"\n"*/ STR(943))
				char_ = /*" "*/ STR(21);
			if (string_width(nstr + char_ + ellipsis) >= wid)
				break;
			nstr += char_;
			pos++;
		}
		
		return nstr + /*"..."*/ STR(2982);
	}
	
	StringType string_limit_ext(VarType str, VarType w, VarType h)
	{
		StringType nstr;
		IntType lh, dx, dy, c, linestart, wordstart;
		nstr = /*""*/ STR(0);
		lh = string_height(/*" "*/ STR(21));
		dx = IntType(0);
		dy = IntType(0);
		if (lh > h || string_width(/*"..."*/ STR(2982)) > w)
			return /*""*/ STR(0);
		linestart = IntType(1);
		wordstart = IntType(1);
		for (c = IntType(1); c <= string_length(str); c++)
		{
			StringType char_;
			IntType charwid;
			char_ = string_char_at(str, c);
			charwid = string_width(char_);
			if (char_ == /*"\n"*/ STR(943))
			{
				dx = IntType(0);
				dy += lh;
				if (dy + lh > h)
				{
					while (c > linestart && string_width(string_copy(str, linestart, (IntType)(c - linestart)) + /*"..."*/ STR(2982)) > w)
						c--;
					
					nstr += string_copy(str, linestart, (IntType)(c - linestart)) + /*"..."*/ STR(2982);
					c = linestart;
					break;
				}
				nstr += string_copy(str, linestart, (IntType)(c - linestart)) + /*"\n"*/ STR(943);
				linestart = c + IntType(1);
			}
			else
			{
				if (char_ == /*" "*/ STR(21) || char_ == /*", "*/ STR(1027) || char_ == /*"."*/ STR(1085) || char_ == /*"/"*/ STR(20) || char_ == /*"-"*/ STR(1087))
					wordstart = c + IntType(1);
				dx += charwid;
				if (dx > w && c > IntType(1))
				{
					dy += lh;
					if (dy + lh > h)
					{
						while (c > linestart && string_width(string_copy(str, linestart, (IntType)(c - linestart)) + /*"..."*/ STR(2982)) > w)
							c--;
						
						nstr += string_copy(str, linestart, (IntType)(c - linestart)) + /*"..."*/ STR(2982);
						c = linestart;
						break;
					}
					if (linestart == wordstart)
						wordstart = c;
					nstr += string_copy(str, linestart, (IntType)(wordstart - linestart)) + /*"\n"*/ STR(943);
					dx = string_width(string_copy(str, wordstart, (IntType)(c - wordstart + IntType(1))));
					linestart = wordstart;
				}
			}
			
		}
		nstr += string_copy(str, linestart, (IntType)(c - linestart));
		return nstr;
	}
	
	ArrType string_line_array(VarType str)
	{
		str = str + /*"\n"*/ STR(943);
		ArrType arr = array_create({ string_count(/*"\n"*/ STR(943), str) });
		for (RealType i = array_length(VarType::CreateRef(arr)) - IntType(1); i > -IntType(1); i--)
		{
			IntType linepos = string_pos(/*"\n"*/ STR(943), str);
			arr[i] = string_copy(str, IntType(0), (IntType)(linepos - IntType(1)));
			str = string_delete(str, IntType(1), linepos);
		}
		return arr;
	}
	
	VarType string_remove_newline(VarType str)
	{
		return string_replace_all(str, /*"\n"*/ STR(943), /*" "*/ STR(21));
	}
	
	ArrType string_split(VarType str, StringType sep)
	{
		ArrType arr;
		IntType arrlen;
		VarType pos;
		StringType escapestr;
		arr = ArrType();
		arrlen = IntType(0);
		str += sep;
		escapestr = /*""*/ STR(0);
		while (true)
		{
			IntType pos = string_pos(sep, str);
			if (pos == IntType(0))
				break;
			IntType escapepos = string_pos(/*"\\"*/ STR(1111) + sep, str);
			if (escapepos > IntType(0) && escapepos < pos)
			{
				escapestr += string_copy(str, IntType(1), (IntType)(escapepos - IntType(1))) + sep;
				str = string_delete(str, IntType(1), escapepos + IntType(1));
				continue;
			}
			arr[arrlen++] = escapestr + string_copy(str, IntType(1), (IntType)(pos - IntType(1)));
			str = string_delete(str, IntType(1), pos);
			escapestr = /*""*/ STR(0);
		}
		
		return arr;
	}
	
	StringType string_time(RealType hours, RealType mnts, RealType secs)
	{
		StringType sep = /*":"*/ STR(758);
		return string_repeat(/*"0"*/ STR(1048), (IntType)(hours < IntType(10))) + string(hours) + sep + string_repeat(/*"0"*/ STR(1048), (IntType)(mnts < IntType(10))) + string(mnts) + sep + string_repeat(/*"0"*/ STR(1048), (IntType)(secs < IntType(10))) + string_replace_all(string_format(secs, IntType(2), IntType(3)), /*" "*/ STR(21), /*""*/ STR(0));
	}
	
	VarType string_time_seconds(RealType secs)
	{
		return string_time((IntType)(secs / IntType(3600)), (IntType)(mod(secs, IntType(3600)) / IntType(60)), mod(secs, IntType(60)));
	}
	
}
