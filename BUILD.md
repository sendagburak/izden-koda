# Algoritma Oyunu v0.7.0 · Derleme ve test

Godot **4.7.2 Standard** ve aynı sürümün resmî dışa aktarma şablonları gerekir. Masaüstü derlemesi Python 3, Bash, tar, zip, file ve dpkg-deb kullanır. Android ihracı OpenJDK 17 veya üzeri ve Godot editöründe kayıtlı Android SDK gerektirir.

## Kaynağı test etme

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/validate_sources.py
python3 tools/campaign_validator.py
godot --headless --editor --path . --import
XDG_DATA_HOME="$(mktemp -d)" godot --headless --path . --script res://tests/runner.gd
godot --headless --path . --script res://tools/validate_levels.gd
godot --headless --path . --script res://tests/test_campaign.gd
XDG_DATA_HOME="$(mktemp -d)" godot --headless --path . --script res://tests/test_app_flow.gd
XDG_DATA_HOME="$(mktemp -d)" godot --headless --path . --script res://tests/play_campaign.gd
```

Test profilleri için her sahne testine boş bir kullanıcı veri dizini verin. Godot bazen script hatasını süreç çıkış koduna yansıtmaz. Çıkış koduyla birlikte günlükteki hata satırlarını inceleyin.

## Hedefleri derleme

```sh
GODOT_BIN=godot bash packaging/build.sh
GODOT_BIN=godot BUILD_ANDROID=debug bash packaging/build.sh
```

Linux ve Windows taşınabilir paketlerinde çalıştırıcıyı ve yanındaki `.pck` dosyasını birlikte çıkarın. Pardus paketi `build/pardus/algoritma-oyunu_0.7.0_amd64.deb` yolundadır.

Android debug ve release aynı uygulama kimliğine sahiptir. Release imzası için `BUILD_ANDROID=release` ve `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` gerekir. İmzasız release'i kurmadan önce imzalayın. İmzayı `apksigner verify --verbose`, izinleri `aapt dump permissions` ile denetleyin.

Yerel kayıtlar `user://profiles/` altındadır. Farklı profil kimliğine ait yedek ayrı profil açar. Android'de uygulamayı kaldırmak kullanıcı verilerini silebilir.

- [Godot dışa aktarma belgesi](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)
- [Godot Android dışa aktarma belgesi](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
