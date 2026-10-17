#include "World/World.hpp"

#include "Generated/Scripts.hpp"

#include <QDirIterator>

namespace CppProject
{
	void world_import_startup()
	{
		World::Init();
	}

	void world_import_world_menu_init()
	{
		// Get Minecraft saves
		World::saves.clear();

		// List all worlds
		QDirIterator it(minecraft_java_directory_get() + "/saves", QDir::Dirs | QDir::NoDotAndDotDot);
		while (it.hasNext())
		{
			QDir saveDir = it.next();
			StringType saveRoot = saveDir.path();

			// Add save to menu if valid
			if (World::AddSave(saveRoot))
				menu_add_item(saveRoot, StringType(World::saves[saveRoot].name));
		}
	}

	void world_import_select_world(ScopeAny, StringType root, StringType dim, BoolType update)
	{
		if (root == "")
			return;

		if (!World::saves.contains(root) && !World::AddSave(root))
		{
			error("worldimporterror");
			return;
		}

		SaveInfo& save = World::saves[root];
		StringType saveDim = dim.IsEmpty() ? StringType(save.playerDim) : dim;
		global::_app->world_import_world_root = root;
		global::_app->world_import_world_name = save.name;
		global::_app->world_import_dimension = saveDim;

		World::preview->resetUpdate = update;
		World::preview->exportFilename.clear();
		Region::loader->active = false;

		// Open world once currently loaded regions are done
		QObject::connect(Region::loader, SIGNAL(UpdateDone()), World::preview, SLOT(Reset()));
	}

	BoolType world_import_has_dimension(StringType dim)
	{
		return World::saves[global::_app->world_import_world_root].dimDir.contains(dim);
	}

	BoolType world_import_has_selection()
	{
		return World::preview->selection.active;
	}

	VecType world_import_get_selection_size()
	{
		return World::preview->selection.GetSize();
	}

	void world_import_apply_settings(ScopeAny)
	{
		if (World::ApplyFilter()) // Reload world if needed (keep position)
			world_import_select_world(ScopeAny(0), global::_app->world_import_world_root, global::_app->world_import_dimension, true);
	}

	void world_import_go_to_player()
	{
		World::preview->GoToPlayer();
	}

	void world_import_go_to_position(IntType x, IntType z)
	{
		World::preview->GoToPosition(x, z);
	}

	void world_import_set_selection(StringType size)
	{
		if (size == "small")
			World::preview->SetSelectionSize({ 50, 20, 50 });
		else if (size == "medium")
			World::preview->SetSelectionSize({ 200, 30, 200 });
		else
			World::preview->SetSelectionSize({ 400, 50, 400 });
	}

	void world_import_confirm()
	{
		// Confirm when region loading is done
		if (World::preview->selection.active && (Region::loader->active || !World::preview->exportFilename.isEmpty()))
		{
			World::preview->exportFilename.clear();
			Region::loader->active = false;

			QObject::connect(Region::loader, SIGNAL(UpdateDone()), World::preview, SLOT(Confirm()));
		}
	}

	void world_import_cancel()
	{
		World::preview->selection.active = false;

		// Unload world when region loading is done
		if (global::_app->world_import_world_root != "" && (Region::loader->active || !World::preview->exportFilename.isEmpty()))
		{
			World::preview->exportFilename.clear();
			Region::loader->active = false;

			QObject::connect(Region::loader, SIGNAL(UpdateDone()), World::preview, SLOT(Cancel()));
		}

		global::_app->window_state = "";
	}

	void world_import_update_surface(IntType x, IntType y, IntType width, IntType height, IntType confirmX, IntType confirmY, IntType confirmWidth, IntType confirmHeight)
	{
		World::preview->Update(FindSurface(global::_app->world_import_surface), QRect(x, y, width, height), QRect(confirmX, confirmY, confirmWidth, confirmHeight));
	}

	void world_import_export_schematic()
	{
		if (!World::preview->selection.active || !Region::loader->active || !World::preview->exportFilename.isEmpty())
			return;

		IntType dataVersion = World::saves.value(global::_app->world_import_world_root).dataVersion;
		WorldBox box = World::preview->selection;
		StringType ext = ".schem";
		if (dataVersion < Chunk::JAVA_1_13)
			ext = ".schematic";

		QString fn = file_dialog_save_schematic(global::_app->world_import_world_name.Str() + ext, ext);
		if (fn.isEmpty() || !Region::loader->active || !World::preview->exportFilename.isEmpty())
			return;

		if (!fn.endsWith(ext, Qt::CaseInsensitive))
			fn += ext;

		World::preview->exportFilename = fn;
		World::preview->exportBox = box;
		Region::loader->active = false;

		// Export when region loading is done
		QObject::connect(
			Region::loader, &RegionLoader::UpdateDone, World::preview, &Preview::ExportSchematic,
			Qt::ConnectionType(Qt::QueuedConnection | Qt::UniqueConnection)
		);
	}
}
