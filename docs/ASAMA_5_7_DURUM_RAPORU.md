# ALGORİTMA OYUNU — Aşama 5–7 doğrulama ve teslim raporu

**Sürüm:** v0.5 — geliştirme kaynak paketi, **nihai oyun / yüklenebilir sürüm değildir**.

**Kapsamın dayanağı:** `docs/GDD.md` ve kullanıcının `algoritma_oyunu_chatgpt_prompt.md` talimatları.

## Üretilen kaynaklar

- **İçerik:** 7 dünya, her dünyada 5 perde × 10 ana görev, toplam **350 görev**. 350 farklı görev kimliği ve iki dilde farklı görev başlığı var. Bazı görevler parametreli ve şablon tabanlı; bu sayılar 350 tamamen bağımsız el yapımı senaryo veya 350 benzersiz mekanik anlamına gelmez.
- **Adaptasyon:** Her görevde `concrete`, `blocks`, `system` katmanları ve bir örnek çözüm; toplam **1.050 çözüm**. Bunlar Python referans modelinde doğrulanmıştır; Godot motorunda henüz oynatılmamıştır.
- **Mekanikler:** 16 ayrı GDScript bulmaca modülü; ortak oyun çalıştırıcısı, veri deposu, ipucu ve kayıt sistemi.
- **Kaynak akışları:** Hikâye görevleri, dünya atlası ve önizleme, günlük keşif, isteğe bağlı süreli yarışma simülasyonu, beş adımlı STEM proje atölyesi, oynanışı hikâye kaydından bağımsız serbest robot parkuru, beceri listesi ve koleksiyon.
- **Yerelleştirme:** Türkçe/İngilizce görev ve UI tabloları. Türkçe karakterlerin gerçek motor ve cihaz üzerinde font testleri tamamlanmadı.
- **Varlıklar:** Programatik üretilmiş küçük piksel sanat ortam/karakter varlıkları ve özgün kısa WAV sesleri. Profesyonel görsel yön/animasyon/oynanış cilası ve kalite kontrolü **tamamlanmadı**.
- **Kayıt:** Yerel profil, yedek ve güvenli kayıt için GDScript kaynakları; gerçek Godot kapanma, bozulma ve migrasyon testleri **çalıştırılamadı**.
- **Müfredat:** `veri/mufredat_eslesme.csv` 350 taslak satır; resmî Maarif çıktı kodları **doğrulanmayı bekliyor**, uydurulmadı.
- **Derleme:** `packaging/build.sh` ve `export_presets.cfg`; gerçek kurulabilir çıktılar üretildiği **iddia edilmemektedir**.

## Gerçekten çalıştırılan testler

| Test / doğrulama | Sonuç | Bu sonucun kanıtlamadığı şey |
| --- | --- | --- |
| `python3 -m unittest discover -s tests -p 'test_*.py' -q` | **18 test geçti** | GDScript sözdizimi, Godot sahne açılışı, gerçek kullanıcı etkileşimi |
| `python3 tools/validate_sources.py` | **350 görev, 16 modül, 1.050 geçerli referans çözüm, 2.235 eşlenen dil anahtarı, 0 veri hatası** | Godot bulmaca motorunun aynı sonuçları üretmesi |
| `python3 tools/campaign_validator.py` | **1.050 örnek çözüm Python'da doğrulandı** | Görevlerin pedagojik çeşitliliği ve gerçek cihaz performansı |
| `bash -n packaging/build.sh; sh -n packaging/pardus/build-deb.sh` | Shell sözdizimi geçti | Paketlerin gerçek derlenmesi / kurulması |
| `bash packaging/build.sh` | **Çıkış 127: Godot çalıştırıcısı bulunamadı** | APK / Windows / Linux / Pardus binary üretimi |
| WAV başlıkları ve kaynak dosya referansları | WAV dosyaları okundu, statik referanslar mevcut (dinamik dizinler hariç) | Oyundaki müzik çalma davranışı |

