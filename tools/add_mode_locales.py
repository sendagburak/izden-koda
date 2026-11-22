#!/usr/bin/env python3
import csv
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]/'veri/locale'
TEXT={
'ui.scan':('Tara','Scan'), 'ui.timer':('İsteğe bağlı süre','Optional timer'),
'ui.workshop_result':('Deney defterine yeni bir kayıt eklendi. Aynı modeli farklı seçimlerle yeniden deneyebilirsin.','A new entry was added to your experiment notebook. Try different choices next time.'),
'ui.workshop_phase_1':('1 · Problemi tanımla','1 · Define a problem'),
'ui.workshop_phase_2':('2 · Tahmin oluştur','2 · Make a prediction'),
'ui.workshop_phase_3':('3 · Tasarla','3 · Design'),
'ui.workshop_phase_4':('4 · Deney yap','4 · Run a test'),
'ui.workshop_phase_5':('5 · Sonucu yorumla','5 · Reflect on results'),
'ui.workshop_question_1':('Seradaki bitkiler farklı hızlarda büyüyor. Önce neyi araştırırsın?','Plants grow at different rates. What do you investigate?'),
'ui.workshop_question_2':('Toprak nemi azaldığında ne olabileceğini öngör.','Predict what might happen when soil moisture drops.'),
'ui.workshop_question_3':('Hangi sistemi tasarlamak istersin?','Which system would you design?'),
'ui.workshop_question_4':('Tahminini nasıl sınayacaksın?','How will you test your prediction?'),
'ui.workshop_question_5':('Sonuçları nasıl yorumlayacaksın?','How will you reflect on your results?'),
'ui.workshop_choice_1_1':('Toprağın nemini ölç','Measure soil moisture'),
'ui.workshop_choice_1_2':('Günlük ışık miktarını ölç','Measure daily light'),
'ui.workshop_choice_2_1':('Nem azsa sulama gerekli olabilir','Low moisture may require watering'),
'ui.workshop_choice_2_2':('Her zaman aynı miktarda su verilmeli','Always use the same water amount'),
'ui.workshop_choice_3_1':('Nem sensörü + otomatik vana','Moisture sensor + automatic valve'),
'ui.workshop_choice_3_2':('Sabit saatli bir sulama çizelgesi','Fixed-time watering schedule'),
'ui.workshop_choice_4_1':('Üç farklı nem değerini dene','Test three moisture values'),
'ui.workshop_choice_4_2':('Yalnızca tek bir değer dene','Test just one value'),
'ui.workshop_choice_5_1':('Su tüketimi ile büyümeyi karşılaştır','Compare water use and growth'),
'ui.workshop_choice_5_2':('Sadece sistemin açılıp açılmadığını kontrol et','Check only whether the system starts'),
'ui.workshop_criterion_hypothesis':('Ölçülebilir tahmin','Measurable prediction'),
'ui.workshop_criterion_controlled_test':('Farklı koşullarda test','Testing different conditions'),
'ui.workshop_criterion_reflection':('Veriyle yorumlama','Data-informed reflection'),
'ui.workshop_discover':('Bu yaklaşımı sonraki deneyinde de inceleyebilirsin.','You can explore this approach in your next experiment.'),
'ui.workshop_found':('Bu yaklaşımı denedin.','You tried this approach.'),
}
for lang,i in [('tr',0),('en',1)]:
    file=ROOT/f'{lang}.csv'
    with file.open(encoding='utf-8-sig',newline='') as f: rows=list(csv.DictReader(f))
    dic={r['key']:r['value'] for r in rows}
    dic.update({key:val[i] for key,val in TEXT.items()})
    with file.open('w',encoding='utf-8',newline='') as f:
        w=csv.writer(f);w.writerow(['key','value'])
        for key in sorted(dic):w.writerow([key,dic[key]])
print('Added',len(TEXT),'mode translation keys')
