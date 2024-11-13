import pytest

from meal_max.models.battle_model import BattleModel
from meal_max.models.meal import Meal

@pytest.fixture()
def BattleModel():
    """Fixture to provide a new instance of BattleModel for each test."""
    return BattleModel()

"""Fixtures providing sample meals for the tests."""
@pytest.fixture
def sample_meal1():
    return Meal(1, "Pasta", "Italian", 12.5, "MED")

@pytest.fixture
def sample_meal2():
    return Meal(2, 'Sushi', 'Japanese', 20.0, 'HIGH')

@pytest.fixture
def sample_combatants(sample_meal1, sample_meal2):
    return [sample_meal1, sample_meal2]


