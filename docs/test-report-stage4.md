# Aşama 4 — Test ve Teslim Raporu

**Teslimin adı:** ALGORİTMA OYUNU / Kayıp Fenerin Sırrı / erken dikey dilim kaynak paketi.

**Şeffaf durum:** Kaynak proje, üç Godot GDScript bulmaca modülü, beş JSON görev, her görevin üç uyarlaması, çevrimdışı profiller / kayıt / yedek / iki dil ve menü-arayüz kodu vardır. **Gerçek Godot editöründe açılış veya oyun ekranı çalıştırılmamıştır. Bu yüzden dikey dilim henüz oynanabilir olarak doğrulanmış değildir.** Android APK, Windows EXE, Linux binary veya Pardus DEB *üretilmedi*.

## Çalıştırılan kontroller (mevcut ortam)

| Komut | Gerçek sonuç | Kapsam |
|---|---|---|
| `python -m unittest discover -s tests -p 'test_*.py' -v` | **10/10 PASS**, 0 fail | Kod/veri yapısı; Python tarafındaki sözleşme testleri |
| `python tools/validate_sources.py` | **PASS**: 5 görev, 15/15 tanık, 99 çeviri anahtarı, 0 hata | Godot kodu **çalıştırmadan** bağımsız oyun verisi oynatım testi |
| `godot --version` | **NOT AVAILABLE**: `godot: command not found` | Sürüm/engine yok |
| `godot --headless --path . --script res://tests/runner.gd` | **UNTESTED**: ikili yok | Gerçek Godot testleri çalıştırılamadı |
| `godot --headless --path . --script res://tools/validate_levels.gd` | **UNTESTED**: ikili yok | Engine içi witness doğrulaması çalıştırılamadı |
| `adb version` | **NOT AVAILABLE** | APK yüklü cihaz testi imkânsız |
| `java -version` | **AVAILABLE**: OpenJDK 21.0.12.1 | SDK mevcut olduğu anlamına gelmez |
| `dpkg-deb --version` | **AVAILABLE**: 1.22.22 | `.deb` üretildiği anlamına gelmez |
| Faz 1 GPU / OpenGL / etkileşimli tahta | **UNTESTED** | Gerçek cihaza erişim yok |
| Android Samsung A32 4G, gerçek dokunma, dosya seçici | **UNTESTED** | Gerçek cihaza erişim yok |
| Ekran görüntüsü/arayüz görsel QA, 16:9/4:3/portre | **UNTESTED** | Render edilmiş gerçek oyun penceresi yok |
| APK manifest INTERNET izni kontrolü | **UNTESTED** | APK yok; test aracı eksik kabul ediyor |

## Kısmi kabul ölçütleri

- [x] D1 ilk beş görev, her biri üç katmanda JSON düzeyinde ve bağımsız deterministik çözüm tanığıyla mevcut.
- [x] 3 farklı mekanik veri/görev alt yapısıyla kodlandı: `grid_route`, `signal_pattern`, `toggle_board`.
- [x] Türkçe/İngilizce CSV anahtarları eşleşiyor, her görevin benzersiz kısa başarı cümlesi var.
- [x] Üç ipucu anahtarı ve örnek çözüm çizgisi kodda var; puan düşürme yok.
- [x] Yerel profil, checksum ve yedekli kayıt, kayıt birleştirme, ayarlar ve dünya önizlemesi için GDScript kaynakları var.
- [ ] Godot 4.7.2 ile sahnenin hatasız açıldığı ve kodun derlendiği doğrulanmadı.
- [ ] Godot içinde ipucu/ayarlar/kayıt ve görsel akışların uçtan uca çalışması doğrulanmadı.
- [ ] Kullanıcının belirttiği Faz 1 / Samsung A32 donanımında testler yapılmadı.
- [ ] APK, EXE, Linux tar veya Pardus `.deb` üretilmedi.
- [ ] Gerçek oyundan alınmış ekran görüntüsü yok; üretilen PNG'ler **oyun varlığıdır, ekran görüntüsü değildir**.

## Açık teknik risk ve tasarım borcu

1. **En yüksek risk:** bazı Faz 1 GPU'lar Godot 4 Compatibility'nin OpenGL gereksinimini karşılamayabilir. Godot 3.6.x için ikinci oynatıcı ayrı kapsam kararı olacaktır.
2. Android SAF yerel dosya seçimi ile yedekleri dışa/içe aktarma gerçek cihazda sınanmadı; şu anda Godot `FileDialog` için kod mevcut.
3. Yazı tipi: Godot yerleşik fontu kullanılıyor; ayrı lisanslı disleksi fontu paketlenmedi. Türkçe glif/erişilebilirlik gerçek cihazda QA bekliyor.
4. Ses seviyesi ayarları saklanıyor; **ses dosyası/çalma henüz mevcut değil**. Dikey dilim sessiz.
5. D1 kalan 45 görev ve diğer 13 bulmaca modülü bu aşamaya ait değil.
6. GDScript'in gerçek derlenmesi/testi engellendiğinden hatasız çalışacağına dair garanti verilemez. Bir sonraki adım Godot 4.7.2 ile import ve headless test, ardından gerçek ekran QA.
7. Algoritma görevleri gerçek motor testine kadar prototip sayılır; Python `replay()` bir bağımsız modeldir, motorun kendisini test etmez.

## Taste / Ponytail özeleştiri

- Kıyı-fener resmi, başlangıç/engel/hedef sprite'ları özel kısıtlı paletle proje içinde oluşturuldu. Hazır ikon kolajı, mor-mavi SaaS gradyanı veya rainbow paleti yok.
- İlk beş görev içinde üç ayrı mekanik korunuyor; 16 boş modül açılmadı.
- UI kodu henüz bir ekranda *görsel olarak kontrol edilmiş* sayılmaz. Özellikle dar mobil portrede buton yoğunluğu, satır kayması ve tasarım hiyerarşisi gerçek render üzerinden değerlendirilmelidir.
- Başarı metinlerinin kopya görünmemesi için beş farklı mekanik/hikâye bağlamına özgü kısa cümle tanımlandı.

**Aşama 4 kabul sonucu: KISMİ.** Kaynak paket sağlandı; gerçek oyun koşucusuyla derleme, cihaz testi ve oynanabilirlik kanıtı henüz eksik.
