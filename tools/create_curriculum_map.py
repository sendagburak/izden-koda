#!/usr/bin/env python3
"""Provisional curriculum mapping, without invented official learning codes."""
from pathlib import Path
import json,csv
ROOT=Path(__file__).resolve().parents[1]
MAPPINGS={
'grid_route':('Matematik;Hayat Bilgisi','Sıralı yönergeler, yön bulma ve rota seçimi'),
'signal_pattern':('Matematik;Müzik','Örüntü ve tekrar ilişkilerini modelleme'),
'toggle_board':('Bilişim Teknolojileri ve Yazılım;Fen Bilimleri','Basit devre bağlantılarındaki neden-sonuç ilişkisi'),
'sort_train':('Bilişim Teknolojileri ve Yazılım;Matematik','Liste düzeni ve komşu değişim işlemleri'),
'binary_lights':('Bilişim Teknolojileri ve Yazılım;Matematik','İkili sayısal temsil ve kodlama sezgisi'),
'cipher_wheel':('Türkçe;Bilişim Teknolojileri ve Yazılım','Metin üzerinde belirli kuralla dönüşüm ve çözümleme'),
'flowchart':('Bilişim Teknolojileri ve Yazılım;Türkçe','Süreç sırası ve akış diyagramı okuma'),
'logic_gate':('Bilişim Teknolojileri ve Yazılım;Fen Bilimleri','Mantıksal bağlaç ve elektrik devresi işlemleri'),
'pattern_machine':('Matematik;Bilişim Teknolojileri ve Yazılım','Aritmetik işlemlerin sırası ve fonksiyon fikri'),
'resource_plan':('Matematik;Teknoloji ve Tasarım','Sınırlı kaynakla çoklu hedef planlama'),
'sensor_lab':('Fen Bilimleri;Robotik Kodlama','Sensör verisine göre otomatik karar verme'),
'robot_course':('Robotik Kodlama;Teknoloji ve Tasarım','Algılayıcı, eyleyici ve program komutlarını birleştirme'),
'graph_path':('Matematik;Sosyal Bilgiler','Ağ yapısı, harita ve maliyetle rota bulma'),
'function_loops':('Bilişim Teknolojileri ve Yazılım;Görsel Sanatlar;Müzik','Tekrar kullanılabilir yordamlarla desen ve ritim oluşturma'),
'state_machine':('Bilişim Teknolojileri ve Yazılım;Fen Bilimleri','Olaylar ve durum geçişlerini modelleme'),
'data_detective':('Matematik;Fen Bilimleri','Veriyi sınıflandırma ve ölçüme göre yorumlama')}
IDX=json.loads((ROOT/'veri/levels/index.json').read_text())
f=ROOT/'veri/mufredat_eslesme.csv'
fields=['gorev_id','dunya','perde','gorev_sirasi','mekanik','oyun_ici_beceriler','taslak_sinif_araligi','onerilen_dersler','oneri_eslesme_aciklamasi','resmi_ogrenme_ciktisi_kodu','kod_dogrulama_durumu','ders_ve_sinif_kapsami_kesin_mi','kaynak_url']
with f.open('w',encoding='utf-8-sig',newline='') as out:
 w=csv.DictWriter(out,fieldnames=fields);w.writeheader()
 for i in IDX['missions']:
  lvl=json.loads((ROOT/i['file']).read_text());subj,desc=MAPPINGS[lvl['type']]
  w.writerow(dict(gorev_id=lvl['id'],dunya=lvl['world'],perde=lvl['act'],gorev_sirasi=lvl['order'],mekanik=lvl['type'],oyun_ici_beceriler=';'.join(lvl['concepts']),taslak_sinif_araligi='2-8',onerilen_dersler=subj,oneri_eslesme_aciklamasi=desc,resmi_ogrenme_ciktisi_kodu='',kod_dogrulama_durumu='DOĞRULANACAK',ders_ve_sinif_kapsami_kesin_mi='HAYIR',kaynak_url='https://mufredat.meb.gov.tr/programlar.aspx'))
print('Created 350 provisional curriculum links; 0 invented official codes')
