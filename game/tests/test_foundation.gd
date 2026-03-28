extends GutTest
## Tests for Phase 1 foundation requirements: renderer, input, physics.

func test_renderer_is_compatibility() -> void:
	# FOUND-01: Compatibility renderer must be set
	var renderer = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	assert_eq(renderer, "gl_compatibility", "Renderer must be gl_compatibility for WebGL")

func test_physics_interpolation_enabled() -> void:
	# FOUND-06: Physics interpolation must be active
	var interp = ProjectSettings.get_setting("physics/common/physics_interpolation")
	assert_true(interp, "Physics interpolation must be enabled")

func test_physics_tick_rate() -> void:
	# FOUND-06: Physics tick rate should be 60 Hz
	var ticks = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
	assert_eq(ticks, 60, "Physics tick rate must be 60 Hz")

func test_input_actions_exist() -> void:
	# FOUND-04: All 8 input actions must be defined
	var actions = ["move_forward", "move_back", "steer_left", "steer_right", "attack", "nitro", "restart", "pause"]
	for action in actions:
		assert_true(InputMap.has_action(action), "Missing input action: %s" % action)

func test_input_actions_have_bindings() -> void:
	# FOUND-04: Each action must have at least one key binding
	var actions = ["move_forward", "move_back", "steer_left", "steer_right", "attack", "nitro", "restart", "pause"]
	for action in actions:
		var events = InputMap.action_get_events(action)
		assert_gt(events.size(), 0, "Action '%s' has no key bindings" % action)

func test_movement_actions_dual_mapped() -> void:
	# FOUND-04: Movement actions must have WASD + arrow keys (2 bindings each)
	var movement_actions = ["move_forward", "move_back", "steer_left", "steer_right"]
	for action in movement_actions:
		var events = InputMap.action_get_events(action)
		assert_gte(events.size(), 2, "Movement action '%s' must have at least 2 bindings (WASD + arrow)" % action)

func test_smaa_enabled() -> void:
	# SMAA anti-aliasing should be set (value 2)
	var aa = ProjectSettings.get_setting("rendering/anti_aliasing/quality/screen_space_aa")
	assert_eq(aa, 2, "Screen space AA should be 2 (SMAA)")
