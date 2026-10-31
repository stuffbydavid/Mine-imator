#include "Generated/Scripts.hpp"
#include "AppHandler.hpp"
#include "Render/Raycast.hpp"

namespace CppProject
{
	void world_raycast_begin(IntType view)
	{
		App->worldRaycast->Begin(view);
	}

	void world_raycast_end()
	{
		App->worldRaycast->End();
	}

	void world_raycast_set_tl(IntType id)
	{
		App->worldRaycast->tlId = id;
	}

	ArrType world_raycast(IntType view, VecType origin, VecType direction, RealType distance, BoolType placing, BoolType build)
	{
		Raycast::Hit hit = App->worldRaycast->Cast(view, origin, direction, distance, placing, build);

		VarType blockPos = null_;
		if (hit.hasBlockPos)
			blockPos = hit.blockPos;

		VarType blockBounds = null_;
		if (!hit.blockBounds.empty)
			blockBounds = ArrType::From({ hit.blockBounds.minPoint, hit.blockBounds.maxPoint });

		return ArrType::From({ hit.found, hit.distance, hit.position, hit.normal, hit.face, hit.tlId, blockPos, blockBounds });
	}
}
