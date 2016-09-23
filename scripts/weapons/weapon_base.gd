extends Spatial;

export var Enabled = true setget _setEnabled
export var HitboxSize = Vector3(.5, .5, .5)

var is_attacking = false

onready var Attack = get_node("Attack")
onready var AltAttack = get_node("AltAttack")
onready var AnimPlayer = get_node("WeaponAnimation")
onready var HitBox = get_node("Attack Area")

onready var parent = get_parent().get_owner()

func _ready():
	var box = BoxShape.new()
	box.set_extents(HitboxSize)
	
	HitBox.get_node("CollisionShape").set_shape(box)
	HitBox.set_translation( -Vector3(0, 0.05, 0.55 + HitboxSize.z))
	
	set_hidden(!Enabled)

func start_attack(alt):
	var attack
	if alt: attack = AltAttack
	else: attack = Attack
	
	if is_attacking or not attack.Enabled: return
	
	if attack.can_attack:
		is_attacking = attack
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

func _setEnabled(enabled):
	set_hidden(!enabled)

func _onAttackFinished():
	is_attacking = false
