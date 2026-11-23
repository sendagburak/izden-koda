# ALGORİTMA OYUNU — Dikey Dilim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Onaylanmış GDD'ye göre D1'in ilk beş görevini, açılış akışını, güvenli çoklu yerel profili, üç kademeli ipucunu, Türkçe/İngilizceyi ve ayarları Godot 4.7.2'de uçtan uca çalıştıran Aşama 4 dikey dilimi hazırlamak.

**Architecture:** Tek Godot oyun motoru + ortak görev yürütücüsü + yeni mekanik ortaya çıktıkça eklenen 16 bulmaca modülü. JSON görevler ve üç uyarlama katmanı ayrı, çeviri tabloları ayrı; güvenli yerel profil kaydı bir merkezî bileşen üzerinden. Ponytail *full*: tekrarı azalt, gereksiz bağımlılık ve boş mimari oluşturma; oyun mekaniklerini azaltma.

**Tech Stack:** Godot 4.7.2 stable, GDScript, Compatibility renderer, yerel JSON, PO/CSV, standart Godot test runner; dış paket/SDK yalnız dağıtım sırasında ve yalnız gereken platform için.

**Spec:** `ALGORITMA_OYUNU_GDD_v0.1.md` (onaylı) ve `ALGORITMA_OYUNU_Teknik_Mimari_v0.1.md` (Aşama 3 taslağı; bu planla birlikte onaya sunuluyor).

## Global Constraints

- 2–8. sınıflar, yedi dünya, 350 ana görev: **yalnızca D1/ilk 5 görev** bu planın ürün kapsamı; geri kalan 345 ve diğer modlar sonraki aşamalara aittir.
- İlk açılış doğrudan görev; hesap, internet, reklam, premium, analitik, telemetri, kullanıcı kaydı formu yok.
- Android `INTERNET` izni kesinlikle yok. Android arm32/arm64 hedefi, Windows taşınabilir, Linux taşınabilir, Pardus `.deb` dağıtım planı korunur.
- Kullanıcı dostu hata dili, üç ücretsiz ipucu, sınırsız deneme, ödül/ilerleme kaybı olmaması, çoklu yerel profil ve güvenilir kayıt zorunlu.
- Görünüm: tutarlı piksel sanat, Godot varsayılan skin'i değil; renk körlüğü/klavye/dokunma erişimi başlangıçtan itibaren.
- Görevler bütün sınıf uyarlama katmanlarında tanık çözümle doğrulanmalı; resmî Maarif kodu doğrulanmadan doldurulmaz.
- Faz 1 grafik uyumsuzluğu **yüksek risk**, donanım denemesi veya açıkça kaydedilmiş bloklayıcı bulgu olmadan platform desteği vaat edilmez.
- Her bağımsız görevde kırmızı→yeşil test döngüsü, sonunda anlamlı Git commit ve kanıtlı rapor; gerçekleştirilemeyen test açıkça yazılır.

## Review Focus

1. **Kaydetme anında güç kesintisi / bozuk asıl dosya:** en son **geçerli** yedeğe dönüş, ödül silinmemesi (Task 5 testleri).
2. **Benzer adlı iki öğrenci:** ayrı profil kimliğiyle izolasyon ve çakışmayan geri yükleme (Task 6 testleri).
3. **Sınıf katmanı değiştirilmesi:** görev başarısı/ödül korunur; etkin katman değişir ve geçerli çözüm tanığı bulunur (Task 3 ve 8).
4. **Herhangi bir çeviri/hint anahtarının kaybolması:** dağıtımda test hatası, varsayılan olarak anahtar kodu ekrana basılmaz (Task 4 ve 8).
5. **Düşük RAM/dar portre/dokunmatik + klavye:** oyun alanı görünür, kontrol ve geri dönüş ulaşılabilir, sürükle-bırak zorunlu değil (Task 8 ve 9).

---

## Uygulama öncesi bağımlılıklar

