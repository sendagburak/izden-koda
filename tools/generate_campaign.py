#!/usr/bin/env python3
"""Deterministic 7x50 bilingual campaign content; original level witnesses.
Re-run only from the repository root. Existing first five D1 missions are preserved.
No internet, external assets, or generative service.
"""
from __future__ import annotations
import csv, json, random
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LOCALES={}
for lang in ('tr','en'):
    with (ROOT/f'veri/locale/{lang}.csv').open(newline='',encoding='utf-8-sig') as f:
        LOCALES[lang]={x['key']:x['value'] for x in csv.DictReader(f)}

WORLDS={
1:("Kayıp Fenerin Sırrı","The Lost Lighthouse",['İlk Işıklar','Ada Postası','Tekrarlanan Sinyaller','Sisli Rota','Fenerler Birlikte'],['First Beacons','Island Post','Repeating Signals','Misty Routes','Beacons Together'],['iskele','kıyı','fener','şamandıra','koy','gelgit','kule','harita','posta','çan'],['pier','shore','beacon','buoy','bay','tide','tower','map','post','bell']),
2:("Saatçilerin Gizli Sokağı","Clockmakers Alley",['Düzenli Tik Tak','İki Çark Bir İş','Kapı Ne Zaman Açılır','Yanlış Takılan Diş','Sokak Orkestrası'],['Steady Tick','Two Gears','When The Door Opens','Misplaced Gear','Street Orchestra'],['çark','vitrin','zil','mekik','yay','sarkaç','pencere','takvim','ibre','atölye'],['gear','window','bell','shuttle','spring','pendulum','pane','calendar','hand','workshop']),
3:("Yaşayan İstasyon","Living Station",['İlk Fideler','Ne Zaman Sulamalı','Denge Defteri','Bir Günlük Model','İstasyonun Nabzı'],['First Seeds','When To Water','Balance Log','A Day Model','Station Heartbeat'],['fide','saksı','kanal','toprak','sensör','sera','tohum','yaprak','nem','kubbe'],['seedling','pot','canal','soil','sensor','greenhouse','seed','leaf','moisture','dome']),
4:("Sessiz Arşiv","Silent Archive",['Kayıp Etiketler','Kodlu Kayıt','Dizinin Mantığı','Şifreli Çekmece','Arşiv Açılıyor'],['Lost Labels','Coded Records','The Index','Cipher Drawer','Archive Opens'],['fiş','raf','kitap','sandık','kayıt','mühür','kart','dizin','anahtar','parşömen'],['file','shelf','book','chest','record','seal','card','index','key','scroll']),
5:("Kesişen Yollar Vadisi","Crossroads Valley",['Küçük Kavşaklar','Köprüler','Yolun Bedeli','İki Rota','Vadinin Haritası'],['Little Junctions','Bridges','Route Cost','Two Routes','Valley Map'],['köprü','yaya yolu','tramvay','tünel','nehir','durak','kavşak','patika','istasyon','vadi'],['bridge','footpath','tram','tunnel','river','stop','crossing','trail','station','valley']),
6:("Ritim ve Desen Atölyesi","Pattern Workshop",['İlk Desen','Düzenli Vuruş','Kısa Bir Fonksiyon','Büyük Kompozisyon','Atölye Sergisi'],['First Pattern','Steady Beat','A Tiny Function','Big Composition','Workshop Show'],['ritim','davul','doku','karo','nota','baskı','sahne','çizgi','desen','dokuma'],['rhythm','drum','texture','tile','note','print','stage','line','pattern','weave']),
7:("Yeni Gün Kenti","New Day City",['Taslak Plan','İlk Deneme','Birleşen Sistemler','Test Alanı','Yeni Gün'],['Draft Plan','First Test','Systems Together','Test Area','New Day'],['meydan','hat','park','aydınlatma','kütüphane','kavşak','atölye','istasyon','meyve bahçesi','okul'],['square','line','park','lighting','library','crossing','workshop','station','orchard','school']),
}
SCHEDULE={
1:['grid_route','grid_route','signal_pattern','toggle_board','grid_route','flowchart','signal_pattern','pattern_machine','grid_route','toggle_board'],
2:['signal_pattern','function_loops','state_machine','logic_gate','toggle_board','flowchart','function_loops','logic_gate','state_machine','signal_pattern'],
3:['sensor_lab','resource_plan','data_detective','logic_gate','pattern_machine','robot_course','sensor_lab','data_detective','resource_plan','robot_course'],
4:['binary_lights','cipher_wheel','sort_train','data_detective','flowchart','binary_lights','sort_train','cipher_wheel','data_detective','flowchart'],
5:['graph_path','grid_route','resource_plan','robot_course','sort_train','graph_path','resource_plan','grid_route','graph_path','robot_course'],
6:['function_loops','pattern_machine','signal_pattern','flowchart','binary_lights','function_loops','pattern_machine','flowchart','function_loops','signal_pattern'],
7:['robot_course','logic_gate','sensor_lab','flowchart','graph_path','state_machine','resource_plan','data_detective','robot_course','graph_path']}
DESC={
'grid_route':('İşaretçiyi hedefe götür; yönlerin sırası yolu belirler.','Guide the marker to its destination; move order matters.'),
'signal_pattern':('Işıkların sırasını incele ve aynı diziyi yeniden kur.','Inspect the lights and reproduce the exact sequence.'),
'toggle_board':('Anahtarların hangi lambaları etkilediğini keşfet ve hedef düzeni kur.','Find out which switches change which lamps; restore the target.'),
'sort_train':('Vagonların sırasını yalnızca komşu değişimleriyle düzenle.','Order the wagons using only adjacent swaps.'),
'binary_lights':('İkili ışık panelinde gerekli bitleri açıp kapat.','Switch the right bits on the binary light panel.'),
'cipher_wheel':('Şifre çarkını döndürüp işaretlenen anahtar ayarını bul.','Rotate the cipher wheel to its marked key.'),
'flowchart':('Akış adımlarını doğru bağlantı sırasıyla yerleştir.','Place the flow steps in their logical order.'),
'logic_gate':('Mantık kapısının girişlerini hedef çıkışı sağlayacak biçimde ayarla.','Set the gate inputs to produce the required output.'),
'pattern_machine':('Sayı makinesini uygun işlemlerle hedefe ulaştır.','Use the number machine operations to reach the target.'),
'resource_plan':('Malzemeleri seç; hem ihtiyacı karşıla hem de bütçeyi aşma.','Choose materials to meet the need without exceeding the budget.'),
'sensor_lab':('Sensör eşiğini seç ve otomatik denetimi etkinleştir.','Set the sensor threshold and enable automatic control.'),
'robot_course':('Önce çevreyi tara, sonra robotu güvenli rotadan geçir.','Scan the area first, then guide the robot along a safe route.'),
'graph_path':('Bağlantılı durakları izle; en uygun maliyetli rotayı keşfet.','Navigate connected stops to find an efficient route.'),
'function_loops':('Hazır yordamları çağırarak uzun bir deseni kısa programla üret.','Use procedures to build a long pattern with a short program.'),
'state_machine':('Olayları doğru sırayla tetikleyerek sistemi hedef duruma getir.','Trigger events in order to reach the target state.'),
'data_detective':('Ölçümlerde belirtilen kurala uyan kayıtları seç.','Select all measurements that satisfy the rule.'),
}
CONCEPTS={
'grid_route':['sequence','direction'], 'signal_pattern':['patterns','sequence'], 'toggle_board':['logic','debug'],
'sort_train':['sorting','arrays'],'binary_lights':['binary','encoding'],'cipher_wheel':['encoding','variables'],
'flowchart':['flowchart','sequence'],'logic_gate':['boolean','conditions'],'pattern_machine':['functions','arithmetic'],
'resource_plan':['optimization','planning'],'sensor_lab':['sensors','conditions'],'robot_course':['robotics','events'],
'graph_path':['graphs','efficiency'],'function_loops':['functions','loops'],'state_machine':['states','events'],
'data_detective':['data','filtering']}

