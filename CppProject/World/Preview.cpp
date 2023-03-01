#include "World.hpp"

#include "AppHandler.hpp"
#include "AppWindow.hpp"
#include "Asset/Shader.hpp"
#include "Asset/Sprite.hpp"
#include "Asset/Surface.hpp"
#include "Asset/VertexBuffer.hpp"
#include "Generated/Scripts.hpp"
#include "Render/GraphicsApiHandler.hpp"
#include "Render/PrimitiveRenderer.hpp"
#include "Render/Texture.hpp"
#include "Render/VertexBufferRenderer.hpp"

namespace CppProject
{
	QVector<BiomeTint> Preview::biomeTints;
	QHash<StringType, uint16_t> Preview::mcBlockIdStyleIndexMap, Preview::filteredMcBlockIdStyleIndexMap;
	QHash<StringType, uint16_t> Preview::mcBiomeIdIndexMap;
	uint16_t Preview::filteredMcLegacyBlockIdStyleIndex[256][16];

	Preview::Preview()
	{
		// Load shaders
		shaderChecker = new Shader("world_checker", Shader::PRIMITIVE);
		shaderPreview = new Shader("world_preview", Shader::WORLD);
		shaderBox = new Shader("world_box", Shader::VERTEX_BUFFER, true);
		shaderBoxResize = new Shader("world_box_resize", Shader::VERTEX_BUFFER, true);
		shaderPlayer = new Shader("world_player", Shader::VERTEX_BUFFER, true);

		// Create meshes
		cube = FindVertexBuffer(vbuffer_create_cube(0.5, VecType(0, 0), VecType(1, 1), 1, 1, false, false));
		cubeInv = FindVertexBuffer(vbuffer_create_cube(0.5, VecType(0, 0), VecType(1, 1), 1, 1, true, false));
		plane = FindVertexBuffer(vbuffer_create_surface(0.5, VecType(0, 0), VecType(1, 1), false));
		playerHead = FindVertexBuffer(global::player_head_vbuffer);
		playerHeadTex = FindSprite(DsMap(ObjType(obj_resource, global::mc_res)->model_texture_map)["entity/steve"]);
		if (!playerHeadTex) // New location
			playerHeadTex = FindSprite(DsMap(ObjType(obj_resource, global::mc_res)->model_texture_map)["entity/player/slim/steve"]);

		// Surface for resizing the selection box
		resizeSurface = new Surface;
	}

	void Preview::Reset()
	{
		Region::loader->disconnect();
		openLoadRegions.clear();

		// Open world
		const SaveInfo& save = World::saves[global::_app->world_import_world_root];
		dimension = global::_app->world_import_dimension;
		World::Open(save.dimDir[dimension]);

		// Set up player parameters
		hasPlayer = (save.hasPlayer && save.playerDim == dimension);
		playerPos = save.playerPos;
		playerRot = save.playerRot;
		spawnPos = save.spawnPos;
		worldOriginPos = hasPlayer ? playerPos : (dimension == "overworld" ? spawnPos : VecType(0, 80, 0));

		RealType playerHeadScale = 1.0 / 16.0;
		playerM =
			Matrix::Scale(playerHeadScale, playerHeadScale, playerHeadScale) *
			Matrix::Rotation({ 1, 0, 0 }, -90.0) * // Z up to Y up
			Matrix::Rotation(playerRot.x, playerRot.y, 0.0) *
			Matrix::Translation(playerPos.x, playerPos.y, playerPos.z);

		if (!resetUpdate)
		{
			// Clear selection
			selection.active = false;

			// Setup camera
			camTargetDis = 8.0;
			camAngleXY = 45.0;
			camAngleZ = 10.0;
			if (hasPlayer)
				camAngleXY = playerRot.y;
			GoToPlayer();
		}
		else
			UpdateSurfaces();

		// Settings
		flyMoveSpeed = global::_app->setting_move_speed * 1.25;
		flyLookSensitivity = global::_app->setting_look_sensitivity;
		flyFastMod = global::_app->setting_fast_modifier;
		flySlowMod = global::_app->setting_slow_modifier;

		LoadRegions(camTarget.x, camTarget.z);
		for (Region* region : World::regions)
			if (region->loadStatus == Region::LOADING)
				openLoadRegions.append(region);

		Region::loader->active = true;
		resetUpdate = false;
		mode = OPENWORLD;
	}

