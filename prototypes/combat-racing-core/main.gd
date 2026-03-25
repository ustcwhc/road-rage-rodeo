# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does smacking bikers off motorcycles feel fun in 3D?
# Date: 2026-03-23
extends Node3D

const RiderScript = preload("res://rider.gd")

var player: CharacterBody3D
var all_riders: Array = []
var camera: Camera3D
var finish_z: float = 6000.0  # ~2 min race at ~300 km/h average
var race_over: bool = false

# Weapon pickups
var pickup_nodes: Array[Node3D] = []
var pickup_cooldowns: Array[float] = []

# Nitro pickups
var nitro_nodes: Array[Node3D] = []
var nitro_cooldowns: Array[float] = []

# Slow-mo
var slow_mo_timer: float = 0.0

# HUD
var hp_label: Label
var weapon_label: Label
var speed_label: Label
var position_label: Label
var progress_label: Label
var message_label: Label
var controls_label: Label


func _ready() -> void:
	_build_environment()
	_build_road()
	_build_pickups()
	_build_nitro_pickups()
	_spawn_riders()
	_build_camera()
	_build_hud()


# ── World ────────────────────────────────────────────────────────────────────

func _build_environment() -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -30, 0)
	light.shadow_enabled = true
	light.light_energy = 1.2
	add_child(light)

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.65, 0.85)
	env.ambient_light_color = Color(0.6, 0.6, 0.65)
	env.ambient_light_energy = 0.4
	env.fog_enabled = true
	env.fog_light_color = Color(0.5, 0.6, 0.7)
	env.fog_density = 0.003
	env_node.environment = env
	add_child(env_node)


func _build_road() -> void:
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color(0.22, 0.22, 0.25)

	# Road surface
	var road := CSGBox3D.new()
	road.size = Vector3(14.0, 0.1, finish_z + 100.0)
	road.position = Vector3(0, -0.05, finish_z / 2.0)
	road.material = road_mat
	road.use_collision = true
	add_child(road)

	# Shoulder / ground planes on each side
	var ground_mat := StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.35, 0.45, 0.25)
	for side in [-1.0, 1.0]:
		var ground := CSGBox3D.new()
		ground.size = Vector3(40.0, 0.1, finish_z + 200.0)
		ground.position = Vector3(side * 27.0, -0.08, finish_z / 2.0)
		ground.material = ground_mat
		ground.use_collision = true
		add_child(ground)

	# Lane dividers (dashed yellow lines)
	var div_mat := StandardMaterial3D.new()
	div_mat.albedo_color = Color(0.9, 0.8, 0.1)
	for lane_x in [-2.3, 2.3]:
		for z in range(0, int(finish_z) + 50, 40):
			var dash := CSGBox3D.new()
			dash.size = Vector3(0.12, 0.12, 3.0)
			dash.position = Vector3(lane_x, 0.02, z)
			dash.material = div_mat
			add_child(dash)

	# Road edge barriers
	var barrier_mat := StandardMaterial3D.new()
	barrier_mat.albedo_color = Color(0.55, 0.55, 0.55)
	for side_x in [-6.5, 6.5]:
		var barrier := CSGBox3D.new()
		barrier.size = Vector3(0.4, 0.6, finish_z + 100.0)
		barrier.position = Vector3(side_x, 0.3, finish_z / 2.0)
		barrier.material = barrier_mat
		add_child(barrier)

	# Finish line
	var finish_mat := StandardMaterial3D.new()
	finish_mat.albedo_color = Color.WHITE
	var finish := CSGBox3D.new()
	finish.size = Vector3(14.0, 0.15, 2.0)
	finish.position = Vector3(0, 0.08, finish_z)
	finish.material = finish_mat
	add_child(finish)

	# Finish checkered posts
	var post_mat := StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.1, 0.1, 0.1)
	for px in [-6.0, 6.0]:
		var post := CSGBox3D.new()
		post.size = Vector3(0.3, 4.0, 0.3)
		post.position = Vector3(px, 2.0, finish_z)
		post.material = post_mat
		add_child(post)


func _build_pickups() -> void:
	# Scatter weapon pickups along the road
	for z in range(40, int(finish_z), 200):
		var x: float = [-4.0, 0.0, 4.0].pick_random()
		var pos := Vector3(x, 0.6, float(z) + randf_range(-10, 10))
		pickup_cooldowns.append(0.0)

		var node := Node3D.new()
		node.position = pos
		add_child(node)

		# Glowing sphere
		var sphere := CSGSphere3D.new()
		sphere.radius = 0.35
		sphere.radial_segments = 12
		sphere.rings = 8
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.75, 0.0)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.85, 0.2)
		mat.emission_energy_multiplier = 1.5
		sphere.material = mat
		node.add_child(sphere)

		# Floating animation column (visual only)
		var pole := CSGCylinder3D.new()
		pole.radius = 0.04
		pole.height = 0.6
		pole.position = Vector3(0, -0.3, 0)
		var pole_mat := StandardMaterial3D.new()
		pole_mat.albedo_color = Color(1.0, 0.85, 0.2, 0.5)
		pole_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pole.material = pole_mat
		node.add_child(pole)

		pickup_nodes.append(node)