- Kullanıcının **Aşama 3 plan onayı** alınacak. Plan onayı, uygulamanın tamamlandığı anlamına gelmez.
- H0 donanım kapısı, gerçek Faz 1 tahtada erken çalıştırılacak; uzaktan erişim yoksa test **yapılmadı** olarak kaydedilip bloklayıcı olarak kullanıcıya bildirilecek.
- Bu işin başlaması ile resmî Maarif kodları üretime alınmaz. Müfredat eşleşmesi ayrı dosyada **DOĞRULANACAK** kalır.

## Task 0 — Donanım ve sürüm uygulanabilirlik kapısı

**Files:**
- Create: `docs/hardware-feasibility.md`
- Create: `packaging/README-tools.md`

**Interfaces:** Donanım bilgileri ve test logu; kod üretimine bağımlı değil. Beklenen GPU özellikleri, Godot 4.7.2 sürümü, Android ABI ve SDK varlığı dokümante edilir.

- [ ] **Step 1: Godot ve destek araçlarının yerel varlığını kaydet.** `godot --version` (veya `godot4 --version`) ile Godot 4.7.2; `adb version`, `dpkg-deb --version`, Android SDK/Java sürümleri; yoksa açıkça `NOT AVAILABLE` kaydı.
- [ ] **Step 2: Gerçek Faz 1 tahtada OpenGL denetimi.** `glxinfo -B` / sistem araçlarıyla renderer ve OpenGL sürümünü belgele. Erişim yoksa `UNTESTED` yaz; kullanıcıdan test erişimi gerekeceğini bildir.
- [ ] **Step 3: Godot 4.7.2 Compatibility başlangıç/etkileşim sınaması.** Yalnızca **onay sonrası** geçici/sökülebilir boş sahne kullan; başlatma, dokunmatik, çözünürlük ve 60 saniye akıcılığı kaydet. Başarısızsa GDD'de belirtilen alternatifleri ayrı onaya getir.
- [ ] **Step 4: `docs/hardware-feasibility.md` test çizelgesini tamamla.** İçerik: cihaz adı, CPU/GPU, grafik sürümü, OS, Godot, test komutu, gözlem, PASS/FAIL/UNTESTED ve desteklenen hedefler.
- [ ] **Step 5: Doküman değişikliklerini commit et.** `git add docs/hardware-feasibility.md packaging/README-tools.md && git commit -m "docs: record hardware feasibility gate"`.

**Accept:** Gerçek cihaz sonuçları ile masa başı varsayımlar ayrıdır; Faz 1 riski görünürdür.

## Task 1 — Çalışır Godot çekirdeği ve bağımlılıksız test koşucusu

**Files:**
- Create: `project.godot`
- Create: `oyun/app/main.tscn`, `oyun/app/main.gd`
- Create: `tests/runner.gd`, `tests/test_boot.gd`
- Create: `README.md`, `.gitignore`

**Interfaces:** `tests/runner.gd` tek tek test scriptlerini çalıştırır ve hata sayısına göre `get_tree().quit(code)` verir. Dış test paketi eklenmez.

- [ ] **Step 1: Testi yaz (`tests/test_boot.gd`).** `ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility"` veya Godot 4.7.2'nin geçerli Compatibility ayarı; ana sahnenin `ResourceLoader.exists("res://oyun/app/main.tscn")` olması; yerel test runner'ın çıktısının `PASS test_boot` olmasını doğrular.
- [ ] **Step 2: Boş projede kırmızı test al.** Çalıştır: `godot --headless --path . --script res://tests/runner.gd` (yerel binary adına göre). **Beklenen:** test/ana sahne yokluğuna bağlı başarısızlık.
- [ ] **Step 3: En az kodla oyun projesini ve runner'ı kur.** Başlangıçta açılış menüsü/onboarding yok; yalnız ilk göreve yönlendiren yükleme durumu. Demo UI varsayılan Godot skin'iyle kalıcı bırakılmaz.
- [ ] **Step 4: `godot --headless --editor --path . --quit` ile kaynakları import et ve test komutunu çalıştır.** **Beklenen:** exit 0, `PASS test_boot`.
- [ ] **Step 5: Commit.** `git add project.godot oyun/app tests/runner.gd tests/test_boot.gd README.md .gitignore && git commit -m "feat: bootstrap offline godot game"`.

