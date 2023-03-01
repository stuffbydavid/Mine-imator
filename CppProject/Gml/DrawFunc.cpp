#include "Generated/GmlFunc.hpp"

#include "AppHandler.hpp"
#include "Asset/Font.hpp"
#include "Asset/Sprite.hpp"
#include "Asset/Surface.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Type/VecType.hpp"

namespace CppProject
{
	BoolType clip_is_active()
	{
		return GFX->clipEnabled;
	}

	void clip_begin(IntType x, IntType y, IntType width, IntType height)
	{
		if (width == 0 && height == 0) // Re-use previous rect
			GFX->ClipBegin(GFX->clipRect);
		else
			GFX->ClipBegin({ (int)x, (int)y, (int)width, (int)height });
	}

	void clip_end()
	{
		GFX->ClipEnd();
	}

	IntType color_get_blue(IntType color)
	{
		return GFX->IntToQColor(color).blue();
	}

	IntType color_get_green(IntType color)
	{
		return GFX->IntToQColor(color).green();
	}

	IntType color_get_hue(IntType color)
	{
		return std::max(0.0, GFX->IntToQColor(color).hueF()) * 255;
	}

	IntType color_get_red(IntType color)
	{
		return GFX->IntToQColor(color).red();
	}

	IntType color_get_saturation(IntType color)
	{
		return GFX->IntToQColor(color).saturation();
	}

	IntType color_get_value(IntType color)
	{
		return GFX->IntToQColor(color).value();
	}

	void draw_clear_alpha(IntType color, RealType alpha)
	{
		GFX->ClearColor(GFX->IntToQColor(color, alpha));
		GFX->ClearDepth();
	}

	void draw_clear(IntType color)
	{
		draw_clear_alpha(color, 1);
	}

	RealType draw_get_alpha()
	{
		return PR->color.alphaF();
	}

	IntType draw_get_color()
	{
		return GFX->QColorToInt(PR->color);
	}

	IntType draw_get_font()
	{
		if (Font* font = PR->font)
			return font->id;
		return 0;
	}

	void draw_line(IntType x1, IntType y1, IntType x2, IntType y2)
	{
		draw_line_width(x1, y1, x2, y2, 1);
	}

	void draw_line_color(IntType x1, IntType y1, IntType x2, IntType y2, IntType col1, IntType col2)
	{
		PR->Begin(pr_linelist);
		draw_vertex_color(x1, y1, col1, PR->color.alphaF());
		draw_vertex_color(x2, y2, col2, PR->color.alphaF());
	}

	void draw_line_width_color(IntType x1, IntType y1, IntType x2, IntType y2, IntType w, IntType col1, IntType col2)
	{
		if (w > 1.0)
		{
			// Rotation by line vector angle
			RealType angle = RADTODEG * qAtan2(y2 - y1, x2 - x1);
			QTransform transform;
			transform.translate(x1, y1);
			transform.rotate(angle);
			transform.translate(0, -w / 2.0);

			// Draw a rectangle with dimensions line length x line width
			RealType alpha = PR->color.alphaF();
			RealType len = VecType(x2 - x1, y2 - y1).GetLength();
			PR->Begin(pr_trianglestrip, 0, transform);
			draw_vertex_color(-1, 0, col1, alpha);
			draw_vertex_color(len + 2, 0, col2, alpha);
			draw_vertex_color(-1, w, col1, alpha);
			draw_vertex_color(len + 2, w, col2, alpha);
		}
		else
			draw_line_color(x1, y1, x2, y2, col1, col2);
	}

	void draw_line_width(IntType x1, IntType y1, IntType x2, IntType y2, IntType w)
	{
		IntType color = GFX->QColorToInt(PR->color);
		draw_line_width_color(x1, y1, x2, y2, w, color, color);
	}

	void draw_point_color(IntType x, IntType y, IntType col)
	{
		PR->Begin(pr_pointlist);
		draw_vertex_color(x, y, col, PR->color.alphaF());
	}

	void draw_primitive_begin(IntType mode)
	{
		PR->Begin(mode, -1);
	}

	void draw_primitive_end()
	{
		// Do nothing, primitives are automatically submitted in batches when needed
	}

