#!/usr/bin/env python3
"""Deterministic 7x50 bilingual campaign content; original level witnesses.
Re-run only from the repository root. Existing first five D1 missions are preserved.
No internet, external assets, or generative service.
"""
from __future__ import annotations
import csv, heapq, json, random
from collections import deque
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
HINTS = {
    "grid_route": (("Hedefin yönünü bul. Engellere bakmadan komut ekleme.", "Find the direction of the goal. Check for obstacles before adding a move."),
                   ("Her komut bir kare ilerletir. Bir engelin çevresinden dolaşabilirsin.", "Each command moves one square. You can go around an obstacle.")),
    "signal_pattern": (("Işık dizisinin tekrar eden parçasını bul.", "Find the repeating part of the signal."),
                       ("Küçük parçayı baştan sona kur, sonra dizide yeniden başlat.", "Build the short pattern first, then repeat it in order.")),
    "toggle_board": (("Başlangıç ve hedefte farklı olan ışıkları belirle.", "Find the lights that differ between the start and the target."),
                     ("Bir anahtara iki kez basmak etkisini geri alır.", "Using the same switch twice cancels its effect.")),
    "sort_train": (("Hedefte hangi vagonun sıranın başında olduğuna bak.", "See which wagon is first in the target order."),
                   ("İki komşu vagonu değiştirerek yanlış sıradaki sayıyı hedefe yaklaştır.", "Swap adjacent wagons to move a misplaced value closer to its target.")),
    "binary_lights": (("Başlangıç ve hedefi aynı konumdaki bitleri eşleştirerek oku.", "Compare the starting and target bits position by position."),
                      ("Yalnızca hedefinden farklı olan bitleri değiştir.", "Toggle the bits whose values differ from their targets.")),
    "cipher_wheel": (("İlk harfin başlangıç ve hedefini karşılaştır.", "Compare the first letter at the start and at the target."),
                     ("Çark her adımda bütün harfleri aynı yöne kaydırır.", "Each turn shifts every letter in the same direction.")),
    "flowchart": (("İlk adım veri okumak, gözlem yapmak ya da ölçmektir.", "Start by reading, observing, or measuring."),
                  ("Önce bilgi toplanır, sonra işlenir ve sonunda kontrol edilir.", "Collect information first, use it next, then check the result.")),
    "logic_gate": (("Kapının adını ve istenen çıkışı birlikte oku.", "Read the gate name together with the required output."),
                   ("Girişlerden birini değiştirip çıkışın nasıl değiştiğini incele.", "Change one input and observe what happens to the output.")),
    "pattern_machine": (("Başlangıç ile hedef arasındaki farkı bul.", "Find the difference between the starting and target values."),
                        ("Çarpma komutunu erken ve geç uygulayarak sonuçları karşılaştır.", "Compare the results of multiplying early and late.")),
    "resource_plan": (("En yüksek katkıyı veren seçeneğin maliyetini kontrol et.", "Check the cost of the option with the greatest benefit."),
                      ("İki seçeneğin maliyet ve katkı toplamını ayrı ayrı hesapla.", "Add the costs and benefits separately for two choices.")),
    "sensor_lab": (("Hedefte 1 olan ölçümler için eşiği düşün.", "Use the measurements marked 1 to narrow down the threshold."),
                   ("Sensör eşikten küçük ölçümlere yanıt verir. Sonra AUTO komutuyla denetimi aç.", "Readings below the threshold trigger the sensor. Use AUTO to enable it.")),
    "robot_course": (("Robot hareket etmeden önce çevresini taramalı.", "The robot needs to scan its surroundings before moving."),
                     ("Taramadan sonra engellerin çevresinden geçecek bir yön sırası kur.", "After scanning, plan a sequence that goes around the obstacles.")),
    "graph_path": (("Başlangıç ile bitiş arasındaki bağlantıları ve varsa uğranacak durakları bul.", "Find the links and any required stops between the start and the destination."),
                   ("Her kenarın maliyetini topla ve zorunlu durakları verilen sırayla geç.", "Add the edge costs and visit any required stops in the given order.")),
    "function_loops": (("Hedef dizide bir yordamın ürettiği parçayı ara.", "Look for a chunk of the target sequence produced by one procedure."),
                       ("Aynı parça art arda geliyorsa varsa tekrar komutunu kullan.", "If the same pattern repeats in a row, use a repeat command when available.")),
    "state_machine": (("Başlangıç durumunda hangi olayların mümkün olduğuna bak.", "Check which events are available in the start state."),
                      ("Her olaydan sonra yeni durumu bul. Bir saat adımı gerekiyorsa TICK kullan.", "Check the new state after each event. Use TICK when a clock step is required.")),
    "data_detective": (("Ölçümlerin sıra numarasını ve eşik değerini ayırt et.", "Distinguish measurement positions from the threshold value."),
                       ("Eşiğe eşit ölçümleri de seç.", "Include readings equal to the threshold.")),
}
MECHANIC_LABELS = {
    "flow.step_observe": ("Gözlemle", "Observe"), "flow.step_plan": ("Planla", "Plan"),
    "flow.step_act": ("Uygula", "Act"), "flow.step_check": ("Kontrol et", "Check"),
    "flow.step_refine": ("İyileştir", "Refine"), "flow.step_share": ("Paylaş", "Share"),
    "flow.step_read": ("Oku", "Read"), "flow.step_select": ("Seç", "Select"),
    "flow.step_sort": ("Sırala", "Sort"), "flow.step_verify": ("Doğrula", "Verify"),
    "flow.step_save": ("Kaydet", "Save"), "flow.step_measure": ("Ölç", "Measure"),
    "flow.step_record": ("Kayda al", "Record"), "flow.step_compare": ("Karşılaştır", "Compare"),
    "machine.state_off": ("Kapalı", "Off"), "machine.state_idle": ("Boşta", "Idle"),
    "machine.state_warming": ("Isınıyor", "Warming"), "machine.state_ready": ("Hazır", "Ready"),
    "machine.state_active": ("Etkin", "Active"), "machine.state_waiting": ("Bekliyor", "Waiting"),
    "machine.state_cooling": ("Soğuyor", "Cooling"), "machine.state_safe": ("Güvenli", "Safe"),
    "machine.state_done": ("Bitti", "Done"),
    "machine.event_start": ("Başlat", "Start"), "machine.event_check": ("Kontrol et", "Check"),
    "machine.event_send": ("Gönder", "Send"), "machine.event_reset": ("Başa al", "Reset"),
    "machine.event_tick": ("Bir saat adımı ilerlet", "Advance one clock tick"),
    "machine.event_open": ("Aç", "Open"), "machine.event_stop": ("Durdur", "Stop"),
}

