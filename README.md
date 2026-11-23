# ALGORİTMA OYUNU · D1 erken dikey dilim

**Durum:** Godot 4 kaynak projesi / deneysel dikey dilim. Resmî Android APK, Windows .exe veya Pardus .deb hazır değildir. Godot ikilisi bulunmayan geliştirme ortamında motor üzerinden derleme/test yapılamadı. Kurulum ve doğrulama adımları `BUILD.md` dosyasında.

## Oyuncu deneyimi

- İlk açılışta adsız `Oyuncu 1` profili açılır; form ve internet yoktur.
- D1 ilk beş görev: kıyı fenerine yol çizme (3 görev), optik işaret örüntüsü (1 görev), bağlı lamba anahtarları (1 görev).
- Her görev Somut Keşif / Bloklar / Sistem olarak üç parametre katmanında tanımlıdır (15 tanık çözüm).
- Komutları dokun/fareyle sıraya ekle, sonra `Işıkları gönder` düğmesiyle dene. Ok tuşları rota görevleri için; `Backspace` son komutu alır, `Enter` dener.
- Üç kademeli ücretsiz ipucu; son ipucunda örnek sıra görüntülenir.
- Dünya Atlası D1 oynanabilir, diğer altı dünya yalnızca önizlemedir.
- Yerel çoklu profil, çift kayıt slotu, JSON yedek dosyası ve ödül korumalı birleştirme altyapısı.
- Türkçe ve İngilizce CSV metinleri. Ekran tasarımında petrol yeşili/kum/kehribar ağırlıklı özgün piksel varlıkları.

## Kaynak

| Dizin | İçerik |
|---|---|
| `oyun/app` | başlangıç ve ekran akışı |
| `oyun/core` | yerel oyun servisleri, kayıt, profile, backup, dil |
| `oyun/modules` | üç farklı mekanik; 16'nın tümü henüz yok |
| `veri/levels/d1` | beş görev ve üç katmanlı çözüm tanıkları |
| `veri/locale` | iki dilin bütün kullanılan arayüz ve görev anahtarları |
| `varliklar/sprites` | özgün piksel varlıkları |
| `tests` | Godot testleri ve bağımsız Python kaynak testleri |
| `docs` | onaylı GDD, mimari ve test raporu |

## Bilinen sınırlamalar

Godot çalıştırıcısı bulunmadığı için GDScript sözdizimi/gerçek sahne/performans denetimi ve Android yedek dosyası SAF testleri henüz yapılamadı. Yerleşik font disleksi alternatifi değildir. Ekran okuyucu/seslendirme henüz yok. Paket/manifest testi ancak gerçek APK çıktısı ile mümkündür. Kodun bir donanım üzerinde çalıştığı iddia edilmez.
