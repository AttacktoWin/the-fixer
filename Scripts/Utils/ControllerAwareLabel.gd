class_name ControllerAwareLabel extends Label

var _keyboardText
var _controllerText


func _ready():
	var split = self.text.split("///")
	if split.size() == 2:
		self._keyboardText = split[0]
		self._controllerText = split[1]
	else:
		var err = "TEXT PARSE ERROR"
		self._keyboardText = err
		self._controllerText = err
	update_text()


func update_text():
	if Scene.is_controller():
		self.text = self._controllerText
	else:
		self.text = self._keyboardText


func _process(_delta):
	update_text()
