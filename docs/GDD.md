# ALGORİTMA OYUNU — Oyun Tasarım Dokümanı (GDD)

**Sürüm:** 0.1 — taslak / onay bekliyor  
**Tarih:** 21 Kasım 2026  
**Aşama:** 2 / 7 — Tasarım  
**Çalışma adı:** ALGORİTMA OYUNU (nihai oyun adı kararlaştırılmadı)  
**Kaynak:** `algoritma_oyunu_chatgpt_prompt.md` ve kullanıcıyla tamamlanan Aşama 1 kararları.

> **Kapsam sınırı:** Bu belge oynanabilir oyunun yapıldığını veya test edildiğini göstermez. Buradaki düzeyler, renkler, mekanikler, sayı hedefleri ve teknik bütçeler *tasarım önerisi*dir. Kodlama yalnızca GDD onayından ve Aşama 3 teknik planının onayından sonra başlayacaktır.

## 1. Tasarım özeti

**Tek cümlelik vaat:** Öğrenci, şiddetsiz ve çevrimdışı bir ajan macerasında yedi birbirine bağlı dünyayı onarırken algoritmik düşünmeyi, kodlamayı, robotik sistemleri ve yaratıcı problem çözmeyi öğrenir.

**Temel şartlar:** 2–8. sınıflar; Godot 4.x kararlı sürüm ve Compatibility hedefi; Türkçe/İngilizce; Android APK, Windows taşınabilir, Linux taşınabilir ve Pardus `.deb` + taşınabilir; internet/reklam/hesap/veri toplama yok; kalıcı ilerleme; destekleyici geri bildirim; yüksek erişilebilirlik; özgün piksel sanat.

**Hedeflenen deneyim:** İlk dakikada etkileşim, 5–12 dakikalık tamamlanabilir görev oturumları, aylara yayılan içerik; süre/sıralama/seri baskısı yok. Öğrenci uygun bir noktada oyundan ayrılıp daha sonra kaldığı yerden devam edebilir.

### 1.1 Önceden onaylanmış kararlar

| Konu | Onaylı karar |
|---|---|
| Dünya ve sınıf | Her dünya birden çok sınıfa uyarlanır; sınıf sert erişim engeli değildir. |
| Dünya erişimi | Henüz açılmamış dünyalar önizlenebilir; oynanabilir görevler doğal ilerlemeyle açılır. |
| Ortak cihaz | Birden çok **yerel** oyuncu profili; hesap/giriş gerekmez. |
| İlk açılış | Soru sorulmadan ilk oynanabilir göreve başlanır; sınıf ayardan sonra seçilir. |
| Müfredat | Kademeli fiilî uygulamadan bağımsız olarak Maarif programları esas alınır. |
| Performans sınıfı | Samsung Galaxy A32 4G ayarında Android ve en eski Faz 1 etkileşimli tahtalar hedeflenir. |
| Açık uçlu değerlendirme | Öğretmen notlaması yok; çoklu, otomatik ve açıklanabilir başarı ölçütleri. |
| Seslendirme | Zorunlu değil; metin ve görsel yönergeler ses olmadan tam anlaşılabilir. |
| Güvenli içe aktarma | Mevcut tamamlamaları/ödülleri silmeyen, çakışmaları birleştiren kayıt yaklaşımı. |
| Anlatı yönü | **Kayıp Fenerin Sırrı** başlangıç dünyası; **Yaşayan İstasyon** ana bağlayıcı dünya. |

### 1.2 Seçilen yaklaşım ve değerlendirilen alternatifler

- **Seçilen: Ortak hikâye + ayrı dünyalar + veri odaklı bulmaca aileleri.** Hikâye ve sanat çeşitliliğini korurken 350 görevin sistematik üretimini kolaylaştırır. Her dünya kendi etkileşimlerini ve geri bildirimlerini taşır.
- **Alternatif: Tek dev açık dünya.** İlk keşif güçlü olabilirdi; ancak düşük donanım, küçük ekran, pedagojik sıra ve içerik testi bakımından daha riskli. Bu sürüm için seçilmedi.
- **Alternatif: Birbirinden bağımsız mini oyun koleksiyonu.** Kısa geliştirme kolaylığına karşı uzun vadeli hikâye/aidiyet zayıflığı taşır. Seçilmedi.

**Tasarım ilkeleri:** Öğrenme oynayışın parçası olur; sorun çözme fiziksel dünyada görünür değişim yaratır; dünya ve karakterler birbirinden ayrışır; her doğru çözüm tek yol değildir; öğrenci hata yaptığında sistem çözümü anlaması için yeni bilgi verir.

## 2. Oyun evreni ve ana hikâye

### 2.1 Hikâye çatısı: Denge Atlası

Yedi bölgenin günlük yaşamını düzenleyen eski bir **Denge Atlası** bulunur. Atlas çevrimdışı, mekanik ve yerel sistemleri temsil eden bir haritadır: fenerin ışık sırası, saatlerin ritmi, seranın sulama düzeni, arşivin dizinleri, ulaşım rotaları ve üretim atölyeleri. Mevsimsel bakım sırasında eski iş akışları birbirine uyumsuz hâle gelmiştir. Kimse kötü niyetli değildir; parçalar tek tek çalışır ama birlikte uyumlu çalışmaz.

Öğrenci, **İz Bürosu** adlı keşif/onarım ekibine katılan bir *çözüm ajanı*dır. Rütbe, rakip ve silah yoktur. Ajan dosyaları, görev mühürleri, not defterleri ve şifreli düzenekler oyunun keşif kimliğini kurar. Hikâyenin merkezindeki **Yaşayan İstasyon**, ilk iki dünyadaki keşiflerden sonra açılır; daha sonraki maceralar için harita/atölye işlevi görür. İstasyon ilk andan dünya haritasında silüet olarak görülebilir.

**Ana dramatik soru:** “Her parça kendi işini yapıyorsa neden bütün düzen aksıyor?” Son bölümde öğrenci, yedi dünyanın öğrendiği mantıkları tek bir sistem tasarımında birleştirir. Final, kapanış değil, serbest atölye ve yeni görevler için başlangıçtır.

### 2.2 Oyuncunun tekrar eden döngüsü

1. Dünyayı keşfet, çevresel bir aksaklığı gözlemle.
2. Kısa ve özgün bir **ajan görev dosyası** aç.
3. Blok, düzenek, yol, veri veya kod aracılığıyla bir çözüm tasarla.
4. **Çalıştır / Dene**: sistem sonucu anlaşılır biçimde canlandırsın.
5. Çözümün niçin çalıştığını gör; farklı çözüm deneyebil.
6. Çevre değişsin, deftere yeni iz düşsün, sonraki görev veya alternatif yol açılsın.

