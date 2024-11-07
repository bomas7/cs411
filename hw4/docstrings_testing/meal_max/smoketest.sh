#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:5000/api"

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

# Run the health checks
check_health
check_db

# Create some meals
create_meal "Spaghetti" "Italian" 10.5 "MED"
create_meal "Tacos" "Mexican" 8.0 "LOW"
create_meal "Sushi" "Japanese" 15.0 "HIGH"

# Get meals by ID
get_meal_by_id 1
get_meal_by_id 2

# Delete a meal and verify it
delete_meal_by_id 1
get_meal_by_id 1  # This should fail

# Get the leaderboard
get_leaderboard

echo "All smoketests passed successfully!"
