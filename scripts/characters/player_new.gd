
extends KinematicBody

export var speed = 6
export var StartingHealth = 10

var health = 10 setget set_health

onready var cameraNode = get_node("Camera")
onready var animNode = get_node("AnimationPlayer")

var weaponIndex = 0
var pending_weapon_change = false

onready var weaponNodes = cameraNode.get_children()
onready var weaponNode = weaponNodes[weaponIndex]

var view_sensitivity = 0.15 setget set_view_sensitivity
onready var yaw = get_rotation().y
onready var pitch = cameraNode.get_rotation().x

var holder_sway_ang = Vector3()

var input = {
	attack1 = "released",
	attack2 = "released",
}

var is_dead = false

var state = {
	moving = false,
	in_ui = false,
	velocity = Vector3()
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
		if not state.in_ui:
			_do_game_input(event)
		
		if event.is_action_pressed("HUD_INV"):
			get_node("HUD").toggle_inventory()
	
	if event.is_action_pressed("HUD_MENU"):
		get_node("HUD").toggle_menu()

func _do_game_input(event):
	if event.type == InputEvent.MOUSE_MOTION and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		#pitch and yaw
		yaw = fmod(yaw - event.relative_x * view_sensitivity, 360)
		pitch = clamp(pitch - event.relative_y * view_sensitivity, -85, 85)
		
		holder_sway_ang += Vector3(event.relative_y, event.relative_x, 0)

	if event.is_action_pressed("ATTACK1") and input.attack1 == "released":
		input.attack1 = "press"
	
	if event.is_action_released("ATTACK1") and input.attack1 == "pressed":
		input.attack1 = "release"
	
	if event.is_action_pressed("ATTACK2") and input.attack2 == "released":
		input.attack2 = "press"
	
	if event.is_action_released("ATTACK2") and input.attack2 == "pressed":
		input.attack2 = "release"
	
	if event.is_action_pressed("WEAPON_PLUS"):
		pending_weapon_change = 1
	
	if event.is_action_pressed("WEAPON_MINUS"):
		pending_weapon_change = -1
	
	if event.is_action_pressed("HUD_MAP"):
		get_node("HUD").toggle_map()


func _fixed_process(delta):
	if state.in_ui:
		state.velocity = state.velocity.linear_interpolate(Vector3(), speed * delta)
	else:
		_do_move(delta)
	
	var motion = move(state.velocity * delta)
	if is_colliding():
		motion = get_collision_normal().slide(motion)
		motion.y = 0
		move(motion)
	
	state.moving = state.velocity.length() >= 1
	
	set_rotation(Vector3(0, deg2rad(yaw), 0))
	cameraNode.set_rotation(Vector3(deg2rad(pitch), 0, 0))

func _do_move(delta):
	var dir = Vector3()
	
	if not is_dead:
		var aim = get_transform().basis
		
		if Input.is_action_pressed("MOVE_FORWARD"):
			dir -= aim.z
		if Input.is_action_pressed("MOVE_BACK"):
			dir += aim.z
		if Input.is_action_pressed("MOVE_LEFT"):
			dir -= aim.x
		if Input.is_action_pressed("MOVE_RIGHT"):
			dir += aim.x
	
	dir.y = 0
	dir = dir.normalized() * speed
	
	if weaponNode.is_attacking:
		dir *= weaponNode.is_attacking.MoveSpeedMul
	
	state.velocity = state.velocity.linear_interpolate(dir, speed * delta)

func _process(delta):
	if not is_dead:
		#sway weapon holder
		holder_sway_ang *= 0.5 * delta
		var ang = weaponNode.get_rotation()
		var t_ang = ang.linear_interpolate(holder_sway_ang, 3 * delta)
		weaponNode.set_rotation(t_ang)
		
		#attack
		if input.attack2 == "released":
			if input.attack1 == "press":
				weaponNode.start_attack(false)
				input.attack1 = "pressed"
			elif input.attack1 == "release":
				weaponNode.stop_attack()
				input.attack1 = "released"
		else:
			if input.attack2 == "press":
				weaponNode.start_attack(true)
				input.attack2 = "pressed"
			elif input.attack2 == "release":
				weaponNode.stop_attack()
				input.attack2 = "released"
		
		#animate
		if !weaponNode.is_attacking:
			if state.moving:
				weaponNode.set_animation("walk", 1.1)
				set_animation("walk")
			else:
				weaponNode.set_animation("idle")
				set_animation("idle")
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
		set_animation("death", 1)
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

func set_animation(name, speed = 1):
	animNode.set_speed(speed)
	if name != animNode.get_current_animation():
		animNode.play(name)

func set_health(amnt):
	health = amnt
	get_node("HUD").set_health(health)

func set_view_sensitivity(num):
	view_sensitivity = (num / 100.0)
