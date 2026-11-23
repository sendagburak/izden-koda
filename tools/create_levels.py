"""Authoring tool: produces the fixed five JSON missions and their reproducible witnesses."""
from collections import deque
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
MOVES={'U':(0,-1),'R':(1,0),'D':(0,1),'L':(-1,0)}

def shortest_path(size,start,goal,rocks):
    queue=deque([(tuple(start),())]); visited={tuple(start)}
    while queue:
        (x,y),seq=queue.popleft()
        if [x,y]==goal: return list(seq)
        for letter,(dx,dy) in MOVES.items():
            q=(x+dx,y+dy)
            if 0<=q[0]<size[0] and 0<=q[1]<size[1] and list(q) not in rocks and q not in visited:
                visited.add(q);queue.append((q,seq+(letter,)))
    raise RuntimeError('No route for '+str(start)+str(goal))

def grid(size,start,goal,rocks):
    path=shortest_path(size,start,goal,rocks)
    return {'params':dict(size=size,start=start,goal=goal,rocks=rocks,max_steps=len(path)+1),'witness':path}

def signal(tokens,alphabet): return {'params':{'target':tokens,'alphabet':alphabet,'max_steps':len(tokens)+2},'witness':tokens}

def switches(wiring,witness):
    lamps=[0]*len(wiring)
    for key in witness:
        for index in wiring[str(key)]:lamps[index]^=1
    return {'params':dict(initial=[0]*len(wiring),goal=lamps,wiring=wiring,max_steps=len(witness)+1),'witness':[str(i) for i in witness]}

def level(i,title_key,typ,concepts,layers):
    id=f'd1-p1-{i:03d}'
    data=dict(schema_version=1,id=id,world='d1',act=1,order=i,type=typ,concepts=concepts,locale_key=f'mission.{id}',hints=[f'hint.{id}.{n}' for n in (1,2,3)],layers=layers)
    (ROOT/f'veri/levels/d1/{i:02d}.json').write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    return {'id':id,'file':f'veri/levels/d1/{i:02d}.json'}

def main():
    items=[]
    items.append(level(1,'first','grid_route',['sequence','direction'],{
        'concrete':grid([5,4],[0,2],[3,2],[]),
        'blocks':grid([5,4],[0,2],[3,2],[[1,2]]),
        'system':grid([6,4],[0,2],[4,2],[[1,2],[2,2],[3,2]])
    }))
    items.append(level(2,'quay','grid_route',['sequence','debug'],{
        'concrete':grid([5,5],[0,4],[4,4],[[2,4]]),
        'blocks':grid([6,5],[0,4],[5,4],[[1,4],[2,4],[3,4]]),
        'system':grid([6,5],[0,4],[5,4],[[1,4],[2,4],[3,4],[4,4],[2,3]])
    }))
    items.append(level(3,'path','grid_route',['planning','efficiency'],{
        'concrete':grid([5,5],[0,0],[4,4],[[2,0],[2,1],[2,2]]),
        'blocks':grid([6,5],[0,0],[5,0],[[2,y] for y in range(4)]),
        'system':grid([6,6],[0,0],[5,0],[[2,y] for y in range(5)])
    }))
    items.append(level(4,'signal','signal_pattern',['pattern','sequence'],{
        'concrete':signal(['A','B','A'],['A','B']),
        'blocks':signal(['A','B','B','A'],['A','B']),
        'system':signal(['A','B','A','C','B','A'],['A','B','C'])
    }))
    wiring3={'0':[0,1],'1':[1,2],'2':[0,2]}
    wiring4={'0':[0,1],'1':[1,2],'2':[2,3],'3':[0,3]}
    items.append(level(5,'panel','toggle_board',['state','cause_effect'],{
        'concrete':switches(wiring3,['0']),
        'blocks':switches(wiring4,['0','2']),
        'system':switches(wiring4,['0','1','3'])
    }))
    (ROOT/'veri/levels/index.json').write_text(json.dumps({'schema_version':1,'worlds':['d1','d2','d3','d4','d5','d6','d7'],'missions':items},indent=2)+'\n')
if __name__=='__main__':main()
