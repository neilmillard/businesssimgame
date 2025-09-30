class_name Buyer
extends Resource

const RESOURCE_NAME : String = "Buyer"

enum BuyerState {
	OBLIVIOUS,
	EDUCATED, 
	INTERESTED
}

# Core buyer attributes
@export var buyer_id : String = ""
@export var buyer_name : String = ""
@export var current_state : BuyerState = BuyerState.OBLIVIOUS

# Buyer characteristics that influence marketing effectiveness
@export var demographics : String = ""  # Age group, income level, etc.
@export var interests : Array[String] = []  # Product categories they care about
@export var marketing_receptiveness : float = 50.0  # How responsive to marketing (0-100)
@export var purchase_likelihood : float = 30.0  # Base likelihood to buy when interested (0-100)
@export var budget : float = 1000.0  # Available spending money

# Tracking
@export var marketing_exposures : int = 0  # How many marketing messages they've seen
@export var time_in_current_state : float = 0.0  # Time spent in current state
@export var last_interaction_time : String = ""

func _init(name: String = "", id: String = ""):
	buyer_name = name if not name.is_empty() else "Buyer " + str(randi() % 10000)
	buyer_id = id if not id.is_empty() else "buyer_" + str(randi() % 100000)
	current_state = BuyerState.OBLIVIOUS
	marketing_receptiveness = randf_range(20.0, 80.0)  # Random receptiveness
	purchase_likelihood = randf_range(20.0, 60.0)  # Random purchase likelihood
	budget = randf_range(100.0, 5000.0)  # Random budget

# Transition from oblivious to educated through marketing
func expose_to_marketing(marketing_effectiveness: float = 50.0) -> bool:
	if current_state != BuyerState.OBLIVIOUS:
		return false
		
	marketing_exposures += 1
	
	# Calculate transition probability based on marketing effectiveness and buyer receptiveness
	var transition_chance = (marketing_effectiveness + marketing_receptiveness) / 200.0
	transition_chance = min(0.8, transition_chance)  # Cap at 80% chance
	
	if randf() < transition_chance:
		current_state = BuyerState.EDUCATED
		time_in_current_state = 0.0
		print("Buyer ", buyer_name, " became EDUCATED after ", marketing_exposures, " exposures")
		return true
	
	return false

# Transition from educated to interested through continued marketing
func build_interest(product_appeal: float = 50.0, marketing_quality: float = 50.0) -> bool:
	if current_state != BuyerState.EDUCATED:
		return false
		
	marketing_exposures += 1
	
	# Interest builds based on product appeal, marketing quality, and buyer characteristics
	var interest_chance = (product_appeal + marketing_quality + marketing_receptiveness) / 300.0
	interest_chance = min(0.6, interest_chance)  # Cap at 60% chance
	
	if randf() < interest_chance:
		current_state = BuyerState.INTERESTED
		time_in_current_state = 0.0
		print("Buyer ", buyer_name, " became INTERESTED")
		return true
	
	return false

# Generate a lead when buyer is interested
func generate_lead() -> Lead:
	if current_state != BuyerState.INTERESTED:
		return null
		
	var lead = Lead.new()
	lead.buyer_id = buyer_id
	lead.buyer_name = buyer_name
	lead.lead_quality = calculate_lead_quality()
	lead.buyer_budget = budget
	lead.conversion_likelihood = calculate_conversion_likelihood()
	
	print("Lead generated from buyer: ", buyer_name, " (Quality: ", lead.lead_quality, ")")
	return lead

# Calculate lead quality based on buyer characteristics
func calculate_lead_quality() -> float:
	var quality = (purchase_likelihood + marketing_receptiveness) / 2.0
	# Higher budget buyers generate better quality leads
	if budget > 2000.0:
		quality += 20.0
	elif budget > 1000.0:
		quality += 10.0
	
	return min(100.0, quality)

# Calculate likelihood of converting to sale
func calculate_conversion_likelihood() -> float:
	var likelihood = purchase_likelihood
	
	# More marketing exposures can increase likelihood (to a point)
	if marketing_exposures > 2:
		likelihood += min(20.0, marketing_exposures * 2.0)
	
	return min(90.0, likelihood)

# Get current state as string
func get_state_string() -> String:
	match current_state:
		BuyerState.OBLIVIOUS:
			return "Oblivious"
		BuyerState.EDUCATED:
			return "Educated"
		BuyerState.INTERESTED:
			return "Interested"
		_:
			return "Unknown"

# Check if buyer can be targeted by marketing
func can_be_marketed_to() -> bool:
	return current_state in [BuyerState.OBLIVIOUS, BuyerState.EDUCATED]

# Update time spent in current state
func update_state_time(delta_time: float):
	time_in_current_state += delta_time