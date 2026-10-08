extends GdToolsTest
## Red-phase contract tests for CommandExecutor (Phase C).
## Executes parsed commands against WorldState + data; returns structured
## records the UI renders verbatim.

const WorldState := preload("res://src/core/world_state.gd")
const CommandParser := preload("res://src/core/command_parser.gd")
const CommandExecutor := preload("res://src/core/command_executor.gd")

const LOG_FIXTURES := "res://tests/fixtures/logs/"

var _ws: WorldState
var _executor: CommandExecutor


func before_each() -> void:
	_ws = WorldState.new("boreas")
	_executor = CommandExecutor.new(_ws, LOG_FIXTURES)


func _run(raw: String) -> Dictionary:
	return _executor.execute(CommandParser.parse(raw))


func test_help_lists_all_verbs() -> void:
	var result := _run("help")
	assert_eq(result["kind"], "help", "help kind")
	var lines: Array = result["lines"]
	assert_true(lines.size() >= 3, "documents query, log, help at minimum")


func test_query_sector_returns_sector_record() -> void:
	var result := _run("query L4")
	assert_eq(result["kind"], "sector", "sector record kind")
	var record: Dictionary = result["record"]
	assert_true(record["doors"].has("L4-02"), "includes L4-02 door state")


func test_query_unit_returns_door_and_sensors() -> void:
	var result := _run("query L4-02")
	assert_eq(result["kind"], "unit", "unit record kind")
	var record: Dictionary = result["record"]
	assert_eq(record["unit_id"], "L4-02", "unit record carries its id")
	assert_eq(record["door"]["state"], "sealed", "door state included")
	assert_true(record.has("sensors"), "sensor readings included")


func test_log_rejects_path_escape() -> void:
	var up := _run("log ../sectors")
	assert_eq(up["kind"], "error", "traversal id rejected")
	var slash := _run("log sub/file")
	assert_eq(slash["kind"], "error", "nested path id rejected")


func test_query_personnel_returns_personnel_record() -> void:
	var result := _run("query arisova")
	assert_eq(result["kind"], "personnel", "personnel record kind")
	assert_eq(result["record"]["name"], "Dr. Elena Arisova", "correct person")


func test_query_unknown_target_is_error() -> void:
	var result := _run("query GHOST_SECTOR")
	assert_eq(result["kind"], "error", "error record kind")
	assert_true(result["message"].contains("GHOST_SECTOR"), "error names the target")


func test_query_without_target_is_usage_error() -> void:
	var result := _run("query")
	assert_eq(result["kind"], "error", "error record kind")
	assert_true(result["message"].contains("usage"), "usage hint included")


func test_log_missing_file_is_error() -> void:
	var result := _run("log no_such_file")
	assert_eq(result["kind"], "error", "error record kind")


func test_log_returns_parsed_entry() -> void:
	var result := _run("log test_entry")
	assert_eq(result["kind"], "log", "log record kind")
	assert_eq(result["record"]["title"], "Test Entry", "title from file")
	assert_eq(result["record"]["body"], "Line one.", "body from file")


func test_unknown_command_passes_through() -> void:
	var result := _run("quary")
	assert_eq(result["kind"], "unknown", "unknown passes through")
	assert_eq(result["suggestion"], "query", "suggestion preserved")


func test_executed_commands_advance_clock() -> void:
	var before: String = _ws.clock_text()
	_run("help")
	assert_ne(_ws.clock_text(), before, "clock advanced after a command")


func test_failed_command_does_not_advance_clock() -> void:
	var before: String = _ws.clock_text()
	_run("query")
	assert_eq(_ws.clock_text(), before, "usage errors cost no time")
