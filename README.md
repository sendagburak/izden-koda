# ALGORİTMA OYUNU — Yedi Dünya Kaynak Sürümü (v0.5 önizleme)

**Durum: kaynak geliştirme teslimi; çalıştırılabilir uygulama olarak doğrulanmadı.**

2–8. sınıf öğrencileri için hesap, reklam, veri toplama, çevrimiçi bağlantı ve cezalandırıcı puanlama olmadan oynanması hedeflenen, Godot 4.7.2 Standard için geliştirilmiş fakat motor içinde henüz derlenmemiş Türkçe/İngilizce piksel sanat algoritma macerası.

## İçerik

- 7 dünya, her birinde 5 perde × 10 görev: **350 görev**.
- Görev başına 3 uyarlama katmanı: **1.050 önceden hazırlanan örnek çözüm**; Python referans modelinde doğrulandı.
- 16 bulmaca ailesi: rota, ışık örüntüsü, anahtar, sıralama, ikili gösterim, eğitimsel şifre, akış diyagramı, mantık kapısı, sayı dönüşümü, kaynak planı, sensör, robot rotası, ağırlıklı graf, yordamlar, durum makinesi, veri seçimi.
- İlk açılışta doğrudan görev, daha sonra ayarlanabilir zorluk katmanı, aynı cihazda çoklu yerel öğrenci profilleri.
- Üç aşamalı ücretsiz ipucu; son ipucunda örnek çözüm. Tamamlanan görev ve rozetler geri alınmaz.
- Dünya atlası, önizleme ve bağlantı görevi (önceki dünyanın 40. görevi sonrası yeni dünya açılır), 50 görevlik dünya listeleri.
- Günlük keşif, isteğe bağlı zaman göstergeli yarışma provası, otomatik çok ölçütlü sera proje atölyesi, serbest deneme, koleksiyon ve beceri haritası.
- Prosedürel özgün dünya arka planları, küçük karakter çizimleri, 7 kısa orijinal ses döngüsü ve 3 ses efekti.
- Yerel JSON profil/yedek; Windows/Linux/Android/Pardus dışa aktarma konfigürasyonu.
- 350 görev için **resmî kazanım kodu uydurulmamış** taslak Maarif eşleşme tablosu.

## Önemli teknik sınır

Godot çalıştırıcısı, export templates ve Android SDK bu çalışma ortamında mevcut olmadığından **GDScript henüz gerçek motor tarafından derlenmedi, sahneler oynanmadı, APK/EXE/DEB oluşmadı**. Python testleri Godot motoru yerine geçmez. Oyun grafiklerinin ve UI'nin görsel kalite testi; Android A32, düşük donanım Faz 1 tahtası, klavye/dokunmatik, yedek geri yükleme ve çevrimdışı APK manifest incelemesi gereklidir. Kodu çalıştırmadan “yayınlanmaya hazır” diye sunmuyoruz.

## Dosyalar

- `docs/GDD.md`: onaylanan oyun tasarımı.
- `veri/levels/d1`…`d7`: 350 görev ve üç katmanlı tanık çözümler.
- `oyun/modules`: 16 bulmaca GDScript modülü.
- `oyun/app/main.gd`: ana oyun arayüzleri ve mod akışları.
- `veri/locale`: tam TR/EN anahtar tabloları.
- `veri/mufredat_eslesme.csv`: 350 doğrulama bekleyen eşleşme.
- `varliklar`: özgün dünya/sprite/ses varlıkları.
- `tools`: veri, sanat ve müzik üretim/denetim betikleri.
- `tests`: Python veri kontrolleri + Godot engine için hazırlanmış testler.
- `BUILD.md`, `packaging/`: kurulum adımları ve hedef paketleme.

## Kaynak testleri

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/campaign_validator.py
python3 tools/validate_sources.py
```

Godot 4.7.2 ile gerçek test ve export için **[BUILD.md](BUILD.md)** dosyasını izleyin.