## Task 2 — Görev deposu, ortak yürütücü, minimal modül sözleşmesi

**Files:**
- Create: `oyun/core/level_repository.gd`, `oyun/core/puzzle_module.gd`, `oyun/core/puzzle_runner.gd`
- Create: `tests/test_level_repository.gd`, `tests/test_puzzle_runner.gd`
- Create: `veri/levels/index.json`

**Interfaces:**
- `LevelRepository.load_level(level_id: String) -> Dictionary` (başarısızsa boş sözlük + tanımlı hata)
- `LevelRepository.validate_level(level: Dictionary) -> PackedStringArray`
- `PuzzleRunner.open(level: Dictionary, layer: String) -> bool`
- `PuzzleRunner.submit(action: Dictionary) -> Dictionary`
- `PuzzleRunner.get_result() -> Dictionary`
- Modül: `validate_level`, `create_state`, `apply_action`, `evaluate`, `explain_hint`, `verify_witness` (mimari doküman §4)

- [ ] **Step 1: Testleri yaz.** Yinelenen ID, eksik alan, bilinmeyen `type`, geçersiz `layer` reddedilir; modüle tanımlı bir eylem gönderildiğinde `{state, events}` biçiminde sonuç döner. Başarı yalnız `evaluate().met` koşulunda.
- [ ] **Step 2: Runner ile kırmızı test al.** **Beklenen:** sınıflar/indeks yok.
- [ ] **Step 3: Minimum kayıt tablosunu ve JSON yüklemeyi yaz.** `type` → gerçek modül bağlantısı; varsayılan switch içinde 16 boş dal açma. Şema sürümü/kimlik denetimi tek yerde.
- [ ] **Step 4: Runner ile yeşil test al.** **Beklenen:** `PASS test_level_repository` ve `PASS test_puzzle_runner`.
- [ ] **Step 5: Commit.** `git add oyun/core veri/levels/index.json tests && git commit -m "feat: add data driven puzzle runner"`.

## Task 3 — D1 oyun mekaniği ve üç uyarlama katmanı

**Files:**
- Create: `oyun/modules/grid_route.gd`
- Create: `oyun/ui/puzzles/grid_route.tscn`, `oyun/ui/puzzles/grid_route.gd`
- Create: `tests/test_grid_route.gd`, `tests/test_layer_adaptation.gd`
- Modify: `oyun/core/puzzle_runner.gd` (modül kayıt listesi)

**Interfaces:**
- `GridRoute` → `PuzzleModule` sözleşmesi.
- `PuzzleRunner.open(level, "concrete" | "blocks" | "system")` aynı `level.id` için farklı görünür zorluk ayarlarını uygular.
- `verify_witness(level, layer) -> bool` belirtilen katmanın eylem izini **gerçek simülasyonla** oynatır.

- [ ] **Step 1: Testleri yaz.** Haritanın dışına çıkan adım güvenle reddedilir; geçerli komut izi hedefe ulaşır; yanlış sıra olumlu keşif mesajı verir ama görev tamamlanmaz; `concrete`, `blocks`, `system` katmanlarının tanığı geçerlidir.
- [ ] **Step 2: Kırmızı test al.** **Beklenen:** `GridRoute` mevcut değil.
- [ ] **Step 3: Tek deterministik ızgara yürütücüsü ve dokun-seç komut arayüzünü uygula.** Bu aşamada sürükle-bırak yalnız alternatif olabilir, tek zorunlu kontrol değil. Kod/arayüz birlikte test edilebilir.
- [ ] **Step 4: Yeşil test ve aynı eylem izini iki kez tekrar oynatma testi.** **Beklenen:** deterministik eş sonuç.
- [ ] **Step 5: Commit.** `git add oyun/modules/grid_route.gd oyun/ui/puzzles tests && git commit -m "feat: grid route puzzle with adaptations"`.

## Task 4 — D1 ilk 5 özgün görev, tanık doğrulama ve iki dil