**Süreler bir yarış değildir:** Ortalamada 5–12 dakikada tamamlanabilir görevler tasarlanır; oyuncu daha kısa veya uzun oynayabilir. Her görevden güvenli ayrılma sağlanır.

## 3. Dünya mimarisi: 7 × 50 = 350 ana görev

**Sabit ana görev tasarımı:** Her dünya 5 perde × 10 görev = **50 benzersiz ana görev**. Ek keşif/bonus görevleri bu 350'nin dışındadır. 50 görev bir örneği 3 kez renklendirerek doldurulmaz; her görevin ayrı bağlamı, kısıtı, hedefi veya keşfi bulunur.

| Dünya | Hikâye / ilk bakış | Temel algoritmik hedefler | Örnek ders köprüleri |
|---|---|---|---|
| **D1 Kayıp Fenerin Sırrı** | Adaların ışık ve posta rotasını düzenle | Sıra, yön, örüntü, basit döngü, debug | Matematik, Hayat Bilgisi, Türkçe, İngilizce |
| **D2 Saatçilerin Gizli Sokağı** | Bir sokağın kendi kendine çalışan saatlerini eşgüdümle | Döngü, iç içe tekrar, if/else, olay, durum | Matematik, Müzik, Bilişim |
| **D3 Yaşayan İstasyon** | Seranın su, ışık ve hava dengesini kur | Sensör/eyleyici, koşul, değişken, veri, simülasyon | Fen, Matematik, Robotik Kodlama |
| **D4 Sessiz Arşiv** | Sırası karışmış kayıtları ve mesajları düzenle | İkili sistem, veri türü, liste, sıralama, arama, kodlama | Türkçe, İngilizce, Matematik |
| **D5 Kesişen Yollar Vadisi** | Köprü, hat, tramvay ve posta rotalarını planla | Grafik, BFS/DFS sezgisi, en kısa yol, verimlilik | Matematik, Sosyal Bilgiler, Teknoloji ve Tasarım |
| **D6 Ritim ve Desen Atölyesi** | Hareket, ses ve görsel desen yapan makineler tasarla | Fonksiyon, parametre, prosedür, ağaç, özyineleme sezgisi | Müzik, Görsel Sanatlar, Matematik |
| **D7 Yeni Gün Kenti** | Bağımsız sistemleri tek bütün olarak çalıştır | Sözde kod, akış şeması, basit metin kodu, karma robotik, STEM | Bilişim, Fen, Matematik, Proje Tasarımı |

### 3.1 D1 — Kayıp Fenerin Sırrı

**Oyuncu hedefi:** Birbirini görebilen küçük adalardaki fener, yüzer posta kutusu ve işaret sistemlerini yeniden kurmak. **Yan karakter:** Harita ustası **Mina**; yönergeleri kısa, meraklı ve yer yer kuru mizahlı: “Fener yolu biliyor. Yalnızca sırayı unutmuş.”

**Ana mekaniğin hissi:** Kareli harita, somut ok/yön taşları, tek tek çalışan fenerler; komutların sonucu fiziksel ışık hareketiyle görünür. Fare/touch ile taşı veya dokun-seç-yerleştir.

**5 perde / 10'ar görev:**
- P1 **İlk Işıklar:** yön, başlangıç-bitiş, komut sırası.
- P2 **Ada Postası:** engel, farklı rota, adım sayısı.
- P3 **Tekrarlanan Sinyaller:** örüntü ve basit `tekrarla`.
- P4 **Sisli Rota:** önceden düşünme, küçük hata ayıklama.
- P5 **Fenerler Birlikte:** karma rota ve çoklu geçerli çözüm.

**Örnek ajan dosyası:** “Üç adaya aynı ışık sırasını gönder. Tekrar eden hareketleri tek komuta sığdırabilir misin?”

**Görsel/işitsel kimlik:** Petrol yeşili `#234A50`, kum `#E5D4AD`, kehribar `#CA964F`; kıyı taşları, kalın cam fener silüeti, mekanik ışık perdeleri; düşük yoğunluklu ahşap-vurmalı sesler ve uzaktan gelen rüzgâr. Karanlık/korku yok.

### 3.2 D2 — Saatçilerin Gizli Sokağı

**Oyuncu hedefi:** Sokak boyunca kendi saatine göre çalışan postacı kuş, açılır kapanır kapı ve mekanik sergileri uyumlandırmak. **Yan karakter:** Saat tamircisi **Seda**; dakik ama mizahı ters köşe: “Saat geç kalmadı. Plan erken gelmiş.”

**Ana mekaniğin hissi:** Çark yuvalarına blok takma; bir hareketin *ne zaman* tetiklendiği önemlidir. Aynı bulmacanın yalnızca “fener = saat” görseli olmaz: olay tetikleme ve eşzamanlama yeni etkileşim getirir.

**Perdeler:** P1 Düzenli Tik Tak (örüntü) · P2 İki Çark Bir İş (döngü) · P3 Kapı Ne Zaman Açılır? (`if/else`) · P4 Yanlış Takılan Diş (debug ve iç içe tekrar) · P5 Sokak Orkestrası (olay ve durum makinesi).

**Örnek ajan dosyası:** “Kapı yalnızca iki zil birlikte çaldığında açılsın. Bir zil sustuğunda ne olmalı?”

**Sanat/ses:** Koyu arduvaz `#29343E`, bakır `#A96C44`, fildişi `#E9DECB`; kare dişli, dar sokak perspektifi, pirinç ibreler; mekanik vuruş ve az notalı ahşap melodiler.

### 3.3 D3 — Yaşayan İstasyon (ana merkez)

**Oyuncu hedefi:** Bitki türleri, su kanalları ve ışık kubbeleri arasında sürdürülebilir bir denge kurmak. **Yan karakter:** Bitki gözlemcisi **Ekin**; aceleci değildir, deney önerir: “Tek bir yaprak değil, bütün serayı dinleyelim.” Küçük yardımcı **Pıt**, renk yerine şekil ile uyarı veren tohum biçimli bir sensör arabasıdır; jenerik insan yüzlü robot değildir.

**Ana mekaniğin hissi:** Sürgülü su kanalları, çevre göstergeleri, algılayıcı-eyleyici bağlantıları, mini veri grafikleri ve farklı sonucu olan simülasyonlar. Sistem değişince bitkiler kademe kademe gelişir. Dünya 1–2'den izler burada haritaya işlenir.

**Perdeler:** P1 İlk Fideler (girdi/çıktı ve algılayıcı) · P2 Ne Zaman Sulamalı? (koşullar ve mantıksal bağlaçlar) · P3 Denge Defteri (değişken ve veri toplama) · P4 Bir Günlük Model (simülasyon, geri besleme) · P5 İstasyonun Nabzı (birden çok sistemi birlikte dengeleme).

**Örnek ajan dosyası:** “Toprak nemliyse sulama yapma; çok kuruysa kanalı aç. İki farklı bitkinin ihtiyacı aynı olmayabilir.”

