#include "Generated/Scripts.hpp"

namespace CppProject
{
	IntType thread_get_number()
	{
		return omp_get_max_threads();
	}

	IntType thread_get_id()
	{
		return omp_get_thread_num();
	}

	void thread_task_begin()
	{
		StringType::BeginOmp();
		VecType::BeginOmp();
	}

	void thread_task_end()
	{
		VecType::EndOmp();
		StringType::EndOmp();
	}
}