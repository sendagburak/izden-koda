# ALGORİTMA OYUNU — Teknik Mimari ve Kalite Bütçesi

**Sürüm:** 0.1 — Aşama 3 / onay taslağı  
**Tarih:** 21 Kasım 2026  
**Tasarım temeli:** `ALGORITMA_OYUNU_GDD_v0.1.md` (kullanıcı tarafından onaylandı)  
**Çalışma adı:** ALGORİTMA OYUNU  
**Durum:** Yalnızca mimari tasarım; henüz Godot projesi kurulmadı, oyun kodu/derleme/test yapılmadı.

## 1. Temel mimari kararı: tek oyun motoru, 16 özgün oyun biçimi

**Seçilen tasarım:** Godot **4.7.2 stable** + **GDScript** + **Compatibility renderer**, tek yürütücü, **16 uzmanlaşmış bulmaca modülü**, görevleri veri olarak yükleyen ortak sistem. Her modülün oynanış kuralları ve sunumu özgün; profil, kayıt, erişilebilirlik, ödüller, ipucu aşamaları, dil, ses ve görev navigasyonu ortaktır.

**Bu, 16 ayrı Godot motoru veya birbirinden bağımsız 16 uygulama değildir.** 16 farklı oynanış ailesi kaybolmaz. Ponytail **full**, kod tekrarını ve gereksiz bağımlılıkları azaltma denetimi olarak kullanılacak; çalışan ve anlamlı bir mekaniği sırf satır azaltmak için kaldırmayacak.

Değerlendirilen alternatifler:

| Yaklaşım | Artı | Eksi | Karar |
|---|---|---|---|
| 16 bağımsız mini oyun/altyapı | Başlangıçta her birine özgürlük | Menü, kayıt, ipucu, input, çeviri ve hata mantığında tekrar; tutarlılık ve bakım riski | Reddedildi |
| Tek büyük jenerik bulmaca kodu ve tek sahne | Başlangıçta az dosya | Ayrışan mekaniklere sürekli koşul eklenir; tüm oyunlar aynı hisseder; test zorlaşır | Reddedildi |
| **Ortak çekirdek + 16 modül + gerektiği kadar ayrı UI** | Çeşitlilik ve test edilebilirlik; paylaşılan güvenlik ve erişim | Modül sözleşmesi ve regresyon testleri gerekir | **Seçildi** |

### 1.1 Gerçekten ne paylaşılır?

- Görevin `id` ile yüklenmesi ve şema doğrulaması; tek **PuzzleRunner** kontrolü.
- Metin dili, ipucu kullanım mantığı, profil, kaydetme, ödül kayıtları, navigasyon, erişilebilirlik ve kontrol eşlemeleri.
- Genel **Dene / Geri Al / İpucu / Çık** eylemleri ve yargılayıcı olmayan geri bildirim sözleşmesi.
- Her bulmaca modülünün *aynı görünmesi* **beklenmez**. Mekanik özgünlüğü sağlayan ekranlar ayrıdır; gerekli olanlarda özel sahne/çizim/girdi mantığı kullanılır.

### 1.2 Modüller ve mekanik farkları

| ID | Mekanik modül | Oyuncunun temel kararı | Doğrulama türü |
|---|---|---|---|
| `grid_route` | Fener Rotası | Komut rotası kur | Adım adım simülasyon + hedef |
| `block_bench` | Komut Tezgâhı | Blok sırala/yerleştir | AST/blok yorumlama + hedef |
| `clock_logic` | Çark Mantığı | Olay-zaman/durum zinciri | Ayrık olay simülasyonu |
| `debug_trace` | Hata Dedektifi | Sapmayı bul/düzelt | Önce-sonra çalışma izi |
| `sort_shelf` | Sıralama Rafı | Karşılaştırma/sıralama | Dizi değişmezi + hedef |
| `graph_routes` | Yol Haritası | Düğüm/kenar/rota seç | Grafik erişim ve hedef ölçütleri |
| `logic_circuit` | Devre Masası | Mantık bağlantısı kur | Doğruluk tablosu + simülasyon |
| `binary_panel` | İkili Işık Paneli | Bit desenini ayarla | Kod çözücü + hedef |
| `message_cipher` | Mesaj Dosyası | Eğitsel kod çözme | Dönüşüm ve anlam koşulu |
| `pattern_machine` | Girdi–Çıktı Makinesi | Örüntü/kural çıkar | Farklı örneklerle doğrulama |
| `flowchart` | Akış Şeması Masası | Akış bağlantısı seç | Kontrol akışı yorumlama |
| `balance_sim` | Denge Simülatörü | Parametre ve koşul ayarla | Çok durumlu deterministik model |
| `resource_plan` | Planlama Masası | Zaman/kaynak sıralaması | Kısıt tatmini |
| `sensor_course` | Algılayıcılı Parkur | Sensörlü program kur | Durum/ölçüm testi |
| `rhythm_pattern` | Ritim/Desen Makinesi | Fonksiyon/parametre/desen | Üretilen dizi ve özellikler |
| `code_notebook` | Kod Not Defteri | Sözde kod/metin komutu | Güvenli, sınırlı eğitim dili yorumlayıcısı |