**Files:**
- Create: `veri/levels/d1/01.json` ... `05.json`
- Create: `veri/locale/tr.csv`, `veri/locale/en.csv`
- Create: `oyun/core/locale_service.gd`, `oyun/core/hint_service.gd`
- Create: `tools/validate_levels.gd`, `tests/test_locale.gd`, `tests/test_hints.gd`, `tests/test_d1_first_five.gd`
- Modify: `veri/levels/index.json`

**Interfaces:**
- `LocaleService.text(key: String, language: String) -> String`
- `HintService.get_hint(level: Dictionary, tier: int) -> Dictionary` (`tier` 1..3)
- `validate_levels.gd` bütün 5 × 3 görev katmanı tanıklarını modül simülasyonuyla doğrular, başarısızlıkta exit!=0.

- [ ] **Step 1: Başarısız testler yaz.** 5 benzersiz görev, farklı mekân/engel/kısıt; her biri için 3 katmanda geçerli tanık; bütün görev/hint/arayüz anahtarları TR+EN; tier 1..3 var ve ipucu hiçbir ödülü silmez.
- [ ] **Step 2: Kırmızı test al.** **Beklenen:** eksik JSON veya dil anahtarı.
- [ ] **Step 3: İlk beş görevi ve kısa doğal çeviri metinlerini yaz.** İlk beş görevin hepsini zorla aynı aileye koyma: GDD D1 ilk perde kapsamında farklı mekanik gerektiğinde Task 4 öncesi küçük bir `pattern_machine` veya `block_bench` modülü için **ayrı küçük TDD görevi** aç; ortak bir modülde anlamsız koşullar biriktirme.
- [ ] **Step 4: Doğrulama komutlarını çalıştır.** `godot --headless --path . --script res://tests/runner.gd` ve `godot --headless --path . --script res://tools/validate_levels.gd`. **Beklenen:** 5 level / 15 layer, 0 çözümsüz görev, 0 kayıp çeviri anahtarı.
- [ ] **Step 5: Commit.** `git add veri oyun/core/locale_service.gd oyun/core/hint_service.gd tests tools && git commit -m "feat: first five solvable bilingual missions"`.

## Task 5 — Çoklu yerel profiller ve bozulmaya dayanıklı kayıt

**Files:**
- Create: `oyun/core/save_store.gd`, `oyun/core/profile_store.gd`, `oyun/core/progress_rules.gd`
- Create: `tests/test_save_store.gd`, `tests/test_progress.gd`, `tests/test_profile_store.gd`

**Interfaces:**
- `SaveStore.read_profile(profile_id: String) -> Dictionary`
- `SaveStore.write_profile(profile: Dictionary) -> bool`
- `ProfileStore.create_default() -> Dictionary`, `list_profiles() -> Array`, `switch_profile(id: String) -> bool`
- `ProgressRules.mark_complete(profile: Dictionary, level_id: String) -> Dictionary`
- Testlerin sandbox yolu `user://tests/<run-id>/` ile gerçek oyuncu verisinden yalıtılır.

- [ ] **Step 1: Kırmızı testleri yaz.** Yeni cihazda adsız `Oyuncu 1` otomatik; iki profilin aynı adlı olması ilerlemeyi karıştırmaz; aynı görevin iki kez bitirilmesi tek tamamlanma; ödül geri alınmaz; bozuk `save.json` sağlam `save.bak.json` ile açılır; eski sürüm migrasyonu ilerlemeyi silmez; beklenmedik sürüm bozulmadan korunur; disk yazma hatası eski geçerli kaydı yok etmez.
- [ ] **Step 2: Testlerin başarısızlığını doğrula.** **Beklenen:** kayıt bileşenleri eksik.
- [ ] **Step 3: `tmp` yaz/flush/doğrula/rename + doğrulanmış yedek + generation + checksum uygula.** Bir veri kaybı kenar durumunu tek satır kazanmak için es geçme. Migrasyon yalnız gerekli `v0→v1` örneğiyle başlar; daha sonraki sürümler gelecekte eklenir.
- [ ] **Step 4: Testleri çalıştır.** **Beklenen:** tüm `test_save_store`, `test_progress`, `test_profile_store` geçer; temp test kayıtları asıl kullanıcı dosyasına yazılmaz.
- [ ] **Step 5: Commit.** `git add oyun/core/save_store.gd oyun/core/profile_store.gd oyun/core/progress_rules.gd tests && git commit -m "feat: safe offline profiles and progression"`.

