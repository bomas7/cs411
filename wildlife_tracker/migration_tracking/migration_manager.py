from typing import Optional

from wildlife_tracker.migration_tracking.migration import Migration
from wildlife_tracker.migration_tracking.migration_path import MigrationPath
from wildlife_tracker.habitat_management.habitat import Habitat

class MigrationManager:
    def __init__(self, 
                migrations: dict[int, Migration] = {},
                paths: dict[int, MigrationPath] = {}
                ) -> None:
        self.migrations = migrations
        self.paths = paths

    def create_migration_path(species: str, start_location: Habitat, destination: Habitat, duration: Optional[int] = None) -> None:
        pass
    def get_migration_by_id(migration_id: int) -> Migration:
        pass
    def get_migration_path_by_id(path_id: int) -> MigrationPath:
        pass