	void Preview::Confirm()
	{
		Region::loader->disconnect();
		Region::loader->active = false;
		World::GenerateBuilderSections(selection);

		ArrType filterArray;
		if (global::_app->setting_world_import_filter_enabled)
		{
			const List& filterList = DsList(global::_app->setting_world_import_filter_list);
			for (const List::ListValue& val : filterList.vec)
				filterArray.Append(val.value);
		}

		// Add resource
		IntType resId = action_res_import_world(ScopeAny(global::_app->id),
			global::_app->world_import_world_name,
			StringType(World::currentRegionsDir.path()),
			(VecType)selection.start,
			(VecType)selection.end,
			global::_app->setting_world_import_filter_mode,
			filterArray
		);

		if (global::_app->world_import_add_tl) // Add template and timeline
			action_res_scenery_animate(ScopeAny(global::_app->id), resId);

		else if (global::_app->world_import_temp != null_) // Template scenery
		{
			global::temp_edit = global::_app->world_import_temp;
			action_lib_scenery(ScopeAny(global::_app->id), resId);
		}
		else // Bench scenery
			action_bench_scenery(ScopeAny(global::_app->id), resId);

		World::Close();
		selection.active = false;
		dimension = "overworld";
		global::_app->window_state = "";
	}

	void Preview::Cancel()
	{
		Region::loader->disconnect();
		Region::loader->active = false;
		dimension = "overworld";
		World::Close();
	}