MOVES = {"U": (0, -1), "R": (1, 0), "D": (0, 1), "L": (-1, 0)}
GATES = {
    "AND": lambda a, b: a and b,
    "OR": lambda a, b: a or b,
    "XOR": lambda a, b: a != b,
    "NAND": lambda a, b: not (a and b),
    "NOR": lambda a, b: not (a or b),
    "NOT": lambda a, b: not a,
}
FLOW_STEPS = (
    ("OBSERVE", "PLAN", "ACT", "CHECK", "REFINE", "SHARE"),
    ("READ", "SELECT", "SORT", "VERIFY", "SAVE", "SHARE"),
    ("MEASURE", "RECORD", "COMPARE", "CHECK", "REFINE", "SHARE"),
)
CIPHER_WORDS = ("ISIK", "DENGE", "IZLER", "KOD", "ROTA", "ADA", "RITIM", "VERI", "KAPI", "YOL",
                "FENER", "ISKELE", "YON", "HARITA", "GOZLEM", "KAYIT", "HAVUZ", "DESEN", "DEVRE", "DENEY")
STATE_STEPS = (
    (("OFF", "START", "READY"), ("READY", "CHECK", "ACTIVE"), ("ACTIVE", "SEND", "DONE")),
    (("IDLE", "START", "WARMING"), ("WARMING", "TICK", "READY"), ("READY", "SEND", "DONE")),
    (("OFF", "START", "READY"), ("READY", "OPEN", "ACTIVE"), ("ACTIVE", "STOP", "SAFE")),
    (("IDLE", "START", "ACTIVE"), ("ACTIVE", "CHECK", "WAITING"), ("WAITING", "TICK", "DONE")),
    (("OFF", "START", "WARMING"), ("WARMING", "TICK", "READY"), ("READY", "TICK", "ACTIVE"), ("ACTIVE", "SEND", "DONE")),
    (("IDLE", "CHECK", "READY"), ("READY", "START", "ACTIVE"), ("ACTIVE", "STOP", "COOLING"), ("COOLING", "TICK", "SAFE")),
)

