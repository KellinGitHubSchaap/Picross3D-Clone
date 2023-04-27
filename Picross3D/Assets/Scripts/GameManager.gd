extends Node3D

enum DIFFICULTY {
	EASY = 0,
	MEDIUM = 30,
	HARD = 50
}
@export var _difficultySetting = DIFFICULTY.EASY

@onready var _buildScript = $"Holder X Rotation/Holder Y Rotation"
@onready var _cameraScript = $"Camera3D"

enum TOOLS {
	NONE = 0,
	BRUSH = 1,
	HAMER = 2
}

var _toolState = TOOLS.NONE
@export var _toolDescriptor : Label

func _ready():
	_buildScript.setup_level()
	_cameraScript.setup_camera()

func _process(delta):
	if(_toolState != TOOLS.NONE):
		change_toolstate(TOOLS.NONE)

	if(Input.is_action_pressed("Select_Brush")):
		change_toolstate(TOOLS.BRUSH)
	elif(Input.is_action_pressed("Select_Hamer")):
		change_toolstate(TOOLS.HAMER)

func change_toolstate(toolState : TOOLS):
	_toolState = toolState
	_toolDescriptor.text = TOOLS.keys()[_toolState]