def params_for(t,w,a,j,layer):
    k={'concrete':0,'blocks':1,'system':2}[layer]
    r=random.Random(w*100000+a*1000+j*37+k*11)
    if t in ('grid_route','robot_course'):
        distance=2+(j+k)%3+k//2
        y=2; width=distance+2; h=5
        obstruction=(j+k)%3!=0
        rocks=[[1,y]] if obstruction else []
        route=['U']+['R']*distance+['D'] if obstruction else ['R']*distance
        p={'size':[width,h],'start':[0,y],'goal':[distance,y],'rocks':rocks,'max_steps':len(route)+2}
        if t=='robot_course':p['needs_scan']=True;route=['S']+route;p['max_steps']+=1
        return p,route
    if t=='signal_pattern':
        alphabet=['K','M','T','S'];n=3+k+(j%3)
        goal=[alphabet[(i*i+j+i//2)%len(alphabet)] for i in range(n)]
        return {'alphabet':alphabet,'target':goal,'max_steps':n+1},goal
    if t=='toggle_board':
        n=3+k;wiring={f'S{i}':[i,(i+1)%n] for i in range(n)}
        commands=[f'S{i}' for i in sorted({j%n,(j+1+k)%n})]
        goal=[0]*n
        for key in commands:
            for ind in wiring[key]:goal[ind]^=1
        return {'initial':[0]*n,'goal':goal,'wiring':wiring,'max_steps':len(commands)+3},commands
    if t=='sort_train':
        n=3+k+(j%2)
        numbers=list(range(1,n+1));r.shuffle(numbers)
        if numbers==sorted(numbers):numbers=numbers[::-1]
        current=numbers[:];ops=[]
        for z in range(n):
            for x in range(n-1):
                if current[x]>current[x+1]:
                    current[x],current[x+1]=current[x+1],current[x];ops.append(str(x))
        return {'initial':numbers,'goal':current,'alphabet':[str(i) for i in range(n-1)],'max_steps':len(ops)+2},ops
    if t=='binary_lights':
        n=4+k+(j%2);target=[(j+k+i*7//3)%2 for i in range(n)]
        if not any(target):target[-1]=1
        return {'initial':[0]*n,'goal':target,'alphabet':[str(i) for i in range(n)],'max_steps':n+2},[str(i) for i,x in enumerate(target) if x]
    if t=='cipher_wheel':
        shift=1+(j+k)%5;word=['ISIK','DENGE','IZLER','KOD','ROTA','ADA','RITIM','VERI','KAPI','YOL'][j%10]
        encodings=[''.join(chr((ord(ch)-65+q)%26+65) for ch in word) for q in range(26)]
        return {'source':word,'encodings':encodings,'goal_shift':shift,'alphabet':['+','-'],'max_steps':10},['+']*shift
    if t=='flowchart':
        n=3+k+(j%2);step_names=['OBSERVE','PLAN','ACT','CHECK','REFINE','SHARE'][:n]
        tokens=list('ABCDEF')[:n];r.shuffle(tokens)
        labels=dict(zip(tokens,step_names))
        return {'nodes':sorted(tokens),'labels':labels,'goal':tokens,'alphabet':sorted(tokens),'max_steps':n+1},tokens
    if t=='logic_gate':
        gate=['AND','OR','XOR','NAND','NOR'][j%5]
        answers={'AND':['A1','B1'],'OR':['B1'],'XOR':['A1'],'NAND':['A0','B0'],'NOR':['A0','B0']}
        goal=int(gate in ['AND','OR','XOR','NAND','NOR'])
        return {'gate':gate,'goal':goal,'alphabet':['A0','A1','B0','B1'],'max_steps':4},answers[gate]
    if t=='pattern_machine':
        start=1+k;ops={'+2':2,'+3':3,'-1':-1,'*2':2};actions=['+2','*2','+3'][:1+(j+k)%3+1];cur=start
        for action in actions:
            cur=cur*2 if action=='*2' else cur+int(action)
        return {'start':start,'goal':cur,'alphabet':list(ops),'max_steps':5},actions
    if t=='resource_plan':
        costs={'A':1+k,'B':2+k,'C':3+k,'D':4+k};benefits={'A':2+k,'B':3+k,'C':2+k,'D':5+k}
        chosen=['A','B'] if j%2 else ['A','C'];goal=sum(benefits[x] for x in chosen);budget=sum(costs[x] for x in chosen)
        return {'costs':costs,'benefits':benefits,'goal':goal,'budget':budget,'max_steps':3,'alphabet':list(costs)},chosen
    if t=='sensor_lab':
        threshold=2+(j+k)%3; samples=[0,1,2,3,4,5]
        return {'samples':samples,'expected':[int(v<threshold) for v in samples],'goal_threshold':threshold,'alphabet':['T1','T2','T3','T4','AUTO'],'max_steps':3},[f'T{threshold}','AUTO']
    if t=='graph_path':
        # Route via B is lower cost than detour via C/E; graph is undirected.
        delta=(j+k)%3
        edges={'A':{'B':1+delta,'C':4+delta},'B':{'A':1+delta,'D':1+k},'C':{'A':4+delta,'E':2},'E':{'C':2,'D':2},'D':{'B':1+k,'E':2}}
        return {'edges':edges,'start':'A','goal':'D','max_cost':2+delta+k,'max_steps':5,'alphabet':['B','C','D','E','A']},['B','D']
    if t=='function_loops':
        macros={'A':'ST','B':'TS','C':'SS'};ops=['A','B'] if (j+k)%2 else ['C','A','B'];target=''.join(macros[x] for x in ops)
        return {'macros':macros,'target':target,'alphabet':list(macros),'max_steps':3},ops
    if t=='state_machine':
        transitions={'OFF':{'START':'READY'},'READY':{'CHECK':'ACTIVE'},'ACTIVE':{'SEND':'DONE'},'DONE':{'RESET':'OFF'}}
        return {'transitions':transitions,'start':'OFF','goal':'DONE','alphabet':['START','CHECK','SEND','RESET'],'max_steps':6},['START','CHECK','SEND']
    if t=='data_detective':
        nums=[r.randint(1,9) for _ in range(4+k)];cutoff=4+(j%3);indexes=[str(i) for i,v in enumerate(nums) if v>=cutoff]
        if not indexes:nums[0]=9;indexes=['0']
        return {'values':nums,'threshold':cutoff,'alphabet':[str(i) for i in range(len(nums))],'max_steps':len(nums)},indexes
    raise ValueError(t)

index={'schema_version':1,'worlds':[f'd{i}' for i in range(1,8)],'missions':[]}
for w in range(1,8):
    tr_world,en_world,tr_acts,en_acts,tr_obj,en_obj=WORLDS[w]
    for n in range(1,51):
        a=(n-1)//10+1;j=(n-1)%10
        mid=f'd{w}-p{a}-{n:03d}'
        path=ROOT/f'veri/levels/d{w}/{n:02d}.json'
        if w==1 and n<=5:
            level=json.loads(path.read_text(encoding='utf-8'))
            typ=level['type']
        else:
            typ=SCHEDULE[w][(j+(a-1)*2)%10]
            title=f'{tr_acts[a-1]}: {tr_obj[j].capitalize()}'
            title_en=f'{en_acts[a-1]}: {en_obj[j].capitalize()}'
            layers={}
            for name in ('concrete','blocks','system'):
                p,sol=params_for(typ,w,a,j,name)
                layers[name]={'params':p,'witness':sol}
            level={'schema_version':1,'id':mid,'world':f'd{w}','act':a,'order':n,'type':typ,'concepts':CONCEPTS[typ],
                   'locale_key':f'mission.{mid}', 'hints':[f'hint.{mid}.{i}' for i in (1,2,3)],'layers':layers}
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text(json.dumps(level,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
            LOCALES['tr'][f'mission.{mid}']=title
            LOCALES['en'][f'mission.{mid}']=title_en
            dtr,den=DESC[typ]
            LOCALES['tr'][f'mission.desc.{mid}']=f'{tr_world} · {tr_obj[j].capitalize()} görevi. {dtr}'
            LOCALES['en'][f'mission.desc.{mid}']=f'{en_world} · {en_obj[j].capitalize()} mission. {den}'
            for tier in (1,2,3):
                hints={1:('Önce hedefi ve başlangıç durumunu karşılaştır.','Compare the target with the starting state.'),
                       2:('Tek hamlenin etkisini izle; aynı kuralı bütün adımlara uygula.','Observe what one move changes, then apply the same rule.'),
                       3:('Ajan defterindeki örnek çözümü incele ve farklı bir yol da dene.','Study the example in the agent notebook, and try another route.')}
                LOCALES['tr'][f'hint.{mid}.{tier}']=hints[tier][0]
                LOCALES['en'][f'hint.{mid}.{tier}']=hints[tier][1]
            LOCALES['tr'][f'result.{mid}']=f'{tr_obj[j].capitalize()} yeniden işliyor. {tr_acts[a-1].lower()} dosyasına yeni bir iz eklendi.'
            LOCALES['en'][f'result.{mid}']=f'{en_obj[j].capitalize()} is working again. A new clue entered the {en_acts[a-1].lower()} file.'
        index['missions'].append({'id':mid,'file':f'veri/levels/d{w}/{n:02d}.json'})
for lang in ('tr','en'):
    for w in range(1,8):
        LOCALES[lang][f'ui.preview_d{w}']=WORLDS[w][0 if lang=='tr' else 1]
    translations={
    'tr':{'ui.daily':'Günlük keşif','ui.simulation':'Yarışma provası','ui.workshop':'Proje atölyesi','ui.sandbox':'Serbest laboratuvar','ui.collection':'Koleksiyon','ui.skills':'Yeteneklerim','ui.mission_list':'Görev dosyaları','ui.world_locked':'Önizleme açık · Görevler henüz açılmadı','ui.world_open':'Dünyayı keşfet','ui.journey':'Yolculuğum','ui.choose':'Seç','ui.ready':'Hazır','ui.progress':'Tamamlanan','ui.preview_route':'Bir önceki dünyanın 40. görevini tamamlayarak buradaki görevlere ulaşabilirsin.','ui.daily_note':'Bugünün keşif dosyası','ui.practice_note':'Dilersen kendi temponda çöz. Süre tutmak zorunda değilsin.','ui.workshop_note':'Bir problemi tanımla, tahmin üret, tasarla, dene ve gözlemle.','ui.sandbox_note':'Dilediğin görevi tekrar dene. Bütün denemeler ücretsiz.','ui.collection_note':'Kazanılan tüm izler burada saklanır. Hiçbiri geri alınmaz.','ui.skills_note':'Burada rekabet veya sıralama yok; keşfettiğin kavramları görürsün.','ui.gate':'Bağlantı görevi','ui.act':'Perde','ui.world':'Dünya','ui.levels':'Görevler','ui.mode':'Mod','ui.home':'Atlas','ui.next_world':'Sonraki dünya','ui.play_again':'Yeniden dene','ui.no_results':'Henüz yeni bir iz yok','ui.unsupported':'Bu görev için bir kontrol henüz hazır değil','ui.cost':'Maliyet','ui.goal_number':'Hedef değer','ui.start_number':'Başlangıç','ui.data':'Ölçümler','ui.active':'Etkin','ui.target':'Hedef'},
    'en':{'ui.daily':'Daily discovery','ui.simulation':'Challenge practice','ui.workshop':'Project studio','ui.sandbox':'Free laboratory','ui.collection':'Collection','ui.skills':'My skills','ui.mission_list':'Mission files','ui.world_locked':'Preview available · Missions not yet open','ui.world_open':'Explore this world','ui.journey':'My journey','ui.choose':'Choose','ui.ready':'Ready','ui.progress':'Completed','ui.preview_route':'Complete mission 40 in the previous world to begin here.','ui.daily_note':'Today’s discovery file','ui.practice_note':'Take your time. A timer is never required.','ui.workshop_note':'Define a problem, predict, design, test, and reflect.','ui.sandbox_note':'Retry any mission. Every attempt is free.','ui.collection_note':'Every earned clue stays in your collection.','ui.skills_note':'No competition or ranking here; track concepts you have explored.','ui.gate':'Connection mission','ui.act':'Act','ui.world':'World','ui.levels':'Missions','ui.mode':'Mode','ui.home':'Atlas','ui.next_world':'Next world','ui.play_again':'Try again','ui.no_results':'No clues here yet','ui.unsupported':'No control is available for this mission yet','ui.cost':'Cost','ui.goal_number':'Goal value','ui.start_number':'Start','ui.data':'Readings','ui.active':'Active','ui.target':'Target'}}
    LOCALES[lang].update(translations[lang])
    with (ROOT/f'veri/locale/{lang}.csv').open('w',encoding='utf-8',newline='') as f:
        writer=csv.writer(f);writer.writerow(['key','value'])
        for key in sorted(LOCALES[lang]):writer.writerow([key,LOCALES[lang][key]])
(ROOT/'veri/levels/index.json').write_text(json.dumps(index,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print('Generated',len(index['missions']),'missions. Families:',sorted({json.loads((ROOT/m['file']).read_text())['type'] for m in index['missions']}))
