"""Source guards against false backup-success reporting and invalid profile ids.

These are static checks, not substitutes for Godot tests/test_backup.gd.
"""
from pathlib import Path
import re
import unittest

BASE = Path(__file__).resolve().parents[1]
APP = (BASE / 'oyun/app/main.gd').read_text(encoding='utf-8')
IO = (BASE / 'oyun/core/backup_io.gd').read_text(encoding='utf-8')


def method(source, name):
    found = re.search(rf'^func {re.escape(name)}\([^\n]+\)(?: -> [^:]+)?:\n(.*?)(?=^func |\Z)', source, re.M | re.S)
    return found.group(1) if found else ''


class BackupRestoreContract(unittest.TestCase):
    def test_foreign_profiles_are_saved_before_being_listed(self):
        handler = method(APP, '_choose_backup')
        self.assertIn('target.length() <= 64', handler)
        self.assertLess(handler.index('store.save_profile(target,'), handler.index('profiles.entries.append('))

    def test_backup_requires_valid_immutable_id(self):
        for method_name in ('import_data', 'export_data'):
            with self.subTest(method=method_name):
                chunk = method(IO, method_name)
                self.assertIn('is_valid_identifier()', chunk)
                self.assertIn('length() <= 64', chunk)
