# H0 — Donanım ve araç uygunluğu

| Alan | Durum | Kanıt |
|---|---|---|
| Godot 4.7.2 ikilisi | NOT AVAILABLE | `command -v godot` ve `command -v godot4`: yok |
| Android SDK / adb | NOT AVAILABLE | `command -v adb`: yok |
| Java | AVAILABLE | `command -v java`: `/usr/bin/java`; sürüm ayrıca kontrol edilecek |
| dpkg-deb | AVAILABLE | `command -v dpkg-deb`: `/usr/bin/dpkg-deb` |
| Faz 1 etkileşimli tahta / GPU | UNTESTED | fiziksel donanıma erişim yok |
| Samsung A32 4G veya emsal tablet | UNTESTED | fiziksel donanıma erişim yok |
| Godot 4.7.2 sahne başlatma / OpenGL | UNTESTED | Godot ikilisi yok; grafik testi yapılmadı |
| Android dokunmatik ve SAF | UNTESTED | APK ve fiziksel cihaz yok |

**Engel:** Godot 4 Compatibility hedefi OpenGL 3.3 masaüstü gerektirebilir; Faz 1 GPU'larda daha eski sürüm bulunabilir. Bu donanımda PASS iddiası yok. Gerektiğinde mevcut JSON oyun verisini eski motor için taşımak ayrı karardır.