**Sanat/ses:** Zeytin `#526449`, kiremit `#B36F51`, açık keten `#E8E4D4`; işlevsel cam kubbeler, su kanalları ve yaprak büyüme sprite'ları; yumuşak tahta tınıları ve mekanik sulama sesleri.

### 3.4 D4 — Sessiz Arşiv

**Oyuncu hedefi:** Eski mesajların indekslerini ve sayı işaretlerini çözerek bir kütüphanenin arama sistemini yeniden düzenlemek. **Yan karakter:** Arşivci **Defne**; kelime oyunlarını sever ama alay etmez: “Kitap kaybolmamış. Yanlış rafta çok rahat etmiş.”

**Ana mekaniğin hissi:** Fiziksel fişler, açılır dolaplar, ikili ışık panelleri, dizilim rafları; çözümde desen kadar *veri temsili* önem kazanır. Şifre çözme eğitsel, zararsız örneklerle sınırlıdır.

**Perdeler:** P1 Dosya Sırası (liste/dizi) · P2 İki Durumlu Işık (ikili sayı) · P3 Mesajın Anahtarı (temel kodlama/şifreleme) · P4 Aradığın Nerede? (sıralama ve arama) · P5 Arşivin Kısa Yolu (veri türü, strateji karşılaştırma).

**Örnek ajan dosyası:** “Arşivdeki kutuları her seferinde tek tek açmadan doğru dosyaya nasıl daha çabuk ulaşırsın?”

**Sanat/ses:** Toprak kahvesi `#67513D`, soluk mürekkep `#343B42`, parşömen `#DDD0B4`; damga, tipografik işaret ve raf geometrisi; kâğıt sürtünmesi ve sakin tıkırtılar.

### 3.5 D5 — Kesişen Yollar Vadisi

**Oyuncu hedefi:** Köyler, köprüler, teslim noktaları ve tramvay durakları arasındaki ulaşım kararlarını düzenlemek. **Yan karakter:** Yol planlayıcısı **Mahir**; çabuk çözüm değil iyi gerekçe arar: “En kısa çizgi her zaman en kısa yol mudur?”

**Ana mekaniğin hissi:** Dünya 1'in kare ızgarasından farklı olarak **düğümler ve bağlantılar** kullanılır. Yolun uzunluğu, aktarma sayısı ve enerji kullanımı farklı hedeflere dönüşür.

**Perdeler:** P1 İki Nokta Arası (graf düğümleri) · P2 Köprüler ve Sapaklar (erişilebilirlik) · P3 Sıra Sıra Keşfet (BFS sezgisi) · P4 Dala Gir ve Dön (DFS sezgisi) · P5 Ulaşım Planı (en kısa yol, maliyet, kaynak yönetimi).

**Örnek ajan dosyası:** “En az aktarmayla üç kütüphaneye uğra. Başka bir rota daha az enerji tüketiyor olabilir mi?”

**Sanat/ses:** Bordo `#724B54`, taş grisi `#A1A29B`, açık krem `#F1E5CE`; ray, köprü, iskele ve kablo çizgilerinden oluşan okunabilir haritalar; yumuşak ray ritimleri.

### 3.6 D6 — Ritim ve Desen Atölyesi

**Oyuncu hedefi:** Kendi kendine ritim çalan, ışık yakan ve piksel desen üreten yaratıcı makineler kurmak. **Yan karakter:** Tasarımcı **Ada**; iki cevaba da aynı tepkiyi vermez, ayrıntıları fark eder: “Bu çizginin bir de başka yolu var.”

**Ana mekaniğin hissi:** Tekrar kullanılabilir komut modülleri, parametre düğmeleri, dallanan desen üreticileri. Hızlı refleks ve kulağa bağımlı görev yok: ritimler görsel vuruş izleriyle de anlaşılır.

**Perdeler:** P1 Desen Tarifi (prosedür) · P2 Tek Parça Birçok İş (fonksiyon) · P3 Ayarlı Makine (parametre) · P4 Dallanan Motif (ağaç yapısı ve özyineleme sezgisi) · P5 Kendi İmzan (fonksiyonları yeniden birleştirme).

**Örnek ajan dosyası:** “Aynı deseni üç farklı boyda çiz. Üç yeni tarif yazmadan tek tarifi nasıl kullanabilirsin?”

**Sanat/ses:** Mürdüm `#55465B`, hardal `#B69A5A`, kirli beyaz `#EAE2D3`; dokuma tezgâhı, kare damga ve melodik mekanizmalar; oyuncu seçimiyle oluşturulan özgün kısa motifler (hazır telifli müzik yok).

### 3.7 D7 — Yeni Gün Kenti

**Oyuncu hedefi:** Önceki dünyalarda öğrendiği sistemleri, kent ölçeğinde tek bir işleyen düzen hâline getirmek. **Yan karakter:** Onarım koordinatörü **Rana**; emir vermez, seçenekleri karşılaştırır: “Bunu bütün şehre uygularsak ne değişir?” Önceki karakterler görev dosyalarına özgün biçimlerde katkı yapar.

**Ana mekaniğin hissi:** Robot parkuru, akış diyagramı masası, veri toplama paneli, sözde kod ve yaşa göre basitleştirilmiş metin kodu yan yana kullanılır. Sonuç bir "doğru/yanlış" kararı yerine ölçütlerle değerlendirilir.

**Perdeler:** P1 Birleştiren Şema (akış diyagramı) · P2 Sözcüklerle Komut (sözde kod) · P3 İlk Metin Satırları (basit metin tabanlı kodlama) · P4 Akıllı Parkur (robotik koşul/döngü/sensör) · P5 Denge Atlası (STEM tasarım ve bütünleşik sistem projesi).

**Örnek ajan dosyası:** “İki teslim aracının aynı dar köprüye aynı anda gelmesini önle. En az iki geçerli çözüm üret ve akışını gözlemle.”

**Sanat/ses:** Lacivert `#28394A`, kil taşı `#C7B9A3`, mat turuncu `#BA8053`; farklı dünyaların nesnelerinin inandırıcı mimariyle birleştirildiği mahalle; düşük tempolu karma akustik motifler. Bölüm, önceki dünyaların tüm renklerini aynı karede gökkuşağı gibi dizmez.

### 3.8 Bölümler birbirine nasıl bağlanır?

- D1'de eksik sinyal sırası bulunur; D2'de bu sıranın bir saat olayıyla ilişkilendiği anlaşılır.
- D2'den edinilen eşzamanlama çizelgesi D3'teki Yaşayan İstasyon'a ulaştırılır.
- D3 istasyon merkezi olur; D4 veriyi, D5 bağlantı yollarını, D6 yeniden kullanılabilir tarifleri tamamlar.
- D7 bütün sistemleri öğrenci tarafından tasarlanan bir planla birleştirir; çözüm tek ve önceden yazılmış bir koreografi değildir.

