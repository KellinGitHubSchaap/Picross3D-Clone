extends MeshInstance3D

@onready var _faceNode = $Faces
@onready var _faces = _faceNode.get_children()
@export var _numberMaterials = []
@export var _circleNumberMaterials = []

@export var _color : Color

@export var _destroyParticleEffect : PackedScene

func set_values_on_the_faces(faceX : Dictionary, faceY : Dictionary, faceZ : Dictionary):
	for i in range(_faces.size()):
		var faceDictionary : Dictionary
		
		if(i <= 1):
			faceDictionary = faceX
		elif(i > 1 and i <= 3):
			faceDictionary = faceY
		elif(i > 3 and i <= 5):
			faceDictionary = faceZ
			
		var count = 0
		for key in range(faceDictionary.values().size()):
			if(faceDictionary.keys()[key] is Vector3 and faceDictionary.values()[key]):
				count += 1
		
		var materialsArray
		if(faceDictionary["ShowValue"]):
			if(faceDictionary["IsAChain"] == false):
				materialsArray = _circleNumberMaterials
				
				var trueFound = false
				for truth in range(faceDictionary.values().size() - 2):
					if(faceDictionary.values()[truth]):
						trueFound = true
				_faces[i].material_override = materialsArray[count - 1] if trueFound else materialsArray[0]
			else:
				materialsArray = _numberMaterials
				_faces[i].material_override = materialsArray[count]

func apply_color():
	for face in range(_faces.size()):
		var material : StandardMaterial3D
		material = _faces[face].get_active_material(0).duplicate()
		material.albedo_color = _color
		_faces[face].material_override = material

func on_destroy():
	var particle = _destroyParticleEffect.instantiate()
	particle.position = global_position
	particle.rotation = global_rotation
	particle.emitting = true
	get_tree().current_scene.add_child(particle)
	
	queue_free()
