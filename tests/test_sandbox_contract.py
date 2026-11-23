"""Source contract for independent no-penalty sandbox (not engine execution)."""
import unittest
from pathlib import Path

PATH=Path(__file__).resolve().parents[1]/'oyun/app/main.gd'

class SandboxContract(unittest.TestCase):
    def test_sandbox_has_separate_execution_and_terrain_editing(self):
        src=PATH.read_text()
        for method in ['_sandbox_execute(', '_sandbox_toggle_rock(', '_sandbox_add(', '_sandbox_clear(']:
            self.assertIn('func '+method,src)
        body=src.split('func _sandbox_execute(',1)[1].split('\nfunc ',1)[0]
        self.assertNotIn('progress.complete(',body)
        self.assertNotIn('store.save_profile(',body)
        self.assertIn('sandbox_commands',body)

if __name__=='__main__': unittest.main()