**Önizleme:** Açılmamış dünya için karakter silüeti, dünyaya özgü kısa mekân sesi, 1 ekranlık hikâye ipucu ve "Henüz keşif sırası gelmedi" tarzında nötr açıklama; oynanamaz görevler tek tek boşa tıklanabilir kartlara dönüşmez.

## 4. Kademeli öğrenme ve sınıf uyarlaması

### 4.1 Üç anlatım/etkileşim katmanı

Bunlar **öğrencinin kimliğine yapışan etiketler değil**, aynı görev için sunulan etkileşim biçimleridir. Sınıfı sonradan ayarlayan kişi anında katmanı değiştirebilir; kazanılmış ilerleme korunur.

| Katman | Önerilen düzey | Temsil | Aynı görevin uyarlanması |
|---|---|---|---|
| **Somut keşif** | 2–3 | Ok, desen, resimli blok; az metin | Kısa yol, görünür ipuçları, küçük durum uzayı |
| **Blok ve gerekçe** | 4–5 | Koşul/döngü blokları ve adımlı düşünme | Aynı göreve ek kısıt, alternatif çözüm, gerekçe |
| **Sistem ve kod** | 6–8 | Blok + sözde kod + kısa metin satırları | Değişken, parametrizasyon, verimlilik ve test senaryoları |

**Önemli:** Her dünya her katmanda en az anlamlı bir görev deneyimi sunar; özyineleme veya BFS'yi 2. sınıfa soyut tanım olarak öğretmeye çalışmayız. Küçükler için “dalı takip et/işaretle ve geri dön” gibi somut sezgisel uygulama, büyüklere aynı kavramın açık temsili sunulur.

**İlk açılış:** Cihaz dili varsayılanı seçilir, oyuncu otomatik **Oyuncu 1** yerel profilinde D1'in bir başlangıç görevine girer; yaş/sınıf/kimlik sorulmaz. Sonradan profil adı ve sınıf önerisi seçilebilir. Otomatik öneriler davranışa ve isteğe bağlı sınıf seçimine dayanır, kilit/ceza üretmez.

### 4.2 Kavram sarmalı

- **D1 → D2:** Sıralı komutlar → tekrar → koşullu zamanlama.
- **D2 → D3:** Koşul ve olay → sensör/eyleyici, değişken ve geri besleme.
- **D3 → D4:** Veri toplama → veriyi saklama, temsil ve arama.
- **D4 → D5:** Arama stratejileri → grafik üzerinde keşif ve optimizasyon.
- **D5 → D6:** Tekrar eden çözüm parçaları → fonksiyon ve parametreler.
- **D6 → D7:** Yeniden kullanılabilir modüller → metin kodu, bütünleşik simülasyon ve tasarım.

**Aralıklı tekrar:** Örneğin D1'deki sıralama D3'te sulama sırası, D5'te durak rotası, D7'de robot komut akışı olarak döner. Her dönüş, yeni bağlam ve bir yeni düşünme gereksinimi ekler.

### 4.3 Temel kavram envanteri

| Kavram | İlk anlamlı karşılaşma | Gelişim/yeniden kullanım |
|---|---|---|
| Sıra, adım, örüntü | D1 | D2, D6, D7 |
| Tekrar / döngü | D1–D2 | D3, D6, D7 |
| İç içe döngü | D2 | D6, D7 |
| Koşul, if/else, iç içe koşul | D2 | D3, D7 |
| Mantıksal işleçler | D2–D3 | D4, D7 |
| Değişken, veri türü | D3–D4 | D6, D7 |
| Liste/dizi | D4 | D5, D7 |
| Fonksiyon/prosedür/parametre | D6 | D7 |
| Olay tabanlı düşünme / durum makinesi | D2 | D3, D7 |
| Debug / test et-değiştir | D1 | Tüm dünyalar |
| Verimlilik ve adım sayısı | D1 | D4, D5, D7 |
| Sıralama/arama | D4 | D5, D7 |
| Grafik/yol bulma, BFS/DFS sezgisi | D5 | D7 |
| Ağaç/özyineleme sezgisi | D6 | D7 |
| İkili sistem/kodlama | D4 | D7 |
| Mantık kapıları/devre | D2–D3 | D7 |
| Temel şifreleme/mesaj çözme | D4 | D7 |
| Simülasyon/modelleme | D3 | D5, D7 |
| Veri toplama/yorumlama | D3 | D4, D7 |
| Algılayıcı/eyleyici | D3 | D7 |
| Sözde kod / akış diyagramı | D2'de görsel öncül, D7'de açık temsil | D7 |
| Basit metin tabanlı kod | D7 (ileri katman) | Serbest atölye |

## 5. Görev ve mini oyun tasarımı

### 5.1 Bulmaca aileleri — mekanik çeşitlilik

1. **Fener Rotası:** Kare ızgarada komut ve hareket.
2. **Komut Tezgâhı:** Blok dizme; dokun-seç-yerleştir alternatifli.
3. **Çark Mantığı:** Olayların zamanlanması ve durum geçişleri.
4. **Hata Dedektifi:** Çalıştır, ilk sapmayı gör, düzelt.
5. **Sıralama Rafı:** Liste ve karşılaştırma işlemleri.
6. **Yol Haritası:** Düğüm-bağlantı, kapsama ve rota seçimi.
7. **Devre Masası:** VE/VEYA/DEĞİL mantığı; anlamı hem ikonla hem metinle gösterilir.
8. **İkili Işık Paneli:** Açık/kapalı durumdan kodlama.
9. **Mesaj Dosyası:** Kural temelli zararsız metin kodlama/çözme.
10. **Girdi–Çıktı Makinesi:** Örüntü, veri ve kural çıkarma.
11. **Akış Şeması Masası:** Koşul/süreç/son sembollerini birleştirme.
12. **Denge Simülatörü:** Sera/ulaşım/tesis modelleme.
13. **Planlama Masası:** Kısıtlı kaynak, sıra ve takvim.
14. **Algılayıcılı Parkur:** Robot görev mantığı, test et/tekrar dene.
15. **Ritim/Desen Makinesi:** Fonksiyonlar, parametreler ve tekrar.
16. **Kod Not Defteri:** Sözde kod sıralama, tamamlama ve kısa metin ifadeleri.

**Özgünlük kapısı:** Her görevin bulmaca ailesi, hedef kavramı, çevresel sebebi, oyuncunun karar türü ve bir görsel geri bildirimi açıklanır. Aynı mekanik aynı dünyada üst üste uzun bir blok oluşturmaz; bir perdede en az üç farklı oyun biçimi bulunur.

### 5.2 50 görevlik perdenin ritmi

