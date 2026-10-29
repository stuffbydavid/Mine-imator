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

	void world_raycast_set_object(IntType object)
	{
		App->worldRaycast->object = object;
	}

	ArrType world_raycast(IntType view, VecType origin, VecType direction, RealType distance, BoolType placing)
	{
		Raycast::Hit hit = App->worldRaycast->Cast(view, origin, direction, distance, placing);
		return ArrType::From({ hit.found, hit.distance, hit.position, hit.normal, hit.face, hit.object });
	}
}
