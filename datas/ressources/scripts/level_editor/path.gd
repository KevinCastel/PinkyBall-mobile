extends Node

"""
	This file contains all instructions that interacts with path from
	
	Here a plan for this script reading:
		All the first functions are dedicated to properties basic function
		For the rest, it's string manipulation dedication
	
"""

var _thread : Thread

var _path_object = null

func _init(p:String):
	self._path_object = Path.new(p)


func _ready():
	self._thread = Thread.new()
	self._thread.start(self._path_object.correct_path)


func _exit_tree():
	self._thread.wait_to_finish()


class Path:
	
	const SPECIAL_CHAR = "$"
	
	var _path = ""
	var _corrected_path = ""
	
	func _set_corrected_path(v):
		_corrected_path = v
	
	func _get_corrected_path():
		return _corrected_path
	
	func _init(path:String):
		self._path = path
	
	func correct_path():
		"""
			Called for correcting path
		"""
		self._corrected_path = self._path
		if "\n" in self._corrected_path:
			self._corrected_path = self.remove_line_return(self._corrected_path)
		
		self._corrected_path = self.apply_syntax(self._corrected_path)
	
	
	func apply_syntax(path:String):
		"""
			Called for removing '/' at the end of the path (string) passed
			as argument
			Also remove special char when possible for example in the following
			example:
					'C:/usr/video-game/PinkyBall$/levels'
				It's gonna to remove like thah:
					'C:/usr/video-game/PinkyBall/levels', check the '$'
					
		"""
		var i = 0
		var a = path.split("")
		path = ""
		
		for char in a:
			if i == len(a)-1:
				if char != "/":
					path += char
				elif a[i-1] == "$":
					path += char
			elif i < len(a)-1: #remove special caracter
				if a[i+1] == "/":
					if char != "$" and char != "/":
						path += char
						
				else:
					path += char
			else:
				path += char
			i += 1
		
		return path
	
	
	func remove_line_return(path):
		return path.replace("\n", "")
	
	
