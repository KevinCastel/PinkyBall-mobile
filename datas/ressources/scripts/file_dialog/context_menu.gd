extends Panel

var _btn_object
var _path = ""

@onready var _parent = self.find_parent("FileDialog")


func _on_button_rename_pressed():
	var path = self._path + "/"+_btn_object.text
	#self.find_parent("FileDialog").delete_dir(path)
	self.queue_free()


func _on_button_delete_pressed():
	var path = self._path + "/"+_btn_object.text
	self._parent.delete_dir(path)
	self.queue_free()
	self.queue_free()



func destroy():
	self.queue_redraw()


func refresh_parent_screen():
	pass
