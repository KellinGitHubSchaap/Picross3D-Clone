extends Node3D

@export var _breakableBlocks: Resource
@export var _dimensions: Vector3

@onready var _unbreakables = get_children()

@onready var _gameManager = get_parent().get_parent()

var _puzzleInfoDict = {
	"FaceX" : {
		"Positions" : {}
	},
	"FaceY" : {
		"Positions" : {}
	},
	"FaceZ" : {
		"Positions" : {}
	}
}

# Setup Level; Builds the level into a playable form
func setup_level():
	scan_axis("FaceX", "FamilyZ", "FamilyY", Vector3(_dimensions.z, _dimensions.y, _dimensions.x))
	scan_axis("FaceY", "FamilyZ", "FamilyX", Vector3(_dimensions.z, _dimensions.x, _dimensions.y))
	scan_axis("FaceZ", "FamilyY", "FamilyX", Vector3(_dimensions.y, _dimensions.x, _dimensions.z))
	
	build_around_puzzle()
	center_all_pieces()

# Scan Axis; Scans every axis on a block (XYZ) upon start and before the "Build Around Puzzle" function is called. This function notes where and how many blocks are placed inside the puzzle 
func scan_axis(face : String, familyA : String, familyB : String, scanOrder : Vector3):
	var positionCheckOrder : Vector3
	
	for a in range(scanOrder.x):
		_puzzleInfoDict[face]["Positions"][familyA + str(a)] = {}
		for b in range(scanOrder.y):
			_puzzleInfoDict[face]["Positions"][familyA + str(a)][familyB + str(b)] = {}
			for c in range(scanOrder.z):
				
				if(face == "FaceX"): positionCheckOrder = Vector3(c, b, a)
				elif(face == "FaceY"): positionCheckOrder = Vector3(b, c, a)
				elif(face == "FaceZ"): positionCheckOrder = Vector3(b, a, c) 
				
				for piece in range(_unbreakables.size()):
					if(!_puzzleInfoDict[face]["Positions"][familyA + str(a)][familyB + str(b)].has(positionCheckOrder)):
						_puzzleInfoDict[face]["Positions"][familyA + str(a)][familyB + str(b)][positionCheckOrder] = false
					
					if(positionCheckOrder == _unbreakables[piece].transform.origin):
						_puzzleInfoDict[face]["Positions"][familyA + str(a)][familyB + str(b)][positionCheckOrder] = true
			
			chain_check(face, familyA, a, familyB, b)
			decide_to_show_values(face, familyA, a, familyB, b)

# Chain Check; Will find out if a set of blocks in a row / column can be considered a "Chain". If there is a gap, "isChain" will return false and is saved in the _puzzleInfoDict
func chain_check(face : String, familyA : String, familyAOffset : int, familyB : String, familyBOffset : int):
	var familyValues = _puzzleInfoDict[face]["Positions"][familyA + str(familyAOffset)][familyB + str(familyBOffset)].values()
	var isChain = false
	var chain = []
	
	for i in range(familyValues.size()):
		if familyValues[i] == true:
			chain.append(true)
			if(chain.size() >= 1):
				isChain = true
				if(chain.rfind(false) != -1):
					isChain = false
		
		if(familyValues[i] == false):
			if(chain.size() >= 1):
				chain.append(false)
	
	_puzzleInfoDict[face]["Positions"][familyA + str(familyAOffset)][familyB + str(familyBOffset)]["IsAChain"] = isChain 

# Decide To Show Values; Based on the _gamemanager.DIFFICULTY setting, this function will decide for each row / column if the value is allowed to be shown to the player
func decide_to_show_values(face : String, familyA : String, familyAOffset : int, familyB : String, familyBOffset : int):
	var randomVal = RandomNumberGenerator.new().randi_range(0, 100)
	
	_puzzleInfoDict[face]["Positions"][familyA + str(familyAOffset)][familyB + str(familyBOffset)]["ShowValue"] = true
	
	if(_gameManager._difficultySetting == _gameManager.DIFFICULTY.MEDIUM and randomVal <= _gameManager.DIFFICULTY.MEDIUM or _gameManager._difficultySetting == _gameManager.DIFFICULTY.HARD and randomVal <= _gameManager.DIFFICULTY.HARD): 
		_puzzleInfoDict[face]["Positions"][familyA + str(familyAOffset)][familyB + str(familyBOffset)]["ShowValue"] = false

# Build Around Puzzle; Places "Breakable" blocks around the already placed ("Unbreakable") blocks 
func build_around_puzzle():
	for i in range(_unbreakables.size()):
		set_breakable_block_values(_unbreakables[i])
	
	for x in range(_dimensions.x):
		for y in range(_dimensions.y):
			for z in range(_dimensions.z):
				var canPlace : bool = true
				for piece in range(_unbreakables.size()):
					if(Vector3(x, y, z) == _unbreakables[piece].transform.origin):
						canPlace = false
				if(canPlace):
					var breakable = _breakableBlocks.instantiate()
					add_child(breakable)
					breakable.transform.origin = Vector3(x, y, z)
					set_breakable_block_values(breakable)

# Set Breakable Block Values; The values stored inside the _puzzleInfoDict will be placed on each face of a block 
func set_breakable_block_values(block):
	if(!block.get_script()): return

	block.set_values_on_the_faces(
		_puzzleInfoDict["FaceX"]["Positions"]["FamilyZ" + str(block.transform.origin.z)]["FamilyY" + str(block.transform.origin.y)],
		_puzzleInfoDict["FaceY"]["Positions"]["FamilyZ" + str(block.transform.origin.z)]["FamilyX" + str(block.transform.origin.x)],
		_puzzleInfoDict["FaceZ"]["Positions"]["FamilyY" + str(block.transform.origin.y)]["FamilyX" + str(block.transform.origin.x)],
	)

# Center All Pieces; Makes sure that the puzzle is centered and will rotate correctly
func center_all_pieces():
	var pivotOffset : Vector3 = (_dimensions / 2) - Vector3(0.5, 0.5, 0.5)
	
	for piece in range(get_child_count()):
		get_child(piece).transform.origin -= pivotOffset 
