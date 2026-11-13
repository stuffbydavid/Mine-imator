function builder_irandom_range(x1, x2, salt = 0, usez = true)
{
	return min(x1, x2) + builder_irandom(abs(x2 - x1), salt, usez)
}
