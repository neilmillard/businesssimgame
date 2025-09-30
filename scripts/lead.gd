class_name Lead
extends Resource

const RESOURCE_NAME : String = "Lead"

enum LeadStatus {
	FRESH,         # Just generated
	CONTACTED,     # Sales team has made contact
	QUALIFIED,     # Lead has been qualified as viable
	CONVERTED,     # Successfully converted to sale
	LOST           # Lead was lost/rejected
}

# Core lead attributes
@export var lead_id : String = ""
@export var buyer_id : String = ""
@export var buyer_name : String = ""
@export var status : LeadStatus = LeadStatus.FRESH

# Lead quality and conversion metrics
@export var lead_quality : float = 50.0  # Overall quality of the lead (0-100)
@export var conversion_likelihood : float = 30.0  # Probability of converting to sale (0-100)
@export var buyer_budget : float = 1000.0  # Available budget from the buyer
@export var urgency_level : float = 50.0  # How urgent the buyer's need is (0-100)

# Product interest
@export var interested_products : Array[String] = []  # Product names they're interested in
@export var product_preferences : Dictionary = {}  # Specific product attribute preferences

# Tracking and timing
@export var generation_time : String = ""
@export var contact_attempts : int = 0
@export var time_since_generation : float = 0.0
@export var last_contact_time : String = ""

# Sales process tracking
@export var assigned_salesperson : String = ""
@export var sales_notes : Array[String] = []

func _init():
	lead_id = "lead_" + str(randi() % 1000000)
	generation_time = Time.get_datetime_string_from_system()
	urgency_level = randf_range(20.0, 80.0)  # Random urgency

# Attempt to convert the lead to a sale
func attempt_conversion(sales_effectiveness: float = 50.0, product_match: float = 50.0) -> bool:
	if status != LeadStatus.QUALIFIED:
		print("Lead ", lead_id, " cannot be converted - not qualified")
		return false
	
	contact_attempts += 1
	
	# Calculate conversion probability based on multiple factors
	var base_chance = conversion_likelihood / 100.0
	var sales_modifier = (sales_effectiveness - 50.0) / 100.0  # -0.5 to +0.5
	var product_modifier = (product_match - 50.0) / 100.0  # -0.5 to +0.5
	var urgency_modifier = (urgency_level - 50.0) / 200.0  # -0.25 to +0.25
	
	# Quality affects conversion rate
	var quality_modifier = (lead_quality - 50.0) / 200.0  # -0.25 to +0.25
	
	var final_chance = base_chance + sales_modifier + product_modifier + urgency_modifier + quality_modifier
	final_chance = max(0.05, min(0.95, final_chance))  # Clamp between 5% and 95%
	
	var success = randf() < final_chance
	
	if success:
		status = LeadStatus.CONVERTED
		print("Lead ", lead_id, " successfully converted to sale! (", int(final_chance * 100), "% chance)")
		return true
	else:
		print("Lead conversion failed for ", lead_id, " (", int(final_chance * 100), "% chance, attempt ", contact_attempts, ")")
		
		# Too many failed attempts can lose the lead
		if contact_attempts >= 3 and randf() < 0.3:
			status = LeadStatus.LOST
			print("Lead ", lead_id, " was lost after ", contact_attempts, " failed attempts")
		
		return false

# Qualify the lead (move from CONTACTED to QUALIFIED)
func qualify_lead(qualification_criteria: Dictionary = {}) -> bool:
	if status != LeadStatus.CONTACTED:
		return false
	
	# Basic qualification: lead quality above threshold and sufficient budget
	var min_quality = qualification_criteria.get("min_quality", 40.0)
	var min_budget = qualification_criteria.get("min_budget", 500.0)
	
	if lead_quality >= min_quality and buyer_budget >= min_budget:
		status = LeadStatus.QUALIFIED
		print("Lead ", lead_id, " qualified successfully")
		return true
	else:
		print("Lead ", lead_id, " failed qualification (Quality: ", lead_quality, ", Budget: ", buyer_budget, ")")
		return false

# Make initial contact with the lead
func make_contact(salesperson: String = "") -> bool:
	if status != LeadStatus.FRESH:
		return false
	
	status = LeadStatus.CONTACTED
	assigned_salesperson = salesperson
	last_contact_time = Time.get_datetime_string_from_system()
	contact_attempts += 1
	
	print("Initial contact made with lead ", lead_id, " by ", salesperson if not salesperson.is_empty() else "sales team")
	return true

# Add a note to the lead
func add_sales_note(note: String):
	sales_notes.append(Time.get_datetime_string_from_system() + ": " + note)

# Get the current status as a string
func get_status_string() -> String:
	match status:
		LeadStatus.FRESH:
			return "Fresh"
		LeadStatus.CONTACTED:
			return "Contacted"
		LeadStatus.QUALIFIED:
			return "Qualified"
		LeadStatus.CONVERTED:
			return "Converted"
		LeadStatus.LOST:
			return "Lost"
		_:
			return "Unknown"

# Check if lead is still active (not converted or lost)
func is_active() -> bool:
	return status in [LeadStatus.FRESH, LeadStatus.CONTACTED, LeadStatus.QUALIFIED]

# Calculate potential sale value
func get_potential_sale_value() -> float:
	# Base sale value on buyer budget and lead quality
	var base_value = buyer_budget * 0.7  # Assume they'll spend 70% of budget
	var quality_multiplier = 0.5 + (lead_quality / 100.0)  # 0.5 to 1.5 multiplier
	return base_value * quality_multiplier

# Update time since generation
func update_age(delta_time: float):
	time_since_generation += delta_time
	
	# Leads can decay over time if not handled
	if status == LeadStatus.FRESH and time_since_generation > 300.0:  # 5 minutes in game time
		urgency_level = max(10.0, urgency_level - delta_time)
		conversion_likelihood = max(10.0, conversion_likelihood - delta_time * 0.1)