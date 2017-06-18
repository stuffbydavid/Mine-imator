/// recent_remove(index)

var n = argument0;

if (recent_thumbnail[n])
    texture_free(recent_thumbnail[n])

recent_amount--

// Push down
for (var r = n; r < recent_amount; r++)
{
    recent_filename[r] = recent_filename[r + 1]
    recent_name[r] = recent_name[r + 1]
    recent_author[r] = recent_author[r + 1]
    recent_description[r] = recent_description[r + 1]
    recent_date[r] = recent_date[r + 1]
    recent_thumbnail[r] = recent_thumbnail[r + 1]
}
