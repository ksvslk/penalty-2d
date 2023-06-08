extends VBoxContainer

var payment = null

const BALL = "ball"
const INTERMEDIATE_ADS = "intermediate_ads"
const TWO_BALLS_NO_ADS = "two_balls_and_remove_ads"

var SKUS = [
	BALL,
	INTERMEDIATE_ADS,
	TWO_BALLS_NO_ADS
]

var max_retries = 5
var retry = 0
var consume_retry = 0
var seconds = [10, 20, 40, 80, 160]

onready var maximum_rew_reached = $WatchRewarded/MaximumRewReached
onready var watch_rewarded = $WatchRewarded
onready var maximum_reached_ads = $TwoBallsNoAds/MaximumReachedAds
onready var maximum_reached = $Ball/MaximumReached
onready var ball = $Ball
onready var intermediate_ads = $IntermediateAds
onready var two_balls_no_ads = $TwoBallsNoAds


signal disable_intermediate_ads
signal add_2_balls_disable_ads
signal add_ball


func _ready():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		# No params.
		payment.connect("connected", self, "_on_connected")
		# No params.
		payment.connect("disconnected", self, "_on_disconnected")
		# Response ID (int), Debug message (string).
		payment.connect("connect_error", self, "_on_connect_error")
		# Purchases (Dictionary[]).
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		# Response ID (int), Debug message (string).
		payment.connect("purchase_error", self, "_on_purchase_error")
		# SKUs (Dictionary[]).
		payment.connect("sku_details_query_completed", self, "_on_sku_details_query_completed")
		# Response ID (int), Debug message (string), Queried SKUs (string[]).
		payment.connect("sku_details_query_error", self, "_on_sku_details_query_error")
		# Purchase token (string).
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		# Purchase token (string).
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		# Response ID (int), Debug message (string), Purchase token (string).
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		# Purchases (Dictionary[])
		payment.connect("query_purchases_response", self, "_on_query_purchases_response")
		payment.startConnection()
	else:
		print("Android IAP support is not enabled. Make sure you have enabled 'Custom Build' and installed and enabled the GodotGooglePlayBilling plugin in your Android export settings! This application will not work.")
	if GPack.plugin:
		GPack.plugin.connect(GPack.s_rewarded_ad_loaded, self, "_set_rewarded_ad_button_state")
		GPack.plugin.connect(GPack.s_rewarded_ad_failed_to_load, self, "_rewarded_failed_to_load")


func _on_connect_error(response_code, debug_message):
	print(response_code, ": ", debug_message)
	if retry < max_retries:
		yield(get_tree().create_timer(seconds[retry]), "timeout")
		print("Retrying to connect..")
		retry += 1
		payment.startConnection()
	else:
		print("Retries reached maximum.")
		retry = 0


func _rewarded_failed_to_load(error):
	print("_rewarded_failed_to_load", error)
	watch_rewarded.disabled = true
	maximum_rew_reached.visible = false


func _set_rewarded_ad_button_state(max_balls_count: int = -1):
	print("_set_rewarded_ad_button_state. Should be rewarded loaded here.")
	if max_balls_count == -1:
		max_balls_count = Data.get_max_balls_to_add_count()
	if max_balls_count > 0:
		watch_rewarded.disabled = false
		maximum_rew_reached.visible = false
	elif max_balls_count <= 0:
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = true
		

func _set_rewarded_ad_button_state_on_load(max_balls_count: int = -1):
	if max_balls_count > 0 and GPack.is_rewarded_ad_loaded():
		watch_rewarded.disabled = false
		maximum_rew_reached.visible = false
	elif max_balls_count >= 0 and not GPack.is_rewarded_ad_loaded():
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = false
	elif max_balls_count <= 0:
		watch_rewarded.disabled = true
		maximum_rew_reached.visible = true


func _set_intermediate_button_state():
	if not Data.is_intermediate_ads_enabled():
		intermediate_ads.visible = false
		two_balls_no_ads.visible = false


func _set_two_balls_button_state(max_balls_count: int):
	if max_balls_count < 2:
		two_balls_no_ads.disabled = true
		maximum_reached_ads.visible = true
	else:
		two_balls_no_ads.disabled = false
		maximum_reached_ads.visible = false
		
	if not Data.is_intermediate_ads_enabled():
		two_balls_no_ads.visible = false
		intermediate_ads.visible = false


func _set_eternal_ball_button_state(max_balls_count: int):
	if max_balls_count < 1:
		ball.disabled = true
		maximum_reached.visible = true
	else:
		ball.disabled = false
		maximum_reached.visible = false


func _set(property, value):
	if property == "visible":
		var max_balls_count = Data.get_max_balls_to_add_count()
		if value == true:
			_set_eternal_ball_button_state(max_balls_count)
			_set_rewarded_ad_button_state_on_load(max_balls_count)
			_set_two_balls_button_state(max_balls_count)


func _on_connected():
	print("PurchaseManager connected")
	payment.queryPurchases("inapp") # Use "subs" for subscriptions.
	payment.querySkuDetails(SKUS, "inapp")


func _notification(what):
	if what == NOTIFICATION_APP_RESUMED:
		payment.queryPurchases("inapp")


