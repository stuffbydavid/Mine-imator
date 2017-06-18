/// temp_update_bodypart()

// TODO
char_bodypart = min(char_bodypart, char_model.part_amount - 1)

with (obj_timeline)
{
    if (type != "bodypart" || temp != other.id)
        continue
    bodypart = other.char_bodypart
    update_matrix = true
    tl_update_value_types()
}