## Task 6 — Yerel yedek dışa/içe aktarma ve korunarak birleştirme

**Files:**
- Create: `oyun/core/backup_io.gd`, `tests/test_backup_io.gd`
- Modify: `oyun/core/save_store.gd` (yalnız gerekiyorsa)

**Interfaces:**
- `BackupIO.export_profile(profile: Dictionary, path: String) -> bool`
- `BackupIO.import_profile(path: String, existing_profiles: Array) -> Dictionary`
- `BackupIO.merge_same_identity(local: Dictionary, incoming: Dictionary) -> Dictionary`

- [ ] **Step 1: Kırmızı testleri yaz.** Eksik/bozuk/çok büyük dosya reddi; aynı ID'nin iki yedeğinin `completed_ids` ve `reward_ids` birleşimi; eski içe aktarmanın yeni yerel tamamlamaları geri almaması; aynı adlı farklı ID'nin ayrı profil oluşturması; çakışan ayarlarda kararlı kural.
- [ ] **Step 2: Başarısızlık çıktısını al.** **Beklenen:** BackupIO henüz yok.
- [ ] **Step 3: İçe/dışa aktarma veri mantığını yaz.** Android yerel picker tarafı Task 8 ekran entegrasyonu; önce `content://` URI olmayan yerel dosya testleri. Üçüncü taraf dosya eklentisi yok.
- [ ] **Step 4: Runner ve kayıttan tekrar açma testi.** **Beklenen:** hiçbir kazanılmış ödül kaybolmaz.
- [ ] **Step 5: Commit.** `git add oyun/core/backup_io.gd oyun/core/save_store.gd tests/test_backup_io.gd && git commit -m "feat: merge safe offline backup transfer"`.

## Task 7 — Ana akış, harita önizlemesi, görev HUD ve kazanım tepkisi

**Files:**
- Create: `oyun/ui/atlas.tscn`, `oyun/ui/atlas.gd`
- Create: `oyun/ui/mission.tscn`, `oyun/ui/mission.gd`
- Create: `oyun/ui/guide.tscn`, `oyun/ui/guide.gd`
- Create: `oyun/ui/theme.tres`
- Create: `tests/test_main_flow.gd`
- Modify: `oyun/app/main.gd`, `oyun/app/main.tscn`

**Interfaces:**
- İlk oynayış D1/001; bitişte `Atlas` görünür.
- `Atlas`: D1 açık, D2–D7 önizleme, oynanamaz dünya görevini başlatmaz.
- `MissionScreen`: `Dene / İpucu / Geri Al / Yeniden Kur / Çık` ve üç katman UI.

- [ ] **Step 1: Test akışını yaz.** Yeni profil hiçbir form olmadan görevde başlar; 001 tamamlanınca atlas; D2 önizlenebilir fakat oynanamaz; tekrar açmada doğru görev ve kazanım kaydı; üç ipucu sırayla açılır; exit güvenlidir.
- [ ] **Step 2: Test kırmızısını doğrula.** **Beklenen:** sahneler yok.
- [ ] **Step 3: Dünyaya ait özgün fakat minimal tema ve ekranları oluştur.** Godot varsayılan skin olarak kalmaz. Bitmiş karakter/çevre sprite'ları yoksa **geçici prototip varlığı** açıkça işaretlenir, kullanıcıya nihai diye gösterilmez.
- [ ] **Step 4: Yeşil otomatik test; 16:9 / 4:3 / telefon portre manuel ekran kontrolü.** Test edilmeyen cihaz türünü `UNTESTED` yaz.
- [ ] **Step 5: Commit.** `git add oyun/app oyun/ui tests/test_main_flow.gd && git commit -m "feat: first play and world atlas loop"`.

## Task 8 — Ayarlar, erişilebilirlik, giriş eşdeğerliği, Android SAF sınaması

