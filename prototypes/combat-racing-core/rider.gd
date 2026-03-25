# PROTOTYPE - NOT FOR PRODUCTION
# Question: Does smacking bikers off motorcycles feel fun in 3D?
# Date: 2026-03-23
extends CharacterBody3D

## Config — set these before add_child()
var is_player: bool = false
var rider_color: Color = Color.WHITE
var rider_index: int = 0

# -- Constants --
const MAX_HP: int = 100
const FIST_DAMAGE: int = 15
const BAT_DAMAGE: int = 30
const BAT_DURABILITY: int = 5
const ATTACK_RANGE_Z: float = 3.5
const ATTACK_RANGE_X: float = 3.5
const ATTACK_COOLDOWN: float = 0.5
const MAX_SPEED: float = 83.3  # 300 km/h
const ACCELERATION: float = 45.0
const BRAKE_FORCE: float = 70.0
const LANE_MOVE_SPEED: float = 18.0
const GRAVITY: float = 30.0
const WALK_SPEED: float = 2.5
const ROAD_MIN_X: float = -5.5
const ROAD_MAX_X: float = 5.5

# -- State --
enum State { RIDING, FLYING, ON_FOOT }
var state: int = State.RIDING
var hp: int = MAX_HP
var forward_speed: float = 0.0

# -- Weapon --
enum Weapon { FISTS, BAT }
var weapon: int = Weapon.FISTS
var weapon_durability: int = 0

# -- Nitro --
var has_nitro: bool = false
var nitro_timer: float = 0.0
var nitro_fading: bool = false
var nitro_fade_timer: float = 0.0
const NITRO_DURATION: float = 2.5
const NITRO_FADE_DURATION: float = 1.5  # Gradual wind-down
const NITRO_SPEED_BOOST: float = 55.0  # ~500 km/h at peak

# -- Combat --
var attack_cooldown: float = 0.0
var is_attacking: bool = false
var attack_flash_timer: float = 0.0

# -- Flying / remount --
var bike_stop_position: Vector3 = Vector3.ZERO
var fly_time: float = 0.0
var stopped_bike_marker: Node3D = null
var is_sliding: bool = false  # Ground slide vs airborne
const SLIDE_FRICTION: float = 8.0

# -- AI --
var ai_speed_target: float = 0.0
var ai_attack_timer: float = 0.0
var ai_lane_timer: float = 0.0
var ai_target_x: float = 0.0

# -- Visuals --
var bike_mesh: Node3D = null
var body_mesh: Node3D = null

# -- Signals --
signal knocked_out(rider: CharacterBody3D)
signal race_finished(rider: CharacterBody3D, place: int)


func _ready() -> void:
	add_to_group("riders")
	_build_visuals()

	if is_player:
		forward_speed = 0.0
	else:
		ai_speed_target = randf_range(MAX_SPEED * 0.60, MAX_SPEED * 0.85)
		ai_attack_timer = randf_range(1.5, 4.0)
		ai_lane_timer = randf_range(2.0, 6.0)
		ai_target_x = position.x
		forward_speed = ai_speed_target * 0.3


# ── Visuals ──────────────────────────────────────────────────────────────────