func _on_query_purchases_response(query_result):
	print("_on_query_purchases_response", query_result)
	if query_result.status == OK:
		for purchase in query_result.purchases:
			# We must acknowledge all purchases.
			# See https://developer.android.com/google/play/billing/integrate#process for more information
			print("_handle_purchase", purchase)
			_handle_purchase(purchase)
	else:
		print("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message)

# "description":"One permanent ball you can use in all levels",
# "id":"ball",
# "one_time_purchase_details":{"formatted_price":"€1.99","price_amount_micros":1990000,"price_currency_code":"EUR"},
# "title":"Ball (com.indest.penalty2d (unreviewed))",
# "type":"inapp"

func _on_sku_details_query_completed(sku_details):
	print("_on_sku_details_query_completed", sku_details)
	for available_sku in sku_details:
		var price = available_sku["price"]
		if available_sku["sku"] == BALL:
			ball.text = available_sku["title"].get_slice("(", 0) + " - " + price
			ball.disabled = false
		elif available_sku["sku"] == INTERMEDIATE_ADS:
			intermediate_ads.text = available_sku["title"].get_slice("(", 0) + " - " + price
			intermediate_ads.disabled = false
		elif available_sku["sku"] == TWO_BALLS_NO_ADS:
			two_balls_no_ads.text = available_sku["title"].get_slice("(", 0) + " - " + price
			two_balls_no_ads.disabled = false


#{"is_acknowledged":false,
#"is_auto_renewing":false,
#"order_id":"GPA.3319-2871-9696-71923",
#"original_json":"{\"orderId\":\"GPA.3319-2871-9696-71923\",
#\"packageName\":\"com.indest.penalty2d\",
#\"productId\":\"ball\",
#\"purchaseTime\":1669751718344,
#\"purchaseState\":0,
#\"purchaseToken\":\"gafkpajggancdhjaifahkhgj.AO-J1OzNbuv8fDgsV2u98PvuAIwF8gOOZ45p0iyNvvd-wJ16xju0XG73KbWQsqv1ajl1qGi5jl3SSfiXH1nyimwjHQyn6nGKYQ\",
#\"quantity\":1,
#\"acknowledged\":false}",
#"package_name":"com.indest.penalty2d",
#"products":["ball"],
#"purchase_state":1,
#"purchase_time":1669751718344,
#"purchase_token":"REMOVED",
#"quantity":1,
#"signature":"REMOVED

func _handle_purchase(purchase):
	if purchase.purchase_state == 1:
		if !purchase.is_acknowledged:
			print("Purchase " + str(purchase.sku) + " giving content!")
			_give_content(purchase.sku, purchase.purchase_token)
			payment.acknowledgePurchase(purchase.purchase_token)
			print("Purchase " + str(purchase.sku) + " has not been acknowledged. Acknowledging...")
			if purchase.sku == BALL:
				_consume(purchase.purchase_token)
				print("Purchase " + str(purchase.sku) + " set to consumed.")
		elif purchase.is_acknowledged and purchase.sku == BALL:
			print("Purchase " + str(purchase.sku) + "is acknowledged so I give content and consume.")
			_consume(purchase.purchase_token)
			_give_content(purchase.sku, purchase.purchase_token)
		else:
			print("Purchase " + str(purchase.sku) + " was acknowledged already. Giving content if needed.")
			_give_content(purchase.sku, purchase.purchase_token)



func _give_content(sku, token):
	match sku:
		BALL:
			if not Data.has_purchase_token(token):
				Data.add_purchase_token(token)
				emit_signal("add_ball")
		INTERMEDIATE_ADS:
			if Data.is_intermediate_ads_enabled():
				intermediate_ads.visible = false
				two_balls_no_ads.visible = false
				emit_signal("disable_intermediate_ads")
		TWO_BALLS_NO_ADS:
			if not Data.is_two_balls_purchased():
				two_balls_no_ads.visible = false
				intermediate_ads.visible = false
				emit_signal("add_2_balls_disable_ads")


func _on_purchases_updated(purchases):
	print("Purchases updated (on resume and startup): %s" % to_json(purchases))
	# See _on_connected
	for purchase in purchases:
		_handle_purchase(purchase)


func _on_purchase_acknowledged(purchase_token):
	print("Purchase acknowledged: %s" % purchase_token)
	

func _on_purchase_consumed(purchase_token):
	print("Purchase consumed successfully: %s" % purchase_token)
	
	
func _on_purchase_error(code, message):
	print("Purchase error %d: %s" % [code, message])
	

func _on_purchase_acknowledgement_error(code, message, token):
	print("Purchase acknowledgement error %d: %s" % [code, message, token])
	
	
func _on_purchase_consumption_error(code, message, purchase_token):
	print("Purchase consumption error %d: %s, purchase token: %s" % [code, message, purchase_token])
	if consume_retry < max_retries:
		yield(get_tree().create_timer(seconds[retry]), "timeout")
		print("Trying again to consume...")
		consume_retry += 1
		_consume(purchase_token)
	else:
		print("Consume retries reached maximum.")
		consume_retry = 0


func _on_sku_details_query_error(code, message, list):
	print("SKU details query error %d: %s" % [code, message, list])
	

func _on_disconnected():
	print("GodotGooglePlayBilling disconnected. Will try to reconnect in 10s...")
	yield(get_tree().create_timer(10), "timeout")
	payment.startConnection()
	

func _purchase(sku):
	if payment:
		var response = payment.purchase(sku)
		if response.status != OK:
			print("Purchase error %s: %s" % [response.response_code, response.debug_message])


func _consume(sku_token):
	if payment:
		if sku_token == null:
			print("You need to set 'test_item_purchase_token' first! (either by hand or in code)")
			return
		payment.consumePurchase(sku_token)


# GUI
func _on_Ball_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(BALL)


func _on_IntermediateAds_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(INTERMEDIATE_ADS)


func _on_TwoBallsNoAds_pressed():
	get_parent()._on_BackButton_pressed()
	_purchase(TWO_BALLS_NO_ADS)


func _on_WatchRewarded_pressed():
	get_parent()._on_BackButton_pressed()
	if GPack.is_rewarded_ad_loaded():
		GPack.show_rewarded_ad()


