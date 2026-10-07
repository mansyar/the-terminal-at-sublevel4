extends GdToolsTest
## Red-phase contract tests for WorldState (Phase B).
## Pinned behaviors: seed determinism, clock-from-01:50, baseline variables,
## no unseeded randomness.

const WorldState := preload("res://src/core/world_state.gd")


func test_clock_starts_at_0150() -> void:
	var ws := WorldState.new("test-seed")
	assert_eq(ws.clock_text(), "01:50", "clock starts at 01:50 AM")


func test_clock_advances_and_wraps_hours() -> void:
	var ws := WorldState.new("test-seed")
	ws.advance_minutes(24)
	assert_eq(ws.clock_text(), "02:14", "01:50 + 24 min = 02:14 (alarm time)")
	ws.advance_minutes(36)
	assert_eq(ws.clock_text(), "02:50", "advances past 02:14")


func test_minutes_elapsed_counts_from_start() -> void:
	var ws := WorldState.new("test-seed")
	assert_eq(ws.minutes_elapsed(), 0, "no minutes elapsed at 01:50")
	ws.advance_minutes(24)
	assert_eq(ws.minutes_elapsed(), 24, "elapsed tracks advance")


func test_clock_does_not_accept_negative_advance() -> void:
	var ws := WorldState.new("test-seed")
	ws.advance_minutes(-5)
	assert_eq(ws.clock_text(), "01:50", "negative advance is rejected, clock unchanged")


func test_same_seed_produces_identical_state() -> void:
	var a := WorldState.new("boreas")
	var b := WorldState.new("boreas")
	assert_eq(a.dump(), b.dump(), "same seed -> identical initial state dump")


func test_different_seed_varies_state() -> void:
	var a := WorldState.new("boreas")
	var b := WorldState.new("permafrost")
	assert_ne(a.dump(), b.dump(), "different seeds -> varied initial state")


func test_baseline_variables_present() -> void:
	var ws := WorldState.new("test-seed")
	var d: Dictionary = ws.snapshot()
	assert_true(d.has("power_units"), "power allocation tracked")
	assert_true(d.has("sectors"), "sector map present")
	assert_true(d.has("personnel"), "personnel roster present")
	assert_true(d["sectors"].has("L4"), "L4 corridor sector exists")
	var l4: Dictionary = d["sectors"]["L4"]
	assert_true(l4["doors"].has("L4-02"), "door L4-02 exists")
	assert_true(l4["sensors"].has("L4-02"), "sensor group L4-02 exists")
	assert_eq(d["personnel"].size(), 3, "three personnel on roster")


func test_personnel_baseline_fields() -> void:
	var ws := WorldState.new("test-seed")
	var roster: Dictionary = ws.snapshot()["personnel"]
	for id in ["arisova", "miller", "chen"]:
		assert_true(roster.has(id), "personnel %s on roster" % id)
		var p: Dictionary = roster[id]
		assert_true(p.has("location"), "%s has location" % id)
		assert_true(p.has("heart_rate_bpm"), "%s has heart rate" % id)
		assert_true(p.has("status"), "%s has status" % id)


func test_identical_command_sequences_stay_in_sync() -> void:
	var a := WorldState.new("boreas")
	var b := WorldState.new("boreas")
	for i in range(6):
		a.advance_minutes(3 + i)
		b.advance_minutes(3 + i)
	assert_eq(a.dump(), b.dump(), "same seed + same ops -> identical state")