def route_on_grid(width, height, start, goal, rocks):
    queue = deque([(start, [])])
    seen = {start}
    while queue:
        position, path = queue.popleft()
        if position == goal:
            return path
        for move, (dx, dy) in MOVES.items():
            spot = (position[0] + dx, position[1] + dy)
            if 0 <= spot[0] < width and 0 <= spot[1] < height and spot not in rocks and spot not in seen:
                seen.add(spot)
                queue.append((spot, path + [move]))
    return []

def graph_params(r, k, act):
    nodes = list("ABCDE" if k == 0 else "ABCDEF")
    order = r.sample(nodes, len(nodes))
    start, goal = order[:2]
    via = order[2:2 + min(2, k + (act >= 4))]
    edges = {node: {} for node in nodes}
    ring = r.sample(nodes, len(nodes))
    connections = list(zip(ring, ring[1:] + ring[:1])) + [tuple(r.sample(nodes, 2)) for _ in range(k + 2)]
    for first, second in connections:
        cost = r.randint(1, 3 + k)
        edges[first][second] = cost
        edges[second][first] = cost
    # A search state includes the progress of the required stops, not just the current stop.
    candidates = [(0, 0, start, [])]
    seen = set()
    while candidates:
        cost, visited, node, path = heapq.heappop(candidates)
        if (node, visited) in seen:
            continue
        seen.add((node, visited))
        if node == goal and visited == len(via):
            return {"edges": edges, "start": start, "goal": goal, "via": via, "max_cost": cost + (2 - k),
                    "max_steps": len(path) + 2, "alphabet": nodes}, path
        for stop, extra in edges[node].items():
            next_visited = visited + int(visited < len(via) and stop == via[visited])
            heapq.heappush(candidates, (cost + extra, next_visited, stop, path + [stop]))
    raise ValueError("unreachable graph objective")

