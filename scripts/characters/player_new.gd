
extends KinematicBody

export var speed = 6
export var StartingHealth = 10

var health = 10 setget set_health

onready var cameraNode = get_node("Yaw/Camera")
onready var animNode = get_node("AnimationPlayer")

var weaponIndex = 0
var pending_weapon_change = false

onready var weaponNodes = cameraNode.get_children()
onready var weaponNode = weaponNodes[weaponIndex]

var view_sensitivity = 0.15 setget set_view_sensitivity
var yaw = 0
var pitch = 0

var holder_sway_ang = Vector3()

var _velocity = Vector3()

var attack_pressed = false

var is_dead = false

var state = {
	moving = false,
}

var anim = "idle"

func _ready():
	set_process_input(true)
	set_fixed_process(true)
	set_process(true)
	
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)
	
	Input.warp_mouse_pos(OS.get_window_size()/2)
	
	health = StartingHealth
	
	for w in weaponNodes:
		w.Enabled = false
	weaponNode.Enabled = true
	
	cameraNode.set_perspective(GLOBAL.settings["fov"], 0.1, 100)
	set_view_sensitivity(GLOBAL.settings["view_sensitivity"])


func _input(event):
	if not is_dead:
		if event.type == InputEvent.MOUSE_MOTION and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#pitch and yaw
			yaw = fmod(yaw - event.relative_x * view_sensitivity, 360)
			pitch = clamp(pitch - event.relative_y * view_sensitivity, -85, 85)
			
			holder_sway_ang += Vector3(event.relative_y, event.relative_x, 0)
			
			get_node("Yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
			cameraNode.set_rotation(Vector3(deg2rad(pitch), 0, 0))
		
		if event.is_action_pressed("ATTACK1"):
			attack_pressed = true
		
		if event.is_action_released("ATTACK1"):
			attack_pressed = false
		
		if event.is_action_pressed("WEAPON_PLUS"):
			pending_weapon_change = 1
		
		if event.is_action_pressed("WEAPON_MINUS"):
			pending_weapon_change = -1
		
		if event.is_action_pressed("HUD_MAP"):
			get_node("SamplePlayer").play("button_press")
			get_node("HUD").toggle_map()
	
	if event.is_action_pressed("HUD_MENU"):
		get_node("HUD").toggle_menu()


func _fixed_process(delta):
	var movef = Input.is_action_pressed("MOVE_FOWARD")
	var moveb = Input.is_action_pressed("MOVE_BACK")
	var mover = Input.is_action_pressed("MOVE_RIGHT")
	var movel = Input.is_action_pressed("MOVE_LEFT")
	
	var dir = Vector3()
	
	if not is_dead:
		var aim = get_node("Yaw").get_transform().basis
		if movef:
			dir -= aim.z
		if moveb:
			dir += aim.z
		if mover:
			dir += aim.x
		if movel:
			dir -= aim.x
	
	dir.y = 0
	dir = dir.normalized() * speed
	
	if weaponNode.is_attacking:
		dir *= weaponNode.Stats.MoveSpeedMul
	
	_velocity = _velocity.linear_interpolate(dir, 6 * delta)
	
	var motion = move(_velocity * delta)
	if is_colliding():
		motion = get_collision_normal().slide(motion)
		motion.y = 0
		move(motion)
	
	state.moving = movef or moveb or mover or movel

func _process(delta):
	if not is_dead:
		#sway weapon holder
		holder_sway_ang *= 0.5 * delta
		var ang = weaponNode.get_rotation()
		var t_ang = ang.linear_interpolate(holder_sway_ang, 3 * delta)
		weaponNode.set_rotation(t_ang)
		
		#attack
		if attack_pressed:
			weaponNode.do_attack()
		
		#animate
		if !weaponNode.is_attacking:
			if state.moving:
				weaponNode.set_animation("walk", 1.1)
				animNode.play("walk")
			else:
				weaponNode.set_animation("idle")
				animNode.play("idle")
			if pending_weapon_change != false:
				set_weapon(weaponIndex + pending_weapon_change)
				pending_weapon_change = false

func take_damage(amnt):
	health -= amnt
	
	get_node("SamplePlayer").play("player_hurt")
	COLOR_MANAGER.animate_white("flash", Color("b52d1b"))
	get_node("HUD").set_health(health)
	
	if health <= 0:
		is_dead = true
		weaponNode.set_animation("death")
		get_node("AnimationPlayer").play("death", 1)
		get_node("HUD").death_menu()
		MUSIC.play_music("JRPG_gameOver", false)

func set_weapon(idx=0):
	idx %= weaponNodes.size()
	weaponIndex = idx
	weaponNode.Enabled = false
	weaponNode = weaponNodes[weaponIndex]
	weaponNode.Enabled = true

func heal(amnt):
	set_health(min(health + amnt, 10))
	get_node("SamplePlayer").play("heal")
	COLOR_MANAGER.animate_white("flash", Color("59b32d"))

func set_health(amnt):
	health = amnt
	get_node("HUD").set_health(health)

func set_view_sensitivity(num):
	view_sensitivity = (num / 100.0)