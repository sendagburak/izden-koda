"""Static guard for resume handling; runtime semantics belong to test_resume.gd."""
from pathlib import Path
import re
import unittest

SOURCE = (Path(__file__).resolve().parents[1] / 'oyun/app/main.gd').read_text(encoding='utf-8')


def body(name):
    match = re.search(rf'^func {re.escape(name)}\([^\n]*\)(?: -> [^:]+)?:\n(.*?)(?=^func |\Z)', SOURCE, re.M | re.S)
    return match.group(1) if match else ''


class ResumeContract(unittest.TestCase):
    def test_initialization_and_profile_switch_use_same_resume_rule(self):
        for function in ('_ready', '_choose_profile', '_create_profile'):
            with self.subTest(function=function):
                self.assertIn('_resume_progress()', body(function))

    def test_resume_rule_selects_world_and_first_unfinished_mission(self):
        logic = body('_resume_target')
        self.assertIn('_world_unlocked(w)', logic)
        self.assertIn('completed_ids', logic)
        self.assertIn('world_number', logic)
        self.assertIn('order', logic)

    def test_resume_clears_non_story_modes(self):
        self.assertIn('mode_context = "story"', body('_resume_progress'))