func _build_visuals() -> void:
	# Collision capsule
	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.5
	shape.height = 1.6
	col.shape = shape
	col.position = Vector3(0, 0.8, 0)
	add_child(col)

	# Bike mesh group
	bike_mesh = Node3D.new()
	bike_mesh.name = "BikeMesh"
	add_child(bike_mesh)

	var bike_mat := StandardMaterial3D.new()
	bike_mat.albedo_color = rider_color.darkened(0.4)

	# Frame
	var frame := CSGBox3D.new()
	frame.size = Vector3(0.5, 0.3, 2.0)
	frame.position = Vector3(0, 0.35, 0)
	frame.material = bike_mat
	bike_mesh.add_child(frame)

	# Front fork
	var fork := CSGBox3D.new()
	fork.size = Vector3(0.15, 0.6, 0.15)
	fork.position = Vector3(0, 0.5, 0.75)
	fork.rotation_degrees.x = -15
	fork.material = bike_mat
	bike_mesh.add_child(fork)

	# Wheels
	var wheel_mat := StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.12, 0.12, 0.12)
	for wz in [-0.7, 0.7]:
		var wheel := CSGTorus3D.new()
		wheel.inner_radius = 0.15
		wheel.outer_radius = 0.32
		wheel.ring_sides = 12
		wheel.sides = 16
		wheel.position = Vector3(0, 0.32, wz)
		wheel.material = wheel_mat
		bike_mesh.add_child(wheel)

	# Rider body group
	body_mesh = Node3D.new()
	body_mesh.name = "BodyMesh"
	add_child(body_mesh)

	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = rider_color

	# Torso
	var torso := CSGBox3D.new()
	torso.size = Vector3(0.4, 0.55, 0.3)
	torso.position = Vector3(0, 0.9, -0.1)
	torso.material = body_mat
	body_mesh.add_child(torso)

	# Head
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = rider_color.lightened(0.4)
	var head := CSGSphere3D.new()
	head.radius = 0.17
	head.radial_segments = 12
	head.rings = 8
	head.position = Vector3(0, 1.35, -0.1)
	head.material = head_mat
	body_mesh.add_child(head)

	# Arms (just two small boxes sticking out)
	for side in [-1.0, 1.0]:
		var arm := CSGBox3D.new()
		arm.size = Vector3(0.45, 0.12, 0.12)
		arm.position = Vector3(side * 0.35, 0.8, 0.1)
		arm.material = body_mat
		body_mesh.add_child(arm)


# ── Physics ──────────────────────────────────────────────────────────────────

func _physics_process(delta: float) -> void:
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)

	# Attack flash indicator
	if attack_flash_timer > 0.0:
		attack_flash_timer -= delta
		if attack_flash_timer <= 0.0:
			is_attacking = false
			_reset_body_color()

	# Nitro timer — full boost then gradual fade
	if has_nitro and not nitro_fading:
		nitro_timer -= delta
		if nitro_timer <= 0.0:
			nitro_fading = true
			nitro_fade_timer = NITRO_FADE_DURATION
	elif nitro_fading:
		nitro_fade_timer -= delta
		if nitro_fade_timer <= 0.0:
			has_nitro = false
			nitro_fading = false

	match state:
		State.RIDING:
			_process_riding(delta)
		State.FLYING:
			_process_flying(delta)
		State.ON_FOOT:
			_process_on_foot(delta)


# ── RIDING state ─────────────────────────────────────────────────────────────

func _process_riding(delta: float) -> void:
	if is_player:
		_player_input(delta)
	else:
		_ai_logic(delta)

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	# Forward (with nitro boost, fades out gradually)
	var effective_speed := forward_speed
	if has_nitro:
		if nitro_fading:
			# Lerp boost down to 0 over fade duration
			var fade_ratio: float = clampf(nitro_fade_timer / NITRO_FADE_DURATION, 0.0, 1.0)
			effective_speed += NITRO_SPEED_BOOST * fade_ratio
		else:
			effective_speed += NITRO_SPEED_BOOST
	velocity.z = effective_speed

	move_and_slide()
	position.x = clampf(position.x, ROAD_MIN_X, ROAD_MAX_X)


func _player_input(delta: float) -> void:
	# Throttle
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		forward_speed = minf(forward_speed + ACCELERATION * delta, MAX_SPEED)
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		forward_speed = maxf(forward_speed - BRAKE_FORCE * delta, 0.0)
	else:
		# Coast — slow drag
		forward_speed = maxf(forward_speed - ACCELERATION * 0.2 * delta, 0.0)

	# Steering — continuous, not lane-snapping
	# Camera faces +Z from behind, so screen-left is -X in world space
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		velocity.x = LANE_MOVE_SPEED
	elif Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		velocity.x = -LANE_MOVE_SPEED
	else:
		velocity.x = 0.0

	# Attack
	if Input.is_key_pressed(KEY_SPACE) and attack_cooldown <= 0.0:
		_do_attack()


