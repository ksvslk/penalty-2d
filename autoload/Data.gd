extends Node

onready var _config := ConfigFile.new()

const _path: String = "user://data.cfg"
const _total_levels_plus_one := 212 # each level has its own section: "1", "2" etc.
const _initial_best_score := 0
var current_level := "-1"


signal best_score_updated(new_score)
signal level_info_updated(dict)
signal level_select_updated(levels)
signal team_changed(new_team)

########################
#	 DATABASE PART	  #
########################	

func _ready():
	var err := _config.load(_path)
	if err == ERR_FILE_NOT_FOUND:
		 # This should be done ONLY ONCE when also cloud has no info!!!
		_set_initial_launch_settings()
	elif err != 0:
		printerr("Could not load local data. ", err)
	var current = _config.get_value(C.VARIOUS_SECTION, C.CURRENT_LEVEL)
	load_level(int(current))

######################################
#	REPOSITORY/VIEWMODEL PART	    #
######################################

func load_level(nr: int) -> void:
	print("Load level: ", nr)
	current_level = str(nr)
	_config.set_value(C.VARIOUS_SECTION, C.CURRENT_LEVEL, current_level)
	_config.save(_path)
	set_level_info(nr)


func next_level() -> void:
	var next = int(current_level) + 1
	current_level = str(next)
	_config.set_value(C.VARIOUS_SECTION, C.CURRENT_LEVEL, current_level)
	_config.save(_path)
	set_level_info()


func get_levels() -> Dictionary:
	var info = Dictionary()
	for i in range(1, _total_levels_plus_one):
		info[_config.get_value(str(i), C.FLAG)] = [
			_config.get_value(str(i), C.COUNTRY),
			_config.get_value(str(i), C.UNLOCKED)
		]
	return info
	

func unlock_next_level() -> String:
	var next = str(int(current_level) + 1)
	if _config.get_value(next, C.UNLOCKED) as bool:
		return String()
	else:
		_config.set_value(next, C.UNLOCKED, 1)
		_config.save(_path)
		var next_country = _config.get_value(next, C.COUNTRY)
		emit_signal("level_select_updated", get_levels())
		return next_country


func is_level_unlocked(nr: int) -> bool:
	return _config.get_value(str(nr), C.UNLOCKED) as bool


func set_level_info(level_nr: int = int(current_level)) -> void:
	var info = Dictionary()
	info[C.FLAG]= _config.get_value(str(level_nr), C.FLAG)
	info[C.COUNTRY]= _config.get_value(str(level_nr), C.COUNTRY)
	info[C.TIME_LIMIT]= _config.get_value(str(level_nr), C.TIME_LIMIT)
	info[C.DIFFICULTY]= _config.get_value(str(level_nr), C.DIFFICULTY)
	info[C.PASS_SCORE]= _config.get_value(str(level_nr), C.PASS_SCORE)
	info[C.BEST_SCORE]= _config.get_value(str(level_nr), C.BEST_SCORE)
	info[C.REWARDED_BALLS] = _config.get_value(str(level_nr), C.REWARDED_BALLS)
	info[C.ETERNAL_BALLS] = _config.get_value(C.VARIOUS_SECTION, C.ETERNAL_BALLS)
	emit_signal("level_info_updated", info)
	
	
func send_score_to_ui():
	var best_score = _config.get_value(current_level, C.BEST_SCORE)
	emit_signal("best_score_updated", str(best_score))


func update_score(score):
	_set_best_results(score)
	set_total_score()
	_config.save(_path)
	Data.save_game()


func get_total_score() -> int:
	return _config.get_value(C.VARIOUS_SECTION, C.TOTAL_SCORE)


func set_total_score():
	var total_score := 0
	for i in range(1, _total_levels_plus_one):
		total_score += _config.get_value(str(i), C.BEST_SCORE)
	_config.set_value(C.VARIOUS_SECTION, C.TOTAL_SCORE, total_score)
	_config.save(_path)
	GPack.submit_score(total_score, C.leaderboard_goat)


func is_first_time() -> bool:
	return _config.get_value(C.VARIOUS_SECTION, C.FIRST_TIME)
	

func _set_best_results(new_score):
	var best_score = _config.get_value(current_level, C.BEST_SCORE)
	if new_score > best_score:
		emit_signal("best_score_updated", str(new_score))
		_config.set_value(current_level, C.BEST_SCORE, new_score)


func get_player_team() -> String:
	return _config.get_value(C.VARIOUS_SECTION, C.PLAYER_TEAM)


func set_intermediate_ads(b: bool) -> void:
	_config.set_value(C.VARIOUS_SECTION, C.INTERMEDIATE_ADS, b as int)
	_config.save(_path)


func is_intermediate_ads_enabled() -> bool:
	return _config.get_value(C.VARIOUS_SECTION, C.INTERMEDIATE_ADS)


func set_two_balls_purchased(b: bool) -> void:
	_config.set_value(C.VARIOUS_SECTION, C.TWO_BALLS_PURCHASED, b as int)
	_config.save(_path)

func is_two_balls_purchased() -> bool:
	return _config.get_value(C.VARIOUS_SECTION, C.TWO_BALLS_PURCHASED)


func change_player_team(team: String):
	_config.set_value(C.VARIOUS_SECTION, C.PLAYER_TEAM, team)
	_config.set_value(C.VARIOUS_SECTION, C.FIRST_TIME, 0)
	_config.save(_path)
	emit_signal("team_changed", team)


func get_max_balls_to_add_count() -> int:
	var rewarded = _config.get_value(current_level, C.REWARDED_BALLS)
	var eternal = _config.get_value(C.VARIOUS_SECTION, C.ETERNAL_BALLS)
	return C.MAX_BALLS_ALLOWED - (rewarded + eternal + C.default_balls_count)


