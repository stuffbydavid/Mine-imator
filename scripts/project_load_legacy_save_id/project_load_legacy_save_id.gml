/// project_load_legacy_save_id()

var saveid = buffer_read_int();

if (saveid = 0) // Tree root
	return "root"
	
if (saveid = 1) // Default resource
	return "default"
	
return saveid