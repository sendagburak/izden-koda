from pathlib import Path
import sys
import unittest
BASE=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(BASE/'tools'))
import validate_sources
class ContentTests(unittest.TestCase):
    def test_all_witnesses_reach_destination(self):
        report=validate_sources.validate(BASE)
        self.assertEqual(report['missions'],350)
        self.assertEqual(report['valid_witnesses'],1050)
        self.assertEqual(report['errors'],[])
    def test_all_missions_have_distinct_outcome_messages(self):
        tr,_=validate_sources.locale_map(BASE/'veri/locale/tr.csv')
        en,_=validate_sources.locale_map(BASE/'veri/locale/en.csv')
        for i in range(1,6):
            key=f'result.d1-p1-{i:03}'
            self.assertTrue(tr.get(key))
            self.assertTrue(en.get(key))
        self.assertEqual(len({tr[f'result.d1-p1-{i:03}'] for i in range(1,6)}),5)

    def test_bad_level_detected(self):
        level={'id':'x','type':'grid_route','layers':{'concrete':{'params':{'size':[2,2], 'start':[0,0],'goal':[1,1],'rocks':[],'max_steps':1},'witness':['R','D']}}}
        self.assertFalse(validate_sources.replay(level,'concrete'))
