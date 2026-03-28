extends GutTest
## Tests for GameEvents signal bus (FOUND-05).

func test_game_events_autoload_exists() -> void:
	# GameEvents must be accessible as autoload singleton
	assert_not_null(GameEvents, "GameEvents autoload not found")

func test_game_events_is_node() -> void:
	# GameEvents must extend Node
	assert_true(GameEvents is Node, "GameEvents must extend Node")

func test_signal_round_trip() -> void:
	# Emit a signal and verify it is received using GUT's signal watcher
	watch_signals(GameEvents)
	GameEvents.race_started.emit()
	assert_signal_emitted(GameEvents, "race_started", "race_started signal round-trip failed")

func test_rider_lifecycle_signals_exist() -> void:
	# Verify rider lifecycle signals are declared
	var signal_names = ["rider_spawned", "rider_damaged", "rider_knocked_out",
		"rider_crash_landed", "rider_stood_up", "rider_started_walking", "rider_remounted"]
	var signal_list = _get_signal_names(GameEvents)
	for sig in signal_names:
		assert_has(signal_list, sig, "Missing rider signal: %s" % sig)

func test_combat_signals_exist() -> void:
	var signal_list = _get_signal_names(GameEvents)
	assert_has(signal_list, "attack_started", "Missing signal: attack_started")
	assert_has(signal_list, "attack_hit", "Missing signal: attack_hit")

func test_weapon_signals_exist() -> void:
	var signal_list = _get_signal_names(GameEvents)
	for sig in ["weapon_picked_up", "weapon_broken", "weapon_swung"]:
		assert_has(signal_list, sig, "Missing weapon signal: %s" % sig)

func test_race_signals_exist() -> void:
	var signal_list = _get_signal_names(GameEvents)
	for sig in ["race_countdown_tick", "race_started", "race_finished", "race_restarted", "rider_finished", "race_position_changed"]:
		assert_has(signal_list, sig, "Missing race signal: %s" % sig)

func test_system_signals_exist() -> void:
	var signal_list = _get_signal_names(GameEvents)
	for sig in ["level_loaded", "game_paused", "game_resumed"]:
		assert_has(signal_list, sig, "Missing system signal: %s" % sig)

func test_minimum_signal_count() -> void:
	# D-04: Full scaffold should have at least 25 signals
	var signal_list = _get_signal_names(GameEvents)
	assert_gte(signal_list.size(), 25, "GameEvents should have at least 25 signals, has %d" % signal_list.size())

## Helper to extract signal names from an object
func _get_signal_names(obj: Object) -> Array:
	var names := []
	for sig in obj.get_signal_list():
		names.append(sig["name"])
	return names
