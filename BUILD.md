# BUILD — ALGORİTMA OYUNU (Aşama 4)

**Durum: Henüz APK veya diğer çalıştırılabilir paketler üretilmedi.** Bu klasör Godot **kaynak projesidir**. 4.7.2 stable ve export templates yükleyin.

## Godot ile aç

1. Godot Project Manager → **Import** → `project.godot`.
2. Renderer seçimini **Compatibility** bırakın.
3. Editörden **F6 / F5** ile çalıştırın veya `godot --path . --editor`.
4. Headless kontroller: `godot --headless --editor --path . --quit`, ardından `godot --headless --path . --script res://tests/runner.gd` ve `godot --headless --path . --script res://tools/validate_levels.gd`.
5. Harici Python veri denetimi: `python tools/validate_sources.py` ve `python -m unittest discover -s tests -p 'test_*.py'`.

## Çıkartımlar

Export şablonları kurulunca Godot Project → Export üzerinden preset eklenmeli. Bu depo `packaging/export_presets.example.cfg` içinde örnek parametreleri sunar; export şablonu ve Android SDK olmadan çalıştırılabilir ürün çıkmaz.

- **Android:** platform `Android` → ayrı `armeabi-v7a` ve `arm64-v8a` seçenekleri; `INTERNET` izni **kapalı**. Test APK anahtarı Godot/Android SDK ile; yayın anahtarını koruyun, Git'e asla koymayın. `python tools/inspect_build.py build/android/algorithm-arm64.apk` ile `aapt` tabanlı manifest denetimi.
- **Windows:** `Windows Desktop` export, oyun exe + PCK aynı klasör → ZIP. `user://profiles/` oyuncunun kullanıcı veri dizinindedir, taşınabilir program klasöründe değil.
- **Linux/Pardus:** `Linux` export, ikili + PCK aynı klasör → `tar.gz`. Pardus `.deb` için `packaging/pardus/build-deb.sh build/linux/algoritma-oyunu`.
- **Eski Faz 1 tahtalar:** OpenGL 3.3 yeteneği ve sahne performansı doğrulanmadı. Destek sözü yok.

## Temel bağımlılıklar

Godot 4.7.2; Android için yerel JDK/SDK/ADB; Windows/Linux için export templates, Pardus için `dpkg-deb`. Python yalnız veri kalite testlerinde kullanılır, oyun çalışırken **gerekmez**. Ağ SDK'sı, ücretli anahtar, reklam veya telemetri içermez.
