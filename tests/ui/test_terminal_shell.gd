extends GdToolsTest
## Smoke tests for the terminal shell (presentation layer).
## Exercises the shell's public surface in the live scene tree; keystroke
## capture itself is verified by manual playtest at the phase checkpoint.

const SHELL_SCENE := preload("res://src/ui/terminal_shell.tscn")

var _shell: Control


func before_each() -> void:
	_shell = SHELL_SCENE.instantiate()
	add_child(_shell)


func after_each() -> void:
	_shell.queue_free()


func test_shell_boots_with_header_and_welcome() -> void:
	var header: Label = _shell.get_node("%Header")
	assert_true(header.text.contains("SEED: boreas"), "header shows resolved seed")
	assert_true(header.text.contains("01:50"), "header shows starting clock")
	var output: RichTextLabel = _shell.get_node("%Output")
	assert_true(output.text.contains("BOREAS SURFACE LINK"), "welcome banner rendered")


func test_submitted_command_appears_and_executes() -> void:
	_shell.submit_line("query L4")
	var output: RichTextLabel = _shell.get_node("%Output")
	assert_true(output.text.contains("> query L4"), "echoed command line rendered")
	assert_true(output.text.contains("L4-02"), "sector query returned door state")


func test_unknown_command_shows_suggestion() -> void:
	_shell.submit_line("quary")
	var output: RichTextLabel = _shell.get_node("%Output")
	assert_true(output.text.contains("DID YOU MEAN: query?"), "fuzzy suggestion rendered")


func test_command_advances_header_clock() -> void:
	var header: Label = _shell.get_node("%Header")
	var before: String = header.text
	_shell.submit_line("help")
	assert_ne(header.text, before, "header clock advanced after command")
