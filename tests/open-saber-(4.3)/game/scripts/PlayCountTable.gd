extends Node
class_name PlayCountTable

# location to store the play counts on filesystem
const PLAY_COUNT_FILEPATH = "user://play_count.json"

# internal copy of the play count table
# restored from user file in _ready()
# {
#   "<song_key>" : {# play counts for a given song
#       "1" : 0, # play count at diffucultyRank 1
#       "3" : 10 # play count at diffucultyRank 3
#   }
# }
var _pc_table: Dictionary = {}

func _ready() -> void:
	load_table()

# clears the whole play count table
func clear_table() -> void:
	_pc_table = {}
	
# removes a given map from the table, effectively resetting that map's counters
func remove_map(map_info: MapInfo) -> void:
	var song_key := map_info.get_key()
	@warning_ignore("return_value_discarded")
	_pc_table.erase(song_key)
	save_table()

# increments the maps play count by 1.
#
# map_info : data structure as read for map's info.dat file
# diff_rank : difficulty rank (1,3,etc.) that the score was set on
#
# return : None
func increment_play_count(map_info: MapInfo, diff_rank: int) -> void:
	var song_key := map_info.get_key()
	var key_dict := Utils.get_dict(_pc_table, song_key, {})
	if not _pc_table.has(song_key):
		_pc_table[song_key] = key_dict
	
	var diff_str := str(diff_rank)
	if not key_dict.has(diff_str):
		key_dict[diff_str] = 0
	
	key_dict[diff_str] += 1
	
	save_table()

# return : the map's play count for the given difficulty
func get_play_count(map_info: MapInfo, diff_rank: int) -> int:
	var song_key := map_info.get_key()
	var key_dict := Utils.get_dict(_pc_table, song_key, {})
	if key_dict.is_empty():
		return 0
	
	var diff_str := str(diff_rank)
	if not key_dict.has(diff_str):
		return 0
	
	return int(Utils.get_float(key_dict, diff_str, 0))

# return : the map's total play count accros all difficulties
func get_total_play_count(map_info: MapInfo) -> int:
	var song_key := map_info.get_key()
	var key_dict := Utils.get_dict(_pc_table, song_key, {})
	if key_dict.is_empty():
		return 0
	
	var total := 0
	for count in key_dict.values():
		total += count
	return total

# restores play count table from filesystem
func load_table() -> void:
	var file := FileAccess.open(PLAY_COUNT_FILEPATH,FileAccess.READ)
	if file:
		var text := file.get_as_text()
		file.close()
		var json_res := JSON.parse_string(text) as Dictionary
		if json_res:
			_pc_table = json_res
	else:
		print("WARN: Failed to open %s (might not exist yet)" % PLAY_COUNT_FILEPATH)

# saves play count table to filesystem
func save_table() -> void:
	var file := FileAccess.open(PLAY_COUNT_FILEPATH,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_pc_table,"   ",true))
		file.close()
	else:
		print("ERROR: Failed to open %s" % PLAY_COUNT_FILEPATH)
