extends CanvasLayer

@export var debug_toggle_btn: Button
@export var fps_label: Label
@export var debug_v_box: VBoxContainer

var debug_vars_to_update : Dictionary = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle debug panel"):
		visible = !visible
	_update_fps()

## WARNING: WILL CAUSE PROBLEMS IF YOU HAVE 2 VARS YOU WANT TO DISPLAY BUT THEY HAVE THE SAME NAME
## EVERYTIME YOU RUN IT IT IT WILL UPDATE THAT VARIABLE SO THE BEST IS TO PUT IT IN
func display_updating_var(variable_label : String, variable : Variant) -> void:
	# if it is not in the list of vars to update then create a label
	if variable_label not in debug_vars_to_update.keys():
		var new_label : Label = Label.new()
		new_label.text = variable_label + ": " + str(variable)
		new_label.name = variable_label
		debug_v_box.add_child(new_label)
		debug_vars_to_update[variable_label] = new_label
	else: # otherwise update the debug var
		print(variable_label + "variable updated")
		debug_vars_to_update[variable_label].text = variable_label + ": " + str(variable)
		
## Like the display_updating_debug_var function but it will never update the variable
## WARNING: will be weird if you call it more than once
func display_constant_var(variable_label : String, variable : Variant) -> void:
	# if it is not in the list of vars to update then create a label
	var new_label : Label = Label.new()
	new_label.text = variable_label + ": " + str(variable)
	new_label.name = variable_label
	debug_v_box.add_child(new_label)
 		
func _update_fps() -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_debug_toggle_button_up() -> void:
	if debug_toggle_btn.text == "off":
		debug_toggle_btn.text = "on"
		Global.debug_mode = true
	else:
		debug_toggle_btn.text = "off"
		Global.debug_mode = false
	print("debug mode is now: " + str(Global.debug_mode))
