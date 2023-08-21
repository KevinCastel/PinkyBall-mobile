extends Node

var _cmd_obj = null

var _cmd  = ""

var _thread : Thread

func _init(s:String):
	self._cmd = s

func _ready():
	self._cmd_obj = Command.new(self._cmd)

	self._thread = Thread.new()
	self._thread.start(self._cmd_obj.execute_command)

func get_commands():
  return self._cmd._dict_command

func is_thread_is_alive():
  return self._thread.is_alive()

func _exit_tree():
	self._thread.wait_to_finish()


class Command:
	"""
		Used for path gestion (based on a string)
		
		Clean the file path for this 
		
		See syntax command here:
			An syntax always have to be followed by '$', in the following
			format:
				'$<command><argument>$E'
			
			All command name are following this line:
				'C' create a file, the file name is an argument
				'D' delete a directory, the file name is an argument
				'H' delete the directory where the user is, take argument as '.',
					recreate the directory where the user is
				'E' specify the end of the command
	"""
	var _dict_command = {}
	var _cmd : String
	
	@export var _command : String:
		set (value):
			set_command_value(value) 
		get :
			return _command
	
	@export var _argument : String:
		set(value):
			set_argument_value(value)
		get:
			return _argument
		
	
	func set_argument_value(v):
		_argument = v
	
	func set_command_value(v):
		_command = v
	
	func _init(v:String):
		self._cmd = v
	
	func execute_command():
		var dict_infos = self.contains_syntax_command()
		if self.is_enough_syntax(dict_infos):
			self._command = dict_infos["start_command"]
			self._argument = dict_infos["argument"]
			
			self._dict_command = dict_infos
			
			print("arg:", self._argument)
			print("cmd:",self._command)
		else:
			#Check for errors
			pass
	
	func is_enough_syntax(d):
		"""
			Check if enough informations was typed for example:
				the user have to write some things.
				This program can know the length that have to be so
				thanks to the user will type, we can check the size of
				information passed by the user.
				Theses informations have to be:
					path (that is by default)
					start_command
					argument
					end_command
		"""
		return (len(d) == 3)
	
	func contains_syntax_command():
		"""
			Return if an command is in the path,
			If an starting command name 'see documentation at the top of
			this script'
			
			Return a dictionary
		"""
		var regex_obj = RegEx.new()
		var patt = "(?<path>.*)(?<starting_command>\\$C|\\$D|\\$H*)(?<argument>.*)"
		regex_obj.compile("(?<path>.*)(?<starting_command>\\$C|\\$D|\\$H*)(?<argument>.*)(\\$E*)")
		var dict_result = {}
		var m = regex_obj.search_all(self._cmd)
		if len(m) > 0:
			var list_result = m[0].strings
			list_result.remove_at(0)
			
			if len(list_result) > 1:
				dict_result["start_command"] = list_result[1]
			
			if len(list_result) > 2:
				dict_result["argument"] = list_result[2]
			
			if len(list_result) > 3:
				dict_result["end_command"] = list_result[3]
				
		return dict_result

  