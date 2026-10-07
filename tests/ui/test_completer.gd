extends GdToolsTest
## Contract tests for Completer: Tab completion over verbs and known
## arguments (sectors, units, personnel, file ids).

const Completer := preload("res://src/ui/completer.gd")


func _completer() -> Completer:
	var completer := Completer.new()
	completer.set_vocabulary(
		["query", "log", "help"], ["L4", "L4-02", "arisova", "miller", "chen"], ["directives_07"]
	)
	return completer


func test_completes_verb_prefix() -> void:
	var completer := _completer()
	assert_eq(completer.complete_for("que"), "query ", "verb completed with trailing space")


func test_completes_target_prefix() -> void:
	var completer := _completer()
	assert_eq(completer.complete_for("query L4-"), "query L4-02 ", "unit id completed")


func test_ambiguous_prefix_returns_common_completion() -> void:
	var completer := _completer()
	var result := completer.complete_for("query L")
	assert_true(result.begins_with("query L"), "still anchored to input")
	assert_true(result in ["query L4 ", "query L4"], "common prefix of L4 and L4-02")


func test_no_match_returns_input_unchanged() -> void:
	var completer := _completer()
	assert_eq(completer.complete_for("log zzz"), "log zzz", "no candidate -> unchanged")


func test_case_insensitive_completion() -> void:
	var completer := _completer()
	assert_eq(completer.complete_for("QUE"), "query ", "uppercase prefix completes")


func test_file_id_completes_for_log_verb() -> void:
	var completer := _completer()
	assert_eq(completer.complete_for("log dir"), "log directives_07 ", "file id completed")