func _ai_logic(delta: float) -> void:
	var hp_ratio := float(hp) / float(MAX_HP)
	var is_armed := weapon == Weapon.BAT

	# Speed — try to match target, slight variation
	forward_speed = lerpf(forward_speed, ai_speed_target, 1.0 * delta)

	# Smart lane behavior based on state
	ai_lane_timer -= delta
	if ai_lane_timer <= 0.0:
		var nearest := _ai_find_nearest_rider()
		if hp_ratio < 0.35 and nearest:
			# LOW HP: flee — move away from nearest rider
			var flee_x: float = position.x + signf(position.x - nearest.position.x) * 4.0
			ai_target_x = clampf(flee_x, ROAD_MIN_X + 1.0, ROAD_MAX_X - 1.0)
			ai_lane_timer = randf_range(0.8, 2.0)
			# Also speed up to escape
			forward_speed = minf(forward_speed + ACCELERATION * 0.5 * delta, MAX_SPEED)
		elif (is_armed or hp_ratio > 0.6) and nearest:
			# ARMED or HEALTHY: approach nearest rider to fight
			ai_target_x = nearest.position.x + randf_range(-1.0, 1.0)
			ai_lane_timer = randf_range(1.0, 3.0)
		else:
			# Default: random lane change
			ai_target_x = randf_range(ROAD_MIN_X + 1.0, ROAD_MAX_X - 1.0)
			ai_lane_timer = randf_range(2.0, 6.0)

	var x_diff := ai_target_x - position.x
	velocity.x = clampf(x_diff * 3.0, -LANE_MOVE_SPEED, LANE_MOVE_SPEED)

	# Attack behavior depends on state
	ai_attack_timer -= delta
	if ai_attack_timer <= 0.0:
		if hp_ratio < 0.35:
			# Low HP: rarely attack, focus on survival
			ai_attack_timer = randf_range(3.0, 6.0)
		elif is_armed:
			# Armed: attack aggressively
			_ai_try_attack()
			ai_attack_timer = randf_range(0.5, 1.5)
		else:
			_ai_try_attack()
			ai_attack_timer = randf_range(1.0, 3.0)

	# AI picks up nitro when available
	if has_nitro and hp_ratio > 0.5:
		# Use nitro strategically — already handled by the nitro timer
		pass


