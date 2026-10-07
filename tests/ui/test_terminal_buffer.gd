extends GdToolsTest
## Contract tests for TerminalBuffer: the 80x24 grid contract, bounded
## scrollback, and per-run file mirror.

const TerminalBuffer := preload("res://src/ui/terminal_buffer.gd")

const COLS := 80


func test_appends_lines_and_reads_them_back() -> void:
	var buffer := TerminalBuffer.new()
	buffer.append_line("BOOT: Facility Boreas link established")
	assert_eq(buffer.line_count(), 1, "one line stored")
	assert_eq(buffer.line_at(0), "BOOT: Facility Boreas link established", "round-trip")


func test_long_lines_wrap_at_eighty_columns() -> void:
	var buffer := TerminalBuffer.new()
	var long_line := "X".repeat(100)
	buffer.append_line(long_line)
	assert_eq(buffer.line_count(), 2, "100 chars wraps into two display lines")
	assert_eq(buffer.line_at(0).length(), COLS, "first wrapped row is exactly 80 chars")
	assert_eq(buffer.line_at(1), "X".repeat(20), "remainder on second row")


func test_word_boundaries_respected_when_wrapping() -> void:
	var buffer := TerminalBuffer.new()
	buffer.append_line("alpha beta gamma delta epsilon zeta eta theta iota kappa lambda mu")
	var first: String = buffer.line_at(0)
	assert_true(first.length() <= COLS, "no row exceeds 80 chars")
	assert_true(
		first.ends_with("lambda") or first.ends_with("mu") or first.ends_with("kappa"),
		"breaks at a word boundary, not mid-word"
	)


func test_explicit_newlines_in_appended_text_split() -> void:
	var buffer := TerminalBuffer.new()
	buffer.append_line("line one\nline two")
	assert_eq(buffer.line_count(), 2, "embedded newline splits into two lines")
	assert_eq(buffer.line_at(1), "line two", "second line intact")


func test_scrollback_is_bounded() -> void:
	var buffer := TerminalBuffer.new(5)
	for i in range(8):
		buffer.append_line("line %d" % i)
	assert_eq(buffer.line_count(), 5, "only the last 5 lines retained")
	assert_eq(buffer.line_at(0), "line 3", "oldest retained line is line 3")


func test_file_mirror_receives_every_line() -> void:
	var path := "user://test_mirror_%d.log" % Time.get_ticks_usec()
	var buffer := TerminalBuffer.new(200, path)
	buffer.append_line("mirrored line A")
	buffer.append_line("mirrored line B")
	var text := FileAccess.get_file_as_string(path)
	assert_true(text.contains("mirrored line A"), "first line mirrored")
	assert_true(text.contains("mirrored line B"), "second line mirrored")


func test_render_joins_lines_with_newlines() -> void:
	var buffer := TerminalBuffer.new()
	buffer.append_line("one")
	buffer.append_line("two")
	assert_eq(buffer.render(), "one\ntwo", "render joins with newlines")
