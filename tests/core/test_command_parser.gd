extends GdToolsTest
## Red-phase contract tests for CommandParser (Phase C).
## Pinned behaviors: verb dispatch, argument splitting, fuzzy
## suggest-the-closest, unknown rejection, case-insensitivity.

const CommandParser := preload("res://src/core/command_parser.gd")


func _parsed(raw: String) -> Dictionary:
	return CommandParser.parse(raw)


func test_parses_query_with_target() -> void:
	var cmd := _parsed("query L4-02")
	assert_eq(cmd["verb"], "query", "verb extracted")
	assert_eq(cmd["args"], ["L4-02"] as Array, "argument captured")


func test_parses_log_with_file_id() -> void:
	var cmd := _parsed("log boreas_directive_07")
	assert_eq(cmd["verb"], "log", "verb extracted")
	assert_eq(cmd["args"], ["boreas_directive_07"] as Array, "file id captured")


func test_parses_help_without_args() -> void:
	var cmd := _parsed("help")
	assert_eq(cmd["verb"], "help", "verb extracted")
	assert_eq(cmd["args"], [] as Array, "no arguments")


func test_parses_multiple_arguments() -> void:
	var cmd := _parsed("query L4-02 temp")
	assert_eq(cmd["verb"], "query", "verb extracted")
	assert_eq(cmd["args"], ["L4-02", "temp"] as Array, "both arguments captured")


func test_parse_is_case_insensitive() -> void:
	assert_eq(_parsed("QUERY L4-02")["verb"], "query", "uppercase verb accepted")
	assert_eq(_parsed("Query L4-02")["verb"], "query", "mixed-case verb accepted")


func test_collapses_extra_whitespace() -> void:
	var cmd := _parsed("  query    L4-02   ")
	assert_eq(cmd["verb"], "query", "verb extracted despite padding")
	assert_eq(cmd["args"], ["L4-02"] as Array, "no empty tokens")


func test_empty_input_is_empty_command() -> void:
	assert_eq(_parsed("")["kind"], "empty", "empty string -> empty command")
	assert_eq(_parsed("   ")["kind"], "empty", "whitespace-only -> empty command")


func test_close_typo_suggests_closest_verb() -> void:
	var cmd := _parsed("quary")
	assert_eq(cmd["kind"], "unknown", "typo is not a verb")
	assert_eq(cmd["suggestion"], "query", "suggests the closest verb")


func test_distant_unknown_has_no_suggestion() -> void:
	var cmd := _parsed("frobnicate")
	assert_eq(cmd["kind"], "unknown", "unknown verb rejected")
	assert_eq(cmd["suggestion"], "", "no suggestion for distant words")


func test_known_verb_has_no_suggestion_field_noise() -> void:
	var cmd := _parsed("help")
	assert_false(
		cmd.has("suggestion") and cmd["suggestion"] != "", "known verbs carry no suggestion"
	)
