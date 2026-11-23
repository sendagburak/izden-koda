"""Stage 5+ content acceptance tests (independent static checks, not Godot runtime)."""
import csv
import json
import unittest
from collections import Counter
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
FAMILIES={"grid_route","signal_pattern","toggle_board","sort_train","binary_lights","cipher_wheel","flowchart","logic_gate","pattern_machine","resource_plan","sensor_lab","robot_course","graph_path","function_loops","state_machine","data_detective"}

class FullContentTests(unittest.TestCase):
    def setUp(self):
        self.idx=json.loads((ROOT/'veri/levels/index.json').read_text())
        self.missions=[json.loads((ROOT/x['file']).read_text()) for x in self.idx['missions']]

    def test_seven_worlds_have_fifty_missions_each(self):
        self.assertEqual(350,len(self.missions))
        self.assertEqual({f'd{x}':50 for x in range(1,8)},dict(Counter(x['world'] for x in self.missions)))
        self.assertEqual(350,len({x['id'] for x in self.missions}))
        for w in range(1,8):
            self.assertEqual({a:10 for a in range(1,6)},dict(Counter(x['act'] for x in self.missions if x['world']==f'd{w}')))

    def test_all_mechanics_present_and_backed_by_scripts(self):
        types={x['type'] for x in self.missions}
        self.assertEqual(FAMILIES,types)
        for name in types:
            self.assertTrue((ROOT/f'oyun/modules/{name}.gd').exists(),name)

    def test_each_level_has_complete_adaptations(self):
        for level in self.missions:
            self.assertEqual(['concrete','blocks','system'],list(level['layers']),level['id'])
            self.assertEqual(3,len(level['hints']),level['id'])
            for k in ['concrete','blocks','system']:
                self.assertTrue(level['layers'][k]['witness'],(level['id'],k))
                self.assertIsInstance(level['layers'][k]['params'],dict)

    def test_localizations_complete_and_distinct_missions(self):
        locales={}
        for lang in ('tr','en'):
            with (ROOT/f'veri/locale/{lang}.csv').open(encoding='utf-8-sig',newline='') as fh:
                rows=list(csv.DictReader(fh))
            self.assertEqual(len(rows),len({r['key'] for r in rows}))
            locales[lang]={r['key']:r['value'] for r in rows}
        self.assertEqual(set(locales['tr']),set(locales['en']))
        for l in self.missions:
            for k in [l['locale_key'],f'mission.desc.{l["id"]}',f'result.{l["id"]}',*l['hints']]:
                for lang in ('tr','en'):
                    self.assertTrue(locales[lang].get(k),(l['id'],lang,k))
        for lang in locales:
            titles=[locales[lang][x['locale_key']] for x in self.missions]
            self.assertEqual(350,len(set(titles)),lang)

    def test_every_witness_reaches_target_in_independent_model(self):
        from tools.campaign_validator import validate
        result=validate(ROOT)
        self.assertEqual(1050,result['witnesses_valid'])
        self.assertEqual([],result['errors'])

    def test_valid_id_and_no_network(self):
        for x in self.missions:
            self.assertRegex(x['id'],r'^d[1-7]-p[1-5]-\d{3}$')
        code='\n'.join(f.read_text() for f in (ROOT/'oyun').rglob('*.gd'))
        for forbidden in ('HTTPRequest','HTTPClient','ads_sdk','analytics_sdk'):
            self.assertNotIn(forbidden,code)

if __name__=='__main__':unittest.main()
