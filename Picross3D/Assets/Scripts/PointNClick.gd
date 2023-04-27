extends Camera3D

@export var _dragSensitivity : float
@export var _zoomStrength : float

@onready var _holderNodeX = get_parent().get_node("Holder X Rotation")
@onready var _holderNodeY = get_parent().get_node("Holder X Rotation/Holder Y Rotation")

var _mouse : Vector2 = Vector2()
var _isHolding : bool = false
var _capturedMouseSpeed = Vector2()

@onready var _gameManager = get_parent()

func setup_camera():
	look_at(_holderNodeX.transform.origin, Vector3.UP)

func _input(event):
	if(event is InputEventMouse):
		_mouse = event.position
	
	if(event is InputEventMouseButton):
		if(event.pressed):
			if(event.is_action_pressed("Left_Click")):
				if(_gameManager._toolState == _gameManager.TOOLS.HAMER or _gameManager._toolState == _gameManager.TOOLS.BRUSH):
					edit_selection(_gameManager._toolState)
			if(event.is_action_pressed("Right_Click")):
				_isHolding = true
			
			if(event.button_index == MOUSE_BUTTON_WHEEL_UP and fov - _zoomStrength * get_process_delta_time() > 1):
				fov -= _zoomStrength * get_process_delta_time() 
			elif(event.button_index == MOUSE_BUTTON_WHEEL_DOWN and fov + _zoomStrength * get_process_delta_time() < 50):
				fov += _zoomStrength * get_process_delta_time()
		elif(!event.pressed):
			if(event.is_action_released("Right_Click")):
				_isHolding = false

	if(event is InputEventMouseMotion):
		if(_isHolding):
			rotate_puzzle(event.relative, get_process_delta_time())

func edit_selection(toolState):
	var worldSpace = get_world_3d().direct_space_state
	var start = project_ray_origin(_mouse)
	var end = project_position(_mouse, 1000)
	var parameters = PhysicsRayQueryParameters3D.create(start, end)
	var result = worldSpace.intersect_ray(parameters)
	
	if(result.keys().size() != 0):
		if(toolState == _gameManager.TOOLS.HAMER and result.collider.get_parent().is_in_group("DestroyableBlock")):
			result.collider.get_parent().on_destroy()
		elif(toolState == _gameManager.TOOLS.BRUSH and result.collider.get_parent().is_in_group("UnbreakableBlock")):
			result.collider.get_parent().apply_color()
		else:
			if(result.keys().size() == 0): return
			print("WRONG BLOCK! +1 Mistake")

func rotate_puzzle(mouseSpeed : Vector2, delta):
	_holderNodeY.rotate_y(mouseSpeed.x * (delta / _dragSensitivity))
	_holderNodeX.rotate_x(mouseSpeed.y * (delta / _dragSensitivity))
	_holderNodeX.rotation.x = clamp(_holderNodeX.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	
	_capturedMouseSpeed = mouseSpeed

