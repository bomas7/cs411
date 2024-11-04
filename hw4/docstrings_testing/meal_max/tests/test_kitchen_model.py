import pytest
from meal_max.model.kitchen_model import (
    create_meal,
    clear_meals,
    delete_meal,
    get_leaderboard,
    get_meal_by_id,
    get_meal_by_name,
    update_meal_stats,
    Meal,
)
from meal_max.utils.sql_utils import get_db_connection

@pytest.fixture(scope="function", autouse=True)
def setup_and_teardown_db():
    """Fixture to clear the meals table before and after each test."""
    clear_meals()  # Ensure a clean state before each test
    yield
    clear_meals()  # Cleanup to avoid test interference

@pytest.fixture
def sample_meal_data():
    """Provides sample meal data for testing purposes."""
    return {
        "meal": "Spaghetti",
        "cuisine": "Italian",
        "price": 10.5,
        "difficulty": "MED",
    }

@pytest.fixture
def add_meal_to_db(sample_meal_data):
    """Adds a sample meal to the database and returns its ID."""
    create_meal(**sample_meal_data)
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM meals WHERE meal = ?", (sample_meal_data["meal"],))
        meal_id = cursor.fetchone()[0]
    return meal_id

##################################################
# Meal Creation Tests
##################################################

def test_create_meal_success(sample_meal_data):
    """Test successful creation of a meal and verify it was added to the database."""
    create_meal(**sample_meal_data)
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT meal, cuisine, price, difficulty FROM meals WHERE meal = ?", (sample_meal_data["meal"],))
        row = cursor.fetchone()
    
    assert row == (sample_meal_data["meal"], sample_meal_data["cuisine"], sample_meal_data["price"], sample_meal_data["difficulty"]), "Meal data in database should match input data"

def test_create_meal_invalid_price():
    """Test creation of a meal with invalid price raises an error."""
    with pytest.raises(ValueError, match="Invalid price: -5.0. Price must be a positive number."):
        create_meal("Spaghetti", "Italian", -5.0, "MED")

def test_create_meal_invalid_difficulty():
    """Test creation of a meal with invalid difficulty level raises an error."""
    with pytest.raises(ValueError, match="Invalid difficulty level: HARD. Must be 'LOW', 'MED', or 'HIGH'."):
        create_meal("Spaghetti", "Italian", 10.5, "HARD")

##################################################
# Meal Deletion Tests
##################################################

def test_delete_meal_success(add_meal_to_db):
    """Test successful deletion of a meal and verify it is marked as deleted in the database."""
    delete_meal(add_meal_to_db)
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT deleted FROM meals WHERE id = ?", (add_meal_to_db,))
        deleted_status = cursor.fetchone()[0]
    
    assert deleted_status, "Meal should be marked as deleted in the database"

def test_delete_nonexistent_meal():
    """Test deleting a meal that does not exist raises an error."""
    with pytest.raises(ValueError, match="Meal with ID 99 not found"):
        delete_meal(99)

def test_delete_already_deleted_meal(add_meal_to_db):
    """Test deleting a meal that was already deleted raises an error."""
    delete_meal(add_meal_to_db)
    with pytest.raises(ValueError, match=f"Meal with ID {add_meal_to_db} has been deleted"):
        delete_meal(add_meal_to_db)

##################################################
# Meal Retrieval Tests
##################################################

def test_get_meal_by_id_success(add_meal_to_db):
    """Test retrieving a meal by ID returns the correct meal data."""
    meal = get_meal_by_id(add_meal_to_db)
    assert meal.meal == "Spaghetti"
    assert meal.cuisine == "Italian"
    assert meal.price == 10.5
    assert meal.difficulty == "MED"

def test_get_meal_by_name_success(add_meal_to_db):
    """Test retrieving a meal by name returns the correct meal data."""
    meal = get_meal_by_name("Spaghetti")
    assert meal.meal == "Spaghetti"
    assert meal.cuisine == "Italian"
    assert meal.price == 10.5
    assert meal.difficulty == "MED"

def test_get_deleted_meal_by_id(add_meal_to_db):
    """Test retrieving a meal by ID that has been deleted raises an error."""
    delete_meal(add_meal_to_db)
    with pytest.raises(ValueError, match=f"Meal with ID {add_meal_to_db} has been deleted"):
        get_meal_by_id(add_meal_to_db)

##################################################
# Leaderboard Tests
##################################################

def test_get_leaderboard_sorted_by_wins():
    """Test retrieving the leaderboard sorted by wins."""
    # Add meals with different stats for sorting verification
    create_meal("Pasta", "Italian", 8.0, "MED")
    create_meal("Burger", "American", 6.0, "LOW")
    
    # Manually update stats to simulate win/loss records
    update_meal_stats(1, "win")
    update_meal_stats(1, "win")
    update_meal_stats(2, "win")
    
    leaderboard = get_leaderboard(sort_by="wins")
    assert leaderboard[0]["meal"] == "Spaghetti"  # Highest wins first
    assert leaderboard[1]["meal"] == "Burger"

def test_get_leaderboard_invalid_sort():
    """Test getting leaderboard with an invalid sort field raises an error."""
    with pytest.raises(ValueError, match="Invalid sort_by parameter:"):
        get_leaderboard(sort_by="invalid")

##################################################
# Meal Statistics Update Tests
##################################################

def test_update_meal_stats_win(add_meal_to_db):
    """Test updating meal stats with a win result."""
    update_meal_stats(add_meal_to_db, "win")
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT battles, wins FROM meals WHERE id = ?", (add_meal_to_db,))
        battles, wins = cursor.fetchone()
    
    assert battles == 1, "Battle count should increment by 1 on win"
    assert wins == 1, "Wins count should increment by 1 on win"

def test_update_meal_stats_loss(add_meal_to_db):
    """Test updating meal stats with a loss result."""
    update_meal_stats(add_meal_to_db, "loss")
    with get_db_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT battles, wins FROM meals WHERE id = ?", (add_meal_to_db,))
        battles, wins = cursor.fetchone()
    
    assert battles == 1, "Battle count should increment by 1 on loss"
    assert wins == 0, "Wins count should remain the same on loss"

def test_update_meal_stats_invalid_result(add_meal_to_db):
    """Test updating meal stats with an invalid result raises an error."""
    with pytest.raises(ValueError, match="Invalid result: tie. Expected 'win' or 'loss'."):
        update_meal_stats(add_meal_to_db, "tie")
