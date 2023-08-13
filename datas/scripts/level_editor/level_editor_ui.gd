extends Control


@onready var _obj = self.get_node("SubViewportContainer/SubViewport/LevelEditor")
@onready var _vslider_zoom = self.get_node("VSliderZoom")

@onready var _textEditPower = self.get_node("panel/VBoxContainer/HBoxContainerPower/TextEditPower")
@onready var _textEditColor = self.get_node("panel/VBoxContainer/HBoxContainerColor/TextEditColor")

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