	void draw_rectangle(IntType x1, IntType y1, IntType x2, IntType y2, BoolType outline)
	{
		if (outline)
		{
			PR->Begin(pr_linestrip);
			draw_vertex(x1, y1);
			draw_vertex(x2, y1);
			draw_vertex(x2, y2);
			draw_vertex(x1, y2);
			draw_vertex(x1, y1);
		}
		else
		{
			PR->Begin(pr_trianglestrip);
			draw_vertex(x1, y1);
			draw_vertex(x2, y1);
			draw_vertex(x1, y2);
			draw_vertex(x2, y2);
		}
	}

	void draw_set_alpha(RealType alpha)
	{
		PR->color.setAlphaF(std::max(alpha, 0.0));
	}

	void draw_set_color(IntType color)
	{
		PR->color = GFX->IntToQColor(color, PR->color.alphaF());
	}

	void draw_set_font(IntType id)
	{
		if (Font* font = FindFont(id))
			PR->font = font;
	}

	void draw_set_halign(IntType halign)
	{
		PR->halign = halign;
	}

	void draw_set_valign(IntType valign)
	{
		PR->valign = valign;
	}

	void draw_sprite_ext(IntType id, IntType subimg, IntType x, IntType y, RealType xscale, RealType yscale, RealType rot, IntType color, RealType alpha)
	{
		if (Sprite* spr = FindSprite(id))
		{
			if (IntType texture = spr->GetTexture(subimg))
			{
				QTransform transform;
				transform.translate(x, y);
				transform.rotate(-rot);
				transform.scale(xscale, yscale);
				transform.translate(-spr->origin.x(), -spr->origin.y());

				PR->Begin(pr_trianglestrip, texture, transform);
				draw_vertex_texture_color(0, 0, 0, 0, color, alpha);
				draw_vertex_texture_color(spr->size.width(), 0, 1, 0, color, alpha);
				draw_vertex_texture_color(0, spr->size.height(), 0, 1, color, alpha);
				draw_vertex_texture_color(spr->size.width(), spr->size.height(), 1, 1, color, alpha);
			}
		}
	}

	void draw_sprite_general(IntType id, IntType subimg, IntType left, IntType top, IntType width, IntType height, IntType x, IntType y, RealType xscale, RealType yscale, RealType rot, IntType c1, IntType c2, IntType c3, IntType c4, RealType alpha)
	{
		if (Sprite* spr = FindSprite(id))
		{
			if (IntType texture = spr->GetTexture(subimg))
			{
				QTransform transform;
				transform.translate(x, y);
				transform.rotate(-rot);
				transform.scale(xscale, yscale);

				QPointF uvStart = { (float)left / spr->size.width(), (float)top / spr->size.height() };
				QSizeF uvSize = { (float)width / spr->size.width(), (float)height / spr->size.height() };
				QPointF uvEnd = { uvStart.x() + uvSize.width(), uvStart.y() + uvSize.height() };

				PR->Begin(pr_trianglelist, texture, transform);
				draw_vertex_texture_color(0, 0, uvStart.x(), uvStart.y(), c1, alpha);
				draw_vertex_texture_color(width, 0, uvEnd.x(), uvStart.y(), c2, alpha);
				draw_vertex_texture_color(width, height, uvEnd.x(), uvEnd.y(), c3, alpha);
				draw_vertex_texture_color(width, height, uvEnd.x(), uvEnd.y(), c3, alpha);
				draw_vertex_texture_color(0, height, uvStart.x(), uvEnd.y(), c4, alpha);
				draw_vertex_texture_color(0, 0, uvStart.x(), uvStart.y(), c1, alpha);
			}
		}
	}

	void draw_sprite_part_ext(IntType id, IntType subimg, IntType left, IntType top, IntType width, IntType height, IntType x, IntType y, RealType xscale, RealType yscale, IntType col, RealType alpha)
	{
		draw_sprite_general(id, subimg, left, top, width, height, x, y, xscale, yscale, 0.0, col, col, col, col, alpha);
	}

	void draw_sprite(IntType id, IntType subimg, IntType x, IntType y)
	{
		draw_sprite_ext(id, subimg, x, y, 1.0, 1.0, 0.0, -1, draw_get_alpha());
	}

	void draw_surface_ext(IntType id, IntType x, IntType y, RealType xscale, RealType yscale, RealType rot, IntType color, RealType alpha)
	{
		if (Surface* surf = FindSurface(id))
		{
			if (IntType surfTexId = surf->frameBuffer->GetColorTexId())
			{
				QTransform transform;
				transform.translate(x, y);
				transform.rotate(-rot);
				transform.scale(xscale, yscale);

				PR->Begin(pr_trianglestrip, surfTexId, transform);
				draw_vertex_texture_color(0, 0, 0, 0, color, alpha);
				draw_vertex_texture_color(surf->size.width(), 0, 1, 0, color, alpha);
				draw_vertex_texture_color(0, surf->size.height(), 0, 1, color, alpha);
				draw_vertex_texture_color(surf->size.width(), surf->size.height(), 1, 1, color, alpha);
			}
		}
	}

