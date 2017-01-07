
extends Spatial

onready var Vis = get_node("VisibilityNotifier")
var billboard = true

func _ready():
	if billboard:
		Vis.connect("enter_screen", self, "_onVisChange", [true])
		Vis.connect("exit_screen", self, "_onVisChange", [false])

func _process(delta):
	var target = DUNGEON_MANAGER.get_player().get_translation()
	target.y = get_global_transform().origin.y
	look_at(target, Vector3(0, 1, 0))

func _onVisChange(vis):
	set_process(billboard and vis)
