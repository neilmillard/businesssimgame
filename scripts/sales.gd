class_name Sales
extends Resource

const RESOURCE_NAME : String = "Sales"

# Sales performance tracking
@export var total_sales : int = 0
@export var total_revenue : float = 0.0
@export var leads_contacted : int = 0
@export var leads_qualified : int = 0
@export var leads_converted : int = 0
@export var leads_lost : int = 0

# Sales team attributes
@export var team_effectiveness : float = 50.0  # Overall sales team skill (0-100)
@export var qualification_standards : Dictionary = {
	"min_quality": 40.0,
	"min_budget": 500.0
}
@export var conversion_rate : float = 25.0  # Historical conversion rate percentage

# Active sales processes
@export var active_leads : Array[Lead] = []
@export var qualified_leads : Array[Lead] = []
@export var sales_history : Array[Dictionary] = []

# Sales cycle timing
@export var average_cycle_time : float = 120.0  # Average time to close a deal
@export var follow_up_frequency : float = 30.0  # How often to follow up with leads

func _init():
	team_effectiveness = randf_range(30.0, 70.0)
	conversion_rate = randf_range(15.0, 35.0)

# Process new leads from marketing
func receive_leads(new_leads: Array[Lead]) -> void:
	for lead in new_leads:
		if lead != null and lead.is_active():
			active_leads.append(lead)
			print("Received new lead: ", lead.buyer_name, " (Quality: ", lead.lead_quality, ")")

# Contact fresh leads
func contact_leads() -> int:
	var contacted_count = 0
	
	for lead in active_leads:
		if lead.status == Lead.LeadStatus.FRESH:
			if lead.make_contact("Sales Team"):
				leads_contacted += 1
				contacted_count += 1
	
	print("Contacted ", contacted_count, " fresh leads")
	return contacted_count

# Qualify contacted leads
func qualify_leads() -> int:
	var qualified_count = 0
	
	for lead in active_leads:
		if lead.status == Lead.LeadStatus.CONTACTED:
			if lead.qualify_lead(qualification_standards):
				qualified_leads.append(lead)
				leads_qualified += 1
				qualified_count += 1
	
	# Remove qualified leads from active leads to avoid double processing
	for lead in qualified_leads:
		if lead in active_leads:
			active_leads.erase(lead)
	
	print("Qualified ", qualified_count, " leads")
	return qualified_count

# Attempt to convert qualified leads to sales
func convert_leads(products: Array[Product] = []) -> Dictionary:
	var converted_count = 0
	var leads_to_remove: Array[Lead] = []
	var new_sales: Array[Dictionary] = []
	
	for lead in qualified_leads:
		if lead.status == Lead.LeadStatus.QUALIFIED:
			# Calculate product match score
			var product_match_score = calculate_product_match(lead, products)
			
			if lead.attempt_conversion(team_effectiveness, product_match_score):
				# Successful conversion
				var sale_value = lead.get_potential_sale_value()
				var best_product_name = get_best_matching_product_name(lead, products)
				var sale_record = record_sale(lead, sale_value, best_product_name)
				new_sales.append(sale_record)
				converted_count += 1
				leads_converted += 1
				leads_to_remove.append(lead)
			elif lead.status == Lead.LeadStatus.LOST:
				# Lead was lost during conversion attempt
				leads_lost += 1
				leads_to_remove.append(lead)
	
	# Clean up converted or lost leads
	for lead in leads_to_remove:
		qualified_leads.erase(lead)
	
	print("Converted ", converted_count, " leads to sales")
	return {
		"converted_count": converted_count,
		"new_sales": new_sales
	}

# Get the name of the best matching product for a lead
func get_best_matching_product_name(lead: Lead, products: Array[Product]) -> String:
	if products.is_empty():
		return "Generic Product"
	
	var best_product = products[0]
	var best_score = 0.0
	
	for product in products:
		var score = (product.attractiveness + product.utility) / 2.0
		if product.retail_price > 0 and product.retail_price <= lead.buyer_budget:
			score += 20.0
		
		if score > best_score:
			best_score = score
			best_product = product
	
	return best_product.product_name

