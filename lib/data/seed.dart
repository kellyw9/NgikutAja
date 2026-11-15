// DATA CONTOH (bukan data nyata), diambil dari desain final NgikutAja.
// Tanggal trip dan transaksi dihitung relatif terhadap hari ini supaya status
// (Diadopsi, Berjalan, Selesai) dan hitung mundur tetap masuk akal kapan pun aplikasi dibuka.
import '../core/format.dart';
import 'models.dart';

Stop _s(String start, String end, String name, Category cat, int cost, [String? photo, String? note, String? desc]) =>
    Stop(start: start, end: end, name: name, cat: cat, cost: cost, photo: photo, note: note, desc: desc);

const _m = Category.makan, _b = Category.budaya, _a = Category.alam, _so = Category.sosial, _l = Category.lainnya;

class Seed {
  Seed(this.now) : today = DateTime(now.year, now.month, now.day) {
    _build();
  }

  final DateTime now;
  final DateTime today;

  /// Transaksi transfer bank contoh dibuat 1 menit sebelum aplikasi dibuka,
  /// supaya batas bayar 15 menitnya masih berjalan.
  DateTime get _pendingAt => now.subtract(const Duration(minutes: 1));

  late final Creator me;
  late final Map<String, Creator> creators;
  late final List<Itinerary> itineraries;
  late final List<Itinerary> drafts;
  late final List<Trip> trips;
  late final List<Review> reviews;
  late final Map<String, List<Comment>> comments;
  late final List<Transaction> transactions;
  late final List<AppNotification> notifications;
  late final Map<String, List<LocalTip>> tips;
  late final List<Person> followers;
  late final List<Person> followingPeople;

  static const ratingDist = {5: 27, 4: 7, 3: 2, 2: 0, 1: 0};

  /// Penjualan bulanan "Samosir Naik Motor 2 Hari" (Jul sampai Nov).
  static const monthly = [('Jul', 2), ('Agu', 4), ('Sep', 5), ('Okt', 6), ('Nov', 1)];

  static const recentSearches = ['Danau Toba', 'Medan', 'Bukittinggi'];

  DateTime _d(int offset) => today.add(Duration(days: offset));