**Çalıştırılamayanlar:** `godot --headless --editor`, GDScript parser/test çalıştırıcısı, gerçek sahne ve arayüz testi, Android SDK/export templates, APK manifest izin incelemesi, APK imzası, Windows exe/Linux portable/Pardus .deb paket oluşturma, Samsung A32 / eski Faz 1 tahtada performans testi, ekran görüntülü Taste Skill değerlendirmesi.

## Kritik açıklar / kabul kriterleri

1. **Derleme hattı eksik:** Godot 4.7.2 çalıştırıcısı ve sürümle eşleşen export templates yok. Bu yüzden **APK, EXE, .deb ve Linux çalıştırılabilir dosyası yok**.
2. **Cihaz uyumluluğu belirsiz:** Faz 1'deki bazı GPU'lar Godot 4 Compatibility için gereken OpenGL seviyesini karşılamayabilir. Eski donanımda çalışır iddiasında bulunulamaz.
3. **Oyun motoru doğrulaması yok:** 16 GDScript modülünün Godot içinde hatasız derlenmesi ve ekranda etkileşimli çalışması doğrulanmadı.
4. **Pedagojik içerik revizyonu gerekli:** 350 veri kaydı tamam; bazı görevler tekrar eden mekanik ve parametre uyarlamalarına dayanır. Yaş düzeyi, özgünlük, öykü ve öğretim kazanımı açısından insan gözden geçirmesi gerekir.
5. **Görsel/işitsel kalite kabulü yok:** Görsel varlıkların tutarlılığı, animasyon, küçük ekran, etkileşimli tahta, klavye erişilebilirliği ve kullanıcı deneyimi gerçek ekranlarda incelenmeli.
6. **Türkçe font:** Ayrı gömülü ve lisansı belirtilmiş uygulama fontu henüz pakete eklenmedi; bu kullanıcı talebinin açık bir eksikliğidir. Varsayılan motor fontuna güvenmek yeterli kabul edilmemelidir.
7. **Mod derinliği:** Yarışma simülasyonu soru listesi ve isteğe bağlı süre sunuyor; tam set değerlendirmesi/sonuç analizi sınırlı. STEM atölyesi tek temel çok-ölçütlü akıştır, özgür proje üretim motoru değildir.
8. **Gerçek dışa aktarma güvenliği:** Presetlerde `permissions/internet=false` bulunması Android APK'nın manifestinde internet izni olmadığı anlamında henüz doğrulanmış değildir.

## Tamamlamak için zorunlu sıra

1. Godot 4.7.2 Standard ve export templates ile projeyi **içe aktar**, varsa parser hatalarını gider.
2. Godot içindeki `tests/runner.gd` ve `tools/validate_levels.gd` testlerini çalıştır. 1.050 witness sonucunun gerçek GDScript ile tutarlı olduğunu doğrula.
3. Klavye/dokunmatik, kayıt/yedek, telefon yatay/dikey, 4:3 tahta, ses, Türkçe yazım ve erişilebilirlik kontrollerini görsel olarak yap.
4. Eğitimcilerle 350 görevi pedagojik ve tekrar açısından gözden geçir, Maarif eşleşmelerini resmî programla doğrula.
5. Paketleme scriptlerini gerçek export templates ve Android SDK ile çalıştır. Yüklenebilir APK, Windows portable, Linux portable, Pardus `.deb` dosyalarının her birini yükleyerek aç; Android manifest ve imzayı doğrula.
6. Faz 1 fiziksel tahta OpenGL uyumsuz çıkarsa hedefi değiştirmeden önce Godot 4'ün uygunluğu konusunda teknik kararı yeniden değerlendir.

Bu belge **test kanıtı olan kaynak teslimini** ve eksik üretim adımlarını ayrı tutar. Yukarıdaki testler geçse bile bitmiş oyun veya yayınlanabilir kurulum dosyası iddiası için yeterli değildir.
