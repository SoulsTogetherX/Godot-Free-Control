# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
@tool
extends EditorPlugin

#region Constants
const SRC_DIR = &"res://addons/FreeControl/src/"
#endregion



#region Virtual Methods
func _enter_tree():
	var scripts := _get_all_files(SRC_DIR)
	
	for script_path : String in scripts:
		var script := load(script_path)
		var script_name : StringName = script.get_global_name()
		if script.get_global_name() == &"":
			continue
		
		var base_type : StringName = script.get_instance_base_type()
		add_custom_type(
			script_name, base_type, script, null
		)
func _exit_tree():
	var scripts := _get_all_files(SRC_DIR)
	
	for script_path : String in scripts:
		var script_name = script_path.get_file().get_basename()
		remove_custom_type(script_name)
#endregion


#region Private Methods
func _get_all_files(path: String) -> PackedStringArray:
	var files := PackedStringArray()
	var dir := DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				files.append_array(_get_all_files(path + file_name + "/"))
			elif file_name.ends_with(".gd"):
				files.append(path + file_name)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	return files
#endregion

# Made by Xavier Alvarez. A part of the "FreeControl" Godot addon.
