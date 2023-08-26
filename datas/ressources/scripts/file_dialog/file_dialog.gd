extends Control

var _dicts_btns_dir = {}

var _childrens = {}

var _path

@onready var _panel_list = self.get_node("Panel/VBoxContainer/HBoxContainer/PanelActual/VBoxContainer")
@onready var _textedit_path = self.get_node("Panel/VBoxContainer/PanelPath/TextEditPath")

@onready var _path_obj = preload("res://datas/ressources/scripts/level_editor/path.gd")
@onready var _cmd_obj = preload("res://datas/ressources/scripts/level_editor/commands.gd")
@onready var _contextMenuPreObj = preload("res://datas/scene/FileDIalog/context_menu.tscn")
var _contextMenuObj
var _is_context_menu_open = false

var _btn_object_hovered

#All errors message are down here:
const ERROR_PATH_UNFOUND = "Ce chemin n'existe pas"
const ERROR_DIR_EMPTY = "Ce dossier est vide"
const MESSAGE_CREAT_DIR = "Création d'un dossier"
const MESSAGE_SUCCESSFULL_CREATED_DIR = "Création du dossier avec succès"
const MESSAGE_SUCCESSFULL_DELETED_DIR = "Suppression du dossier avec succès"
const MESSAGE_HELP_CMD_FINNISH = "Une commande se termine toujours par '$E'"
const MESSAGE_HELP_DEL_ALL = "Specifier '.' pour effacer tout de ce dossier"

func _ready():
	self._path = self.get_actual_path()
	self._textedit_path.text = self._path
	self.load_path()
	self.add_btns()

func _process(_delta):
	if Input.is_action_pressed("return_textedit"):
		if self._textedit_path.has_focus():
			
			self._textedit_path.release_focus()
		elif self._is_context_menu_open:
			self.HideContextMenu()
	
	
	if Input.is_action_just_pressed("right_click"):
		if self._is_context_menu_open:
			self.HideContextMenu()
		else:
			self.ShowContextMenu()

func set_files_btns_properties():
	var btn_load = self.get_node("VBoxContainer/HBoxContainerFiles/ButtonLoad")
	var btn_save = self.get_node("VBoxContainer/HBoxContainerFiles/ButtonSave")
	
	var min_size : Vector2i = Vector2i(120, 6)
	
	btn_save.custom_miminum_size = min_size
	btn_load.custom_minimum_size = min_size
	
	var v_size : Vector2i = Vector2i(120, 6)
	
	btn_load.set_size = v_size
	btn_save.set_size = v_size
	


func add_btns():
	for c in self._childrens:
		if self._childrens[c] == "dir":
			self.create_dir_btn(self._path+"/"+c)
			var dir_object = self.Dir.new() 
			dir_object.dir_name = c
			dir_object.path = self._path+"/"+c
			self._dicts_btns_dir[c] = dir_object
		else:
			self.create_file_label(self._path+"/"+c)


func load_path():
	"""
		Load all dirs and files from the actual path
	"""
	var path = self._textedit_path.text
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				self._childrens[file_name] = "dir"
			else:
				self._childrens[file_name] = "file"
			file_name = dir.get_next()
	
	if len(self._childrens) == 0:
		self.show_message(self.ERROR_DIR_EMPTY)


func create_file_label(path:String):
	"""
		Called for creating label for an specified file name,
		At the difference for a directory, this one shouldn't be clicked
		as a file
		
		Take Args AS:
			path (string) is the path of this file
	"""
	var label_object = Label.new()
	label_object.text = self.get_df_name(path)
	label_object.set_size(Vector2(30,50), false)
	label_object.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	label_object.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	self._panel_list.add_child(label_object)

func create_dir_btn(path:String):
	"""
		Called for creating clickable button linked to a specified
		dir path
	"""
	var btn_object = Button.new()
	btn_object.text = self.get_df_name(path)
	btn_object.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_object.set_size(Vector2(30,50),false)
	btn_object.connect("pressed", _on_btn_dir_pressed.bind(btn_object.text))
	btn_object.connect("mouse_entered", _on_btn_dir_hovered.bind(btn_object))
	btn_object.connect("mouse_exited", _on_btn_dir_unhovered.bind(btn_object))
	
	self._panel_list.add_child(btn_object)


func get_actual_path():
	"""
		Return the software execution path
	"""
	var path = OS.get_executable_path()
	if path.ends_with("Godot_v4.0.3-stable_linux.x86_64"):
		path = path.replace("Godot_v4.0.3-stable_linux.x86_64","PinkyBall-windows/levels")
	
	return path


func get_df_name(path:String):
	"""
		Called for getting a file name or directory name
		in a path for example if the path is:
			'c/usr/PinkyBall/level_editor'
		
		The function will return 'level_editor' from 'c/usr/PinkyBall/level_editor'
	"""
	var df_name = ""
	for c in path:
		if c == "/":
			df_name = ""
		else:
			df_name += c
	
	return df_name