def params_for(t, w, a, j, layer, variation=0):
    k = {"concrete": 0, "blocks": 1, "system": 2}[layer]
    r = random.Random(w * 100000 + a * 1000 + j * 37 + k * 11 + variation * 1000003)
    if t in ("grid_route", "robot_course"):
        width = 4 + k + (a >= 3) + r.randrange(2)
        height = 4 + (k > 0) + (a >= 4)
        start, goal = (0, r.randrange(height)), (width - 2, r.randrange(height))
        spaces = [(x, y) for x in range(width) for y in range(height) if (x, y) not in [start, goal]]
        rocks = r.sample(spaces, r.randint(1, 2 + a // 2 + k))
        path = route_on_grid(width, height, start, goal, rocks)
        while not path:
            rocks.pop()
            path = route_on_grid(width, height, start, goal, rocks)
        if t == "robot_course":
            path = ["S"] + path
        return {"size": [width, height], "start": list(start), "goal": list(goal),
                "rocks": [list(pos) for pos in sorted(rocks)], "max_steps": len(path) + 3 - k}, path
    if t == "signal_pattern":
        alphabet = ["K", "M", "T", "S"]
        motif = r.sample(alphabet, 2 + (a >= 3) + (k == 2))
        repetitions = 2 + (a >= 4) + (k == 2)
        target = (motif * repetitions)[:3 + k + (a >= 3) * 2 + j % 2]
        return {"alphabet": alphabet, "target": target, "max_steps": len(target)}, target
    if t == "toggle_board":
        n = 3 + k + (a >= 4)
        wiring = {f"S{i}": [i, r.choice([other for other in range(n) if other != i])] for i in range(n)}
        initial = [r.randrange(2) if a > 1 or k else 0 for _ in range(n)]
        commands = r.sample(list(wiring), 1 + (a >= 3) + (k == 2))
        goal = initial[:]
        for key in commands:
            for i in wiring[key]:
                goal[i] ^= 1
        if goal == initial:
            commands = commands[:1]
            for i in wiring[commands[0]]:
                goal[i] ^= 1
        return {"initial": initial, "goal": goal, "wiring": wiring, "max_steps": len(commands) + 2}, commands
    if t == "sort_train":
        n = 3 + k + (a >= 3)
        numbers = r.sample(range(1, 11 + a), n)
        reverse = k == 2 and a >= 3
        target = sorted(numbers, reverse=reverse)
        if numbers == target:
            numbers = numbers[::-1]
        current = numbers[:]
        actions = []
        for stop in range(n - 1, 0, -1):
            for index in range(stop):
                left, right = current[index:index + 2]
                out_of_order = left < right if reverse else left > right
                if out_of_order:
                    current[index], current[index + 1] = current[index + 1], current[index]
                    actions.append(str(index))
        return {"initial": numbers, "goal": target, "alphabet": [str(i) for i in range(n - 1)],
                "max_steps": len(actions) + 2}, actions
    if t == "binary_lights":
        n = 4 + k + (a >= 3)
        initial = [r.randrange(2) if a > 1 or k else 0 for _ in range(n)]
        toggles = sorted(r.sample(range(n), r.randint(1, n)))
        target = [bit ^ int(index in toggles) for index, bit in enumerate(initial)]
        return {"initial": initial, "goal": target, "alphabet": [str(i) for i in range(n)],
                "max_steps": len(toggles) + 2}, [str(i) for i in toggles]
    if t == "cipher_wheel":
        shift = r.randint(1 + k, 3 + k + a)
        if k or a >= 3:
            shift *= r.choice([-1, 1])
        word = r.choice(CIPHER_WORDS)
        encodings = ["".join(chr((ord(ch) - 65 + offset) % 26 + 65) for ch in word) for offset in range(26)]
        return {"source": word, "encodings": encodings, "goal_shift": shift % 26, "alphabet": ["+", "-"],
                "max_steps": abs(shift) + 2}, ["+" if shift > 0 else "-"] * abs(shift)
    if t == "flowchart":
        n = min(6, 3 + k + (a >= 3))
        sequence = list(r.choice(FLOW_STEPS)[:n])
        tokens = list("ABCDEF")[:n]
        r.shuffle(tokens)
        labels = dict(zip(tokens, sequence))
        return {"nodes": sorted(tokens), "labels": labels, "goal": tokens, "alphabet": sorted(tokens),
                "max_steps": n + 1}, tokens
    if t == "logic_gate":
        choices = list(GATES) if a + k >= 3 else ["AND", "OR", "NOT"]
        gate = r.choice(choices)
        initial = [r.randrange(2), r.randrange(2) if gate != "NOT" else 0]
        desired = int(not GATES[gate](*initial))
        targets = [[first, second] for first in range(2) for second in range(2)
                   if int(GATES[gate](first, second)) == desired]
        if gate == "NOT":
            targets = [[1 - initial[0], 0]]
        target = min(r.sample(targets, len(targets)), key=lambda bits: sum(x != y for x, y in zip(initial, bits)))
        commands = [f"{symbol}{after}" for symbol, before, after in zip("AB", initial, target) if before != after]
        alphabet = ["A0", "A1"] if gate == "NOT" else ["A0", "A1", "B0", "B1"]
        return {"gate": gate, "initial": initial, "goal": desired, "alphabet": alphabet,
                "max_steps": len(commands) + 2}, commands
    if t == "pattern_machine":
        start = r.randint(1, 3 + a + k)
        alphabet = ["+2", "+3", "-1", "*2"]
        actions = [r.choice(alphabet) for _ in range(1 + k + (a >= 3))]
        current = start
        for operation in actions:
            current = current * 2 if operation == "*2" else current + int(operation)
        if current == start:
            actions.append("+2")
            current += 2
        return {"start": start, "goal": current, "alphabet": alphabet, "max_steps": len(actions) + 2}, actions
    if t == "resource_plan":
        names = list("ABCD" if k < 2 else "ABCDE")
        costs = {item: r.randint(1, 4 + k + a // 2) for item in names}
        benefits = {item: r.randint(1, 5 + k + a // 2) for item in names}
        chosen = sorted(r.sample(names, 2 + (a >= 3 and k > 0)))
        return {"costs": costs, "benefits": benefits, "goal": sum(benefits[x] for x in chosen),
                "budget": sum(costs[x] for x in chosen), "max_steps": len(chosen) + 1,
                "alphabet": names}, chosen
    if t == "sensor_lab":
        threshold = r.randint(2, 3 + (k > 0))
        samples = [threshold - 1, threshold] + [r.randrange(6) for _ in range(3 + k)]
        r.shuffle(samples)
        return {"samples": samples, "expected": [int(v < threshold) for v in samples], "goal_threshold": threshold,
                "alphabet": ["T1", "T2", "T3", "T4", "AUTO"], "max_steps": 3}, [f"T{threshold}", "AUTO"]
    if t == "graph_path":
        return graph_params(r, k, a)
    if t == "function_loops":
        patterns = ["ST", "TS", "SS", "TT", "MK", "KM"] if k else ["ST", "TS", "SS", "TT"]
        macros = dict(zip("ABC", r.sample(patterns, 3)))
        alphabet = list(macros)
        if k > 0 or a >= 3:
            alphabet += [name + "*2" for name in macros]
        if k == 2:
            alphabet += [name + "*3" for name in macros]
        program = [r.choice(alphabet) for _ in range(2 + (a >= 3))]
        if k and all("*" not in operation for operation in program):
            program[0] += "*2"
        target = "".join(macros[token[0]] * (int(token[-1]) if "*" in token else 1) for token in program)
        return {"macros": macros, "target": target, "alphabet": alphabet,
                "max_steps": len(program) + 2}, program
    if t == "state_machine":
        program = r.choice(STATE_STEPS[:4] if a < 3 and k == 0 else STATE_STEPS)
        transitions = {before: {event: after} for before, event, after in program}
        start, goal = program[0][0], program[-1][2]
        transitions[goal] = {"RESET": start}
        if k or a >= 3:
            for mode in r.sample([before for before, _, _ in program[1:]], k or 1):
                transitions[mode]["RESET"] = start
        alphabet = sorted({event for actions in transitions.values() for event in actions})
        return {"transitions": transitions, "start": start, "goal": goal,
                "alphabet": alphabet, "max_steps": len(program) + 1 + (2 - k)}, [event for _, event, _ in program]
    if t == "data_detective":
        cutoff = r.randint(3, 6)
        values = [cutoff - 1, cutoff] + [r.randint(1, 9) for _ in range(2 + k + (a >= 4))]
        r.shuffle(values)
        return {"values": values, "threshold": cutoff, "alphabet": [str(i) for i in range(len(values))],
                "max_steps": len(values)}, [str(i) for i, reading in enumerate(values) if reading >= cutoff]
    raise ValueError(t)

def param_signature(kind, layers):
    return kind, json.dumps([layer["params"] for layer in layers.values()], sort_keys=True)

def turkish_title(word):
    return word[0].translate(str.maketrans("iı","İI")).upper() + word[1:]

index={'schema_version':1,'worlds':[f'd{i}' for i in range(1,8)],'missions':[]}
seen_params = set()
for w in range(1,8):
    tr_world,en_world,tr_acts,en_acts,tr_obj,en_obj=WORLDS[w]
    for n in range(1,51):
        a=(n-1)//10+1;j=(n-1)%10
        mid=f'd{w}-p{a}-{n:03d}'
        path=ROOT/f'veri/levels/d{w}/{n:02d}.json'
        if w==1 and n<=5:
            level=json.loads(path.read_text(encoding='utf-8'))
            typ=level['type']
            seen_params.add(param_signature(typ, level["layers"]))
        else:
            typ=SCHEDULE[w][(j+(a-1)*2)%10]
            place_tr = turkish_title(tr_obj[j])
            place_en = en_obj[j].capitalize()
            title=f'{tr_acts[a-1]}: {place_tr}'
            title_en=f'{en_acts[a-1]}: {en_obj[j].capitalize()}'
            for variation in range(16):
                layers={}
                for name in ('concrete','blocks','system'):
                    p,sol=params_for(typ,w,a,j,name,variation)
                    layers[name]={'params':p,'witness':sol}
                signature = param_signature(typ, layers)
                if signature not in seen_params:
                    seen_params.add(signature)
                    break
            else:
                raise ValueError(f"duplicate parameters for {mid}")
            level={'schema_version':1,'id':mid,'world':f'd{w}','act':a,'order':n,'type':typ,'concepts':CONCEPTS[typ],
                   'locale_key':f'mission.{mid}', 'hints':[f'hint.{mid}.{i}' for i in (1,2,3)],'layers':layers}
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text(json.dumps(level,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
            LOCALES['tr'][f'mission.{mid}']=title
            LOCALES['en'][f'mission.{mid}']=title_en
            dtr,den=DESC[typ]
            LOCALES['tr'][f'mission.desc.{mid}']=f'{tr_acts[a-1]} · {place_tr}. {dtr}'
            LOCALES['en'][f'mission.desc.{mid}']=f'{en_acts[a-1]} · {place_en}. {den}'
            hints = HINTS[typ] + (('Örnek programı adım adım izle. Sonra uygun gördüğün yerde başka bir yol dene.',
                                   'Step through the example program. Try another approach where it fits.'),)
            for tier in (1,2,3):
                LOCALES['tr'][f'hint.{mid}.{tier}']=hints[tier-1][0]
                LOCALES['en'][f'hint.{mid}.{tier}']=hints[tier-1][1]
            LOCALES['tr'][f'result.{mid}']=f'{place_tr} görevi tamamlandı. {tr_acts[a-1]} dosyasına yeni bir iz eklendi.'
            LOCALES['en'][f'result.{mid}']=f'{place_en} mission complete. A new clue was added to the {en_acts[a-1]} file.'
        index['missions'].append({'id':mid,'file':f'veri/levels/d{w}/{n:02d}.json'})
for lang in ('tr','en'):
    for w in range(1,8):
        LOCALES[lang][f'ui.preview_d{w}']=WORLDS[w][0 if lang=='tr' else 1]
    translations={
    'tr':{'ui.daily':'Günlük keşif','ui.simulation':'Yarışma provası','ui.workshop':'Proje atölyesi','ui.sandbox':'Serbest laboratuvar','ui.collection':'Koleksiyon','ui.skills':'Yeteneklerim','ui.mission_list':'Görev dosyaları','ui.world_locked':'Önizleme açık · Görevler henüz açılmadı','ui.world_open':'Dünyayı keşfet','ui.journey':'Yolculuğum','ui.choose':'Seç','ui.ready':'Hazır','ui.progress':'Tamamlanan','ui.preview_route':'Bir önceki dünyanın 40. görevini tamamlayarak buradaki görevlere ulaşabilirsin.','ui.daily_note':'Bugünün keşif dosyası','ui.practice_note':'Dilersen kendi temponda çöz. Süre tutmak zorunda değilsin.','ui.workshop_note':'Bir problemi tanımla, tahmin üret, tasarla, dene ve gözlemle.','ui.sandbox_note':'Dilediğin görevi tekrar dene. Bütün denemeler ücretsiz.','ui.collection_note':'Kazanılan tüm izler burada saklanır. Hiçbiri geri alınmaz.','ui.skills_note':'Burada rekabet veya sıralama yok; keşfettiğin kavramları görürsün.','ui.gate':'Bağlantı görevi','ui.act':'Perde','ui.world':'Dünya','ui.levels':'Görevler','ui.mode':'Mod','ui.home':'Atlas','ui.next_world':'Sonraki dünya','ui.play_again':'Yeniden dene','ui.no_results':'Henüz yeni bir iz yok','ui.unsupported':'Bu görev için bir kontrol henüz hazır değil','ui.cost':'Maliyet','ui.goal_number':'Hedef değer','ui.start_number':'Başlangıç','ui.data':'Ölçümler','ui.active':'Etkin','ui.target':'Hedef'},
    'en':{'ui.daily':'Daily discovery','ui.simulation':'Challenge practice','ui.workshop':'Project studio','ui.sandbox':'Free laboratory','ui.collection':'Collection','ui.skills':'My skills','ui.mission_list':'Mission files','ui.world_locked':'Preview available · Missions not yet open','ui.world_open':'Explore this world','ui.journey':'My journey','ui.choose':'Choose','ui.ready':'Ready','ui.progress':'Completed','ui.preview_route':'Complete mission 40 in the previous world to begin here.','ui.daily_note':'Today’s discovery file','ui.practice_note':'Take your time. A timer is never required.','ui.workshop_note':'Define a problem, predict, design, test, and reflect.','ui.sandbox_note':'Retry any mission. Every attempt is free.','ui.collection_note':'Every earned clue stays in your collection.','ui.skills_note':'No competition or ranking here; track concepts you have explored.','ui.gate':'Connection mission','ui.act':'Act','ui.world':'World','ui.levels':'Missions','ui.mode':'Mode','ui.home':'Atlas','ui.next_world':'Next world','ui.play_again':'Try again','ui.no_results':'No clues here yet','ui.unsupported':'No control is available for this mission yet','ui.cost':'Cost','ui.goal_number':'Goal value','ui.start_number':'Start','ui.data':'Readings','ui.active':'Active','ui.target':'Target'}}
    for key, value in translations[lang].items():
        LOCALES[lang].setdefault(key, value)
    for key, values in MECHANIC_LABELS.items():
        LOCALES[lang][key] = values[0 if lang == "tr" else 1]
    with (ROOT/f'veri/locale/{lang}.csv').open('w',encoding='utf-8',newline='') as f:
        writer=csv.writer(f);writer.writerow(['key','value'])
        for key in sorted(LOCALES[lang]):writer.writerow([key,LOCALES[lang][key]])
(ROOT/'veri/levels/index.json').write_text(json.dumps(index,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
print('Generated',len(index['missions']),'missions. Families:',sorted({json.loads((ROOT/m['file']).read_text())['type'] for m in index['missions']}))
