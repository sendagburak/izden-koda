#!/usr/bin/env python3
"""Independent Python reference model for mission data. Not a Godot execution test."""
import json, csv, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
MOVES={'U':(0,-1),'D':(0,1),'L':(-1,0),'R':(1,0)}

def replay(level,layer):
    e=level['layers'][layer];p=e['params'];commands=e['witness'];t=level['type']
    if not isinstance(commands,list) or not commands or len(commands)>int(p.get('max_steps',999)):return False
    try:
        if t in ('grid_route','robot_course'):
            x,y=p['start'];rocks={tuple(z) for z in p.get('rocks',[])};scanned=False
            for cmd in commands:
                if cmd=='S' and t=='robot_course':scanned=True;continue
                if cmd not in MOVES or (t=='robot_course' and not scanned):return False
                dx,dy=MOVES[cmd];x+=dx;y+=dy
                if not (0<=x<p['size'][0] and 0<=y<p['size'][1]) or (x,y) in rocks:return False
            return [x,y]==p['goal'] and (t!='robot_course' or scanned)
        if t=='signal_pattern':return commands==p['target'] and all(c in p['alphabet'] for c in commands)
        if t=='toggle_board':
            current=p['initial'][:]
            for c in commands:
                for ix in p['wiring'][c]:current[ix]=1-current[ix]
            return current==p['goal']
        if t=='sort_train':
            current=p['initial'][:]
            for c in commands:
                if c not in p['alphabet']:return False
                i=int(c);current[i],current[i+1]=current[i+1],current[i]
            return current==p['goal']
        if t=='binary_lights':
            bits=p['initial'][:]
            for c in commands:
                if c not in p['alphabet']:return False
                i=int(c);bits[i]=1-bits[i]
            return bits==p['goal']
        if t=='cipher_wheel':
            shift=0
            for c in commands:
                if c not in p['alphabet']:return False
                shift=(shift+(1 if c=='+' else -1))%26
            return shift==p['goal_shift']
        if t=='flowchart':return commands==p['goal'] and len(set(commands))==len(commands) and all(x in p['nodes'] for x in commands)
        if t=='logic_gate':
            a=b=0
            for c in commands:
                if c not in p['alphabet']:return False
                if c[0]=='A':a=int(c[1])
                else:b=int(c[1])
            result={'AND':a and b,'OR':a or b,'XOR':a!=b,'NAND':not(a and b),'NOR':not(a or b)}[p['gate']]
            return int(result)==p['goal']
        if t=='pattern_machine':
            n=p['start']
            for c in commands:
                if c not in p['alphabet']:return False
                n=n*2 if c=='*2' else n-1 if c=='-1' else n+int(c)
            return n==p['goal']
        if t=='resource_plan':
            if len(set(commands))!=len(commands) or any(c not in p['costs'] for c in commands):return False
            return sum(p['costs'][x] for x in commands)<=p['budget'] and sum(p['benefits'][x] for x in commands)>=p['goal']
        if t=='sensor_lab':
            th=1;auto=False
            for c in commands:
                if c not in p['alphabet']:return False
                if c=='AUTO':auto=True
                else:th=int(c[1:])
            return auto and all((v<th)==(v<p['goal_threshold']) for v in p['samples'])
        if t=='graph_path':
            node=p['start'];total=0
            for c in commands:
                if c not in p['edges'].get(node,{}):return False
                total+=p['edges'][node][c];node=c
            return node==p['goal'] and total<=p['max_cost']
        if t=='function_loops':return ''.join(p['macros'][x] for x in commands)==p['target'] and len(commands)<len(p['target'])
        if t=='state_machine':
            mode=p['start']
            for c in commands:
                if c not in p['transitions'].get(mode,{}):return False
                mode=p['transitions'][mode][c]
            return mode==p['goal']
        if t=='data_detective':
            expected={str(i) for i,v in enumerate(p['values']) if v>=p['threshold']}
            return len(set(commands))==len(commands) and set(commands)==expected
    except (KeyError,ValueError,IndexError,TypeError,ZeroDivisionError):return False
    return False

def validate(root=ROOT):
    index=json.loads((root/'veri/levels/index.json').read_text(encoding='utf-8'))
    errors=[];valid=0
    for record in index.get('missions',[]):
        path=root/record['file']
        if not path.is_file():errors.append('missing '+record['file']);continue
        level=json.loads(path.read_text(encoding='utf-8'))
        for layer in ('concrete','blocks','system'):
            if replay(level,layer):valid+=1
            else:errors.append(f'invalid witness {level["id"]}/{layer}')
    return {'missions':len(index['missions']),'witnesses_valid':valid,'errors':errors}
if __name__=='__main__':
    report=validate(); print(json.dumps(report,ensure_ascii=False,indent=2));sys.exit(0 if not report['errors'] else 1)
