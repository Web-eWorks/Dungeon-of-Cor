
extends Node

export var Enabled = true
export var AnimationName = "attack"

export var CooldownTime = 0.2
export var MoveSpeedMul = 0.5

var can_attack = true
onready var CooldownTimer = Timer.new()
onready var weapon = get_parent()

func _ready():
	CooldownTimer.set_wait_time(CooldownTime)
	CooldownTimer.connect("timeout", self, "_onCooldownFinished")
	add_child(CooldownTimer)

func start_attack():
	can_attack = false
	# Directly start the animation, as set_animation() may fail
	# due to the old animation not being cleared yet
	get_parent().AnimPlayer.set_speed(1)
	get_parent().AnimPlayer.play(AnimationName)

func attack_finished():
	CooldownTimer.start()

func _onCooldownFinished():
	can_attack = true
