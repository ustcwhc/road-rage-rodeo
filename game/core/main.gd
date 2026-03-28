extends Node3D
## Phase 1 pipeline verification scene.
## Validates: renderer, physics interpolation, input actions, signal bus.
## NOTE: This is NOT the main_scene. test_track.tscn is the startup scene.
## This script can be run manually or referenced by GUT tests.

func _ready() -> void:
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
