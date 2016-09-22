
extends Spatial

func _ready():
	set_process(true)

func _process(delta):
	var target = DUNGEON_MANAGER.get_player().get_translation()
	target.y = get_global_transform().origin.y
	look_at(target, Vector3(0, 1, 0))
