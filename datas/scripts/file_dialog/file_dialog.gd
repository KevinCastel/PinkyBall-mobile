extends Control

var _dicts_btns_dir = {}

var _childrens = {}

var _path

@onready var _panel_list = self.get_node("VBoxContainer/HBoxContainer/PanelActual/VBoxContainer")
@onready var _textedit_path = self.get_node("VBoxContainer/PanelPath/TextEditPath")

@onready var _path_obj = preload("res://datas/scripts/level_editor/path.gd")
@onready var _cmd_obj = preload("res://datas/scripts/level_editor/commands.gd")

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

func _process(_Okdelta):
	if Input.is_action_pressed("return_textedit"):
		if self._textedit_path.has_focus():
			self._textedit_path.release_focus()

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
	var path = self._textedit_path.text
	var backup_cmd = path
	var caret_position = self._textedit_path.get_caret_column(0)
	
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
	
	var d = null
	while cmd_obj.is_thread_alive():
	  d = cmd_obj._cmd_obj._dict_command
	
	cmd_obj.queue_free()
	
	self.execute_command(d)
	
	"""
	var recursive_path = ""
	var argument = "" #can serve for stocking file_name specified for example
	if "$C" in path:
		argument = self.get_file_name_from_cmd(path)
		self.clean_file_system_ui()
		self.show_message(self.MESSAGE_CREAT_DIR+" :"+argument)
		
		if "$E" in path:
			recursive_path = self.get_path_without_cmd(path, argument, "$C")
			self.execute_file_name_cmd(recursive_path, argument)
			path = recursive_path+argument
			self.clean_file_system_ui()
			self.show_message(self.MESSAGE_SUCCESSFULL_CREATED_DIR)
	elif "$D" in path:
		argument = self.get_file_name_from_cmd(path)
		self.clean_file_system_ui()
		self.show_message(self.MESSAGE_HELP_CMD_FINNISH)
		if "$E" in path:
			recursive_path = self.get_path_without_cmd(path, argument, "$D")
			path = recursive_path
			self.execute_delete_dir_cmd(path+argument)
			self.clean_file_system_ui()
			self.show_message(self.MESSAGE_SUCCESSFULL_DELETED_DIR)
	elif "$H" in path:
		argument = self.get_file_name_from_cmd(path)
		if "$E" in path:
			if argument == ".":
				recursive_path = self.get_path_without_cmd(path, argument, "$H")
				if recursive_path.ends_with("/"):
					#recursive_path = self.correct_path(recursive_path)
					
					self.execute_delete_dir_cmd(recursive_path)
					self.execute_file_name_cmd(recursive_path,"")
					self.clean_file_system_ui()
					self.show_message(self.MESSAGE_SUCCESSFULL_DELETED_DIR)
				else:
					self.clean_file_system_ui()
					self.show_message(self.MESSAGE_HELP_DEL_ALL)
		else:
			self.clean_file_system_ui()
			self.show_message(self.MESSAGE_HELP_CMD_FINNISH)
	
	self._textedit_path.text = path
	self._textedit_path.set_caret_column(caret_position)
	"""


func execute_command(d):
  """
    Called for executing command parsed
    from the path typed by the user.
    
    Take Args As:
      d (dictionay(string:string) contains command datas
  """
  var start_cmd = d["start_command"]
  if start_cmd == "$C":
    pass
  elif start_cmd == "$H":
    pass
  elif start_cmd == "$D":
    pass

func get_path_without_cmd(path:String, file_name:String, start_prefix:String):
	var recursive_path = path.replace(start_prefix, "")
	recursive_path = recursive_path.replace("$E","")
	recursive_path = recursive_path.replace(file_name, "")+"/"
	return recursive_path


func execute_delete_dir_cmd(path:String):
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


func execute_file_name_cmd(path:String, file_name:String):
	var output = []
	OS.execute("mkdir",[path+file_name],output)
	

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
