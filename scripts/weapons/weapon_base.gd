extends Spatial;

export var Enabled = true setget _setEnabled
export var HitboxSize = Vector3(.5, .5, .5)

var is_attacking = false
var can_attack = true

var _cooldownTimer = Timer.new()

onready var Attack = get_node("Attack")
onready var AltAttack = get_node("AltAttack")
onready var AnimPlayer = get_node("WeaponAnimation")
onready var HitBox = get_node("Attack Area")

onready var parent = get_parent().get_owner()

func _ready():
	_cooldownTimer.connect("timeout", self, "_onCooldownFinished")
	add_child(_cooldownTimer)
	
	var box = BoxShape.new()
	box.set_extents(HitboxSize)
	
	HitBox.get_node("CollisionShape").set_shape(box)
	HitBox.set_translation( -Vector3(0, 0.05, 0.55 + HitboxSize.z))
	
	set_hidden(!Enabled)

func start_attack(alt):
	var attack
	if alt:
		attack = AltAttack
	else:
		attack = Attack
	if can_attack and attack.Enabled:
		run_timer(attack.CooldownTime)
		is_attacking = attack
		can_attack = false
		
		set_animation(attack.AnimationName, 1)
		if attack.has_method("start_attack"):
			attack.start_attack()

func do_attack():
	if is_attacking:
		is_attacking.do_attack()

func stop_attack():
	if is_attacking and is_attacking.has_method("stop_attack"):
		is_attacking.stop_attack()

func set_animation(name, speed=1):
	AnimPlayer.set_speed(speed)
	var _name = AnimPlayer.get_current_animation()
	if name != _name:
		AnimPlayer.play(name)

func run_timer(time):
	_cooldownTimer.set_wait_time(time)
	_cooldownTimer.start()

func _setEnabled(enabled):
	set_hidden(!enabled)

func _onAttackFinished():
	is_attacking = false

func _onCooldownFinished():
	can_attack = true