Her 10 görevlik perdede önerilen yapı: **2 keşif/tanıtım + 3 deneme/uygulama + 2 farklı bağlam + 2 karma görev + 1 hikâye düğümü**. Bu, tekrarlanan sabit anlatı şablonu değil, pedagojik çeşitlilik kontrolüdür; dünya bazında uygulanışı değişebilir.

**Birincil içerik sayısı:** 7 dünya × 5 perde × 10 görev = **350 benzersiz ana görev**. 2–3 / 4–5 / 6–8 katmanları *aynı görev kimliğine bağlı farklı sunum ve parametreler* olduğundan toplam 1.050 farklı hikâye görevi varmış gibi pazarlanmaz.

### 5.3 Bulmaca çözülebilirliği ve açık uçlu değerlendirme

- Kapalı uçlu görevler veriyle tanımlanır. Her kayda bir ya da daha fazla çözüm yolu veya çözücü tarafından doğrulanabilir başarı şartı eklenir.
- **Doğrulayıcı**, erişilebilir durumu ve geçerli çözümü kontrol eder; tek bir örnek çözümün varlığı, alternatif çözümün reddedilmesini gerektirmez.
- Açık uçlu STEM görevlerinde **çoklu başarı ölçütleri** kullanılır: örneğin sistem çalışır, kaynak tüketimi sınırını aşmaz, güvenli koşullar korunur, her hedef en az bir kez karşılanır. Birden fazla geçerli tasarım kabul edilir.
- “Tümünü maksimum yap” anlayışı yoktur. Ölçütler *seçenek* ve *gözlem* olarak gösterilir. Öğrenci farklı tasarımları güvenle deneyebilir.
- Yalnızca otomatik ölçülebilir iddialar kesin doğrulanır. Yaratıcılık gibi öznel alanlar sayısal olarak kesin yargılanmaz; “Farklı bir çözüm denedin” gibi kanıta dayalı geribildirim verilir.

### 5.4 İpucu ve hata dili

Üç katman: (1) **Gözünü buraya çevir** (küçük yön), (2) **Şu iki adımı incele** (somutlaştırma), (3) **Beraber deneyelim** (adım adım gösterim). Yardım sınırsız ve ücretsizdir; ipucu kullanımı ödül engeli değildir.

Olumlu örnek: “Kapı açılmadı; iki zil aynı anda mı çaldı, bir göz atalım.” Kaçınılan söylem: “Yanlış!”, “Kaybettin”, kırmızı çarpı, yıldız kesintisi, zaman cezası.

## 6. İlerleme, dünyaların açılması ve profil

### 6.1 İlerleme kapısı

- **D1** hemen oynanır. D2–D7 harita üzerinden önizlenebilir.
- Sonraki dünyanın açılması için önceki dünyada bir **Bağlantı Görevi** (temel becerilerin uygulaması) tamamlanır. Önceki dünyanın 50 görevinin tümü şart değildir. Böylece daha ileri öğrenciler gereksiz tekrar yaşamaz.
- Bağlantı Görevi ilgili dünyada temel kavramlar keşfedildikten sonra açılır; gerektiğinde **alternatif/yan görev yoluyla** erişilir.
- Önceki dünyadaki kalan görevler, yan keşifler ve kazanımlar her zaman erişilebilir. Katman değişimi veya ipucu kullanımı kapıyı geri kapatmaz.
- Bütün dünyalar bittikten sonra serbest atölye ve dönüşümlü görev havuzu açık kalır.

### 6.2 Beceri atlası

**Öğrencinin gördüğü ekran:** “Bugün sıra, döngü ve araştırma izlerini büyüttün” gibi yargılamayan bir görselleştirme. “Zayıfsın/başarısızsın/yüzdelik dilimdesin” yok.

**Yerel öneri mantığı (tasarım):** Kavramın hangi bağlamlarda görüldüğü; en son ne zaman uygulandığı; keşfedilmiş çözüm çeşitleri; isteğe bağlı yeni kavram denemesi. İpuçları bir eksiltme ölçütü değildir. Öğretmen notu veya diğer öğrenciyle kıyas yok.

### 6.3 Ödüller ve koleksiyon

- **Rozet:** İlk keşif, yeniden deneme, başkasına yardımcı olma temalı senaryo, ikinci çözüm yolu, eski beceriyi yeni yerde kullanma.
- **Karakter kartları:** Ayrı silüeti, sesi, konuşma alışkanlığı olan yan karakterler; satın alınamaz.
- **Eşya:** Görev haritası parçaları, işlevsel atölye damgaları, istasyon panosu parçaları.
- Kazanılmış ödüller geri alınmaz; kullanıcının süresi, yaşı veya ipucu tüketimi ödül kaybına yol açmaz.

### 6.4 Çoklu yerel profil ve veri güvenliği

- Kurulumda **Oyuncu 1** oluşturulur; çoklu profiller sonradan istenirse açılır, ağ hesabı yok.
- Her profilin görev durumu, kazanım koleksiyonu, ekran tercihi ve beceri atlası ayrı tutulur.
- Ayarlardan manuel dışa/içe aktarma bulunur. İçe aktarma aynı profil kimliğinde tamamlanmış görevlerin ve ödüllerin **birleşimini** yapar; yerel kayıttaki ilerleme geri gitmez.
- Aynı isimli *farklı* profil kayıtları otomatik birleştirilmez; yerel profil kimliği kullanılır. Yanlışlıkla başka çocuğun ilerlemesinin karışması önlenir.
- Kayıt sistemi atomik yazma, yedek, sürüm ve migrasyon gerektirir. Bunlar **Aşama 3'te planlanıp Aşama 4'te test edilecektir**. Cihazın fiziksel olarak kaybolması/bozulması durumunda manuel dışa aktarılmış yedek olmadan mutlak veri koruma vaat edilemez.
- Kullanıcı arayüzünde bir “ilerlemeyi sıfırla” düğmesi **yoktur**.

## 7. Oyun modları

| Mod | Tasarım amacı | Geri bildirim / güvence |
|---|---|---|
| **Hikâye** | Yedi dünyanın 350 görevlik omurgası | Her görev çevrede değişiklik bırakır |
| **Günlük Keşif** | Günde bir küçük yeni bağlam/pekiştirme | Cihaz yerel tarihinden deterministik seçim; seri/kaçırma cezası yok; eski günlük keşifler koleksiyonda tutulabilir |
| **Yarışma Simülasyonu** | Bebras benzeri akıl yürütme; robotik ve proje mantığı | **İsteğe bağlı** süre; sıralama/rekabet/eleme yok; resmî yarışmaların soruları, logoları veya onay iması kullanılmaz |
| **STEM Proje Atölyesi** | Problem → hipotez → tasarla → test → yorumla | Çoklu doğrulanabilir ölçüt, öğretmen değerlendirmesi yok |
| **Serbest Atölye** | Robot/sistem tasarla ve güvenle test et | Denemelerin sınırı yok, kaydedilebilir yerel tasarımlar |
| **Koleksiyon ve Karakter Odası** | Dünyanın kültürünü ve kazanımları tekrar ziyaret | Rozetler geri alınmaz, satın alma yok |