**Files:**
- Create: `oyun/ui/settings.tscn`, `oyun/ui/settings.gd`
- Create: `oyun/core/settings_store.gd`, `oyun/core/input_actions.gd`
- Create: `tests/test_settings.gd`, `tests/test_accessibility.gd`
- Modify: `oyun/ui/mission.gd` ve görev UI gerekirse

**Interfaces:**
- Dil TR/EN, profil değişimi, performans modu, yazı boyutu, yüksek kontrast, renk ayarı, azaltılmış hareket, ses seviyeleri ve yerel yedekleme bu ekrandan yönetilir.
- Dokun-seç-yerleştir, fare ve klavye aynı komut eylemini üretir.

- [ ] **Step 1: Kırmızı testleri yaz.** Ayarlar profil sınırlarına uygun saklanır, Türkçe karakterler doğru gösterilir; eksik TR/EN anahtarı test hatasıdır; giriş türleri aynı `action` yapısını üretir; yazı büyütme ve yüksek kontrast görevden çıkış gerektirmez; `reduced_motion` döngüyü etkilemez.
- [ ] **Step 2: Kırmızı çalıştırma al.** **Beklenen:** ayar/girdi servisleri yok.
- [ ] **Step 3: Yerleşik Godot kontrol/tema özelliğiyle uygula; ekstra UI paketi ekleme.** Fiziksel mobil/tablet üzerinde dokunma alanı ve ekran kesilmesini ayrıca kontrol et.
- [ ] **Step 4: `DisplayServer.file_dialog_show()` SAF adayını Android APK'da test et.** `content://` URI ile **export+import**; test cihazı yoksa `UNTESTED`, teslimde açık bloklayıcı. Native picker çalışmazsa mevcut bilgiyle başarı iddiası üretme.
- [ ] **Step 5: Otomatik test ve manuel matrisi güncelle; commit.** `git add oyun/core oyun/ui tests docs && git commit -m "feat: accessible settings and input parity"`.

## Task 9 — Dikey dilim paket denetimi, performans, lisans ve kanıta dayalı rapor

**Files:**
- Create: `BUILD.md`, `LISANSLAR.md`, `varliklar/license_index.csv`
- Create: `tools/inspect_build.py`
- Create: `packaging/build.sh`, `packaging/build.ps1`
- Create: `packaging/export_presets.example.cfg`
- Create: `packaging/pardus/DEBIAN/control`, `packaging/pardus/algoritma-oyunu.desktop`
- Create: `docs/test-report-stage4.md`

**Interfaces:** `inspect_build.py <apk-or-zip-path>` üretim çıktısının varlığı, boyut, APK manifest izni ve paket dosyası yapısı için uygunsa denetim yapar; raporda her platform `PASS/FAIL/UNTESTED`.

- [ ] **Step 1: Paket testlerini yaz.** Sürüm uyumu, eksik çeviri/çözümsüz görev/izin tespitleri başarısızlığa götürür; `INTERNET` görünürse release reddedilir. Gerçek APK yokken `PASS` basılmaz.
- [ ] **Step 2: Denetleyici testlerini kırmızı çalıştır.** **Beklenen:** olmayan APK için hata, denetleyici yoksa başarısızlık.
- [ ] **Step 3: Minimum build scriptleri ve dokümantasyonu oluştur.** Proje kodu bağımlılığı ekleme; Android debug/release anahtar yolu yalnız ortam değişkeninden, gizli anahtar repoya yazılmaz. Pardus control/.desktop pakete girer, kayıt `user://` içinde kalır.
- [ ] **Step 4: İmkan varsa Android/Windows/Linux/Pardus gerçek export'u başlat.** Çıkmayan dosyayı üretildi diye raporlama. Derleme alt yapısı yoksa kullanım komutunu ve engeli yaz.
- [ ] **Step 5: Tüm testler + sahne/performans ölçümü + rapor + commit.** `git add BUILD.md LISANSLAR.md varliklar tools packaging docs && git commit -m "build: document and verify offline exports"`.

