"""Static UI contract: optional practice timer stays visible during a mission."""
from pathlib import Path
import unittest

SRC=(Path(__file__).resolve().parents[1]/'oyun/app/main.gd').read_text()

class SimulationContract(unittest.TestCase):
 def test_timer_shown_and_updates_while_solving(self):
  render=SRC.split('func _render_mission() -> void:',1)[1].split('\nfunc ',1)[0]
  process=SRC.split('func _process(_delta: float) -> void:',1)[1].split('\nfunc ',1)[0]
  self.assertIn('mode_context == "simulation" and sim_timer_enabled',render)
  self.assertIn('sim_clock_label',render)
  self.assertIn('screen in ["competition", "mission"]',process)

if __name__=='__main__':unittest.main()