func _build_nitro_pickups() -> void:
	# Scatter nitro pickups along the road (offset from weapon pickups)
	for z in range(80, int(finish_z), 350):
		var x: float = [-3.0, 1.0, 5.0].pick_random()
		var pos := Vector3(x, 0.6, float(z) + randf_range(-15, 15))
		nitro_cooldowns.append(0.0)

		var node := Node3D.new()
		node.position = pos
		add_child(node)

		# Lightning bolt shape — cyan sphere with emission
		var sphere := CSGSphere3D.new()
		sphere.radius = 0.3
		sphere.radial_segments = 10
		sphere.rings = 6
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.0, 0.9, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.0, 0.85, 1.0)
		mat.emission_energy_multiplier = 2.5
		sphere.material = mat
		node.add_child(sphere)

		# Small arrow pointing up
		var arrow := CSGCylinder3D.new()
		arrow.radius = 0.06
		arrow.height = 0.5
		arrow.position = Vector3(0, 0.35, 0)
		var arrow_mat := StandardMaterial3D.new()
		arrow_mat.albedo_color = Color(0.0, 1.0, 1.0, 0.6)
		arrow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		arrow.material = arrow_mat
		node.add_child(arrow)

		nitro_nodes.append(node)


# ── Riders ───────────────────────────────────────────────────────────────────

func _spawn_riders() -> void:
	# Player — blue
	player = _make_rider(Vector3(0, 0.5, 5), true, Color(0.2, 0.45, 1.0), 0)
	all_riders.append(player)

	# AI opponents
	var ai_configs := [
		[Vector3(-4, 0.5, 0), Color(0.9, 0.15, 0.15), 1],   # Red
		[Vector3(4, 0.5, 2), Color(0.15, 0.8, 0.15), 2],     # Green
		[Vector3(0, 0.5, -3), Color(0.9, 0.55, 0.1), 3],     # Orange
	]
	for cfg in ai_configs:
		var r := _make_rider(cfg[0], false, cfg[1], cfg[2])
		all_riders.append(r)


func _make_rider(pos: Vector3, is_player_flag: bool, color: Color, idx: int) -> CharacterBody3D:
	var rider := CharacterBody3D.new()
	rider.set_script(RiderScript)
	rider.is_player = is_player_flag
	rider.rider_color = color
	rider.rider_index = idx
	rider.position = pos
	add_child(rider)
	rider.knocked_out.connect(_on_knockout)
	return rider


func _on_knockout(rider: CharacterBody3D) -> void:
	# Slow-mo for dramatic effect
	Engine.time_scale = 0.25
	slow_mo_timer = 0.6


# ── Camera ───────────────────────────────────────────────────────────────────

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = player.position + Vector3(0, 5, -8)
	camera.fov = 65
	add_child(camera)
	camera.make_current()


func _update_camera(delta: float) -> void:
	if not player:
		return

	var offset: Vector3
	match player.state:
		RiderScript.State.RIDING:
			offset = Vector3(0, 4.5, -8)
		RiderScript.State.FLYING:
			offset = Vector3(0, 7, -12)
		RiderScript.State.SLIDING:
			offset = Vector3(0, 6, -10)
		RiderScript.State.ON_FOOT:
			offset = Vector3(0, 5, -9)

	var target_pos := player.position + offset
	camera.position = camera.position.lerp(target_pos, 4.0 * delta)
	camera.look_at(player.position + Vector3(0, 1.2, 2))


# ── HUD ──────────────────────────────────────────────────────────────────────

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	# Left panel — stats
	var panel := VBoxContainer.new()
	panel.position = Vector2(20, 20)
	layer.add_child(panel)

	hp_label = _make_label("HP: 100 / 100", 22)
	panel.add_child(hp_label)

	weapon_label = _make_label("Weapon: Fists", 20)
	panel.add_child(weapon_label)

	speed_label = _make_label("Speed: 0", 20)
	panel.add_child(speed_label)

	position_label = _make_label("Position: 1 / 4", 22)
	panel.add_child(position_label)

	progress_label = _make_label("Progress: 0%", 20)
	panel.add_child(progress_label)

	# Center message (race over, etc.)
	message_label = _make_label("", 36)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.anchors_preset = Control.PRESET_CENTER_TOP
	message_label.position = Vector2(640, 80)
	message_label.size = Vector2(400, 50)
	message_label.position.x -= 200
	layer.add_child(message_label)

	# Controls help — bottom right
	controls_label = _make_label(
		"[W/Up] Accelerate  [S/Down] Brake\n[A/D or Left/Right] Steer\n[Space] Attack  [R] Restart",
		16
	)
	controls_label.position = Vector2(900, 640)
	controls_label.modulate = Color(1, 1, 1, 0.6)
	layer.add_child(controls_label)


func _make_label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label