func _on_text_edit_path_text_changed():
	var caret_position = self._textedit_path.get_caret_column()
	var path = self._textedit_path.text
	var backup_cmd = path
	
	var node_path_obj = self._path_obj.new(path)
	self.add_child(node_path_obj)
	
	while node_path_obj._thread.is_alive():
		path = node_path_obj._path_object._corrected_path
	
	node_path_obj.queue_free()
	
	if DirAccess.dir_exists_absolute(path):
		self._path = path
		self.clean_file_system_ui()
		self.load_path()
		self.add_btns()
	else:
		self.clean_file_system_ui()
		self.show_message(self.ERROR_PATH_UNFOUND)
	
	var cmd_obj = self._cmd_obj.new(backup_cmd)
	self.add_child(cmd_obj)
	
	var d = {}
	while cmd_obj.is_thread_alive():
		d = cmd_obj._cmd_obj._dict_command
	
	cmd_obj.queue_free()
	if len(d) > 0:
		self.execute_command(d, self._path)
	
	self._textedit_path.text = path
	self._textedit_path.set_caret_column(caret_position)


func execute_command(d:Dictionary, path:String):
	"""
	Called for executing command parsed
	from the path typed by the user.
	
	Take Args As:
	  d (dictionay(string:string) contains command datas
	"""
	var error_level = 0
	var argument : String
	if not "start_command" in d:
		error_level = 1
	
	if not "end_command" in d:
		error_level = 1
	elif d["end_command"] != "$E":
		error_level = 1
	
	if "argument" in d:
		argument = d["argument"]
	else:
		error_level = 1
	
	if error_level == 0:
		var start_cmd = d["start_command"]
		if start_cmd == "$C":
			self.create_file(path,argument)
			self.clean_file_system_ui()
			self.show_message(self.MESSAGE_SUCCESSFULL_CREATED_DIR)
			self._textedit_path.text = path+"/"+argument
			
		elif start_cmd == "$H":
			self.delete_dir(path)
			path = path.replace(argument, "")
			path = path.replace(d["start_command"],"")
			path = path.replace(d["command_end"],"")
			
			self.clean_file_system_ui()
			self._textedit_path.text = path
		elif start_cmd == "$D":
			self.delete_dir(path+argument)
			path = path.replace(self.get_df_name(path), "")
			self.clean_file_system_ui()
			self._textedit_path.text = path


func get_path_without_cmd(path:String, file_name:String, start_prefix:String):
	var recursive_path = path.replace(start_prefix, "")
	recursive_path = recursive_path.replace("$E","")
	recursive_path = recursive_path.replace(file_name, "")+"/"
	return recursive_path


func delete_dir(path:String):
	print("tentative d'élimination de:'",path,"'")
	var output = []
	OS.execute("rm", ["-fr",path], output)


func clean_file_system_ui():
	"""
		Remove all btns (dir) and labels (file) from the last path,
		This could serve for adding further all files and directories that
		contains the new path
	"""
	self._dicts_btns_dir.clear()
	self._childrens.clear()
	for child in self._panel_list.get_children():
		self._panel_list.remove_child(child)


func show_message(error:String):
	var label_object = Label.new()
	
	label_object.text = error
	label_object.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label_object.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	label_object.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_object.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	self._panel_list.add_child(label_object)


func ShowContextMenu():
	if not self._is_context_menu_open:
		self._contextMenuObj = self._contextMenuPreObj.instantiate()
		self.add_child(self._contextMenuObj)
		self._contextMenuObj.name = "context_menu"
		self._contextMenuObj._path = self._textedit_path.text
		self._contextMenuObj._btn_object = self._btn_object_hovered
		self._contextMenuObj.global_position = self.get_global_mouse_position()
		self._is_context_menu_open = true

func HideContextMenu():
	if self._is_context_menu_open:
		self._is_context_menu_open = false
		self._contextMenuObj.queue_free()

func get_file_name_from_cmd(path:String):
	var array_chars = path.split("")
	var index_c = 0
	var last_char = ""
	var file_name = ""
	var can_get_file_name = false
	for c in array_chars:
		if can_get_file_name:
			if last_char != "$" and c != "$":
				file_name += c
			
			if index_c < len(array_chars)-1:
				if last_char == "$" && c == "E":
					can_get_file_name = false
		else:
			if index_c > 0:
				if last_char == "$":
					if c == "C" or c == "D" or c == "H":
						can_get_file_name = true
			
		last_char = c
		index_c += 1
	
	return file_name


func create_file(path:String, file_name:String):
	var output = []
	OS.execute("mkdir",[path+"/"+file_name],output)
	

func remove_special_char(path:String):
	var path_length = len(path)-1
	var index_c = 0
	var array_chars = path.split("")
	path = ""
	for c in array_chars:
		if index_c < path_length:
			if c != self.SPECIAL_CHAR:
				path += c
			elif array_chars[index_c+1] != "/":
				path += c
		else:
			path += c
		
		index_c += 1
	return path


func _on_btn_dir_hovered(btn_obj):
	self._btn_object_hovered = btn_obj


func _on_btn_dir_unhovered(btn_obj):
	if self._btn_object_hovered:
		self._btn_object_hovered = null

func _on_btn_dir_pressed(txt:String):
	var dir_object = self._dicts_btns_dir[txt]
	var new_path = dir_object.path
	self._textedit_path.text = new_path
	self.clean_file_system_ui()
	self.load_path()
	self.add_btns()


class Dir:
	var dir_name = ""
	var maxChild = 0 #represents all dirs and files that this dir contains
	var path = ""