func get_max_level() -> int:
	var level = -1
	for level_nr in range(1, _total_levels_plus_one):
		var is_unlocked = _config.get_value(str(level_nr), C.UNLOCKED)
		if is_unlocked:
			level = level_nr
	return level
		

func add_rewarded_ball():
	var current_balls = _config.get_value(current_level, C.REWARDED_BALLS)
	_config.set_value(current_level, C.REWARDED_BALLS, current_balls + 1)
	_config.save(_path)


func add_eternal_ball(count: int = 1):
	var current_balls = _config.get_value(C.VARIOUS_SECTION, C.ETERNAL_BALLS)
	_config.set_value(C.VARIOUS_SECTION, C.ETERNAL_BALLS, current_balls + count)
	_config.save(_path)
	

func _set_initial_launch_settings():
	_config.set_value(C.VARIOUS_SECTION, C.CURRENT_LEVEL, "1")
	_config.set_value(C.VARIOUS_SECTION, C.TOTAL_SCORE, 0)
	_config.set_value(C.VARIOUS_SECTION, C.PLAYER_TEAM, "gb-eng")
	_config.set_value(C.VARIOUS_SECTION, C.FIRST_TIME, 1)
	_config.set_value(C.VARIOUS_SECTION, C.ETERNAL_BALLS, 0)
	_config.set_value(C.VARIOUS_SECTION, C.INTERMEDIATE_ADS, 1)
	_config.set_value(C.VARIOUS_SECTION, C.TWO_BALLS_PURCHASED, 0)
	
	var file = File.new()
	file.open("res://assets/level_flag_mapping.json", File.READ)
	var data = JSON.parse(file.get_as_text())
	if typeof(data.result) != TYPE_DICTIONARY:
		push_error("Unexpected results.")
	
	var difficulty = 1
	var current_pass_score := 10
	var pass_score_to_50 = 10
	var pass_score_50_to_100 = 30
	var pass_score_100_to_150 = 50
	var pass_score_150_and_up = 70
	var time_limit = 40
	var count = 3
	var count_temp = 3
	
	
	for i in range(1, _total_levels_plus_one):
		if i == 50:
			count = 2
			count_temp = 2
		elif i == 100:
			count = 3
			count_temp = 3
		elif i == 150:
			count = 4
			count_temp = 4
		elif i == 200:
			count = 5
			count_temp = 5 
			
		count -= 1
		if count == 0:
			current_pass_score += 1
			count = count_temp

		if i >= 50 and i < 100:
			time_limit = 50
		elif i >= 100 and i < 150:
			time_limit = 60
		elif i >= 150:
			time_limit = 70
			
		_config.set_value(String(i), C.FLAG, data.result[str(i)]["flag"])
		_config.set_value(String(i), C.COUNTRY, data.result[str(i)]["country"])
		_config.set_value(String(i), C.TIME_LIMIT, time_limit)
		_config.set_value(String(i), C.DIFFICULTY, difficulty)
		_config.set_value(String(i), C.PASS_SCORE, current_pass_score)
		_config.set_value(String(i), C.PLAYER_SCORE, 0)
		_config.set_value(String(i), C.BEST_SCORE, 0)
		if i == 1:
			_config.set_value(String(i), C.UNLOCKED, 1)
		else:
			_config.set_value(String(i), C.UNLOCKED, 0)
		_config.set_value(String(i), C.REWARDED_BALLS, 0)
		difficulty += 0.1
	_config.save(_path)
	file.close()


func save_game() -> void:
	if OS.get_name() == "Android":
		var game_data = Dictionary()
		for key in C.various_section_dictionary_keys:
			game_data[key] = str(_config.get_value(C.VARIOUS_SECTION, key))
		for level_nr in range(1, _total_levels_plus_one):
			var level = str(level_nr)
			var level_info = []
			for level_info_key in _config.get_section_keys(level):
				if level_info_key == C.FLAG or level_info_key == C.COUNTRY:
					level_info.push_back(str(_config.get_value(level, level_info_key)))
				else:
					level_info.push_back(_config.get_value(level, level_info_key))
			game_data[level] = str(level_info)
		var max_level = get_max_level()
		GPack.save_game(game_data, max_level)


func load_game(game_data: Dictionary) -> void:
	for key in C.various_section_dictionary_keys:
		if key == C.CURRENT_LEVEL:
			_config.set_value(C.VARIOUS_SECTION, key, game_data[key] as String)
		elif key == C.PLAYER_TEAM:
			var current_team = _config.get_value(C.VARIOUS_SECTION, C.PLAYER_TEAM)
			if current_team != game_data[key]:
				_config.set_value(C.VARIOUS_SECTION, key, current_team)
		else:
			_config.set_value(C.VARIOUS_SECTION, key, game_data[key] as int)
		
	for level_nr in range(1, _total_levels_plus_one):
		var level = str(level_nr)
		var level_info = game_data[level] as String
		level_info = level_info.substr(1, level_info.length() - 2)
		var sliced = level_info.split(",", false)
		for index in range(0, sliced.size()):
			var key = C.level_section_dictionary_keys[index]
			if key == C.DIFFICULTY:
				_config.set_value(level, key, sliced[index].strip_edges() as float)
			elif key == C.FLAG or key == C.COUNTRY:
				_config.set_value(level, key, sliced[index].strip_edges() as String)
			else:
				_config.set_value(level, key, sliced[index].strip_edges() as int)
	_config.save(_path)
	emit_signal("level_select_updated", get_levels())
	var current = _config.get_value(C.VARIOUS_SECTION, C.CURRENT_LEVEL)
	load_level(int(current))

