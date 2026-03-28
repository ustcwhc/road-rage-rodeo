extends Node
## Global event bus for cross-system communication.
## Signals are scaffolded for all 14 systems even if unused in early phases.
## This provides a stable contract for downstream development (Phases 2-9).
## Naming convention: past-tense snake_case (per D-03).

# -- Rider Lifecycle --
signal rider_spawned(rider: CharacterBody3D)
signal rider_damaged(rider: CharacterBody3D, amount: int, source: Node)
signal rider_knocked_out(rider: CharacterBody3D, launch_force: float, weapon_type: StringName)
signal rider_crash_landed(rider: CharacterBody3D)
signal rider_stood_up(rider: CharacterBody3D)
signal rider_started_walking(rider: CharacterBody3D)
signal rider_remounted(rider: CharacterBody3D)

# -- Combat --
signal attack_started(attacker: CharacterBody3D)
signal attack_hit(attacker: CharacterBody3D, target: CharacterBody3D, damage: int)

# -- Weapons --
signal weapon_picked_up(rider: CharacterBody3D, weapon_name: StringName)
signal weapon_broken(rider: CharacterBody3D)
signal weapon_swung(rider: CharacterBody3D, weapon_name: StringName)

# -- Nitro --
signal nitro_picked_up(rider: CharacterBody3D)
signal nitro_activated(rider: CharacterBody3D)
signal nitro_expired(rider: CharacterBody3D)

# -- Race --
signal race_countdown_tick(seconds_left: int)
signal race_started()
signal race_finished(rankings: Array)
signal race_restarted()
signal rider_finished(rider: CharacterBody3D, position: int)
signal race_position_changed(rider: CharacterBody3D, new_position: int)

# -- Camera / Juice --
signal slow_mo_requested(duration: float, time_scale: float)
signal screen_shake_requested(intensity: float, duration: float)
signal hit_flash_requested()

# -- System --
signal level_loaded(level_index: int)
signal game_paused()
signal game_resumed()
