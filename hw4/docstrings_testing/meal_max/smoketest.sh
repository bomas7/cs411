#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:5000/api"

#missing clear meals, get meal by name, clear combatants, get combatants
# Function to check the health of the service
check_health() {
  echo "Checking health status..."
  curl -s -X GET "$BASE_URL/health" | grep -q '"status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Service is healthy."
  else
    echo "Health check failed."
    exit 1
  fi
}

# Function to check the database connection
check_db() {
  echo "Checking database connection..."
  curl -s -X GET "$BASE_URL/db-check" | grep -q '"database_status": "healthy"'
  if [ $? -eq 0 ]; then
    echo "Database connection is healthy."
  else
    echo "Database check failed."
    exit 1
  fi
}

# Function to create a meal
create_meal() {
  meal=$1
  cuisine=$2
  price=$3
  difficulty=$4

  echo "Creating meal: $meal ($cuisine, $price, $difficulty)..."
  response=$(curl -s -X POST "$BASE_URL/create-meal" -H "Content-Type: application/json" \
    -d "{\"meal\":\"$meal\", \"cuisine\":\"$cuisine\", \"price\":$price, \"difficulty\":\"$difficulty\"}")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal created successfully."
  else
    echo "Failed to create meal."
    echo "$response"
    exit 1
  fi
}

# Function to delete a meal by ID
delete_meal_by_id() {
  meal_id=$1

  echo "Deleting meal by ID ($meal_id)..."
  response=$(curl -s -X DELETE "$BASE_URL/delete-meal/$meal_id")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal deleted successfully."
  else
    echo "Failed to delete meal by ID ($meal_id)."
    echo "$response"
    exit 1
  fi
}

# Function to get a meal by ID
get_meal_by_id() {
  meal_id=$1

  echo "Retrieving meal by ID ($meal_id)..."
  response=$(curl -s -X GET "$BASE_URL/get-meal/$meal_id")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal retrieved successfully by ID ($meal_id)."
  else
    echo "Failed to retrieve meal by ID ($meal_id)."
    echo "$response"
    exit 1
  fi
}

# Function to get the leaderboard
get_leaderboard() {
  echo "Getting the leaderboard..."
  response=$(curl -s -X GET "$BASE_URL/leaderboard")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Leaderboard retrieved successfully."
  else
    echo "Failed to get the leaderboard."
    echo "$response"
    exit 1
  fi
}

# Function to prepare a combatant for a battle
prep_combatant() {
  meal_id=$1

  echo "Preparing meal with ID $meal_id for battle..."
  response=$(curl -s -X POST "$BASE_URL/prep-combatant" -H "Content-Type: application/json" \
    -d "{\"meal_id\":$meal_id}")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal with ID $meal_id prepared for battle."
  else
    echo "Failed to prepare meal with ID $meal_id for battle."
    echo "$response"
    exit 1
  fi
}

# Function to start a battle
battle() {
  echo "Starting battle..."
  response=$(curl -s -X POST "$BASE_URL/battle")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Battle executed successfully."
  else
    echo "Battle execution failed."
    echo "$response"
    exit 1
  fi
}

clear_meals() {
  echo "Clearing the meals..."
  curl -s -X DELETE "$BASE_URL/clear-meals" | grep -q '"status": "success"'
}

clear_combatants() {
  echo "Clearing the combatants..."
  curl -s -X DELETE "$BASE_URL/clear-combatants" | grep -q '"status": "success"'
}
  
get_combatants() {
  echo "Getting the combatants..."
  response=$(curl -s -X GET "$BASE_URL/get-combatants")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Combatants retrieved successfully"
  else
    echo "Failed to retrieve combatants"
    echo "$response"
    exit 1
  fi
}

get_meal_by_name() {
  name_id=$1
  echo "Getting the meal by name..."
  response=$(curl -s -X GET "$BASE_URL/get-meal-by-name/$name_id")
  if echo "$response" | grep -q '"status": "success"'; then
    echo "Meal retrived by name successfully"
  else
    echo "Failed to get the meal by name."
    echo "$response"
    exit 1
  fi
}

# Run the health checks
check_health
check_db

create_meal "Spaghetti" "Italian" 10.5 "MED"
clear_meals
create_meal "Spaghetti" "Italian" 10.5 "MED"
delete_meal_by_id 1
create_meal "Spaghetti" "Italian" 10.5 "MED"
get_meal_by_id 1
get_meal_by_name "Spaghetti"
create_meal "Tacos" "Mexican" 8.0 "LOW"
get_meal_by_id 2
get_meal_by_name "Tacos"
create_meal "Sushi" "Japanese" 15.0 "HIGH"
get_meal_by_name "Sushi"

prep_combatant 1
clear_combatants
prep_combatant 1
prep_combatant 2

battle  

get_leaderboard

delete_meal_by_id 1

prep_combatant 3
battle
get_leaderboard
clear_meals
clear_combatants

echo "All smoketests passed successfully!"
