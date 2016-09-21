extends Spatial;

export var AttackAnimName = "attack"
export var Enabled = true setget _setEnabled

var _cooldownTimer = Timer.new()

var is_attacking = false
var can_attack = true

onready var Stats = get_node("WeaponStats")
onready var AnimPlayer = get_node("WeaponAnimation")
onready var HitBox = get_node("Attack Area")

func _ready():
	_cooldownTimer.set_wait_time(Stats.CooldownTime)
	_cooldownTimer.connect("timeout", self, "_onCooldownFinished")
	add_child(_cooldownTimer)
	
	HitBox.get_node("CollisionShape").get_shape().set_extents(Stats.HitboxSize)
	HitBox.set_translation( -Vector3(0, 0.05, 0.55 + Stats.HitboxSize.z))
	
	set_hidden(!Enabled)

func do_attack():
	if can_attack:
		_cooldownTimer.start()
		is_attacking = true
		can_attack = false
		
		AnimPlayer.play(AttackAnimName, -1, 1)

func set_animation(name, speed=1):
	AnimPlayer.set_speed(speed)
	var _name = AnimPlayer.get_current_animation()
	if name != _name:
		AnimPlayer.play(name)

func _eval_hit():
	var enemies = HitBox.get_overlapping_bodies()
	for e in enemies:
		if e.is_in_group("Enemy") and e.has_method("take_damage"):
			#yield(get_tree(), "idle_frame")
			e.take_damage(Stats.WeaponDamage)

func _setEnabled(enabled):
	set_hidden(!enabled)

func _onAttackFinished():
	is_attacking = false

func _onCooldownFinished():
	can_attack = true