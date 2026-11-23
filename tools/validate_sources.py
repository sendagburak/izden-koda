#!/usr/bin/env python3
"""Offline independent data-contract checks. NOT an executed Godot test."""
from pathlib import Path
import csv
import json
import re
import sys
from collections import Counter
from campaign_validator import replay as replay_any
MOVES={'U':(0,-1),'D':(0,1),'L':(-1,0),'R':(1,0)}

def replay(level,layer):
    return replay_any(level,layer)

def locale_map(path):
    with path.open(encoding='utf-8-sig',newline='') as f:
        reader=csv.DictReader(f)
        pairs=list(reader)
    return {r['key']:r['value'] for r in pairs},[r['key'] for r in pairs]

def validate(root):
    errors=[]
    idx=json.loads((root/'veri/levels/index.json').read_text(encoding='utf-8'))
    missions=idx.get('missions',[])
    if len(missions)!=350:errors.append('unexpected mission count')
    ids=[m['id'] for m in missions]
    if len(ids)!=len(set(ids)):errors.append('duplicate mission ids')
    locs={};loc_ids={}
    for lang in ('tr','en'):
        locs[lang],loc_ids[lang]=locale_map(root/f'veri/locale/{lang}.csv')
        if len(set(loc_ids[lang]))!=len(loc_ids[lang]):errors.append('duplicate translations: '+lang)
    if set(locs['tr'])!=set(locs['en']):errors.append('translation key mismatch')
    valid=0;types=Counter()
    for record in missions:
        path=root/record['file']
        if not path.is_file():errors.append('missing level '+str(path));continue
        level=json.loads(path.read_text(encoding='utf-8'))
        if level.get('schema_version')!=1 or level.get('id')!=record['id']:
            errors.append('invalid schema/id '+record['id']);continue
        types[level['type']]+=1
        if set(level.get('layers',{}))!={'concrete','blocks','system'}:
            errors.append('incomplete adaptation '+level['id'])
        for layer in ['concrete','blocks','system']:
            if replay(level,layer):valid+=1
            else: errors.append('bad witness '+level['id']+'/'+layer)
        for key in [level.get('locale_key',''), 'mission.desc.'+level['id'], 'result.'+level['id']]+level.get('hints',[]):
            if not all(locs[lang].get(key,'').strip() for lang in locs):
                errors.append('missing translation '+key)
    source=(root/'oyun/app/main.gd').read_text(encoding='utf-8')
    # Constant UI string keys must exist. Dynamic keys are checked separately via prefixes.
    for key in set(re.findall(r'"(ui\.[a-z_0-9]+)"',source)):
        if key not in locs['tr'] and not key.endswith('_'):errors.append('untranslated UI key '+key)
    for script in (root/'oyun').rglob('*.gd'):
        code=script.read_text(encoding='utf-8')
        for token in ['HTTPRequest','HTTPClient','MultiplayerAPI','ads_sdk','analytics_sdk']:
            if token in code:errors.append('unexpected online API '+script.name+'/'+token)
        for resource in re.findall(r'res://[\w\-./]+\.(?:gd|png|tscn|csv|json)',code):
            if not (root/resource[6:]).exists():errors.append('missing resource '+resource)
    return {'missions':len(missions),'valid_witnesses':valid,'module_counts':dict(types),'locale_keys':len(locs['tr']),'errors':errors}

if __name__=='__main__':
    result=validate(Path(__file__).resolve().parents[1])
    print(json.dumps(result,ensure_ascii=False,indent=2))
    sys.exit(0 if not result['errors'] else 1)