## Acceptance: Aşama 4 onayı için teslim listesi

- [ ] D1'in **5 özgün** ilk görevi üç katmanda oynanabilir, her katmanda tanık yürütmesi geçerli.
- [ ] Yeni kurulum **oyuncuya soru sormadan** göreve girer; dünya haritası ve 6 önizleme vardır.
- [ ] Türkçe + İngilizce metinler tamam; ipucu 1/2/3, sınırsız deneme ve ücretsiz yardım.
- [ ] Çoklu profiller birbirinden ayrılır; `save.tmp`, doğrulanmış yedek, şema sürümü, migrasyon ve güvenli içe aktarma testleri çalışır.
- [ ] Temel klavye, fare, dokunmatik ve alternatif seç/yerleştir etkileşimleri doğrulanır.
- [ ] En az bir özgün piksel sanat oyun ekranı **gerçek oynanış görüntüsüdür**, mockup gibi sunulmaz.
- [ ] Ağ/ödeme/reklam yok; gerçek APK üretilebilirse manifestte INTERNET izni olmadığı denetlenir.
- [ ] Faz 1 / Android donanım uyumu raporlanır: PASS/FAIL/UNTESTED.
- [ ] Dosya/derleme/test raporu, bilinen sorunlar ve sıradaki aşama açıkça yazılır.

## Aşama 5–7 makro uygulama sırası (ayrıntılı mikro planlar dünya başında hazırlanacak)

| Aşama | Büyüme birimi | Doğrulama / onay |
|---|---|---|
| 5 D1 | İlk 5 görevden 50 ana göreve | Her onluk perde ve dünya sonunda tanık/çeviri/erişim testi, dünya onayı |
| 5 D2 | Saatçilerin Sokağı + gerekli `clock_logic`, debug, block | 50 görev, 3 katman, özgün sanat ve dünya onayı |
| 5 D3 | Yaşayan İstasyon + sensör/simülasyon | 50 görev, otomatik çoklu ölçüt ve ana merkez onayı |
| 5 D4 | Arşiv + binary/cipher/sort | 50 görev, kodlama güvenliği ve dünya onayı |
| 5 D5 | Graf/yol haritası + planlama | 50 görev, farklı optimizasyon hedefleri ve dünya onayı |
| 5 D6 | Ritim/desen + fonksiyonlar | 50 görev, ses kapalı eşdeğer oynanış ve dünya onayı |
| 5 D7 | Akış şeması + eğitim kodu + birleşik görevler | 50 görev, adım sınırı, tam öğrenme zinciri ve dünya onayı |
| 6 | Günlük keşif, yarışma, STEM, serbest, koleksiyon | Deterministik yerel görev seçimi, açık uçlu otomatik ölçüt, cezasız sonuç |
| 7 | APK arm32/arm64, Windows ZIP, Linux tar.gz, Pardus `.deb` | Gerçek paket/izin/lisans, erişim ve cihaz performans kanıtı |

## Bu planda bilerek yapılmayacaklar

- 16 modülü **başta** boş dosyalar olarak oluşturmak.
- Oyun içi hesaba, sunucuya, veritabanına, bulut yedeklemeye veya internet SDK'sına başvurmak.
- 16 modül için 16 bağımsız profil/ödül/çeviri/ipuçları altyapısı kurmak.
- Harici bir oyun framework'ü, DI container, uzak servis veya otomatik kod üretim hattı eklemek.
- Ücretsiz ve bağımsız lisansla çözülebilen iş için ücretli API kullanmak.
- Test edilmemiş Faz 1 desteğini ya da çalışan APK'yı varmış gibi duyurmak.

## Aşama 3 durum

**Hazırlandı:** dosya haritası, modül sözleşmeleri, test-first küçük adımlar, ürün/donanım kalite kapıları ve kabul ölçütleri.  
**Oyun testi:** yapılmadı; bu bir plan.  
**Bloklayıcı risk:** Faz 1 grafik uyumluluğu.  
**Sıradaki adım:** kullanıcı Aşama 3 plan onayı → Task 0 donanım kapısı → Task 1–9 ile dikey dilim.
