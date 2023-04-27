extends GPUParticles3D

@onready var _timeCreated = Time.get_ticks_msec()
@export var _timeTillSelfDestroy : float

func _process(delta):
	if(Time.get_ticks_msec() - _timeCreated > _timeTillSelfDestroy):
		queue_free()