### Yarışma simülasyonunun etik çerçevesi

TÜBİTAK/TEKNOFEST/FLL/Bebras/Code Week **beceri alanlarından esinlenen özgün** görevler tasarlanır. Bu çalışma ilgili kurumların resmî uygulaması, resmî seçme sınavı veya doğrudan yarışma içeriği olarak sunulmaz. Gerçek güncel kurallar ileride resmî kaynaklardan ayrıca doğrulanır. Süre modu varsayılan olarak **kapalı**dır.

## 8. Ekran akışları ve etkileşim mimarisi

```text
Uygulamayı aç
  └─ İlk oynanış: D1 ilk mini görev (hesap/soru/onboarding formu yok)
       └─ D1 / görev sonuçları → Denge Atlası (dünya haritası)
            ├─ Açık dünya → keşif alanı → ajan dosyası → bulmaca → dene → gözlemle → devam
            ├─ Önizleme dünyası → kısa hikâye/çevre tasviri → haritaya dön
            ├─ İz Defteri → becerilerim / eski görevler / kazanımlar
            ├─ Atölye → serbest deney / STEM
            ├─ Günlük Keşif → kısa görev
            ├─ Yarışma Simülasyonu → isteğe bağlı süreli görev seti
            └─ Ayarlar → dil / erişilebilirlik / ses / performans / profil / yedek
```

**Oynanış HUD:** tek görev amacı; oyun alanı; işlem araçları; **Dene**, **İpucu**, **Geri Al**, **Yeniden Kur**, **Çık**. Çıkış her zaman güvenli; geri alma mevcut görevin denemelerini etkiler, kazanılmış ilerlemeyi etkilemez. Dokunmatik hedefler büyük; klavye odağı görünür; fare ile aynı eylemler yapılır.

**Telefon dikey/yatay:** Dünya sahnesi korunurken araç paneli yatayda yan sütun, dikeyde alt panel olur. **4:3 / 16:9 / 16:10 etkileşimli tahta:** Fazla genişlik yalnızca esnetme ile doldurulmaz; yan bilgi paneli veya nefes alanı olarak kullanılır. Piksel sanat ayrı tam sayı ölçekli katmandadır; okunur metinler keskin kalır.

**Ajan görevi metni:** Birincil amaç 1–2 kısa cümle. Uzun hikâye isteğe bağlı defterde. Görev dili yerelleştirilebilir ve aynı cümle kalıbı onlarca kez tekrar edilmez.

## 9. Sanat yönetimi ve Taste kalite kapısı

### 9.1 Tek bir sanat ailesi, yedi ayrı lehçe

- **Önerilen sprite ölçüsü:** ana karakterler için tutarlı piksel ızgarası; üretim sırasında örneğin 24×32 veya 32×32 aileleri test edilir. Nihai ölçü Aşama 3/dikey dilimde kararlaştırılır.
- **Görünüm:** Elle yönlendirilmiş/özgün piksel sanat; az renk, net malzeme, işlevsel ışık, bilinçli silüet. Uzak/küçük sahneler için gereksiz mikro-detay yok.
- **UI:** Godot varsayılan panel görünümü kullanılmaz; görev dosyası, harita mühürü, sekmeli defter ve işlevsel araç rafı dünyaya ait hissettirir.
- **Dünyalar:** Her biri kendi nesne şekli, zemini, ışığı, ses ritmi ve karakter cümle uzunluğuyla ayrışır. Sadece arka planın rengini değiştirmek kabul edilmez.
- **Renk:** Her sahnede denetimli 2–3 vurgu tonunu geçmeyen hiyerarşi. **Gökkuşağı geçişi veya gökkuşağı renklerinin yan yana dekoratif dizilimi yok.** Renk körlüğü erişimi desen/simge desteğiyle çözülür.
- **Yazı:** Piksel fontu tüm uzun metinlere zorla uygulamayız; Türkçe glifleri tam, gömülü, yüksek okunurluğa sahip UI yazı tipi gerekir. Pixel-art estetiği okunurluğun önüne geçmez.
- **Ses:** Bölüm başına ayırt edici kısa özgün motif ve geri bildirimler; düşük dosya/bellek bütçesi; telif kaydı; ses kapalıyken tam işlev.

### 9.2 Jenerik görünüm denetimi (her sahnede)

1. Ekranın amacı oyun içi fiziksel bir işleve dayanıyor mu, yoksa SaaS paneli gibi mi görünüyor?
2. Silüet ve malzeme kapatıldığında dünya diğerlerinden ayırt edilebiliyor mu?
3. Karakterin cümlesini başka bir karakter söyleyince hâlâ aynı mı duyuluyor? Öyleyse yeniden yaz.
4. Görünüm gereksiz parıltı, mor-mavi degrade, anlamsız simge, aynı tip yuvarlak kart ve emojiye yaslanıyor mu? Varsa çıkar.
5. Görevde oyuncunun kararı **gerçek bir görsel sistem sonucuna** yol açıyor mu?
6. Kontrast, Türkçe karakter, 4:3 ve 9:16 görünüm ve dokunmatik kontrol korunuyor mu?

**Özeleştiri örneği:** “Fener görevini aynı kartlara numara değiştirerek doldurduk” → reddet. Yerine fener perdesi, ayna açısı, rota ve ışık dizisi gibi ayrı mekanik varyasyonlar tasarla.

## 10. Erişilebilirlik — doğrudan tasarım kapsamı

- Renk tek sinyal olamaz; ikon/şekil/desen, açıklayıcı etiket ve odak çerçevesi bulunur.
- Renk görme farklılıkları için ayar profilleri ve yüksek kontrast.
- En az üç metin boyutu ve okunabilir yazı tipi seçeneği; disleksi dostu alternatifin lisans ve Türkçe karakter desteği kontrol edilir. Bir font tek başına okuma güçlüğünü çözdüğü iddia edilmez.
- Müzik, efekt ayrı ses kaydırıcıları; tamamen sessiz kullanım; sesli yönergeye bağımlı bulmaca bulunmaz.
- Azaltılmış hareket; ekran sarsıntısı ve cezalandırıcı hata animasyonu tasarlanmaz.
- Sürükle-bıraka denk **dokun-seç-yerleştir** ve klavyeyle seç/taşı/onayla.
- Büyük dokunma alanı (tasarım hedefi mobilde en az yaklaşık 48 dp); erişim alanı piksel sanattan bağımsız büyütülebilir.
- Menüde klavye odağı görünür; Esc/Geri ile çıkış güvenli.
- Her yönerge ve ipucu tekrar açılabilir; görsel anlatım esas, uzun metin isteğe bağlı.

