/// history_save_loaded()
/// @desc Stores the newly loaded objects.

loaded_amount = 0
with (obj_template)
{
    if (!loaded)
        continue
    other.loaded[other.loaded_amount] = iid
    other.loaded_amount++
}

with (obj_timeline)
{
    if (!loaded)
        continue
    other.loaded[other.loaded_amount] = iid
    other.loaded_amount++
}

with (obj_resource)
{
    if (!loaded)
        continue
    other.loaded[other.loaded_amount] = iid
    other.loaded_amount++
}
