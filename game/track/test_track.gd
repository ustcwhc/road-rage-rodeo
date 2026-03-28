extends Node3D
## Minimal test track for pipeline verification and Phase 2 motorcycle testing.
## Road: 12m wide x 200m long straight with visible red barriers.
##
## This is the main_scene -- pipeline verification runs in _ready() to confirm
## the foundation is correctly configured when the game launches.

func _ready() -> void:
	print("[TestTrack] Loaded -- road 12x200m, barriers visible, spawn point at %s" % $SpawnPoint.global_position)

	# -- Pipeline verification (same checks as core/main.gd) --
	# Verify GameEvents autoload is accessible
	assert(GameEvents != null, "GameEvents autoload not found -- check project.godot [autoload] section")

	# Verify renderer is Compatibility
	var renderer: String = ProjectSettings.get_setting("rendering/renderer/rendering_method")
	assert(renderer == "gl_compatibility", "Renderer must be gl_compatibility, got: %s" % renderer)

	# Verify physics interpolation is enabled
	var interp: bool = ProjectSettings.get_setting("physics/common/physics_interpolation")
	assert(interp == true, "Physics interpolation must be enabled")

	# Verify input actions exist
	var required_actions := ["move_forward", "move_back", "steer_left", "steer_right", "attack", "nitro", "restart", "pause"]
	for action in required_actions:
		assert(InputMap.has_action(action), "Missing input action: %s" % action)

	# Test signal bus round-trip
	var signal_received := false
	GameEvents.race_started.connect(func(): signal_received = true)
	GameEvents.race_started.emit()
	assert(signal_received, "Signal bus round-trip failed")

	print("[Phase 1] All pipeline checks passed:")
	print("  - Renderer: %s" % renderer)
	print("  - Physics interpolation: %s" % interp)
	print("  - Input actions: %d configured" % required_actions.size())
	print("  - Signal bus: round-trip OK")
	print("  - GameEvents signals: %d scaffolded" % GameEvents.get_signal_list().size())
