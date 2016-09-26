
extends Node

export var Enabled = true
export var AnimationName = "attack"

export var CooldownTime = 0.7
export var MoveSpeedMul = 0.5

var can_attack = true
onready var CooldownTimer = Timer.new()
onready var weapon = get_parent()

func _ready():
	CooldownTimer.set_wait_time(CooldownTime)
	CooldownTimer.connect("timeout", self, "_onCooldownFinished")
	add_child(CooldownTimer)

func start_attack():
	CooldownTimer.start()
	can_attack = false
	get_parent().set_animation(AnimationName, 1)

func _onCooldownFinished():
	can_attack = true