func _update_hud() -> void:
	# HP bar using text
	var hp_pct: float = float(player.hp) / 100.0
	var hp_bar := "█".repeat(int(hp_pct * 20)) + "░".repeat(20 - int(hp_pct * 20))
	hp_label.text = "HP: %s %d%%" % [hp_bar, player.hp]
	hp_label.modulate = Color.RED if player.hp < 30 else Color.WHITE

	# Weapon
	if player.weapon == 1:  # BAT
		weapon_label.text = "Weapon: BAT [%d hits left]" % player.weapon_durability
		weapon_label.modulate = Color(1, 0.8, 0)
	else:
		weapon_label.text = "Weapon: Fists"
		weapon_label.modulate = Color.WHITE

	# Speed + nitro indicator
	if player.has_nitro:
		var boost: float = player.NITRO_SPEED_BOOST
		if player.nitro_fading:
			boost *= clampf(player.nitro_fade_timer / player.NITRO_FADE_DURATION, 0.0, 1.0)
		var display_speed: int = int((player.forward_speed + boost) * 3.6)
		if player.nitro_fading:
			speed_label.text = "Speed: %d km/h  NITRO..." % display_speed
			speed_label.modulate = Color(0.0, 0.6, 0.7)
		else:
			speed_label.text = "Speed: %d km/h  NITRO!" % display_speed
			speed_label.modulate = Color(0.0, 1.0, 1.0)
	else:
		speed_label.text = "Speed: %d km/h" % int(player.forward_speed * 3.6)
		speed_label.modulate = Color.WHITE

	# Race position
	var ahead := 0
	for rider in all_riders:
		if rider != player and rider.position.z > player.position.z:
			ahead += 1
	var place := ahead + 1
	position_label.text = "Position: %d / %d" % [place, all_riders.size()]
	match place:
		1: position_label.modulate = Color(1, 0.85, 0)
		2: position_label.modulate = Color(0.8, 0.8, 0.8)
		_: position_label.modulate = Color.WHITE

	# Progress
	var pct := clampf(player.position.z / finish_z * 100.0, 0.0, 100.0)
	progress_label.text = "Progress: %d%%" % int(pct)


# ── Pickup logic ─────────────────────────────────────────────────────────────

func _check_pickups(delta: float) -> void:
	for i in pickup_nodes.size():
		# Cooldown
		if pickup_cooldowns[i] > 0.0:
			pickup_cooldowns[i] -= delta
			if pickup_cooldowns[i] <= 0.0:
				pickup_nodes[i].visible = true
			continue

		# Check all riders for collection
		for rider in all_riders:
			if rider.state != RiderScript.State.RIDING:  # Not RIDING
				continue
			if rider.position.distance_to(pickup_nodes[i].position) < 1.5:
				rider.pickup_weapon(1)  # Give BAT
				pickup_nodes[i].visible = false
				pickup_cooldowns[i] = 15.0  # Respawn delay
				break

	# Rotate visible pickups
	for node in pickup_nodes:
		if node.visible:
			node.rotation_degrees.y += 90.0 * delta

	# Nitro pickups
	for i in nitro_nodes.size():
		if nitro_cooldowns[i] > 0.0:
			nitro_cooldowns[i] -= delta
			if nitro_cooldowns[i] <= 0.0:
				nitro_nodes[i].visible = true
			continue

		for rider in all_riders:
			if rider.state != RiderScript.State.RIDING:
				continue
			if rider.position.distance_to(nitro_nodes[i].position) < 1.5:
				rider.pickup_nitro()
				nitro_nodes[i].visible = false
				nitro_cooldowns[i] = 20.0
				break

	for node in nitro_nodes:
		if node.visible:
			node.rotation_degrees.y += 120.0 * delta


# ── Race management ──────────────────────────────────────────────────────────

func _check_race_finish() -> void:
	if race_over:
		return

	for rider in all_riders:
		if rider.position.z >= finish_z:
			race_over = true
			Engine.time_scale = 1.0  # Reset slow-mo

			# Sort by position
			var sorted_riders := all_riders.duplicate()
			sorted_riders.sort_custom(func(a, b): return a.position.z > b.position.z)

			var player_place := sorted_riders.find(player) + 1
			var place_suffix := ["st", "nd", "rd", "th"]
			var suffix: String = place_suffix[mini(player_place - 1, 3)]

			message_label.text = "RACE OVER! You finished %d%s!\n[R] to restart" % [player_place, suffix]
			message_label.modulate = Color(1, 0.85, 0) if player_place == 1 else Color.WHITE
			return


func _restart_race() -> void:
	# Brute force restart
	get_tree().reload_current_scene()


# ── Main loop ────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	# Slow-mo timer (counts in real time)
	if slow_mo_timer > 0.0:
		slow_mo_timer -= delta / maxf(Engine.time_scale, 0.01)
		if slow_mo_timer <= 0.0:
			Engine.time_scale = 1.0

	_check_pickups(delta)
	_update_camera(delta)
	_update_hud()
	_check_race_finish()

	# Restart
	if Input.is_key_pressed(KEY_R):
		_restart_race()