# Calculate how well available products match the lead's interests
func calculate_product_match(lead: Lead, products: Array[Product]) -> float:
	if products.is_empty():
		return 30.0  # Low match if no products available
	
	var best_match = 0.0
	
	for product in products:
		# Base match on product attractiveness and utility
		var match_score = (product.attractiveness + product.utility) / 2.0
		
		# Adjust for price vs budget compatibility
		if product.retail_price > 0 and product.retail_price <= lead.buyer_budget:
			match_score += 20.0  # Bonus for affordable products
		elif product.retail_price > lead.buyer_budget:
			match_score -= 30.0  # Penalty for unaffordable products
		
		# Factor in quality
		match_score += product.quality * 0.3
		
		best_match = max(best_match, match_score)
	
	return min(100.0, max(0.0, best_match))

# Record a successful sale
func record_sale(lead: Lead, sale_value: float, product_name: String = "") -> Dictionary:
	total_sales += 1
	total_revenue += sale_value
	
	var sale_record = {
		"sale_id": "sale_" + str(randi() % 1000000),
		"lead_id": lead.lead_id,
		"buyer_name": lead.buyer_name,
		"product_name": product_name,
		"sale_value": sale_value,
		"sale_date": Time.get_datetime_string_from_system(),
		"lead_quality": lead.lead_quality
	}
	
	sales_history.append(sale_record)
	print("Sale recorded: $", sale_value, " from ", lead.buyer_name)
	
	return sale_record

# Run complete sales process cycle
func run_sales_cycle(products: Array[Product] = []) -> Dictionary:
	var conversion_results = convert_leads(products)
	
	var results = {
		"contacted": contact_leads(),
		"qualified": qualify_leads(),
		"converted": conversion_results.converted_count,
		"new_sales": conversion_results.new_sales
	}
	
	# Update conversion rate based on recent performance
	if leads_contacted > 0:
		conversion_rate = (float(leads_converted) / float(leads_contacted)) * 100.0
	
	return results

# Improve sales team effectiveness through training
func invest_in_training(investment: float = 1000.0) -> bool:
	var improvement = investment / 1000.0 * 5.0  # 5 points per $1000
	team_effectiveness = min(95.0, team_effectiveness + improvement)
	
	print("Sales team training completed. Effectiveness now: ", team_effectiveness)
	return true

# Adjust qualification standards
func update_qualification_standards(min_quality: float = -1.0, min_budget: float = -1.0) -> void:
	if min_quality >= 0:
		qualification_standards["min_quality"] = min_quality
	if min_budget >= 0:
		qualification_standards["min_budget"] = min_budget
	
	print("Qualification standards updated - Min Quality: ", qualification_standards["min_quality"], 
		  ", Min Budget: $", qualification_standards["min_budget"])

# Get sales performance summary
func get_performance_summary() -> Dictionary:
	var active_lead_count = active_leads.size() + qualified_leads.size()
	var average_sale_value = total_revenue / max(1, total_sales)
	
	return {
		"total_sales": total_sales,
		"total_revenue": total_revenue,
		"average_sale_value": average_sale_value,
		"active_leads": active_lead_count,
		"qualified_leads": qualified_leads.size(),
		"conversion_rate": conversion_rate,
		"team_effectiveness": team_effectiveness,
		"leads_contacted": leads_contacted,
		"leads_qualified": leads_qualified,
		"leads_converted": leads_converted,
		"leads_lost": leads_lost
	}

# Get leads in specific status
func get_leads_by_status(status: Lead.LeadStatus) -> Array[Lead]:
	var filtered_leads: Array[Lead] = []
	
	for lead in active_leads + qualified_leads:
		if lead.status == status:
			filtered_leads.append(lead)
	
	return filtered_leads

# Clean up old lost leads
func cleanup_old_leads(max_age: float = 600.0) -> int:
	var cleaned_count = 0
	var leads_to_remove: Array[Lead] = []
	
	for lead in active_leads:
		if lead.time_since_generation > max_age and lead.status == Lead.LeadStatus.LOST:
			leads_to_remove.append(lead)
			cleaned_count += 1
	
	for lead in leads_to_remove:
		active_leads.erase(lead)
	
	return cleaned_count