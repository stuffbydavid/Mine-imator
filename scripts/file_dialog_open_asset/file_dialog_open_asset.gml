/// file_dialog_open_asset()

var formats = "*miobj; *.mipart; *.schematic; *.miproj; *.mp3; *.wav; *.ogg; *.flac; *.wma; *.m4a; *.png; *.jpg; *.zip; *.object; *.keyframes; *.particles; *.mproj; *.mani; *.blocks";
return file_dialog_open(text_get("filedialogopenasset") + " (" + formats + ")|" + formats, "", "", text_get("filedialogopenassetcaption"))
