extends GdToolsTest
## Contract tests for HistoryStore: command recall (Up/Down) and the
## ghost-text lookup used for inline diegetic suggestions.

const HistoryStore := preload("res://src/ui/history_store.gd")


func test_empty_history_has_no_entries() -> void:
	var history := HistoryStore.new()
	assert_eq(history.entry_count(), 0, "starts empty")


func test_push_adds_entries_in_order() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	history.push("help")
	assert_eq(history.entry_count(), 2, "two entries stored")


func test_consecutive_duplicates_are_collapsed() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	history.push("query L4")
	assert_eq(history.entry_count(), 1, "duplicate collapse")


func test_recall_walks_backwards_then_forwards() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	history.push("help")
	history.push("log directives")
	assert_eq(history.recall_up(), "log directives", "first Up = latest")
	assert_eq(history.recall_up(), "help", "second Up = previous")
	assert_eq(history.recall_up(), "query L4", "oldest stops the walk")
	assert_eq(history.recall_down(), "help", "Down returns toward present")
	assert_eq(history.recall_down(), "log directives", "Down returns to latest")
	assert_eq(history.recall_down(), "", "past latest returns to live input")


func test_reset_after_recall_returns_to_live_input() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	history.recall_up()
	history.reset_cursor()
	assert_eq(history.recall_down(), "", "cursor back at live input")


func test_new_push_while_recalling_lands_at_end() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	history.recall_up()
	history.push("help")
	assert_eq(history.recall_up(), "help", "latest entry is the new push")


func test_ghost_text_suggests_latest_matching_entry() -> void:
	var history := HistoryStore.new()
	history.push("query L4-02")
	history.push("query L4")
	assert_eq(history.ghost_for("query "), "L4", "most recent match wins")
	assert_eq(history.ghost_for("query L4-0"), "2", "suffix of the match")
	assert_eq(history.ghost_for("log "), "", "no match -> no ghost")


func test_ghost_requires_prefix_match() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	assert_eq(history.ghost_for("query"), " L4", "prefix includes the space")
	assert_eq(history.ghost_for("log "), "", "input matching no entry shows nothing")


func test_empty_input_has_no_ghost() -> void:
	var history := HistoryStore.new()
	history.push("query L4")
	assert_eq(history.ghost_for(""), "", "empty input shows nothing")