**Güvenlik/performans:** Öğrenci metnini işletim sistemi kabuğunda, eval'de veya gerçek Python/JS motorunda çalıştırmayacağız. `code_notebook`, önceden tanımlanan sözdizimine sahip, adım limiti bulunan **küçük bir eğitim dili** kullanır. İleri kod editörüne dönüştürmek bu sürümün hedefi değildir.

**Ponytail denetimi:** Önce iki modül tamamlanıp ortaklıklar görülecek; yalnızca *gerçek tekrar* olursa ortak yardımcı çıkarılacak. Tek örneği olan `factory`, `interface` hiyerarşisi, harici DI, üçüncü taraf bulmaca framework'ü, analitik veya telemetri eklenmeyecek. Modüller aynı sözleşmeye uyar; gereken farklı veri yapısını kullanabilir.

## 2. Godot sürümü, grafik ve donanım sınırı

- **Sürüm kilidi:** Godot **4.7.2 stable** ve eşleşen export template sürümü. Godot 4.8 beta kullanılmaz. Yükseltme otomatik yapılmaz; test sonrası planlanır.
- **Dilin seçimi:** yalnızca GDScript (C#/Mono gereksiz paket/yükleme maliyeti taşır).
- **İlk çizim:** 2D Compatibility / OpenGL ES 3.0 Android, masaüstünde OpenGL 3.3 sınıfı; GPU tabanlı efekt, ağır shader ve parçacık yok.
- **Piksel sanat:** nearest-neighbor filtre, tutarlı piksel ızgarası ve uygun yerde tamsayı ölçek; yazı ve kontrol alanları gerçek ekran boyutuna göre ayrı UI katmanında uyarlanır. Tam ekranı her zaman tek sabit çözünürlüğe kilitlemek mobil dikey kullanımda doğru olmaz.
- **Oyun tabanı:** öneri 480×270 yatay görsel kompozisyon ve ayrı telefon dikey yerleşimi; gerçek ekranlarda okunurluk testinden sonra kesinleşir.
- **FPS:** düşük modda 30 FPS hedefi; normal modda 60 FPS hedefi. Oyun mantığı FPS'e bağlı olmayacak.
- **Çalışma belleği tasarım hedefi:** tek aktif bulmaca sahnesi için Android'de yaklaşık 256 MB veya altı; *ölçülmüş gerçek değil*.
- **APK boyutu tasarım hedefi:** 100–180 MB; *başlangıç hedefidir, motor ve varlıklar ölçülmeden garanti verilmez*. Uygulama çıkışı için tüm ek içerik bir pakete alındığında bütçe yeniden gözden geçirilir.
- **Asgari cihaz testi:** Samsung Galaxy A32 4G bandı; eski Faz 1 Pardus/ETAP etkileşimli tahta, 4:3, fare+dokunmatik+klavye.

### 2.1 Birinci risk kapısı: Faz 1 grafik desteği

Godot 4 Compatibility sürücüsünün OpenGL 3.3 gereksinimi, bazı Faz 1 tahtalardaki Intel HD Graphics 3000 / OpenGL 3.1 sınırıyla **çelişebilir**. Donanıma ilişkin bilgiler tek marka/modeli kapsamaz; sürücü farkı önemlidir. **Bu nedenle Faz 1'de çalıştığı söylenemez.**

**İlk teknik uygulama iş paketi:** hedef tahtanın CPU/GPU/Mesa/OpenGL bilgilerinin kaydı, Godot 4.7.2 boş sahne başlatma, 60 saniyelik sahne çizimi, dokunmatik ve çözünürlük kontrolü. Sonuç başarısızsa **daha fazla ürün kodu üretmeden** kullanıcıya iki seçenek sunulur: (a) Godot 4 ile desteklenen cihaz alt kümesine odaklanmak; (b) aynı JSON oyun verisiyle en eski tahtalar için ayrı **Godot 3.6.x** uyumluluk oynatıcısını ayrıca planlamak. İkinci seçenek yalnızca yeni onayla uygulanır; bu iki motoru baştan birlikte geliştirmeyiz.

**Android ARMv7/ARM64:** İki ABI tek APK yerine imzalı **ayrı arm32 ve arm64 APK** üretimi planlanır (yükleme boyutu ve test kolaylığı). Kullanıcının A32 sınıfı cihazında gerçek yükleme, ekran ve dokunma testi zorunlu. Oyun **INTERNET izni** istemeyecek.

## 3. Sorumluluklara göre dosya yapısı (öneri)

```text
algoritma-oyunu/
├─ project.godot
├─ README.md
├─ BUILD.md
├─ LISANSLAR.md
├─ docs/
│  ├─ GDD.md                         # onaylı GDD kopyası
│  ├─ teknik-mimari.md
│  └─ superpowers/plans/
│     └─ 2026-11-21-algoritma-oyunu-vertical-slice.md
├─ oyun/
│  ├─ app/main.tscn, main.gd         # ilk açılış ve durum geçişleri
│  ├─ core/puzzle_runner.gd          # modül seçimi, eylem, değerlendirme
│  ├─ core/puzzle_module.gd          # asgari modül sözleşmesi (extends RefCounted)
│  ├─ core/level_repository.gd       # JSON yükleme ve bağımsız kontrol
│  ├─ core/hint_service.gd           # ipucu kademesi
│  ├─ core/progress_rules.gd         # kapılar, kazanım, beceri olayları
│  ├─ core/save_store.gd             # atomik kayıt, yedek, migrasyon
│  ├─ core/backup_io.gd              # yerel dışa/içe aktarım, birleşim
│  ├─ core/settings_store.gd         # cihaz/yerel profil ayarları
│  ├─ core/locale_service.gd         # dil ve metin anahtarları
│  ├─ core/input_actions.gd          # dokun, fare, klavye eşleme
│  ├─ modules/
│  │  ├─ grid_route.gd
│  │  ├─ block_bench.gd
│  │  └─ ...                          # 16 modül; ihtiyaç zamanı
│  ├─ ui/atlas.tscn, atlas.gd         # dünya haritası ve önizlemeler
│  ├─ ui/mission.tscn, mission.gd     # ajan dosyası ve ortak HUD
│  ├─ ui/settings.tscn, settings.gd   # ayarlar ve çoklu profil
│  ├─ ui/guide.tscn, guide.gd         # üç aşamalı ipucu gösterimi
│  ├─ ui/puzzles/grid_route.tscn      # bulmaca ailesine özgü yüzey
│  └─ ui/puzzles/...                 # yalnız gerekenler
├─ veri/
│  ├─ levels/d1/01.json             # görev başına dosya; ilk dikey dilim
│  ├─ levels/index.json             # dünya/perde/bağlantı görevleri
│  ├─ locale/tr.csv, en.csv          # tüm oyuncu metinleri
│  └─ mufredat_eslesme.csv          # resmî kodlar yalnız doğrulananlar
├─ varliklar/
│  ├─ sprites/, ui/, audio/, fonts/
│  └─ license_index.csv
├─ tests/
│  ├─ runner.gd                      # Godot headless test çalıştırıcı
│  ├─ test_level_repository.gd
│  ├─ test_puzzle_runner.gd
│  ├─ test_grid_route.gd
│  ├─ test_save_store.gd
│  ├─ test_backup_io.gd
│  ├─ test_locale.gd
│  └─ test_progress.gd
├─ tools/
│  ├─ validate_levels.gd             # headless tüm görevleri tarar
│  └─ inspect_build.py               # standart kütüphane ile denetim
└─ packaging/
   ├─ export_presets.example.cfg     # imza anahtarı yok
   ├─ build.sh
   ├─ build.ps1
   └─ pardus/DEBIAN/control, pardus/algoritma-oyunu.desktop
```

**Not:** Ağaç **hedef** mimaridir; henüz bu dosyalar oluşturulmadı. Her 16 modülün klasörünü önceden boş olarak açmayacağız. Bir modül ilk gerçek görevle birlikte gelecek.

## 4. Modül sözleşmesi ve veri akışı

Godot'ta tek bir `PuzzleRunner` görev ID'si alır → `LevelRepository` ile görev sözlüğünü okur → `type` değerine göre kayıtlı `PuzzleModule` örneğini seçer → başlangıç durumunu oluşturur → kullanıcı eylemleri modüle gider → modül yeni durum + olay/geri bildirim döndürür → `ProgressRules` yalnız **geçerli başarıyı** kaydeder → `SaveStore` güvenli kaydeder. UI, kayıt dosyalarını veya görev JSON'unu doğrudan değiştirmez.

**Modül asgari API (GDScript imzaları; implementasyon henüz yok):**

```gdscript
# oyun/core/puzzle_module.gd — soyut sözleşme, yalnız plan
extends RefCounted

func validate_level(level: Dictionary) -> PackedStringArray
func create_state(level: Dictionary, layer: String) -> Dictionary
func apply_action(level: Dictionary, state: Dictionary, action: Dictionary) -> Dictionary
func evaluate(level: Dictionary, state: Dictionary) -> Dictionary
func explain_hint(level: Dictionary, state: Dictionary, tier: int) -> Dictionary
func verify_witness(level: Dictionary, layer: String) -> bool
```

Sözleşme: `apply_action` sonucu `{state: Dictionary, events: Array}`; `evaluate` sonucu `{met: bool, criteria: Dictionary, evidence: Array}`; `explain_hint` sonucu çevrilebilir metin anahtarı ve isteğe bağlı gösterim adımları. `state` JSON uyumlu, görevler deterministik. Rastgele seçim varsa `seed` seviyede/profilde açıkça belirtilir. Eylemler bir test günlüğünden tekrar oynatılabilir.

**Özel düzeltme:** Her modülün kendine özgü `solve()` ile en iyi çözümü otomatik üretmesi şart değil. Bunun yerine her görev ve her sınıf katmanı için `witness` (başarıyı sağlayan en az bir örnek eylem izi) bulunur. Doğrulayıcı bu izi **gerçek modül simülasyonunda yeniden yürütür**; ardından hedef ölçütlerinin sağlandığını doğrular. Açık uçlu görevlerde en az bir tanık tasarım her otomatik kriteri birlikte sağlamalı; alternatif yaratıcı çözümler de kabul edilir. Böylece 16 ayrı tam çözüm arama algoritması yazılmadan *gerçek çözülebilirlik tanığı* denetlenir. Bu, tüm olası çözümleri listeleme iddiası değildir.

### 4.1 Görev veri şeması: sürümlendirilmiş JSON

```json
{
  "schema_version": 1,
  "id": "d1-p1-001",
  "world": "d1",
  "act": 1,
  "order": 1,
  "type": "grid_route",
  "concepts": ["sequence", "direction"],
  "locale_key": "mission.d1_p1_001",
  "hints": ["hint.d1_p1_001.1", "hint.d1_p1_001.2", "hint.d1_p1_001.3"],
  "layers": {
    "concrete": {"params": {}, "witness": []},
    "blocks": {"params": {}, "witness": []},
    "system": {"params": {}, "witness": []}
  },
  "rules": {},
  "goal": {},
  "unlock": []
}
```

Bu JSON **alan sözleşmesi örneğidir**, oynanabilir bir görev veya geçerli çözülebilirlik tanığı değildir. Gerçek örnek görev, ilk testle birlikte yazılacak. Her `witness` sonradan eylem formatında doldurulacak. `layers` aynı görev kimliği ve kazanılmış ilerlemeyi paylaşır; katmanlar üç kat daha fazla ana görev sayılmaz.

`veri/levels/index.json`: görünürlük, önerilen sıra, **Bağlantı Görevi** açma eşiği, yan yol ve her görev kimliği. Bağlantı görevleri 350 ana görev içinde işaretlenir (ayrı 7 yeni zorunlu görev icat edilmez).

**Doğrulama zinciri:** JSON biçimi → şema sürümü → benzersiz ID → çeviri/hint anahtarları → ekran/görev sınırı → tüm katmanlarda tanık eylem izi → başarı ölçütleri → açılma grafiğinde en az bir ulaşılır rota → kullanıcı metninde sakınılan dil. `veri/mufredat_eslesme.csv` doğrulanmamış kodu doldurmaz; doğrulama durumu ayrı tutulur.

## 5. Güvenli kayıt, yerel profil ve yedek

- `user://profiles/<opaque_id>/save.json` asıl kayıt, `save.bak.json` son **doğrulanmış** yedek ve `save.tmp` yazım dosyası. Profillerin adları dosya yolu olmaz. Makineye özgü kullanıcı hesabı yok; cihazda rastgele yerel profil ID'si.
- Kaydın içinde `schema_version`, `generation` (monoton artan), `profile_id`, `completed_ids`, `reward_ids`, `unlocked_worlds`, `skill_events`, `settings` ve `checksum` bulunur.
- **Yaz:** JSON serileştir → geçici dosyaya yaz + `flush` + kapat → geçici dosyayı yeniden açıp şema/checksum kontrolü → varsa doğrulanmış eski kaydı yedeğe döndür → geçici dosyayı asıl dosya olarak yeniden adlandır. Başarısız işlemde doğrulanmış kayıt silinmez. *Dosya sistemi güç kesintisinin tüm olasılıklarına sıfır kayıp garantisi yoktur*.
- **Oku:** asıl dosyayı doğrula; hatalıysa `.bak` doğrula; ikisi de sağlamsa en yüksek `generation` geçerli olanı kullan; kötü kayıt bulunduğunda kullanıcı ilerlemesine dokunmadan kurtar. Şema ileri sürüm ise üzerine yazıp bozmadan uyar.
- **Migrasyon:** Her eski `schema_version` → bir sonraki sürüme açık dönüşüm fonksiyonu, var olan tamamlamalar ve ödüller korunur. Sınıf/layer değişimi ilerleme sıfırlamaz.
- **İçe aktarma:** Geçerli dosya / sınırlandırılmış boyut / checksum / `profile_id` eşleşmesi kontrolü. Aynı profilde tamamlamalar ve kazanımlar küme birleşimiyle korunur; eski kayıttaki daha yeni ama farklı tercihler için kullanıcıya net seçenek gösterilir. Aynı adlı farklı ID'li profiller **otomatik** birleştirilmez; ayrı profil olarak içe alınır.
- **Elle aktarım:** Masaüstünde yerel dosya seçici; Android 10+ üzerinde Godot `DisplayServer.file_dialog_show` ve **Storage Access Framework** aday. Android'deki gerçek `content://` URI ile okuma/yazma, iki farklı Android sürümünde doğrulanmadan 'çalışıyor' denmez. Başarısızsa ikinci kullanıcı yolu tasarlanır; pahalı eklenti otomatik eklenmez.
- **Otomatik kayıt:** Görev tamamlanınca, profil değiştirilince, uygulama arka plana gidince ve güvenli çıkışta. Oyun içi 'sıfırla' işlevi yok. Güncel görev denemesinin ara durumunu da güvenli kontrol noktasında saklama stratejisi.

**Koruyucu testler:** eksik JSON, yarım yazılmış JSON, bozuk checksum, gelecekteki şema sürümü, iki aynı isimli profil, iki dosyada aynı ödül, kayıt içe aktarma çatışması, disk dolu/yazma hatası simülasyonu, eski veriye migrasyon, işlem yarıda kesilmesi.

## 6. Erişilebilirlik, dil ve oyun etiketi

- **Dil:** `tr.csv` ve `en.csv`; görev adı, seçenekler, geri bildirimler ve erişilebilirlik etiketleri anahtarlarla bağlanır. İkinci dilde eksik anahtar varsa otomatik test başarısız olur. Türkçe karakter görüntüleme gerçek fontla denetlenir. Metin dışındaki açıklama ikonları yerelleştirilebilir.
- **İpucu:** `1/2/3` kademeleri; kullanım ne puanı ne rozeti azaltır, sonsuz deneme. İpucu için aileye özgü görsel yönlendirme mümkün; sözleşme tek.
- **Girdi:** seç-yerleştir ve sürükle-bırak eşdeğer; tam klavye erişimi ve görünür odak; Android dokunma hedefi öneri ≥48 dp, etkileşimli tahta için büyük kontrol.
- **Görme/okuma:** renge tek başına bağımlı bilgi yok; şekil/desen/etiket, yazı ölçeği, yüksek kontrast, renk görme varyantları, okunaklı alternatif font, azaltılmış hareket; ses ayrı ayarlarla kapanır. Sesli anlatım zorunlu değil.
- **Dil kontrolü:** Öğrenciye `yanlış`, `kaybettin`, `game over`, kırmızı ceza/sarsıntı yok. İpucu cümleleri bağlama özgü. Süre yalnız yarışma simülasyonunda isteğe bağlı.
- **İlk açılış:** yerel `Oyuncu 1` oluşturulur ve D1 P1 001'e girilir; isim, sınıf, kayıt formu ve internet istemi yok.

## 7. Ekran/sahne akışı ve otomatik test

```text
Main (ilk açılış → doğrudan D1/001)
 ├─ Atlas (D1 açık; D2–D7 önizleme)
 ├─ MissionScreen (ajan dosyası)
 │   ├─ PuzzleRunner (tip → modül → aileye özgü PuzzleView)
 │   └─ HintGuide (kademeler, yönlendirme)
 ├─ Skills / Rewards (Aşama 4'te minimal yer tutucu, Aşama 6'da tam)
 └─ Settings (dil, profil, erişim, kayıt dışa/içe)
```

**Godot araçları:** `--headless --path . --script res://tests/runner.gd` ile çalışabilen üçüncü taraf bağımlılıksız küçük test koşucusu. GDD'nin istediği testlerin tamamı sonraki aşamalarda eklenir. Her test başarısızlığında `exit code != 0`; 'PASS' yalnız komut çıktısı ile raporlanır.

**Aşama 4 dikey dilim testleri:** görev JSON ve üç katman, D1 ilk beş görevin her birine oynanabilir çözüm tanığı, yerelleştirme, ipucu kademeleri, sınıf değiştirme, bağlantı görünürlüğü, çoklu profil izolasyonu, kayıt bozma/yedekten geri alma, içe aktarmada kazanım korunması, ağ izni denetimi, klavye + dokunmatik manuel kontrol, düşük mod ve gerçek FPS/MB/çözünürlük ölçümü.

**Aşama 5:** her dünya + 50 görev + tanık doğrulama; 16 modül *gerektikçe* eklenir. Önce D1 için `grid_route`, `block_bench`, `pattern_machine`, `debug_trace` içinden gerçekten ilk beş görevin kullandıkları uygulanır. Boş modül oluşturulmaz.

## 8. Derleme ve dağıtım hattı

- `packaging/build.sh` (Linux/macOS), `packaging/build.ps1` (Windows): Godot sürümü ve export templates kontrolü → testler → görev/çeviri validasyonu → platform export → paket → rapor. Üretim anahtarları repoya yazılmaz.
- **Android:** ayrı arm32/arm64 APK için export preset; debug ve release imzası; `aapt dump permissions` veya eşdeğer arşiv incelemesiyle **`android.permission.INTERNET` bulunmadığını kanıtla**. Depolama izinleri 'her dosyaya erişim' olarak genişletilmez; mümkün olduğunca SAF.
- **Windows:** 64-bit taşınabilir klasör/ZIP, gerekirse gerçek ihtiyaç doğrulanırsa 32-bit hedef. Kayıt konumu varsayılan `user://`; taşınabilir klasör içi kayıt isteğe bağlı, eşitleme/çakışma riskleri belgelenecek.
- **Linux/Pardus:** x86_64 taşınabilir `tar.gz`; Pardus için gerekli mimariye uygun `.deb`, `DEBIAN/control`, `.desktop`, simge ve kurulum/kaldırma adımları. Düşük Faz 1 CPU/GPU doğrulaması ambalajdan önce gelir.
- **Boyut denetimi:** her dağıtımda motor tabanı, grafikler, sesler ve içerik boyutu raporlanır. Aynı büyük sprite'ın gereksiz kopyaları ve kullanılmayan varlıklar dışlanır. Uygulama içi performans modunu ayrı kurulum paketine dönüştürmeyiz.
- **Lisans:** paket içindeki her görsel/font/ses için `LISANSLAR.md` ve `varliklar/license_index.csv`; yalnız özgün veya açıkça izinli varlıklar. Herhangi bir özel harici API anahtarı yok, çalışma anında ağ çağrısı yok.

## 9. Aşama geçitleri ve kabul ölçütleri

| Kapı | Tamamlanmış kabul ölçütü | Kimin kararı? |
|---|---|---|
| **Aşama 3 onayı** | Bu mimari + uygulama planı değerlendirildi | Kullanıcı |
| **H0 Donanım sınaması** | Faz 1 GPU/OpenGL, gerçek başlatma/dokunma ve A32 profili raporlandı; olmazsa alternatif seçenek | Test kanıtı + kullanıcı kapsam kararı |
| **Aşama 4 dikey dilim** | D1 ilk 5 görev, üç katman, profil/kayıt/ipuçları/ayarlar ve otomatik testler çalışır | Kullanıcı |
| **Aşama 5 her dünya** | 50 özgün görev, tanıklar, çeviriler, alan kontrolü ve test raporu | Her dünya sonunda kullanıcı |
| **Aşama 6 modlar** | Günlük keşif, yarışma, STEM, serbest atölye, koleksiyon; veri/erişim testleri | Kullanıcı |
| **Aşama 7 paketler** | Android, Windows, Linux ve Pardus dosyaları; gerçek build/test ve lisans/izin denetimi | Kullanıcı |

### Açık riskler / kesin olmayan sayılar

1. **Faz 1 tahtalar:** Masaüstü OpenGL 3.3 koşulunu sağlamayabilir. Gerçek donanım testi olmadan garanti yok.
2. **Android `content://` aktarımı:** Godot 4.7.2/API 29+ için belge desteği vardır; seçilen cihaz ve işletim sisteminde mutlaka test edilmelidir.
3. **350 görev, 16 modül ve üç uyarlama katmanı:** Hepsinin özgünlüğü, erişilebilirliği ve tanık çözülebilirliği içerik üretimi sırasında tek tek doğrulanmalıdır.
4. **Boyut, RAM ve FPS hedefleri:** Öneri bütçelerdir; ölçüm yapılmadı.
5. **Pardus `.deb` ve APK imzası:** Çalıştırılabilir üretim ortamı ve gerçek test cihazı şu anda mevcut değil.
6. **Müfredat kodları:** Onaylanmamış kodlar üretime girmeyecek; ayrı CSV'de doğrulama statüsü tutulacak.

## 10. Kanıt ve kaynaklar

- Godot 4.7.2 stable (18 Ağustos 2026): https://godotengine.org/article/maintenance-release-godot-4-7-2/
- Godot sistem gereksinimleri: https://docs.godotengine.org/en/stable/about/system_requirements.html
- Android export ve ABI seçimleri: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Android/masaüstü yerel dosya seçici ve SAF: https://docs.godotengine.org/en/stable/classes/class_displayserver.html
- Godot FileAccess: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html
- Yürürlükteki onaylı tasarım: `ALGORITMA_OYUNU_GDD_v0.1.md`
- Üst talimat: `algoritma_oyunu_chatgpt_prompt.md`

## Aşama 3 durum bildirimi

**Hazırlandı:** teknik mimari, modül sözleşmesi, görev verisi, profil/kayıt, doğrulama ve dağıtım stratejisi.  
**Gerçekten test edildi:** bu dokümanın yapısal bütünlüğü kontrol edilecek; oyun veya derleme testi **yapılmadı**.  
**Bilinen sorun:** gerçek Faz 1 ve Android cihaz testleri uygulama sırasında zorunlu.  
**Sıradaki adım:** Kullanıcı Aşama 3'ü onaylarsa H0 teknik uyumluluk sınaması ve Aşama 4 dikey dilim görevleri. Onay olmadan oyun kodu yazılmayacak.
