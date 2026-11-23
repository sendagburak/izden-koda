"""Offline source and task-data checks; not a substitute for launching Godot."""
import csv
import json
import pathlib
import unittest

ROOT=pathlib.Path(__file__).resolve().parents[1]

class TestVerticalSlice(unittest.TestCase):
    def test_bootstrap_exists(self):
        project=(ROOT/'project.godot').read_text(encoding='utf-8')
        self.assertIn('gl_compatibility',project)
        self.assertTrue((ROOT/'oyun/app/main.tscn').is_file())
    def test_first_five_have_all_layers(self):
        idx=json.loads((ROOT/'veri/levels/index.json').read_text(encoding='utf-8'))
        self.assertEqual(len(idx['missions']),350)
        for item in idx['missions']:
            level=json.loads((ROOT/item['file']).read_text(encoding='utf-8'))
            self.assertEqual(set(level['layers']),{'concrete','blocks','system'})
            self.assertEqual(len(level['hints']),3)
            for layer in level['layers'].values(): self.assertTrue(layer['witness'])
    def test_english_turkish_keys_match(self):
        def keys(p):
            with (ROOT/p).open(encoding='utf-8-sig',newline='') as f:
                return {r['key'] for r in csv.DictReader(f)}
        self.assertEqual(keys('veri/locale/tr.csv'),keys('veri/locale/en.csv'))
    def test_no_network_or_paid_addons(self):
        cfg=(ROOT/'project.godot').read_text(encoding='utf-8')
        self.assertNotIn('INTERNET',cfg)
        self.assertNotIn('http',cfg)
if __name__ == '__main__': unittest.main()