func _ai_find_nearest_rider() -> CharacterBody3D:
	var nearest: CharacterBody3D = null
	var nearest_dist: float = 999.0
	for other in get_tree().get_nodes_in_group("riders"):
		if other == self or other.state != State.RIDING:
			continue
		var dist := position.distance_to(other.position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = other
	return nearest


func _ai_try_attack() -> void:
	if attack_cooldown > 0.0:
		return
	for other in get_tree().get_nodes_in_group("riders"):
		if other == self or other.state != State.RIDING:
			continue
		var dz := absf(other.position.z - position.z)
		var dx := absf(other.position.x - position.x)
		if dz < ATTACK_RANGE_Z and dx < ATTACK_RANGE_X:
			_do_attack()
			return


# ── Combat ───────────────────────────────────────────────────────────────────

func _do_attack() -> void:
	if attack_cooldown > 0.0 or state != State.RIDING:
		return

	attack_cooldown = ATTACK_COOLDOWN
	var damage: int = FIST_DAMAGE
	var used_weapon: int = weapon

	if weapon == Weapon.BAT:
		damage = BAT_DAMAGE
		weapon_durability -= 1
		if weapon_durability <= 0:
			weapon = Weapon.FISTS

	# Find closest valid target
	var best: CharacterBody3D = null
	var best_dist: float = 999.0

	for other in get_tree().get_nodes_in_group("riders"):
		if other == self or other.state != State.RIDING:
			continue
		var dz := absf(other.position.z - position.z)
		var dx := absf(other.position.x - position.x)
		if dz < ATTACK_RANGE_Z and dx < ATTACK_RANGE_X:
			var d := dz + dx
			if d < best_dist:
				best_dist = d
				best = other

	if best:
		best.take_damage(damage, position, used_weapon)
		# Attack visual indicator — flash body red/orange
		_show_attack_indicator()
		# Punch animation — quick arm thrust
		_punch_anim()


func _punch_anim() -> void:
	var tween := create_tween()
	tween.tween_property(body_mesh, "position", Vector3(0, 0, 0.3), 0.08)
	tween.tween_property(body_mesh, "position", Vector3.ZERO, 0.12)


func _show_attack_indicator() -> void:
	is_attacking = true
	attack_flash_timer = 0.3
	# Flash body bright red/orange to show attack
	for child in body_mesh.get_children():
		if child is CSGShape3D and child.material:
			var mat: StandardMaterial3D = child.material
			mat.emission_enabled = true
			mat.emission = Color(1.0, 0.3, 0.0)
			mat.emission_energy_multiplier = 3.0


func _reset_body_color() -> void:
	for child in body_mesh.get_children():
		if child is CSGShape3D and child.material:
			var mat: StandardMaterial3D = child.material
			mat.emission_enabled = false


func take_damage(amount: int, from_pos: Vector3 = Vector3.ZERO, weapon_used: int = Weapon.FISTS) -> void:
	if state != State.RIDING:
		return
	hp -= amount
	_hit_feedback()
	if hp <= 0:
		_start_flying(from_pos, weapon_used)


func _hit_feedback() -> void:
	# Scale pulse
	var tween := create_tween()
	tween.tween_property(body_mesh, "scale", Vector3(1.4, 1.4, 1.4), 0.06)
	tween.tween_property(body_mesh, "scale", Vector3.ONE, 0.1)


# ── FLYING state ─────────────────────────────────────────────────────────────

func _start_flying(attacker_pos: Vector3, weapon_used: int = Weapon.FISTS) -> void:
	state = State.FLYING
	hp = 0
	fly_time = 0.0

	# Bike slides forward and stops
	bike_stop_position = position + Vector3(0, 0, forward_speed * 0.3)
	forward_speed = 0.0

	# Launch direction — away from attacker + upward
	var away := (position - attacker_pos).normalized()
	away.y = 0.0
	if away.length() < 0.1:
		away = Vector3(randf_range(-1, 1), 0, 1).normalized()

	# Knockout: short flight off the bike, then ground slide
	# Distance and height scale with the rider's speed at impact
	# Bat hits add extra force on top of speed-based values
	is_sliding = true
	var speed_ratio: float = clampf(forward_speed / MAX_SPEED, 0.2, 1.0)

	# Weapon type heavily determines flight arc and distance
	# Fists: low scrappy tumble, mostly sliding
	# Bat: dramatic high arc, flies far before sliding
	var launch_x: float
	var launch_y: float
	var launch_z: float
	match weapon_used:
		Weapon.BAT:
			# Bat: insane sky launch — sends them flying
			launch_x = away.x * randf_range(20, 35)
			launch_y = randf_range(55.0, 80.0)
			launch_z = forward_speed * 0.8 + randf_range(30, 50)
		_:
			# Fists: moderate arc, noticeable but not huge
			launch_x = away.x * randf_range(5, 9)
			launch_y = randf_range(10.0, 16.0) * speed_ratio
			launch_z = forward_speed * 0.4 + randf_range(5, 10)

	velocity = Vector3(launch_x, launch_y, launch_z)

	# Visuals: hide bike, show body flying
	bike_mesh.visible = false

	# Place a stopped bike marker on the road
	stopped_bike_marker = Node3D.new()
	var marker_box := CSGBox3D.new()
	marker_box.size = Vector3(0.5, 0.3, 1.8)
	marker_box.position = Vector3(0, 0.3, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = rider_color.darkened(0.6)
	marker_box.material = mat
	stopped_bike_marker.add_child(marker_box)
	stopped_bike_marker.position = bike_stop_position
	get_parent().add_child(stopped_bike_marker)

	# Arrow pointing to bike (visible from far away)
	var arrow := CSGCylinder3D.new()
	arrow.radius = 0.15
	arrow.height = 3.0
	arrow.position = Vector3(0, 2.5, 0)
	var arrow_mat := StandardMaterial3D.new()
	arrow_mat.albedo_color = rider_color.lightened(0.3)
	arrow_mat.emission_enabled = true
	arrow_mat.emission = rider_color
	arrow_mat.emission_energy_multiplier = 2.0
	arrow.material = arrow_mat
	stopped_bike_marker.add_child(arrow)

	knocked_out.emit(self)


func _process_flying(delta: float) -> void:
	fly_time += delta
	velocity.y -= GRAVITY * delta

	if is_sliding and is_on_floor() and fly_time > 0.15:
		# Ground sliding: apply friction to slow down gradually
		velocity.y = 0.0
		var speed := Vector2(velocity.x, velocity.z).length()
		if speed > 0.5:
			# Friction decelerates the slide
			var friction_force: float = SLIDE_FRICTION * delta
			var direction := Vector2(velocity.x, velocity.z).normalized()
			var new_speed: float = maxf(speed - friction_force * speed, 0.0)
			velocity.x = direction.x * new_speed
			velocity.z = direction.y * new_speed

			# Body tumbles along the ground while sliding
			body_mesh.rotation_degrees.x += 180.0 * delta
			body_mesh.rotation_degrees.z = sin(fly_time * 8.0) * 25.0
		else:
			# Slide finished — come to rest
			_land()
			return
	else:
		# Airborne phase (brief hop off bike before sliding)
		# Tumble the body
		body_mesh.rotation_degrees.x += 300.0 * delta
		body_mesh.rotation_degrees.z += 180.0 * delta

		# Transition to ground slide when landing
		if is_on_floor() and fly_time > 0.15:
			velocity.y = 0.0

	move_and_slide()
	position.x = clampf(position.x, ROAD_MIN_X - 3.0, ROAD_MAX_X + 3.0)


func _land() -> void:
	state = State.ON_FOOT
	velocity = Vector3.ZERO
	body_mesh.rotation_degrees = Vector3.ZERO
	# Shift body down to look like a standing person (no bike)
	body_mesh.position.y = -0.2


# ── ON_FOOT state ────────────────────────────────────────────────────────────

func _process_on_foot(delta: float) -> void:
	var to_bike := bike_stop_position - position
	to_bike.y = 0.0

	if to_bike.length() < 1.5:
		_remount()
		return

	velocity = to_bike.normalized() * WALK_SPEED
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	# Exaggerated wobble + bobbing animation for maximum comedy at slow speed
	fly_time += delta  # Reuse timer for wobble
	body_mesh.rotation_degrees.z = sin(fly_time * 6.0) * 18.0
	body_mesh.rotation_degrees.x = sin(fly_time * 12.0) * 5.0
	body_mesh.position.y = -0.2 + absf(sin(fly_time * 10.0)) * 0.12


func _remount() -> void:
	state = State.RIDING
	hp = MAX_HP
	forward_speed = 0.0
	is_sliding = false
	weapon = Weapon.FISTS
	weapon_durability = 0
	position = bike_stop_position
	bike_mesh.visible = true
	body_mesh.position.y = 0.0
	body_mesh.rotation_degrees = Vector3.ZERO

	if stopped_bike_marker:
		stopped_bike_marker.queue_free()
		stopped_bike_marker = null

	# AI: reset speed target for variety
	if not is_player:
		ai_speed_target = randf_range(MAX_SPEED * 0.60, MAX_SPEED * 0.85)


func pickup_weapon(weapon_type: int) -> void:
	weapon = weapon_type
	if weapon_type == Weapon.BAT:
		weapon_durability = BAT_DURABILITY


func pickup_nitro() -> void:
	has_nitro = true
	nitro_fading = false
	nitro_timer = NITRO_DURATION