	void Preview::Update(Surface* surface, QRect rect, QRect confirmRect)
	{
		BoolType updateSurfaces = false;
		BoolType updateBoxResizeSurface = false;

		// Render world preview
		surface_set_target(surface->id);
		draw_clear_alpha(0, 0);
		gpu_set_texfilter(false);

		// Classic checkerboard
		shader_set(shaderChecker->id);
		GFX->shader->SubmitVec2(GFX->shader->GetUniformIndex("uSize"), rect.width(), rect.height());
		IntType dim = 0;
		if (dimension == "nether")
			dim = 1;
		else if (dimension == "end")
			dim = -1;
		GFX->shader->SubmitInt(GFX->shader->GetUniformIndex("uDim"), dim);
		PR->Begin(pr_trianglestrip);
		draw_vertex_texture(0, 0, 0, 0);
		draw_vertex_texture(rect.width(), 0, 1, 0);
		draw_vertex_texture(0, rect.height(), 0, 1);
		draw_vertex_texture(rect.width(), rect.height(), 1, 1);
		shader_reset();

		// No world
		if (!World::regions.count())
		{
			surface_reset_target();
			return;
		}

		// Load intial regions
		if (mode == OPENWORLD)
		{
			IntType loaded = 0;
			RealType progress = 0.0;
			for (Region* region : openLoadRegions)
			{
				progress += region->GetLoadProgress();
				if (region->meshStatus == Region::UPDATE_BUFFERS)
					loaded++;
			}
			progress /= openLoadRegions.size();

			if (loaded == openLoadRegions.size()) // Done
			{
				openLoadRegions.clear();
				progress = 1.0;
				mode = DEFAULT;
			}

			// Loading bar
			draw_set_color(0);
			draw_set_alpha(0.25);
			draw_rectangle(0, 0, rect.width(), rect.height(), false);
			draw_set_alpha(1.0);
			IntType loadPadding = 200;
			IntType loadHeight = 20;
			draw_loading_bar(ScopeAny(global::_app->id), loadPadding, rect.height() / 2 - loadHeight / 2, rect.width() - loadPadding * 2, loadHeight, progress, "");
			surface_reset_target();

			return;
		}

		// Animate camera
		if (camAnim.length)
		{
			if (!camAnim.startTime)
				camAnim.startTime = App->GetMsec();

			// Interpolate parameters
			RealType progress = (RealType)(App->GetMsec() - camAnim.startTime) / camAnim.length;
			progress = std::min(1.0, 1.0 - std::pow(1.0 - progress, 3.0)); // Ease out exponential
			camPos = camAnim.posStart + (camAnim.posEnd - camAnim.posStart) * progress;
			camTargetDis = camAnim.targetDisStart + (camAnim.targetDisEnd - camAnim.targetDisStart) * progress;

			if (camAnim.animateCamPos) // Position animation
			{
				camAngleXY = camAnim.angleXYStart + (camAnim.angleXYEnd - camAnim.angleXYStart) * progress;
				camAngleZ = camAnim.angleZStart + (camAnim.angleZEnd - camAnim.angleZStart) * progress;
				UpdateCameraPosition();
			}
			else // Target animation
				UpdateCameraTarget();

			if (progress >= 1.0)
			{
				camAnim.length = 0;
				updateSurfaces = true;
			}
		}

		// Find new regions to load
		if (camPos.y < 800.0)
		{
			LoadRegions(camPos.x, camPos.z);
			LoadRegions(camTarget.x, camTarget.z);
		}

		// Create projection
		matrixV = Matrix::LookAt(camPos, camTarget, VecType(0, 1, 0));
		matrixP = Matrix::Perspective(-60, (RealType)rect.width() / rect.height(), PREVIEW_ZNEAR, PREVIEW_ZFAR);

		Matrix vTransp = matrixV.GetTransposed();
		VecType right, up, forward;
		right = (vTransp * VecType(-1, 0, 0)).GetNormalized();
		up = (vTransp * VecType(0, 1, 0)).GetNormalized();
		forward = (vTransp * VecType(0, 0, 1)).GetNormalized();

		// Check resize
		if (resizeSurface->size != rect.size())
		{
			resizeSurface->Resize(rect.size());
			updateBoxResizeSurface = true;
		}

		if (global::_app->window_busy == "worldimportrelease")
			global::_app->window_busy = "";

		// World
		shader_set(shaderPreview->id);
		matrix_set(matrix_view, matrixV);
		matrix_set(matrix_projection, matrixP);
		gpu_set_ztestenable(true);
		gpu_set_texrepeat(false);
		GFX->SetCullFrontFace(true);

		// Loaded region meshes
		IntType uTexture = GFX->shader->GetSamplerIndex("uTexture");
		GFX->shader->SubmitTexture(uTexture, BlockStyle::previewTexture->GetId());

		for (Region* region : World::regions)
			if (region->meshStatus == Region::UPDATE_BUFFERS)
				region->UpdateBuffers();

		for (uint8_t m = 0; m < Region::MeshTypeAmount; m++)
		{
			for (Region* region : World::regions)
			{
				Region::MeshData& mData = region->meshData[m];
				if (!mData.numIndices || !mData.mesh.HasBuffers() || region->unload)
					continue;

				// Check unload
				VecType regionMidPos = region->pos + WorldVec(REGION_SIZE / 2, 128, REGION_SIZE / 2);
				if (global::_app->setting_world_import_unload_regions.ToBool() &&
					(VecType(camPos.x, 128, camPos.z) - regionMidPos).GetLength() > PREVIEW_UNLOAD_DISTANCE &&
					(VecType(camTarget.x, 128, camTarget.z) - regionMidPos).GetLength() > PREVIEW_UNLOAD_DISTANCE)
				{
					region->unload = true;
					continue;
				}

				// Render
				if (GFX->IsVisible(mData.mesh.bounds))
				{
					mData.mesh.BeginUse();
					matrix_set(matrix_world, Matrix::Translation(region->pos));
					GFX->shader->SubmitVertices(Shader::TRIANGLE_LIST, mData.mesh.numIndices);
					mData.mesh.EndUse();
					VB->renderCalls++;
					VB->trianglesSubmitted += mData.mesh.numVertices;
				}
				else
					GFX->shader->ResetObjects();
			}
		}

		gpu_set_texrepeat(true);
		shader_reset();

		// Box controls
		BoolType mouseActive = false;
		QPoint mousePoint = QPoint(gmlGlobal::mouse_x, gmlGlobal::mouse_y);
		BoolType mouseInSurface = (rect.contains(mousePoint) && !confirmRect.contains(mousePoint));
		mousePoint.rx() -= rect.x();
		mousePoint.ry() -= rect.y();

		if (global::_app->world_import_world_root != "" && mouseInSurface)
		{
			// Get mouse and block position in world
			if (!camAnim.length && !updateSurfaces)
			{
				mouseWorldPos = GetWorldPosition(surface, mousePoint, mouseDepth);

				VecType worldPosAdjust = mouseWorldPos + (mouseWorldPos - camPos).GetNormalized() * 0.1;
				mouseBlock = {
					(IntType)std::floor(worldPosAdjust.x),
					(IntType)std::floor(worldPosAdjust.y),
					(IntType)std::floor(worldPosAdjust.z)
				};
			}

			if (global::_app->window_busy == "")
			{
				global::_app->shortcut_bar_state = "worldimport";

				// Mouse wheel
				IntType mouseWheelDelta = mouse_wheel_down() - mouse_wheel_up();
				RealType zoomScalar = mouseWheelDelta * 0.2;
				RealType worldPosDis = (camPos - mouseWorldPos).GetLength();

				if ((zoomScalar < 0.0 && worldPosDis > PREVIEW_ZOOM_MIN) ||
					(zoomScalar > 0.0 && worldPosDis < PREVIEW_ZOOM_MAX))
					camAnim = {
						App->GetMsec(), 100,
						camPos, camPos + (camPos - mouseWorldPos) * zoomScalar,
						camTargetDis, std::clamp(worldPosDis + worldPosDis * zoomScalar, PREVIEW_ZOOM_MIN, PREVIEW_ZOOM_MAX)
					};

				mouseActive = true;

				// Mouse button
				mouseButton = 0;
				for (IntType mb = mb_left; mb <= mb_middle; mb++)
					if (mouse_check_button(mb))
						mouseButton = mb;

				// Check with selection box
				resizeDir = VecType();
				if (selection.active && !keyboard_check(vk_alt))
				{
					QColor color = resizeSurface->GetColor(mousePoint);
					if (color != Qt::black)
					{
						// Find direction
						resizeDir = VecType(
							(color.red() == 255) - (color.red() < 255 && color.red() > 0),
							(color.green() == 255) - (color.green() < 255 && color.green() > 0),
							(color.blue() == 255) - (color.blue() < 255 && color.blue() > 0)
						);
						global::_app->mouse_cursor = cr_handpoint;
						mouseActive = false;
					}
				}

				if (mouseButton)
				{
					if (camAnim.length) // Cancel animation
					{
						camAnim.length = 0;
						updateSurfaces = true;
					}

					mouseClickX = gmlGlobal::mouse_x;
					mouseClickY = gmlGlobal::mouse_y;
					global::_app->window_busy = "worldimport";

					// Click/Resize
					if (mouseButton == mb_left)
					{
						if (keyboard_check(vk_shift))
							mode = Mode::PAN;
						else if (mouseActive)
							mode = Mode::CLICK;
						else
						{
							float depth;
							resizeStartSelection = selection;
							resizeStartPos = GetWorldPosition(resizeSurface, mousePoint, depth);
							mode = Mode::RESIZE;
							updateBoxResizeSurface = true;
						}
					}

					// Pan
					else if (mouseButton == mb_middle)
						mode = Mode::PAN;

					// Fly
					else if (mouseButton == mb_right)
						mode = Mode::FLY_BEGIN;
				}
			}
		}
		
		// Handle input
		if (global::_app->window_busy == "worldimport")
		{
			global::_app->shortcut_bar_state = "worldimport";

			if (mode >= Mode::RESIZE && !mouse_check_button(mouseButton)) // Exit resize/camera movement
			{
				if (mode == Mode::FLY) // Restore cursor
					display_mouse_set(mouseLastX, mouseLastY);
				global::_app->window_busy = "worldimportrelease";
				mode = Mode::DEFAULT;
				updateSurfaces = true;
			}
			else // Check mode
			{
				switch (mode)
				{
					// Clicked in viewport, if mouse moves start rotating or select if released
					case Mode::CLICK:
					{
						mouseActive = true;

						if (std::abs(gmlGlobal::mouse_x - mouseClickX) > 2 ||
							std::abs(gmlGlobal::mouse_y - mouseClickY) > 2)
							mode = Mode::ROTATE;
						
						else if (!mouse_check_button(mb_left))
						{
							selection = { mouseBlock, mouseBlock + WorldVec(1, 1, 1) };
							mode = Mode::SELECT;
						}
						break;
					}

					// Create selection
					case Mode::SELECT:
					{
						selection.end = mouseBlock + WorldVec(1, 1, 1);
						global::_app->shortcut_bar_state = "worldimportselection";

						if (mouse_check_button(mb_left)) // Confirm
						{
							selection.Adjust();
							VecType size = selection.GetSize();
							selection.active = (size.x > 1 || size.y > 1 || size.z > 1);
							mode = Mode::DEFAULT;
							global::_app->window_busy = "worldimportrelease";
							updateBoxResizeSurface = true;
							mouse_clear(mb_left);
						}
						else if (mouse_check_button(mb_right)) // Cancel
						{
							selection.active = false;
							mode = Mode::DEFAULT;
							global::_app->window_busy = "worldimportrelease";
							updateSurfaces = true;
							mouse_clear(mb_right);
						}

						break;
					}

					// Resize selection face
					case Mode::RESIZE:
					{
						if (updateBoxResizeSurface)
							break;

						if (resizeDirValid)
						{
							float depth;
							VecType mousePlanePos = GetWorldPosition(resizeSurface, mousePoint, depth);
							VecType mouseMoveVec = mousePlanePos - resizeStartPos;
							IntType delta = VecType::DotProduct(mouseMoveVec.GetNormalized(), resizeDir) * mouseMoveVec.GetLength();
							
							if (resizeDir.x > 0) // Right
								selection.end.x = std::max(selection.start.x + 1, resizeStartSelection.end.x + delta);
							if (resizeDir.x < 0) // Left
								selection.start.x = std::min(selection.end.x - 1, resizeStartSelection.start.x - delta);
							if (resizeDir.y > 0) // Front
								selection.end.y = std::max(selection.start.y + 1, resizeStartSelection.end.y + delta);
							if (resizeDir.y < 0) // Back
								selection.start.y = std::min(selection.end.y - 1, resizeStartSelection.start.y - delta);
							if (resizeDir.z > 0) // Top
								selection.end.z = std::max(selection.start.z + 1, resizeStartSelection.end.z + delta);
							if (resizeDir.z < 0) // Bottom
								selection.start.z = std::min(selection.end.z - 1, resizeStartSelection.start.z - delta);
						}

						global::_app->mouse_cursor = cr_handpoint;
						break;
					}

					// Rotate around the target
					case Mode::ROTATE:
					{
						camAngleXY += (mouseLastX - gmlGlobal::mouse_x) * 0.25;
						camAngleZ -= (mouseLastY - gmlGlobal::mouse_y) * 0.25;
						camAngleZ = std::clamp(camAngleZ, -89.9, 89.9);
						UpdateCameraPosition();

						global::_app->mouse_cursor = cr_size_all;
						break;
					}

					// Move position and target along camera up/right vector
					case Mode::PAN:
					{
						RealType deltaX = (mouseLastX - gmlGlobal::mouse_x) * (camTargetDis * 0.00125);
						RealType deltaY = (mouseLastY - gmlGlobal::mouse_y) * (camTargetDis * 0.00125);
						VecType moveVec = right * deltaX - up * deltaY;
						camPos += moveVec;
						camTarget += moveVec;

						global::_app->mouse_cursor = cr_size_all;
						break;
					}
					
					// Wait 1 frame to allow mouse to be locked
					case Mode::FLY_BEGIN:
					{
						mouseLastX = display_mouse_get_x();
						mouseLastY = display_mouse_get_y();
						mouseLocked = false;
						global::_app->mouse_cursor = cr_none;
						mode = Mode::FLY;
						break;
					}

					// Lock mouse in center and get delta position, and apply movement vector to camera position+target
					case Mode::FLY:
					{
						// Get mouse delta from window center
						IntType lockX, lockY;
						if (AppWin->mouseEnableLock)
						{
							lockX = window_get_x() + rect.center().x();
							lockY = window_get_y() + rect.center().y();
						}
						else
						{
							QPoint lockPos = AppWin->mouseLocked ? AppWin->mouseLockPos : AppWin->mousePos;
							lockX = lockPos.x(), lockY = lockPos.y();
						}

						if (mouseLocked)
						{
							camAngleXY += (lockX - display_mouse_get_x()) * flyLookSensitivity * 0.25;
							camAngleZ -= (lockY - display_mouse_get_y()) * flyLookSensitivity * 0.25;
							camAngleZ = std::clamp(camAngleZ, -89.9, 89.9);
							UpdateCameraTarget();
						}

						// Get speed modifier
						RealType mod = flyMoveSpeed;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_SLOW], active)))
							mod *= flySlowMod;
						else if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_FAST], active)))
							mod *= flyFastMod;

						// Apply keys to vector
						VecType moveVec = { 0, 0, 0 };
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_FORWARD], active)))
							moveVec += forward;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_BACK], active)))
							moveVec -= forward;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_RIGHT], active)))
							moveVec += right;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_LEFT], active)))
							moveVec -= right;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_ASCEND], active)))
							camPos.y += mod, camTarget.y += mod;
						if (keyboard_check(idVar(global::keybinds[e_keybind_CAM_DESCEND], active)))
							camPos.y -= mod, camTarget.y -= mod;

						moveVec *= mod;
						camPos += moveVec;
						camTarget += moveVec;

						if (AppWin->mouseEnableLock)
							global::_app->mouse_cursor = cr_none;
						display_mouse_set(lockX, lockY);
						mouseLocked = true;
						global::_app->shortcut_bar_state = "cameramove";
						break;
					}
				}
			}
		}

		// Boxes
		shader_set(shaderBox->id);
		matrix_set(matrix_view, matrixV);
		matrix_set(matrix_projection, matrixP);
		GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uEye"), camPos);

		// Unloaded regions
		for (Region* region : World::regions)
		{
			if (region->meshData[0].loaded && !region->unload)
				continue;

			VecType col = { 0.6, 0.3, 0.3, 1.0 };
			if (region->loadStatus == Region::LOAD_ERROR)
				col = { 1.0, 0.2, 0.2, 1.0 };

			VecType regionSize = { REGION_SIZE, 256, REGION_SIZE };
			GFX->shader->SubmitVec4(GFX->shader->GetUniformIndex("uColor"), col);
			GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uResizeDir"), 0, 0, 0);
			GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), regionSize);
			matrix_set(matrix_world,
				Matrix::Scale(regionSize) *
				Matrix::Translation((VecType)region->pos + regionSize / 2.0)
			);

			// Fill
			if (region->loadStatus != Region::UNLOADED)
			{
				GFX->shader->SubmitInt(GFX->shader->GetUniformIndex("uBorder"), 0);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 0.8f);
				VB->Add(cube);
			}

			// Border
			else
			{
				GFX->shader->SubmitInt(GFX->shader->GetUniformIndex("uBorder"), 1);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 0.25f);
				VB->Add(cubeInv);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 0.5f);
				VB->Add(cube);
			}
		}

		// Render selection boxes
		if (mouseActive || selection.active)
		{
			GFX->shader->SubmitVec4(GFX->shader->GetUniformIndex("uColor"), 0.6f, 1.0f, 0.6f, 1.0f);

			Matrix mouseBoxM;
			if (mouseActive)
				mouseBoxM =
					Matrix::Scale(1.05, 1.05, 1.05) *
					Matrix::Translation(mouseBlock.x + 0.5, mouseBlock.y + 0.5, mouseBlock.z + 0.5);

			// Set selection box start/size
			if (selection.active)
			{
				VecType selectSize = selection.GetSize();
				VecType selectMid = (VecType)selection.GetStart() + selectSize / 2.0;

				selectionM =
					Matrix::Scale(selectSize.x + 0.05, selectSize.y + 0.05, selectSize.z + 0.05) *
					Matrix::Translation(selectMid);
			}

			// Fill
			GFX->shader->SubmitInt(GFX->shader->GetUniformIndex("uBorder"), 0);
			GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 1.f);
			GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uResizeDir"), resizeDir);
			if (selection.active)
			{
				matrix_set(matrix_world, selectionM);
				GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), selection.GetSize());
				VB->Add(cube);
			}
			if (mouseActive)
			{
				matrix_set(matrix_world, mouseBoxM);
				GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), 1, 1, 1);
				VB->Add(cube);
			}
			VB->SubmitBatch();

			// Border
			gpu_set_ztestenable(false);
			GFX->shader->SubmitInt(GFX->shader->GetUniformIndex("uBorder"), 1);
			if (selection.active)
			{
				matrix_set(matrix_world, selectionM);
				GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), selection.GetSize());
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 0.5f);
				VB->Add(cubeInv);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 1.f);
				VB->Add(cube);
			}
			if (mouseActive)
			{
				matrix_set(matrix_world, mouseBoxM);
				GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), 1, 1, 1);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 0.5f);
				VB->Add(cubeInv);
				GFX->shader->SubmitFloat(GFX->shader->GetUniformIndex("uAlpha"), 1.f);
				VB->Add(cube);
			}
			VB->SubmitBatch();
		}

		shader_reset();
		gpu_set_ztestenable(false);

		// Player
		if (hasPlayer)
		{
			shader_set(shaderPlayer->id);
			matrix_set(matrix_view, matrixV);
			matrix_set(matrix_projection, matrixP);
			matrix_set(matrix_world, playerM);
			GFX->shader->SubmitTexture(GFX->shader->GetSamplerIndex("uTexture"), playerHeadTex->GetTexture(0));
			VB->Add(playerHead);
			VB->SubmitBatch();
			shader_reset();
		}
		GFX->SetCullFrontFace(false);

		// Region loading bars
		for (Region* region : World::regions)
		{
			if (region->loadStatus == Region::UNLOADED || !region->numChunks)
				continue;

			RealType progress = region->GetLoadProgress();
			if (progress > 0.99)
				continue;

			VecType regionSize = { REGION_SIZE, 256, REGION_SIZE };
			VecType loadingWorldPos = (VecType)region->pos + regionSize / 2.0;
			VecType loadingScreenPos = point3D_project(loadingWorldPos, VarType(GFX->matrixVP), rect.width(), rect.height());

			if (!global::point3D_project_error)
			{
				IntType loadingWidth = 300;
				IntType loadingHeight = 15;
				draw_loading_bar(ScopeAny(global::_app->id), loadingScreenPos.x - loadingWidth / 2, loadingScreenPos.y - loadingHeight / 2, loadingWidth, loadingHeight, progress, "");
			}
		}
		surface_reset_target();

		if (mode != Mode::FLY)
		{
			mouseLastX = gmlGlobal::mouse_x;
			mouseLastY = gmlGlobal::mouse_y;
		}

		if (updateSurfaces)
			UpdateSurfaces();
		else if (updateBoxResizeSurface)
			UpdateBoxResizeSurface();
	}

	void Preview::UpdateCameraPosition()
	{
		camPos =
			camTarget +
				Matrix::Rotation(0, camAngleXY, camAngleZ) *
				VecType(camTargetDis, 0, 0);
	}

	void Preview::UpdateCameraTarget()
	{
		camTarget =
			camPos -
				Matrix::Rotation(0, camAngleXY, camAngleZ) *
				VecType(camTargetDis, 0, 0);
	}

	void Preview::UpdateSurfaces()
	{
		if (Surface* surface = FindSurface(global::_app->world_import_surface))
			surface->ClearDepthCache();

		UpdateBoxResizeSurface();
	}

	void Preview::UpdateBoxResizeSurface()
	{
		if (!selection.active)
			return;

		surface_set_target(resizeSurface->id);
		shader_set(shaderBoxResize->id);
		gpu_set_ztestenable(true);
		gpu_set_texfilter(false);
		GFX->SetCullFrontFace(true);
		matrix_set(matrix_view, matrixV);
		matrix_set(matrix_projection, matrixP);
		draw_clear(0);

		// Draw selection box with separate colors per side for hit detection
		if (mode == DEFAULT)
		{
			matrix_set(matrix_world, selectionM);
			GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uEye"), camPos);
			GFX->shader->SubmitVec3(GFX->shader->GetUniformIndex("uBoxSize"), selection.GetSize());
			VB->Add(cube);
			VB->SubmitBatch();
		}
		// Draw plane on mouse depth position oriented perpendicular to resize direction
		else
		{
			VecType rotate = { 0, 0, 0 };
			VecType toStartPos = (camPos - resizeStartPos).GetNormalized();
			RealType dot = VecType::DotProduct(resizeDir, toStartPos);
			if (dot > 0.0 && dot < 0.95)
			{
				resizeDirValid = true;

				if (resizeDir.y != 0) // Towards eye
				{
					rotate.x = 90;
					rotate.z = 90 + RADTODEG * qAtan2(toStartPos.z, toStartPos.x);
				}
				else if (std::abs(RADTODEG * qAtan(toStartPos.y)) < 15) // Side if Y angle too low
				{
					rotate.x = 90;
					if (resizeDir.z != 0)
						rotate.z = 90;
				}

				matrix_set(matrix_world,
					Matrix::Scale(PREVIEW_ZFAR, PREVIEW_ZFAR, PREVIEW_ZFAR) *
					Matrix::Rotation(rotate.x, rotate.y, rotate.z) *
					Matrix::Translation(resizeStartPos)
				);
				GFX->SetCulling(false);
				VB->Add(plane);
				VB->SubmitBatch();
				GFX->SetCulling(true);
			}
			else
				resizeDirValid = false;
		}

		shader_reset();
		surface_reset_target();
		gpu_set_ztestenable(false);
		GFX->SetCullFrontFace(false);
		resizeSurface->ClearColorCache();
		resizeSurface->ClearDepthCache();
	}

	VecType Preview::GetWorldPosition(Surface* surface, QPoint point, float& outDepth)
	{
		float depth = surface->GetDepth(point);
		if (depth < 1.0)
			outDepth = depth;

		float tx = (float)point.x() / surface->size.width();
		float ty = 1.0 - (float)point.y() / surface->size.height();
		VecType clipSpace = { tx * 2.0 - 1.0, ty * 2.0 - 1.0, outDepth * 2.0 - 1.0, 1.0 };
		VecType viewSpace = vec4_homogenize(GFX->matrixP.GetInversed() * clipSpace);
		return GFX->matrixV.GetInversed() * VecType(viewSpace.x, viewSpace.y, viewSpace.z, 1.0);
	}

	void Preview::GoToPlayer()
	{
		camTarget = worldOriginPos;
		camAnim = {
			0, 2000,
			{}, {},
			camTargetDis, 100.0,
			mod_fix(camAngleXY, 360), -45.0,
			camAngleZ, 25.0,
			true
		};

		// Behind player
		if (hasPlayer)
		{
			camAnim.angleXYEnd = playerRot.y - 90;
			camAnim.targetDisEnd = 30.0;
		}

		// Adjust angles
		RealType diff = camAnim.angleXYStart - camAnim.angleXYEnd;
		if (diff > 180)
			camAnim.angleXYStart -= 360;
		else if (diff < -180)
			camAnim.angleXYEnd -= 360;
	}

	void Preview::SetSelectionSize(VecType size)
	{
		WorldVec mid = worldOriginPos;
		if (selection.active)
			mid = selection.GetStart() + (selection.GetSize() / 2.0);

		selection.start = mid - size / 2.0;
		selection.end = mid + size / 2.0;
		selection.active = true;
	}

	void Preview::LoadRegions(IntType x, IntType z)
	{
		IntType xBlock = x & 511, zBlock = z & 511;
		IntType xReg = std::floor((RealType)x / REGION_SIZE), zReg = std::floor((RealType)z / REGION_SIZE);

		if (Region* mid = Region::Find(xReg, zReg, Region::UNLOADED))
			mid->loadStatus = Region::LOADING;

		BoolType onRightEdge = (xBlock > REGION_SIZE - REGION_BOUNDARY_LOAD_SIZE);
		BoolType onLeftEdge = (xBlock < REGION_BOUNDARY_LOAD_SIZE);
		BoolType onFrontEdge = (zBlock > REGION_SIZE - REGION_BOUNDARY_LOAD_SIZE);
		BoolType onBackEdge = (zBlock < REGION_BOUNDARY_LOAD_SIZE);

		if (onLeftEdge)
			if (Region* left = Region::Find(xReg - 1, zReg, Region::UNLOADED))
				left->loadStatus = Region::LOADING;
		if (onLeftEdge && onBackEdge)
			if (Region* backLeft = Region::Find(xReg - 1, zReg - 1, Region::UNLOADED))
				backLeft->loadStatus = Region::LOADING;
		if (onBackEdge)
			if (Region* back = Region::Find(xReg, zReg - 1, Region::UNLOADED))
				back->loadStatus = Region::LOADING;
		if (onRightEdge && onBackEdge)
			if (Region* backRight = Region::Find(xReg + 1, zReg - 1, Region::UNLOADED))
				backRight->loadStatus = Region::LOADING;
		if (onRightEdge)
			if (Region* right = Region::Find(xReg + 1, zReg, Region::UNLOADED))
				right->loadStatus = Region::LOADING;
		if (onFrontEdge && onRightEdge)
			if (Region* frontRight = Region::Find(xReg + 1, zReg + 1, Region::UNLOADED))
				frontRight->loadStatus = Region::LOADING;
		if (onFrontEdge)
			if (Region* front = Region::Find(xReg, zReg + 1, Region::UNLOADED))
				front->loadStatus = Region::LOADING;
		if (onFrontEdge && onLeftEdge)
			if (Region* frontLeft = Region::Find(xReg - 1, zReg + 1, Region::UNLOADED))
				frontLeft->loadStatus = Region::LOADING;
	}
}
