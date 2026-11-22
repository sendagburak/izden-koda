# ALGORİTMA OYUNU — Kaynaktan derleme

> **Durum:** Bu repository derleme hedeflerini içerir; bu dağıtım ortamında Godot 4.7.2 ve Android SDK mevcut olmadığı için Android APK, Windows EXE, Linux portable ve Pardus `.deb` **oluşturulmadı**. Bu dosya gerçek bir paket veya motor testinin kanıtı değildir.

## Gerekli araçlar

1. **Godot 4.7.2 Standard** ile birebir eşleşen **Godot 4.7.2 export templates**. Özel C#/.NET sürümüne gerek yok.
2. Android çıktısı için **OpenJDK 17+**, Android SDK/Build Tools ve Godot Editor Settings'de doğru JDK/SDK konumu. Linux/Windows için SDK gerekmez.
3. Linux / Pardus için `python3`, `zip`, `tar`, `dpkg-deb`; Windows için PowerShell ve uygun zip aracı.
4. Paketleme öncesi gerçek cihaz/GPU, dokunmatik ve kayıt/geri yükleme testi. Faz 1 Intel HD Graphics 3000 OpenGL 3.1 uyumsuzluğu hâlâ araştırılmalıdır.

## Testler (derleme olmadan da çalışır)

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/campaign_validator.py
python3 tools/validate_sources.py
```

Bu kontroller görev verilerini Python modelinde doğrular. Godot GDScript derlemesini **doğrulamazlar**. Godot kuruluyken ayrıca:

```sh
godot --headless --editor --path . --quit
# Projeyi içe aktarır; herhangi bir parser hatasında ilerlemeyin.
godot --headless --path . --script res://tests/runner.gd
godot --headless --path . --script res://tools/validate_levels.gd
```

## Masaüstü ve Pardus

```sh
GODOT_BIN=godot bash packaging/build.sh
```

Başarılıysa şu dosyaları üretir:

- `build/algoritma-oyunu-linux-portable.tar.gz` (Linux/Pardus portable)
- `build/algoritma-oyunu-windows-portable.zip` (Windows portable)
- `build/pardus/algoritma-oyunu_0.5.0-preview1_amd64.deb` (Pardus x86-64)

`packaging/pardus/build-deb.sh`, gerçek Linux export binary'si olmadığında çalışmayı reddeder; boş veya sahte `.deb` oluşturmaz. **Faz 1 cihaz uyumluluğu garanti değildir.**

## Android APK (çevrimdışı, izinsiz)

`export_presets.cfg` içinde iki Android preset vardır: `Android ARM64` ve `Android ARM32`. Her ikisinde de `permissions/internet=false` olarak ayarlanmıştır. Gerçek APK manifesti ayrıca incelenmelidir; yalnız preset doğrulaması yeterli değildir.

Android release imzası için kendi keystore'unuzu güvenli yerde üretin. Gizli anahtarı ve şifreyi kaynak projeye eklemeyin. Kabuk oturumunda:

```sh
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH='/private/path/algoritma-release.keystore'
export GODOT_ANDROID_KEYSTORE_RELEASE_USER='algoritma-release'
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='YOUR_SECRET'
BUILD_ANDROID=1 GODOT_BIN=godot bash packaging/build.sh
```

Godot Editor'de gerekli Android SDK yolunun ve export template'lerin tanımlı olması gerekir. Bu çalıştırıldığında `build/android/algoritma-oyunu-arm64.apk` ve `build/android/algoritma-oyunu-arm32.apk` **oluşması beklenir**; elde çalıştırılmış build sonucu yoktur. SDK ve Godot sürümüne bağlı preset düzenlemesi gerekebilir.

Paket üretiminden sonra `apkanalyzer manifest permissions` veya `aapt dump permissions` ile **INTERNET** izni bulunmadığını doğrulayın; gerçek bir Samsung A32 üzerinde dokunmatik, kayıt ve kapalı ağ testi yapın.

## Kullanıcı verileri ve yedekleme

Godot `user://profiles/` kullanıcıya özel uygulama veri dizinini kullanır. Paket güncellerken bu dizini silmeyin. Ayarlar → dışa/içe aktarma ile JSON yedek alınabilir. Yedek birleştirmede tamamlanmış görev ve kazanılmış rozetler korunur. Windows ve Linux portable paketler, uygulama kodunu taşınabilir çalıştırır; kayıtlar varsayılan olarak kullanıcı profiline özgü `user://` konumundadır.

## Resmî dökümantasyon

- Godot 4.7 Exporting: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html
- Godot 4.7 Android: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
- Godot Engine MIT: https://godotengine.org/license/