	void draw_surface(IntType id, IntType x, IntType y)
	{
		draw_surface_ext(id, x, y, 1.0, 1.0, 0.0, -1, 1.0);
	}

	void draw_text_ext(IntType x, IntType y, StringType text, IntType sep, IntType w)
	{
		if (text == "" || !PR->font)
			return;

		text = PR->font->GetWrappedText(text, w);
		QPoint off = PR->font->GetTextOffset(text, PR->halign, PR->valign, sep);

		// Transform
		QTransform transform;
		transform.translate(x, y);

		if (text.Contains("\n")) // Multi-line
		{
			transform.translate(0, off.y());

			IntType dy = 0;
			QStringList lines = text.Split('\n');
			for (const QString& line : lines) // Render each line
			{
				IntType lineHorOff = PR->font->GetTextOffset(line, PR->halign).x();
				QTransform lineTransform = transform;
				lineTransform.translate(lineHorOff, dy);
				PR->font->RenderText(line, lineTransform);
				dy += PR->font->height;
			}
		}
		else // Single-line
		{
			transform.translate(off.x(), off.y());
			PR->font->RenderText(text, transform);
		}
	}

	void draw_text_transformed(IntType x, IntType y, StringType text, RealType xscale, RealType yscale, RealType angle)
	{
		if (text == "" || !PR->font)
			return;

		QPoint off = PR->font->GetTextOffset(text, PR->halign, PR->valign);

		// Transform
		QTransform transform;
		transform.translate(x, y);
		transform.rotate(-angle);
		transform.scale(xscale, yscale);

		if (text.Contains("\n")) // Multi-line
		{
			transform.translate(0, off.y());

			IntType dy = 0;
			QStringList lines = text.Split('\n');
			for (const QString& line : lines) // Render each line
			{
				IntType lineHorOff = PR->font->GetTextOffset(line, PR->halign).x();
				QTransform lineTransform = transform;
				lineTransform.translate(lineHorOff, dy);
				PR->font->RenderText(line, lineTransform);
				dy += PR->font->height;
			}
		}
		else // Single-line
		{
			transform.translate(off.x(), off.y());
			PR->font->RenderText(text, transform);
		}
	}

	void draw_text(IntType x, IntType y, StringType text)
	{
		draw_text_transformed(x, y, text, 1.0, 1.0, 0.0);
	}

	void draw_vertex_color(IntType x, IntType y, IntType col, RealType alpha)
	{
		draw_vertex_texture_color(x, y, 0.0, 0.0, col, alpha);
	}

	void draw_vertex_texture_color(IntType x, IntType y, RealType u, RealType v, IntType col, RealType alpha)
	{
		PR->Add({ { (float)x, (float)y }, { u, v }, col, (float)std::clamp(alpha, 0.0, 1.0) });
	}

	void draw_vertex_texture(IntType x, IntType y, RealType u, RealType v)
	{
		IntType color = GFX->QColorToInt(PR->color);
		draw_vertex_texture_color(x, y, u, v, color, PR->color.alphaF());
	}

	void draw_vertex(IntType x, IntType y)
	{
		IntType color = GFX->QColorToInt(PR->color);
		draw_vertex_texture_color(x, y, 0.0, 0.0, color, PR->color.alphaF());
	}

	IntType make_color_hsv(IntType h, IntType s, IntType v)
	{
		return GFX->QColorToInt(QColor::fromHsv((h / 256.0) * 360, s, v));
	}

	IntType make_color_rgb(IntType r, IntType g, IntType b)
	{
		return GFX->QColorToInt({ (int)r, (int)g, (int)b });
	}

	IntType merge_color(IntType col1, IntType col2, RealType amount)
	{
		QColor color1 = GFX->IntToQColor(col1);
		QColor color2 = GFX->IntToQColor(col2);
		
		return GFX->QColorToInt(QColor(
			(color1.redF() + (color2.redF() - color1.redF()) * amount) * 255,
			(color1.greenF() + (color2.greenF() - color1.greenF()) * amount) * 255,
			(color1.blueF() + (color2.blueF() - color1.blueF()) * amount) * 255
		));
	}
}
