#include "World.hpp"

#include <QTimer>

namespace CppProject
{
	RegionLoader::RegionLoader()
	{
		QTimer* timer = new QTimer(this);
		timer->setInterval(50);
		timer->connect(timer, &QTimer::timeout, this, &RegionLoader::UpdateLoadRegions);
		timer->start();

		QThread* thread = new QThread;
		StringType::AddQThread(thread);
		QObject::moveToThread(thread);
		thread->start();
	}

	void RegionLoader::UpdateLoadRegions()
	{
		// Load regions
		for (Region* region : World::regions)
		{
			if (!active) // Set on main thread
				break;
			if (region->loadStatus == Region::LOADING)
				region->Load();
			if (region->unload)
				region->Unload();
		}

		for (Region* region : World::regions)
		{
			if (!active) // Set on main thread
				break;
			if (region->meshStatus == Region::UPDATE_MESH)
				region->UpdateMesh();
		}

		emit UpdateDone();
	}
}