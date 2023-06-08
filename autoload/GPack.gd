extends Node

var plugin = null
var gc = null


func _ready():
	if Engine.has_singleton("GPack"):
		plugin = Engine.get_singleton("GPack")
	elif Engine.has_singleton("GameCenter"):
		gc = Engine.get_singleton("GameCenter")
		gc.authenticate()
	print("GPack ready")


# ios game center
func has_game_center() -> bool:
	return gc and gc.is_authenticated()


func show_game_center():
	if has_game_center():
		gc.show_game_center(Dictionary())


func is_signed_in() -> bool:
	if plugin:
		return plugin.isSignedIn()
	return false
	
	
################
# ACHIEVEMENTS #
################

func unlock_ios_achievement(id: String) -> void:
	match id:
		C.achievement_fast_shot_5x:
			gc.award_achievement({ 
				"name":C.ios_achievement_fast_shot_5x,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_15_x_fast_shot:
			gc.award_achievement({ 
				"name":C.ios_achievement_15_x_fast_shot,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_last_second_pass:
			gc.award_achievement({ 
				"name":C.ios_achievement_last_second_pass,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_goal_on_first_second:
			gc.award_achievement({ 
				"name":C.ios_achievement_goal_on_first_second,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_50_second_rounds:
			gc.award_achievement({ 
				"name":C.ios_achievement_50_second_rounds,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_shot_to_center_50_plus:
			gc.award_achievement({ 
				"name":C.ios_achievement_shot_to_center_50_plus,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_shot_to_corner_100_plus:
			gc.award_achievement({ 
				"name":C.ios_achievement_shot_to_corner_100_plus,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_same_country:
			gc.award_achievement({ 
				"name":C.ios_achievement_same_country,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_60_second_rounds:
			gc.award_achievement({ 
				"name":C.ios_achievement_60_second_rounds,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_only_goals:
			gc.award_achievement({ 
				"name":C.ios_achievement_only_goals,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_70_second_rounds:
			gc.award_achievement({ 
				"name":C.ios_achievement_70_second_rounds,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_all_6_continents:
			gc.award_achievement({ 
				"name":C.ios_achievement_all_6_continents,
				"progress":100.0,
				"show_completion_banner":true
			})
		C.achievement_world_champion:
			gc.award_achievement({ 
				"name":C.ios_achievement_world_champion,
				"progress":100.0,
				"show_completion_banner":true
			})


func unlock_achievement(id: String) -> void:
	if plugin:
		plugin.unlockAchievement(id)
	elif gc:
		unlock_ios_achievement(id)


func increment_achievement(id: String, num_steps: int) -> void:
	if plugin:
		plugin.incrementAchievement(id, num_steps)


func show_achievements() -> void:
	if plugin:
		plugin.showAchievements()
	elif gc:
		gc.show_game_center({ "view":"achievements" })


################
# LEADERBOARD  #
################

func submit_ios_score(score: int, leaderboard: String) -> void:
	match leaderboard:
		C.leaderboard_goat:
			gc.post_score({
				"score":score,
				"category":C.ios_leaderboard_goat
			})


func submit_score(score: int, leaderboard: String) -> void:
	if plugin:
		plugin.submitScore(score, leaderboard)
	elif gc:
		submit_ios_score(score, leaderboard)
	

func show_leaderboard(id: String) -> void:
	if plugin:
		plugin.showLeaderboard(id)
	elif gc:
		gc.show_game_center({ "view":"leaderboards" })


################
#   FIREBASE   #
################

func log_event(event_name: String, dictionary: Dictionary) -> void:
	if plugin:
		plugin.logEvent(event_name, dictionary)


################
#    ADMOB     #
################

func load_rewarded_ad() -> void:
	if plugin:
		plugin.loadRewardedAd()


func is_rewarded_ad_loaded() -> bool:
	if plugin:
		return plugin.isRewardedAdLoaded()
	return false


func show_rewarded_ad() -> void:
	if plugin:
		print("ANDROID: show_rewarded_ad")
		plugin.showRewardedAd()


func load_interstitial_ad() -> void:
	if plugin:
		plugin.loadInterstitialAd()


func is_interstitial_ad_loaded() -> bool:
	if plugin:
		return plugin.isInterstitialAdLoaded()
	return false


func show_interstitial_ad() -> void:
	if plugin:
		var is_loaded = is_interstitial_ad_loaded()
		if is_loaded:
			plugin.showInterstitialAd()
		else:
			plugin.loadInterstitialAd()
	
	
################
#  SAVE GAME   #
################

func save_game(data: Dictionary, progress: int) -> void:
	if plugin:
		plugin.saveGame(data, progress)
	elif Engine.has_singleton("ICloud"):
		data["progress"] = progress
		var cloud = Engine.get_singleton("ICloud")
		var result = cloud.set_key_values(data)


func load_game() -> void:
	if plugin:
		plugin.loadGame()



# Signals you can connect to in the Android plugin.
# Prefixed by "s" so they would be recognized more easily from various scripts.
const s_rewarded_ad_loaded = "rewarded_ad_loaded"
const s_rewarded_ad_failed_to_load = "rewarded_ad_failed_to_load"
const s_reward_earned = "reward_earned"
const s_rewarded_ad_was_not_ready_to_show = "rewarded_ad_was_not_ready_to_show"
const s_on_rewarded_ad_showed = "on_rewarded_ad_showed"
const s_on_rewarded_ad_failed_to_show = "on_rewarded_ad_failed_to_show"
const s_on_rewarded_ad_dismissed = "on_rewarded_ad_dismissed"

const s_on_start_loading_saved_game = "on_start_loading_saved_game"
const s_on_loading_saved_game_complete = "on_loading_saved_game_complete"
const s_on_start_saving_game = "on_start_saving_game"
const s_on_saving_game_complete = "on_saving_game_complete"

const s_on_signed_in_status_changed = "on_signed_in_status_changed"

const s_on_start_showing_review = "on_start_showing_review"
const s_on_ending_review = "on_ending_review"