## 11. Müfredat uyumluluğu ve öğrenme çıktıları

### 11.1 Esas kaynak ve kod disiplini

**Esas:** MEB Talim ve Terbiye Kurulu Başkanlığının **Türkiye Yüzyılı Maarif Modeli** öğretim programları. Oyun, 2026–2027'de hangi sınıfın fiilen modele geçtiğinden bağımsız olarak yayımlanmış programı referans alır. Bilişim Teknolojileri ve Yazılım (5–6), Robotik Kodlama, Türkçe, Matematik, Fen, Hayat Bilgisi, İngilizce, Sosyal Bilgiler, Görsel Sanatlar, Müzik, Teknoloji ve Tasarım ve proje odaklı dersler için ilgili program bağlantıları kontrol edilir.

- **Doğrulanan şey:** Resmî programların listede bulunması ve kapsam başlıkları.
- **Henüz doğrulanmayan şey:** Her görevle ilgili tam **öğrenme çıktısı**, alt bileşen ve kod eşleştirmesi. Bunlar bu GDD'de **DOĞRULANACAK** durumundadır; uydurma resmî kod yoktur.
- **Teslim eki:** `mufredat_eslesme_taslak.csv`, her örnek görev ailesi için *önerilen* disiplinler arası bağlantı ve doğrulama durumu taşır. Bu CSV henüz resmî onaylanmış kazanım listesi değildir.

**Resmî program dizini:** https://mufredat.meb.gov.tr/programlar.aspx  
**TYMM öğretim programları arayüzü:** https://tymm.meb.gov.tr/ogretim-programlari/temel-egitim

### 11.2 Dersler arası proje örnekleri (tümü taslak eşleşme)

| Ders / bağlam | Örnek tasarım görevi | Dünyalar | Resmî kod |
|---|---|---|---|
| İlkokul/Ortaokul Matematik | Örüntü tanı, rotayı karşılaştır, ölçütle optimizasyon | D1, D2, D5, D6 | DOĞRULANACAK |
| Hayat Bilgisi | Günlük yaşamda sıralama ve çevre düzeni | D1, D3 | DOĞRULANACAK |
| Fen Bilimleri | Nem/ışık değişkenleri, basit devre ve sistem modeli | D3, D7 | DOĞRULANACAK |
| Bilişim Teknolojileri ve Yazılım | Blok kod, hata ayıklama, sözde kod | D2, D4, D7 | DOĞRULANACAK |
| Robotik Kodlama | Algılayıcı/eyleyici, rota ve kontrol mantığı | D3, D7 | DOĞRULANACAK |
| Türkçe | Mesajı sırala, anlamı koruyarak kodu çöz | D1, D4 | DOĞRULANACAK |
| İngilizce | Kısa resimli yönergeyi doğru sıraya koy, iki dilde yol bul | D1, D4 | DOĞRULANACAK |
| Sosyal Bilgiler | Harita, karar verme ve rota planlama | D5 | DOĞRULANACAK |
| Görsel Sanatlar | Yönergeyle piksel deseni ve simetri tasarımı | D6 | DOĞRULANACAK |
| Müzik | Ritim örüntüsü ve tekrar birimleri | D2, D6 | DOĞRULANACAK |
| Teknoloji ve Tasarım | Kullanıcı gereksinimi ve sistem prototipleme | D5, D7 | DOĞRULANACAK |
| Proje Tasarımı ve Uygulamaları | Problem, hipotez, deney, yorum ve yeni tasarım | D3, D7 | DOĞRULANACAK |

**Genişlik uyarısı:** Bütün derslerin bütün sınıf düzeylerinde aynı adla zorunlu olarak okutulduğu varsayılmaz. Örneğin Bilişim Teknolojileri ve Yazılım programının resmî dizinde 5–6 olarak listelenmesi, D1'in 2. sınıf görevini otomatik olarak 2. sınıf Bilişim kazanımına dönüştürmez.

### 11.3 Öğrenmenin ölçülebilir, baskısız kanıtları

- **Sıra:** Oyuncu istenen hedefe ulaşan çalışır bir komut dizisi kurar.
- **Döngü:** Tekrarlayan işlem örüntüsünü doğru çalıştırır; aynı hedefe farklı komut sayılarıyla ulaşabilir.
- **Koşul:** En az iki durum için uygun davranışı test eder.
- **Debug:** Sapan adımı bulup bir değişiklikle hedefi yeniden sağlar.
- **Arama:** Arama stratejisini farklı küçük haritalarda uygular; adım sayısı isteğe bağlı karşılaştırılır.
- **Robotik:** Girdi değişince robot davranışının uygun şekilde değiştiğini gözlemler.
- **STEM:** Tasarım belirlenen güvenli ve işlevsel ölçütleri sağlar; gerekirse ikinci tasarım denenir.

Bunlar **oyun içi tasarım ölçütleri** olup resmî Maarif öğrenme çıktılarının kelimesi kelimesine metni değildir.

## 12. Cihazlar ve erken teknik risk kapısı

### 12.1 Hedef donanım (onay bekleyen mühendislik bütçesi)

| Sınıf | Önerilen tasarım bütçesi (hedef; test edilmiş gerçek değil) |
|---|---|
| Android A32 4G bandı | 4 GB RAM sınıfında 2D oyun; Compatibility/OpenGL ES 3.0; 30 FPS hedefi, daha iyi cihazda 60 FPS seçeneği; tek sahne 256 MB altı **hedef çalışma belleği** |
| Faz 1 Pardus/ETAP | Yaklaşık 4 GB RAM sınıfı; 2D tek sahne; 30 FPS hedefi; grafik sürücüsü/OpenGL sürümü **kritik belirsizlik** |
| Windows/Linux | 2 GB RAM ve uyumlu GPU düzeyi **asgari doğrulama adayı**, 4 GB pratik hedef |
| Kurulum boyutu | Android APK için **100–180 MB hedef aralığı** (henüz ölçülmedi; müzik/çeviri varlıklarına göre değişebilir) |
| Giriş/ekran | Android dokunmatik/dikey-yatay; fare/klavye; 4:3, 16:9, 16:10 ve mobil portre |

### 12.2 Faz 1 / Godot 4 uyuşmazlık olasılığı — öncelikli

Godot 4 Compatibility, masaüstü için **OpenGL 3.3**, Android için **OpenGL ES 3.0** sınıfında grafik desteği ister. Faz 1 olarak tanımlanan bazı Vestel tahtalarda Intel HD Graphics 3000 raporlanır; Intel'in destek tablosunda bu GPU için OpenGL **3.1** yer alır. Linux/Pardus Mesa sürücüsünün yetenekleri cihaz bazında değişebilir. Sonuç: **“Tüm Faz 1 tahtalarda Godot 4 kesin çalışır” iddiası şu anda doğrulanamaz.**

