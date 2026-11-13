function alpha_ease(old, goal)
{
	return old + (goal - old) / max(1, 4 / delta)
}