  void _build() {
    me = Creator(
      id: 'dinda',
      name: 'Dinda Saragi',
      handle: '@dindasaragi',
      tint: 0,
      bio: 'Anak Medan. Suka sarapan di pasar dan duduk lama di pinggir danau.',
      followers: 86,
      following: 112,
    );

    creators = {
      'rahmat': Creator(
        id: 'rahmat',
        name: 'Rahmat Siregar',
        handle: '@jalanjalanmedan',
        tint: 1,
        bio: 'Pemandu lokal Medan. Rute pagi sampai malam tanpa buang waktu di jalan.',
        followers: 1240,
        following: 75,
      ),
      'lestari': Creator(
        id: 'lestari',
        name: 'Lestari Manurung',
        handle: '@tobaslowtravel',
        tint: 3,
        bio: 'Tinggal di Samosir. Menulis rute pelan untuk yang mau menginap.',
        followers: 860,
        following: 140,
      ),
      'bayu': Creator(
        id: 'bayu',
        name: 'Bayu Prasetyo',
        handle: '@jogjahemat',
        tint: 4,
        bio: 'Keliling Jogja naik Trans Jogja dan jalan kaki.',
        followers: 2310,
        following: 98,
      ),
      'komang': Creator(
        id: 'komang',
        name: 'Komang Ayu',
        handle: '@rutebaliutara',
        tint: 2,
        bio: 'Bali bagian utara: danau, air terjun, pantai pasir hitam.',
        followers: 540,
        following: 61,
      ),
      'yosef': Creator(
        id: 'yosef',
        name: 'Yosef Ndun',
        handle: '@bajoharian',
        tint: 5,
        bio: 'Kapten kapal wisata di Labuan Bajo.',
        followers: 410,
        following: 33,
      ),
      'nadia': Creator(
        id: 'nadia',
        name: 'Nadia Kusuma',
        handle: '@bandungjadul',
        tint: 1,
        bio: 'Gedung tua, kopi, dan jalan kaki di Bandung.',
        followers: 690,
        following: 210,
      ),
    };
    final c = creators;

    final medan = Itinerary(
      id: 'medan',
      title: '3 Hari Kuliner dan Sejarah di Medan',
      city: 'Medan',
      region: 'Medan, Sumatera Utara',
      days: 3,
      cover: 'maimun',
      creator: c['rahmat']!,
      price: 0,
      adopted: 212,
      likes: 486,
      rating: 4.8,
      reviews: 36,
      tags: ['Kuliner', 'Budaya'],
      publishedAt: _d(-20),
      desc:
          'Tiga hari keliling Medan dengan urutan yang hemat jalan: pagi di istana dan masjid tua, siang di rumah saudagar, '
          'sore jalan kaki di Kesawan. Hari kedua dan ketiga fokus kuliner malam dan oleh-oleh.',
      dayTitles: ['Istana dan kota tua', 'Pasar dan kuliner malam', 'Oleh-oleh sebelum pulang'],
      plan: [
        [
          _s('07.30', '08.30', 'Soto Kesawan', _m, 35000, 'soto', 'Pesan soto ayam campur, kuahnya santan kuning.'),
          _s('09.00', '10.30', 'Istana Maimun', _b, 10000, 'maimun', 'Datang sebelum rombongan tur, sekitar jam 9.'),
          _s('10.45', '11.30', 'Masjid Raya Al-Mashun', _b, 0, 'masjidraya', 'Ada kain pinjaman di pintu masuk.'),
          _s(
            '13.00',
            '14.30',
            'Tjong A Fie Mansion',
            _b,
            35000,
            'tjongafie',
            'Ikut tur pemandu, durasi sekitar 45 menit.',
            'Rumah saudagar Tionghoa tahun 1900 di Jalan Ahmad Yani, sekarang museum dengan perabot aslinya.',
          ),
          _s('15.00', '16.00', 'Jalan kaki di Kesawan', _so, 0, 'kesawan', 'Deretan ruko tua di sepanjang Jalan Ahmad Yani.'),
          _s('16.15', '17.00', 'Bika Ambon Jalan Mojopahit', _m, 60000, 'bika', 'Beli yang ukuran kecil kalau mau dibawa pulang.'),
        ],
        [
          _s('08.00', '09.30', 'Pasar Petisah', _so, 50000),
          _s('10.30', '12.00', 'Museum Negeri Sumatera Utara', _b, 10000),
          _s('13.00', '14.00', 'Mie Aceh Titi Bobrok', _m, 75000),
          _s('19.00', '21.00', 'Makan malam seafood', _m, 250000),
        ],
        [_s('09.00', '11.00', 'Pusat oleh-oleh Jalan Mojopahit', _l, 300000), _s('12.00', '13.00', 'Makan siang sebelum ke bandara', _m, 25000)],
      ],
    );

    final toba = Itinerary(
      id: 'toba',
      title: 'Danau Toba 2 Hari Santai ala Lokal',
      city: 'Samosir',
      region: 'Samosir, Sumatera Utara',
      days: 2,
      cover: 'toba',
      creator: c['lestari']!,
      price: 25000,
      adopted: 97,
      likes: 233,
      rating: 4.9,
      reviews: 21,
      tags: ['Alam'],
      lodging: 970000,
      publishedAt: _d(-10),
      desc:
          'Rute pelan mengelilingi Samosir: kapal dari Ajibata, menginap di Tuktuk, bukit Holbung saat cuaca cerah, '
          'dan sore di pantai Parbaba.',
      dayTitles: ['Kapal, Tuktuk, dan Holbung', 'Desa adat dan pulang'],
      plan: [
        [
          _s('08.00', '09.00', 'Kapal dari Pelabuhan Ajibata', _l, 15000, null, 'Kapal berangkat tiap jam. Duduk di dek atas.'),
          _s('09.30', '11.00', 'Tuktuk Siadong', _so, 0, 'samosir', 'Titip tas di penginapan, lalu jalan kaki.'),
          _s(
            '12.30',
            '14.30',
            'Bukit Holbung',
            _a,
            10000,
            'holbung',
            'Naik 20 menit. Bawa air, tidak ada warung di atas.',
            'Bukit savana di sisi barat Samosir dengan pemandangan Danau Toba dan Pulau Tulas. Jalur naik tanah padat, licin setelah hujan.',
          ),
          _s('15.30', '17.30', 'Pantai Pasir Putih Parbaba', _a, 5000, 'parbaba', 'Sewa tikar Rp10.000 kalau mau duduk lama.'),
        ],
        [
          _s('08.00', '09.30', 'Desa Tomok', _b, 10000),
          _s('10.00', '11.30', 'Museum Huta Bolon', _b, 15000),
          _s('12.00', '13.00', 'Makan siang ikan mas arsik', _m, 60000),
          _s('14.00', '15.00', 'Kapal kembali ke Ajibata', _l, 15000),
        ],
      ],
    )..plan[0][2].address = 'Desa Hasinggahan, Samosir';

    final jogja = Itinerary(
      id: 'jogja',
      title: 'Jogja Hemat 3 Hari Naik Trans Jogja',
      city: 'Yogyakarta',
      region: 'Yogyakarta, DIY',
      days: 3,
      cover: 'prambanan',
      creator: c['bayu']!,
      price: 0,
      adopted: 341,
      likes: 702,
      rating: 4.7,
      reviews: 58,
      tags: ['Budaya', 'Kuliner'],
      desc: 'Tiga hari tanpa sewa mobil.',
      estimateSeed: 520000,
      placesSeed: 11,
      publishedAt: _d(-300),
      plan: [
        [
          _s('08.00', '10.00', 'Malioboro', _so, 0, 'malioboro'),
          _s('10.30', '12.00', 'Taman Sari', _b, 15000, 'tamansari'),
          _s('12.30', '13.30', 'Gudeg Yu Djum', _m, 30000, 'gudeg'),
        ],
      ],
    );

    itineraries = [
      medan,
      toba,
      jogja,
      Itinerary(
        id: 'bali',
        title: 'Bali Utara yang Lebih Tenang',
        city: 'Buleleng',
        region: 'Buleleng, Bali',
        days: 4,
        cover: 'bratan',
        creator: c['komang']!,
        price: 35000,
        adopted: 58,
        likes: 140,
        rating: 4.6,
        reviews: 11,
        tags: ['Alam'],
        estimateSeed: 2300000,
        placesSeed: 14,
        publishedAt: _d(-40),
      ),
      Itinerary(
        id: 'bajo',
        title: 'Labuan Bajo 3 Hari Lompat Pulau',
        city: 'Labuan Bajo',
        region: 'Manggarai Barat, NTT',
        days: 3,
        cover: 'labuanbajo',
        creator: c['yosef']!,
        price: 45000,
        adopted: 73,
        likes: 198,
        rating: 4.8,
        reviews: 17,
        tags: ['Alam'],
        estimateSeed: 3400000,
        placesSeed: 9,
        publishedAt: _d(-30),
      ),
      Itinerary(
        id: 'bandung',
        title: 'Bandung 2 Hari Gedung Tua dan Kopi',
        city: 'Bandung',
        region: 'Bandung, Jawa Barat',
        days: 2,
        cover: 'bandung',
        creator: c['nadia']!,
        price: 0,
        adopted: 129,
        likes: 266,
        rating: 4.7,
        reviews: 24,
        tags: ['Budaya'],
        estimateSeed: 640000,
        placesSeed: 8,
        publishedAt: _d(-120),
      ),
      Itinerary(
        id: 'medanmalam',
        title: 'Medan Malam: 6 Tempat Makan setelah Jam 7',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        days: 1,
        cover: 'kesawan',
        creator: c['rahmat']!,
        price: 15000,
        adopted: 64,
        rating: 4.8,
        tags: ['Kuliner'],
        placesSeed: 6,
        publishedAt: _d(-45),
      ),
      Itinerary(
        id: 'kotatua',
        title: 'Kota Tua Medan dalam Setengah Hari',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        days: 1,
        cover: 'tjongafie',
        creator: c['rahmat']!,
        price: 0,
        adopted: 140,
        rating: 4.7,
        tags: ['Budaya'],
        publishedAt: _d(-200),
      ),
      Itinerary(
        id: 'medantoba',
        title: 'Medan ke Danau Toba Lewat Jalur Darat',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        days: 3,
        cover: 'toba',
        creator: c['lestari']!,
        price: 20000,
        adopted: 41,
        rating: 4.6,
        tags: ['Alam'],
        publishedAt: _d(-60),
      ),
      Itinerary(
        id: 'samosirmotor',
        title: 'Samosir Naik Motor 2 Hari',
        city: 'Samosir',
        region: 'Samosir, Sumatera Utara',
        days: 2,
        cover: 'samosir',
        creator: me,
        price: 20000,
        adopted: 18,
        likes: 52,
        tags: ['Alam'],
        lodging: 450000,
        publishedAt: _d(-120),
        desc: 'Keliling Samosir naik motor sewaan dari Tuktuk: Holbung siang hari, sore di Parbaba, hari kedua desa adat.',
        dayTitles: ['Keliling Samosir', 'Desa adat'],
        plan: [
          [
            _s('08.00', '09.00', 'Kapal dari Pelabuhan Ajibata', _l, 15000),
            _s('09.30', '11.00', 'Sewa motor di Tuktuk', _l, 100000, 'samosir'),
            _s('12.30', '14.30', 'Bukit Holbung', _a, 10000, 'holbung', 'Naik 20 menit. Bawa air, tidak ada warung di atas.'),
            _s('15.30', '17.30', 'Pantai Pasir Putih Parbaba', _a, 5000, 'parbaba'),
          ],
          [
            _s('08.00', '09.30', 'Desa Tomok', _b, 10000),
            _s('10.00', '11.30', 'Museum Huta Bolon', _b, 15000),
            _s('13.00', '14.00', 'Kapal kembali ke Ajibata', _l, 15000),
          ],
        ],
      ),
      Itinerary(
        id: 'sarapan',
        title: 'Sarapan Medan Sebelum Jam 9',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        days: 1,
        cover: 'soto',
        creator: me,
        price: 0,
        adopted: 34,
        likes: 41,
        tags: ['Kuliner'],
        publishedAt: _d(-150),
        dayTitles: ['Sarapan'],
        plan: [
          [
            _s('07.00', '07.45', 'Soto Kesawan', _m, 35000, 'soto', 'Pesan soto ayam campur, kuahnya santan kuning.'),
            _s('08.00', '08.45', 'Bika Ambon Jalan Mojopahit', _m, 60000, 'bika'),
          ],
        ],
      ),
    ];

    drafts = [
      Itinerary(
        id: 'draft-berastagi',
        title: 'Berastagi Sehari dari Medan',
        city: 'Berastagi',
        region: 'Karo, Sumatera Utara',
        days: 1,
        cover: null,
        creator: me,
        isDraft: true,
        plan: [[]],
        dayTitles: [''],
      ),
      Itinerary(
        id: 'draft-sarapan',
        title: 'Sarapan Medan Sebelum Jam 9 (revisi)',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        days: 1,
        cover: 'soto',
        creator: me,
        isDraft: true,
        tags: ['Kuliner'],
        desc: 'Versi baru dengan tambahan lontong pagi.',
        dayTitles: ['Sarapan'],
        plan: [
          [_s('07.00', '07.45', 'Soto Kesawan', _m, 35000, 'soto')],
        ],
      ),
    ];

    final dinda = Member(name: 'Dinda Saragi', handle: '@dindasaragi', role: MemberRole.owner, tint: 0);

    trips = [
      Trip(
        id: 'toba-kampus',
        title: 'Danau Toba bareng teman kampus',
        city: 'Samosir',
        region: 'Samosir, Sumatera Utara',
        start: today,
        cover: 'toba',
        from: toba,
        plan: copyPlan(toba.plan),
        dayTitles: [...toba.dayTitles],
        members: [
          dinda,
          Member(name: 'Kevin Tambunan', handle: '@kevintbn', role: MemberRole.editor, tint: 2, joined: _fmt(_d(-3))),
          Member(name: 'Sari Lubis', handle: '@sarilubis', role: MemberRole.viewer, tint: 3, joined: _fmt(_d(-3))),
        ],
        expenses: [
          Expense(id: 'e1', name: 'Tiket kapal Ajibata', cat: ExpenseCat.transportasi, amount: 45000, by: 'Dinda', day: 0, time: '08.05'),
          Expense(id: 'e2', name: 'Sarapan di Tuktuk', cat: ExpenseCat.makan, amount: 96000, by: 'Kevin', day: 0, time: '09.50'),
          Expense(id: 'e3', name: 'Sewa motor setengah hari', cat: ExpenseCat.transportasi, amount: 120000, by: 'Dinda', day: 0, time: '11.55'),
          Expense(id: 'e4', name: 'Tiket Bukit Holbung', cat: ExpenseCat.tiket, amount: 30000, by: 'Sari', day: 0, time: '12.40'),
        ],
        packing: [
          PackGroup('Dokumen', [PackItem('KTP', true), PackItem('Tiket kapal (foto)', true)]),
          PackGroup('Pakaian', [PackItem('Jaket tipis untuk pagi di Holbung', true), PackItem('Sandal pantai'), PackItem('Kaos ganti 2', true)]),
          PackGroup('Elektronik', [PackItem('Power bank', true), PackItem('Kabel charger')]),
          PackGroup('Lainnya', [PackItem('Botol minum'), PackItem('Sunscreen', true), PackItem('Obat pribadi')]),
        ],
        checkins: {'0-0': '08.06', '0-1': '09.42'},
        story:
            'Dua hari keliling Samosir bareng Kevin dan Sari. Rencananya ngikut itinerary Kak Lestari, '
            'tapi hari pertama kami tambah sewa motor.',
        journal: {
          0: JournalEntry(
            title: 'Kapal jam 8, langsung ke Tuktuk',
            text:
                'Kapal dari Ajibata penuh anak sekolah. Di Tuktuk kami sarapan dulu, terus sewa motor buat ke Holbung. '
                'Kabutnya baru hilang jam 12.',
            photos: ['samosir', 'holbung'],
          ),
        },
        offline: true,
        offlineSize: 14,
        syncedAt: '07.58',
      ),
      Trip(
        id: 'medan-libur',
        title: '3 Hari Kuliner dan Sejarah di Medan',
        city: 'Medan',
        region: 'Medan, Sumatera Utara',
        start: _d(38),
        cover: 'maimun',
        from: medan,
        plan: copyPlan(medan.plan),
        dayTitles: [...medan.dayTitles],
        desc: 'Liburan sekolah bareng Mama dan adik. Fokus kuliner, jangan terlalu banyak jalan siang.',
        members: [Member(name: dinda.name, handle: dinda.handle, role: MemberRole.owner, tint: 0)],
      ),
      Trip(
        id: 'jogja-sep',
        title: 'Jogja Hemat 3 Hari Naik Trans Jogja',
        city: 'Yogyakarta',
        region: 'Yogyakarta, DIY',
        start: _d(-45),
        cover: 'prambanan',
        from: jogja,
        plan: [copyPlan(jogja.plan).first, [], []],
        members: [Member(name: dinda.name, handle: dinda.handle, role: MemberRole.owner, tint: 0)],
        photos: [
          TripPhoto(src: 'malioboro', day: 0, caption: 'Malioboro', time: '08.31'),
          TripPhoto(src: 'tamansari', day: 0, caption: 'Taman Sari', time: '10.52'),
          TripPhoto(src: 'gudeg', day: 0, caption: 'Gudeg Yu Djum', time: '12.47'),
          TripPhoto(src: 'prambanan', day: 1, caption: 'Candi Prambanan', time: '16.20'),
        ],
        seedPlaces: 11,
        seedVisited: 10,
        seedSpending: 612000,
        recapNote: (2, 'Prambanan jam 4 sore ternyata pas, matahari sudah turun dan rombongan tur sekolah sudah pulang.'),
      ),
    ];

    reviews = [
      Review(
        name: 'Yohana Pardede',
        tint: 2,
        stars: 5,
        date: 'Okt 2026',
        text: 'Urutannya pas. Jam 9 di Istana Maimun memang masih sepi, jadi bisa foto tanpa antre.',
      ),
      Review(
        name: 'Arif Nasution',
        tint: 4,
        stars: 5,
        date: 'Sep 2026',
        text: 'Soto Kesawan enak, tapi datang jam 7.30 sudah ramai. Bika Ambon yang direkomendasikan beda dari yang di bandara.',
      ),
      Review(
        name: 'Meiliana',
        tint: 5,
        stars: 4,
        date: 'Agu 2026',
        text: 'Hari kedua agak padat kalau bawa anak kecil. Kami geser museum ke hari ketiga.',
      ),
    ];

    comments = {
      'medan': [
        Comment(name: 'Putri Hasibuan', tint: 3, time: '2 jam lalu', text: 'Tjong A Fie buka hari Senin nggak, Bang?'),
        Comment(
          name: 'Rahmat Siregar',
          tint: 1,
          time: '1 jam lalu',
          text: 'Buka setiap hari, jam 9 sampai 17.',
          creator: true,
          replyTo: 'Putri Hasibuan',
        ),
        Comment(name: 'Dodi Ginting', tint: 4, time: 'Kemarin', text: 'Bika Ambon Mojopahit cepat habis kalau sore, mending beli pagi.'),
      ],
    };

    final bali = itineraries.firstWhere((x) => x.id == 'bali');
    final bajo = itineraries.firstWhere((x) => x.id == 'bajo');
    transactions = [
      Transaction(
        id: _trx(_d(-5), '0977'),
        item: bajo,
        date: _d(-5).add(const Duration(hours: 21, minutes: 2)),
        method: 'E-Wallet',
        amount: 45000,
        status: TxStatus.gagal,
      ),
      Transaction(id: _trx(today, '0103'), item: bali, date: _pendingAt, method: 'Transfer Bank', amount: 35000, status: TxStatus.pending),
    ];
    final pendingTime = fromMinutes(_pendingAt.hour * 60 + _pendingAt.minute);

    final yday = weekdaysLong[_d(-1).weekday - 1];
    notifications = [
      AppNotification(
        id: 'n1',
        kind: NotifKind.reminder,
        icon: 'alarm',
        lead: '30 menit lagi: ',
        text: 'Bukit Holbung pukul 12.30. Jaraknya 6,4 km dari posisimu.',
        time: '12.00',
        today: true,
        unread: true,
      ),
      AppNotification(
        id: 'n2',
        kind: NotifKind.invite,
        icon: 'group',
        lead: '@rinaharahap',
        text: ' mengundangmu ke trip "Medan Kuliner Akhir Tahun".',
        time: '10.15',
        today: true,
        unread: true,
      ),
      AppNotification(
        id: 'n3',
        kind: NotifKind.payment,
        icon: 'receipt_long',
        lead: 'Pembayaran menunggu: ',
        text: 'Bali Utara yang Lebih Tenang, ${rp(35000)} via Transfer Bank.',
        time: pendingTime,
        today: true,
      ),
      AppNotification(
        id: 'n4',
        kind: NotifKind.departure,
        icon: 'luggage',
        lead: 'Besok berangkat. ',
        text: 'Trip "Danau Toba bareng teman kampus" mulai ${weekdaysLong[today.weekday - 1]}, ${today.day} ${monthsShort[today.month - 1]}.',
        time: '$yday 19.00',
        today: false,
      ),
      AppNotification(
        id: 'n5',
        kind: NotifKind.like,
        icon: 'favorite',
        lead: '@putrihsb',
        text: ' dan 4 orang lain menyukai "Samosir Naik Motor 2 Hari".',
        time: '$yday 15.20',
        today: false,
      ),
      AppNotification(
        id: 'n6',
        kind: NotifKind.comment,
        icon: 'chat_bubble',
        lead: '@dodiginting',
        text: ' berkomentar: "Motor sewaan di Tuktuk ada yang matic?"',
        time: '$yday 09.12',
        today: false,
      ),
    ];

    tips = {
      'Samosir': [
        LocalTip(
          icon: 'directions_car',