**Aşama 3 ön kararı:** Herhangi bir 350-görev üretimine başlamadan önce gerçek Faz 1 cihazında küçük bir teknik başlatma/çizim/dokunmatik test planlanır. Uyumluluk sağlanmazsa kullanıcıya gerekçeli alternatifler (mevcut motorla desteklenen donanım tabanını daraltma; en eski tahtalar için ayrı düşük sürüm hattı vb.) **ayrıca onaya sunulur**. Godot 4'ten sessizce vazgeçilmez; kanıtsız çalışıyor denmez.

**Kaynaklar:**  
- Godot 4.6 resmî gereksinimler: https://docs.godotengine.org/en/4.6/about/system_requirements.html  
- Intel desteklenen API'ler: https://www.intel.com/content/www/us/en/support/articles/000005524/graphics.html  
- Faz 1 özellikleri için ikincil referans: https://www.nedir-bu.com/fatih-projesi-faz-1-ve-faz-2-akilli-tahta-ozellikleri/  
- MEB etkileşimli tahtalar ve Pardus ETAP: https://mersinfatih.meb.gov.tr/www/fatih-projesi-kapsaminda-kullanilan-etkilesimli-tahtalar/icerik/92

## 13. Aşama 3–7 kabul ölçütlerinin GDD düzeyindeki çerçevesi

### Aşama 3 — Teknik mimari (sonraki adım, **henüz başlamadı**)
- GDScript ile veri/mantık ayrımı, görev şeması ve birden çok bulmaca ailesinin ortak API'si.
- JSON/Resource görev doğrulama ve çözülebilirlik testi; açık uçlular için otomatik ölçüt denetleyicileri.
- Yerelleştirme CSV/PO, Türkçe karakter doğrulaması, açık lisans kaydı.
- Yerel profil sürümleri, atomik yazma, ikincil yedek, veri migrasyonu ve içe aktarma birleşim kuralları.
- Build/paketleme planı: Android APK, Windows portable, Linux portable, Pardus `.deb`.
- Gerçek Faz 1 uyumluluğu için pilot test koşulları.

### Aşama 4 — Dikey dilim
**Yalnızca D1'in ilk 5 görevi**, ana menü/harita, ilk profil, güvenli kayıt, üç aşamalı ipucu, ayarlar ve Türkçe/İngilizce içeren uçtan uca test. Dosya üretildi veya test edildi iddiası yalnızca çalıştırma kanıtıyla yapılır.

### Aşama 5 — İçerik üretimi
Her dünya 50 benzersiz görev ve ilgili katman varyasyonlarıyla tamamlanır. Çözülebilirlik ve dil kontrolleri, dünyaya özgü sanat/görev metni denetimi yapılır. Her dünya sonunda kullanıcı onayı alınır.

### Aşama 6 — Yan modlar
Günlük keşif, yarışma simülasyonu, STEM atölyesi, serbest atölye, karakter/koleksiyon sistemleri ayrı testle eklenir.

### Aşama 7 — Paketleme ve cilalama
Gerçek cihaz performansı, erişilebilirlik, internet izni yokluğu, lisans, test raporu, `BUILD.md`, Pardus `.deb` meta bilgileri ve bütün hedefler için mümkün olan gerçek çalıştırma doğrulamaları.

## 14. Açık riskler ve karar bekleyenler

| Risk / konu | Durum | Önlem |
|---|---|---|
| **Faz 1 OpenGL** | **Yüksek risk, doğrulanmadı** | Erken gerçek cihaz test kapısı; mimari onaydan önce garanti yok |
| 350 görevin özgünlüğü | Tasarımda yöntem var, içerik henüz yok | Perde/ailesi/kısıt/bağlam incelemesi; tekrar denetimi |
| Maarif tam öğrenme çıktısı kodları | Resmî programlar bulundu; görev bazında **doğrulanmadı** | CSV ve bağımsız doğrulama listesi; koda resmî olmayan değer yazma yok |
| Açık uçlu otomatik değerlendirme | Tasarım ilkesi onaylı, algoritma henüz yok | Ölçülebilir çoklu kriter ve test örnekleri |
| Android 32-bit arm32 | Hedef kapsamda, build doğrulanmadı | Aşama 3'te Godot export şablonu ve gerçek cihaz doğrulaması |
| Tahtada dokunmatik | Hedef kapsamda, test edilmedi | Faz 1 ETAP üzerinde dokunmatik/ekran odak testi |
| Piksel art okunurluğu | Stil tanımlı; asset yok | Gerçek cihazda uzak mesafe ve düşük çözünürlük denemesi |
| Ses/müzik telifi | Tasarımda özgün üretim planı | Kaynak kaydı `LISANSLAR.md`, lisans denetimi |

### Tasarım onayıyla netleşecek öneriler

1. **Yedi dünya sırası ve isimleri** (çalışma başlıkları): D1 Fener, D2 Saatçiler, D3 Yaşayan İstasyon, D4 Arşiv, D5 Kesişen Yollar, D6 Ritim/Desen, D7 Yeni Gün Kenti.
2. **Her dünyada 50 ana görev, 5×10 perde** ve üç uyarlama katmanı.
3. **Dünyaların Bağlantı Görevi ile açılması**, tüm 50 görevin zorunlu tutulmaması.
4. **350 görev + sonradan yan modlar** ile dikey dilimden büyüyen üretim sırası.
5. Faz 1 uyumluluğunu bir **erken teknik karar kapısı** olarak görme; sorun varsa alternatif motor/sürüm kapsamını yeni onay olmadan değiştirmeme.

## 15. Durum bildirimi (GDD v0.1)

- **Yapılan:** Kaynak talimatlarla ve kullanıcı yanıtlarıyla tutarlı olarak ana hikâye, yedi dünyalık temel tasarım, görev/perde düzeni, beceri sarmalı, modlar, profil, erişilebilirlik, sanat yönü, müfredat taslağı ve risk kaydı **yazıldı**.
- **Test edilen:** Oyun, Godot projesi ve derleme **yok**; hiçbir oynanış, performans veya kayıt testi yapılmadı. GDD aritmetiği: **7 × 5 × 10 = 350**.
- **Bilinen sorunlar:** Faz 1 cihaz uyumluluğu ve resmî öğrenme çıktısı kodları doğrulanmadı; görev/sprite/ses dosyaları henüz üretilmedi.
- **Sonraki adım:** **Kullanıcıdan GDD onayı**. Onay sonrası Superpowers *writing-plans* ile **Aşama 3 teknik mimari ve uygulanabilir görev planı** hazırlanacak; bu aşama da ayrıca onaya sunulacak. Onaydan önce ürün kodu, Godot projesi veya üretim varlığı yazılmayacak.
