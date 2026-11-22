"""Source-level guard for preserving every locally tracked progress field."""
from pathlib import Path
import unittest

TEXT = (Path(__file__).resolve().parents[1] / 'oyun/core/backup_io.gd').read_text(encoding='utf-8')

class ProgressMergeContract(unittest.TestCase):
    def test_merge_preserves_progress_fields(self):
        func = TEXT.split('func merge(', 1)[-1]
        for field in ('daily_history', 'skill_events', 'workshop', 'workshop_criteria', 'last_attempt'):
            with self.subTest(field=field):
                self.assertIn(f'"{field}"', func)
