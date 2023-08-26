extends Control

"""
Script for the level_editor_ui but all inputs things are mostly in
the level_editor script
"""

@onready var _obj = self.get_node("SubViewportContainer/SubViewport/LevelEditor")
@onready var _vslider_zoom = self.get_node("VSliderZoom")

@onready var _textEditPower = self.get_node("panel/VBoxContainer/HBoxContainerPower/TextEditPower")
@onready var _textEditColor = self.get_node("panel/VBoxContainer/HBoxContainerColor/TextEditColor")
@onready var _sys_file = preload("res://datas/ressources/scripts/level_editor/file.gd").new()

var _brick_index = 0

var _dict_bricks_tileset_index = {"white_plane":0,
	"blue_plane":1,
	"green_plane":2,
	"yellow_plane":3,
	"pink_plane":4,
	"white_coffee":5,
	"blue_coffee":6,
	"green_coffee":7,
	"yellow_coffee":8,
	"pink_coffee":9,
	"white_slowerball":10,
	"blue_slowerball":11,
	"green_slowerball":12,
	"yellow_slowerball":13,
	"pink_slowerball":14,
	"white_deadhead":15,
	"blue_deadhead": 16,
	"green_deadhead":17,
	"yellow_deadhead":18,
	"pink_deadhead": 19,
	"white_bomb":20,
	"blue_bomb":21,
	"green_bomb":22,
	"yellow_bomb":23,
	"pink_bomb":24,
	"white_acohol":25,
	"blue_alcohol":26,
	"green_alcohol":27,
	"yellow_alcohol":28,
	"pink_alcohol":29,
	"white_ball": 30,
	"blue_ball":31,
	"green_ball":32,
	"yellow_ball":33,
	"pink_ball":34,
	"blue_rocket":35,
	"white_rocket":36,
	"green_rocket":37,
	"yellow_rocket":38,
	"pink_rocket":39,
	"white_bullet":40,
	"blue_bullet":41,
	"yellow_bullet":42,
	"green_bullet":43,
	"pink_bullet":44,
	"white_heart":45,
	"blue_heart":46,
	"green_heart":47,
	"yellow_heart":48,
	"pink_heart":49,
	"white":50,
	"blue":51,
	"pink":52,
	"yellow":53,
	"green":54,
	"black":55,
	"white_rc":56,
	"pink_rc":57,
	"yellow_rc":58,
	"blue_rc":59,
	"green_rc":60
}


func _ready():
	self.set_VSliderZoom_values()
	self._on_level_editor_zoom_key_board_short_cut(0.0030)
	
	var win = self.get_window()
	win.title = "Editeur de niveau"



func set_VSliderZoom_values():
	"""
		Called for setting maximum value and minimum value
		for the VSliderZoom
	"""
	self._vslider_zoom.max_value = self._obj.CAM_MAXIMUM_ZOOM
	self._vslider_zoom.min_value = self._obj.CAM_MINIMUM_ZOOM




func _on_v_slider_zoom_value_changed(value):
	var cam_object = self._obj.get_node("Camera2D")
	cam_object.zoom.x = value
	cam_object.zoom.y = value


func _on_level_editor_zoom_key_board_short_cut(step):
	self._vslider_zoom.step = step
	var cam_zoom = self._obj.get_node("Camera2D").zoom.x
	self._vslider_zoom.value = float(cam_zoom)
	

func CleanLineReturn(object):
	if self.ContainsLineReturn(object.text):
		object.text = object.text.replace("\n","")
		

func ContainsLineReturn(text):
	return "\n" in text


func _on_text_edit_power_text_changed():
	self.CleanLineReturn(self._textEditPower)


func _on_text_edit_color_text_changed():
	self.CleanLineReturn(self._textEditColor)


func get_textedit_focus():
	"""
		Return an boolean if ones of textEdit
		have focus 
	"""
	var focus = false
	
	if self._textEditColor.has_focus():
		focus = true
	if self._textEditPower.has_focus():
		focus = true
	
	return focus


func get_textedit_has_focus():
	"""
		Return an text edit object that have focus
		between two text Edit
	"""
	if self._textEditColor.has_focus():
		return self._textEditColor
	elif self._textEditPower.has_focus():
		return self._textEditPower


func change_brick(new_index:int):
	"""
		Called for changing brick ui on the interface also change
		the brick that the user can change on the tilemap
		
		new_index (int) is the value that is additionned to the actual brick
		index for the user this value can be equal to 1 also to -1
	"""
	self._brick_index += new_index
	self._brick_index += int(self._brick_index < 0) - int(self._brick_index > 60)
	
	self._obj.get_tileset_brick_index(self._brick_index)
	
	self.set_brick_texture(new_index)
	var brick_name = self.get_brick_name()
	
	self._obj.set_brick(brick_name)
	
	self.set_field(brick_name)


func set_brick_texture(new_index:int):
	var sprite_object = self.get_node("panel/VBoxContainer/Panel/HBoxContainer/Control/Sprite2D/Sprite2D")
	if get_brick_name_starts_with("white"):
		self._brick_index += new_index
	
	if self._brick_index <= 0:
		self._brick_index = 1
	
	sprite_object.frame = self._brick_index


func get_brick_name_starts_with(start_content:String):
	var brick_name = self._dict_bricks_tileset_index.keys()[self._brick_index]
	return brick_name.begins_with(start_content)

func set_field(brick_name:String):
	var pattern = "(?<name>(blue|black|yellow|green|pink)+)(?<power>_*(plane|alcohol|deadhead|bomb|slowerball|heart|ball|coffee|rocket|rc|bullet)*)"
	
	self.get_node("panel/VBoxContainer/HBoxContainerColor/TextEditColor").text = self.get_color(brick_name, pattern)
	self.get_node("panel/VBoxContainer/HBoxContainerPower/TextEditPower").text = self.get_power(brick_name, pattern)


func get_power(brick_name:String, pattern:String):
	var reg = RegEx.new()
	reg.compile(pattern)
	var m = reg.search_all(brick_name)
	if m:
		var t = m[0].strings
		return t[len(t)-1]
	
	return ""


func get_color(brick_name:String, pattern:String):
	var reg = RegEx.new()
	reg.compile(pattern)
	var m = reg.search_all(brick_name)
	if m:
		return m[0].strings[1]
	
	return ""


func _on_button_next_brick_pressed():
	self.change_brick(1)


func _on_button_previous_brick_pressed():
	self.change_brick(-1)


func get_brick_name():
	return self._dict_bricks_tileset_index.keys()[self._brick_index]


func _on_button_save_map_pressed():
	var tilemap_brick = self.get_node("SubViewportContainer/SubViewport/LevelEditor/TileMapBricks")
	self._sys_file.export_map(tilemap_brick, "map_test.json")

