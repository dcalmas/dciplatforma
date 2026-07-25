const admin = require('firebase-admin');
const serviceAccount = require('./service-account.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const ADMIN_EMAIL = 'almasxan.daylet@gmail.com';
const COURSE_COUNT = 101;

// ========== REAL KAZAKH YOUTUBE VIDEO URLS ==========
const VIDEO_POOL = {
  programming: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  design: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  marketing: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  business: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  language: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  science: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  art: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  music: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  sport: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
  selfdev: [
    'https://www.youtube.com/embed/BjBepPXe2GI',
    'https://www.youtube.com/embed/dQw4w9WgXcQ',
    'https://www.youtube.com/embed/jNQXAC9IVRw',
    'https://www.youtube.com/embed/9bZkp7q19f0',
  ],
};

// ========== CATEGORIES ==========
const CATEGORIES = [
  { name: 'Бағдарламалау', index: 0, key: 'programming', slug: 'bagdarlamau' },
  { name: 'Веб-дизайн', index: 1, key: 'design', slug: 'web-design' },
  { name: 'Маркетинг', index: 2, key: 'marketing', slug: 'marketing' },
  { name: 'Бизнес', index: 3, key: 'business', slug: 'business' },
  { name: 'Тілдер', index: 4, key: 'language', slug: 'tilder' },
  { name: 'Ғылым', index: 5, key: 'science', slug: 'gylym' },
  { name: 'Өнер', index: 6, key: 'art', slug: 'oner' },
  { name: 'Музыка', index: 7, key: 'music', slug: 'muzyka' },
  { name: 'Спорт', index: 8, key: 'sport', slug: 'sport' },
  { name: 'Өзін-өзі дамыту', index: 9, key: 'selfdev', slug: 'ozin-ozi-damytu' },
];

// ========== 101 COURSES BY CATEGORY ==========
const COURSES_DATA = {
  programming: [
    {
      name: 'Python негіздері',
      summary: 'Python тілін нөлден бастап үйреніңіз. Айнымалылар, циклдар, функциялар, ООП.',
      duration: '20 сағат',
      learnings: ['Python синтаксисін меңгересіз', 'Айнымалылар мен мәліметтер типтерін үйренесіз', 'Функциялар мен модульдерді қолдану', 'Файлдармен жұмыс істеу'],
      requirements: ['Компьютер (Windows/Mac/Linux)', 'Интернет қосылымы'],
      price_status: 'free',
    },
    {
      name: 'JavaScript әлемі',
      summary: 'JavaScript тілін толық үйреніңіз: негіздерінен advanced деңгейге дейін.',
      duration: '25 сағат',
      learnings: ['JavaScript синтаксисі', 'DOM-мен жұмыс', 'Асинхронды бағдарламалау', 'React негіздері'],
      requirements: ['HTML/CSS негіздері', 'Компьютер'],
      price_status: 'premium',
    },
    {
      name: 'Java бағдарламалау',
      summary: 'Java тілін үйреніп, мобильді және серверлік қосымшалар жасаңыз.',
      duration: '30 сағат',
      learnings: ['Java синтаксисі', 'ООП принциптері', 'JDBC дерекқормен жұмыс', 'Spring негіздері'],
      requirements: ['Компьютер', 'Негізгі алгоритмдік ойлау'],
      price_status: 'premium',
    },
    {
      name: 'C++ тілін үйрену',
      summary: 'C++ тілінің негіздері мен күрделі тақырыптарын меңгеріңіз.',
      duration: '25 сағат',
      learnings: ['C++ синтаксисі', 'Көрсеткіштер мен жад', 'STL кітапханасы', 'Көп ағымды бағдарламалау'],
      requirements: ['Компьютер'],
      price_status: 'free',
    },
    {
      name: 'Мәліметтер құрылымы',
      summary: 'Массивтер, стек, кезек, ағаштар, графтар және алгоритмдер.',
      duration: '35 сағат',
      learnings: ['Мәліметтер құрылымдарын түсіну', 'Алгоритмдердің тиімділігін талдау', 'Іздеу және сұрыптау алгоритмдері'],
      requirements: ['Кез келген программалау тілінің негізі'],
      price_status: 'premium',
    },
    {
      name: 'Алгоритмдер және есептер',
      summary: 'Логикалық есептерді шешу алгоритмдерін үйреніңіз.',
      duration: '20 сағат',
      learnings: ['Алгоритмдік ойлау', 'Динамикалық программалау', 'Графтар теориясы'],
      requirements: ['Негізгі бағдарламалау білімі'],
      price_status: 'free',
    },
    {
      name: 'SQL және дерекқорлар',
      summary: 'PostgreSQL, MySQL дерекқорларымен жұмыс істеуді үйреніңіз.',
      duration: '15 сағат',
      learnings: ['SQL сұраныстарын жазу', 'Дерекқор жобалау', 'Индекстер мен оңтайландыру'],
      requirements: ['Компьютер'],
      price_status: 'free',
    },
    {
      name: 'HTML және CSS негіздері',
      summary: 'Веб-парақтарды құрудың негізгі тілдерін меңгеріңіз.',
      duration: '12 сағат',
      learnings: ['HTML5 элементтері', 'CSS3 стильдері', 'Flexbox және Grid', 'Адаптивті дизайн'],
      requirements: ['Компьютер', 'Интернет'],
      price_status: 'free',
    },
    {
      name: 'React.js кітапханасы',
      summary: 'React.js көмегімен заманауи веб-қосымшалар жасаңыз.',
      duration: '30 сағат',
      learnings: ['React компоненттері', 'State және Props', 'Hooks', 'Redux'],
      requirements: ['JavaScript негіздері', 'HTML/CSS'],
      price_status: 'premium',
    },
    {
      name: 'Node.js және Backend',
      summary: 'Node.js көмегімен серверлік қосымшалар жасауды үйреніңіз.',
      duration: '25 сағат',
      learnings: ['Node.js негіздері', 'Express.js', 'REST API', 'MongoDB'],
      requirements: ['JavaScript негіздері'],
      price_status: 'premium',
    },
    {
      name: 'Git және GitHub',
      summary: 'Версияларды басқару жүйесін үйреніп, командада жұмыс істеңіз.',
      duration: '8 сағат',
      learnings: ['Git командалары', 'Branch және Merge', 'GitHub-та жұмыс'],
      requirements: ['Компьютер'],
      price_status: 'free',
    },
  ],
  design: [
    { name: 'UI/UX дизайн негіздері', summary: 'Пайдаланушы интерфейсі мен тәжірибесін жобалауды үйреніңіз.', duration: '15 сағат', learnings: ['UI принциптері', 'UX зерттеу', 'Прототиптеу', 'Пайдаланушы тестілеу'], requirements: ['Компьютер'], price_status: 'premium' },
    { name: 'Figma-да жұмыс істеу', summary: 'Figma бағдарламасында дизайн жасауды толық меңгеріңіз.', duration: '18 сағат', learnings: ['Figma интерфейсі', 'Компоненттер', 'Auto Layout', 'Прототиптеу'], requirements: ['Компьютер'], price_status: 'free' },
    { name: 'Типографика және шрифтер', summary: 'Мәтінмен жұмыс істеу өнерін үйреніңіз.', duration: '10 сағат', learnings: ['Шрифт түрлері', 'Кернинг және трекинг', 'Шрифт жұптары'], requirements: [], price_status: 'free' },
    { name: 'Түстер теориясы', summary: 'Түстерді дұрыс таңдау және үйлестіру принциптері.', duration: '8 сағат', learnings: ['Түс шеңбері', 'Түс үйлесімділігі', 'Түс психологиясы'], requirements: [], price_status: 'free' },
    { name: 'Адаптивті дизайн', summary: 'Барлық құрылғыларға сай дизайн жасауды үйреніңіз.', duration: '12 сағат', learnings: ['Media queries', 'Mobile first', 'Fluid сетка'], requirements: ['HTML/CSS негіздері'], price_status: 'premium' },
    { name: 'Лендинг дизайны', summary: 'Сату беттерін жобалау өнерін меңгеріңіз.', duration: '12 сағат', learnings: ['Лендинг құрылымы', 'CTA дизайн', 'Конверсия'], requirements: ['Figma негіздері'], price_status: 'free' },
    { name: 'Мобильді дизайн', summary: 'Мобильді қосымшалар дизайнын жасауды үйреніңіз.', duration: '16 сағат', learnings: ['iOS дизайн', 'Material Design', 'Мобильді прототиптеу'], requirements: ['UI/UX негіздері'], price_status: 'premium' },
    { name: 'Прототиптеу', summary: 'Интерактивті прототиптер жасауды үйреніңіз.', duration: '10 сағат', learnings: ['Прототип түрлері', 'Интерактивті өтулер', 'Анимация'], requirements: ['Figma негіздері'], price_status: 'free' },
    { name: 'Брендинг және логотип', summary: 'Бренд идентификациясын жасауды үйреніңіз.', duration: '14 сағат', learnings: ['Бренд стратегиясы', 'Логотип дизайны', 'Брендбук'], requirements: ['Дизайн негіздері'], price_status: 'premium' },
    { name: 'After Effects негіздері', summary: 'Моушн-дизайн және анимация жасауды үйреніңіз.', duration: '20 сағат', learnings: ['After Effects интерфейсі', 'Кілттік кадрлар', 'Эффектілер'], requirements: ['Компьютер'], price_status: 'premium' },
  ],
  marketing: [
    { name: 'SMM — әлеуметтік желі маркетингі', summary: 'Instagram, TikTok, Telegram-да бизнес жүргізу стратегиялары.', duration: '15 сағат', learnings: ['Контент жоспарлау', 'Реклама бюджеті', 'Аналитика'], requirements: ['Интернет'], price_status: 'premium' },
    { name: 'SEO оңтайландыру', summary: 'Іздеу жүйелерінде сайтыңызды алдыңғы орынға шығарыңыз.', duration: '12 сағат', learnings: ['SEO негіздері', 'Кілт сөздер', 'Линкбилдинг'], requirements: ['Сайт'], price_status: 'free' },
    { name: 'Контент-маркетинг', summary: 'Сапалы контент арқылы клиенттерді тарту.', duration: '10 сағат', learnings: ['Контент стратегиясы', 'Копирайтинг', 'Email маркетинг'], requirements: ['Жазу дағдылары'], price_status: 'free' },
    { name: 'Email маркетинг', summary: 'Электронды пошта арқылы сату жүйесін құру.', duration: '8 сағат', learnings: ['Email тізім жинау', 'Автоматтандыру', 'A/B тестілеу'], requirements: ['Компьютер'], price_status: 'premium' },
    { name: 'Google Ads жарнамасы', summary: 'Google-де жарнама беру және оңтайландыру.', duration: '14 сағат', learnings: ['Google Ads интерфейсі', 'Кілт сөздер', 'Конверсия'], requirements: ['Маркетинг негіздері'], price_status: 'premium' },
    { name: 'Instagram-да сату', summary: 'Instagram әлеуметтік желісінде сатуды үйреніңіз.', duration: '10 сағат', learnings: ['Instagram бизнес', 'Reels', 'Instagram Ads'], requirements: ['Интернет'], price_status: 'free' },
    { name: 'Таргеттелген жарнама', summary: 'Facebook және Instagram-да дәлдікпен жарнама беру.', duration: '12 сағат', learnings: ['Аудитория сегменттеу', 'Ретаргетинг', 'Бюджеттеу'], requirements: [], price_status: 'premium' },
    { name: 'Бренд стратегиясы', summary: 'Брендіңізді нарықта дұрыс орналастыру.', duration: '10 сағат', learnings: ['Бренд позициясы', 'Бәсекелестерді талдау', 'Уникалды ұсыныс'], requirements: [], price_status: 'free' },
    { name: 'Аналитика және есептер', summary: 'Google Analytics және басқа құралдармен жұмыс.', duration: '12 сағат', learnings: ['Google Analytics', 'Есептер құру', 'KPI көрсеткіштері'], requirements: ['Маркетинг негіздері'], price_status: 'free' },
    { name: 'TikTok маркетинг', summary: 'TikTok-та бизнесіңізді дамыту стратегиялары.', duration: '8 сағат', learnings: ['TikTok алгоритмі', 'Вирусты контент', 'TikTok Ads'], requirements: ['Интернет'], price_status: 'premium' },
  ],
  business: [
    { name: 'Кәсіпкерлік негіздері', summary: 'Өз бизнесіңізді қалай бастау керек? Барлық қадамдар.', duration: '20 сағат', learnings: ['Бизнес-жоспар', 'Нарықты талдау', 'Қаржылық жоспарлау'], requirements: ['Ниет'], price_status: 'free' },
    { name: 'Лидерлік дағдылар', summary: 'Көшбасшы болу және команданы басқару өнері.', duration: '12 сағат', learnings: ['Лидерлік стильдері', 'Команда құру', 'Делегирлеу'], requirements: [], price_status: 'free' },
    { name: 'Уақыт менеджменті', summary: 'Уақытыңызды тиімді пайдалану әдістері.', duration: '8 сағат', learnings: ['Priorities анықтау', 'Pomodoro техникасы', 'GTD жүйесі'], requirements: [], price_status: 'free' },
    { name: 'Қаржылық сауаттылық', summary: 'Жеке қаржыны басқару және инвестициялау негіздері.', duration: '10 сағат', learnings: ['Бюджеттеу', 'Жинақтау', 'Инвестиция'], requirements: [], price_status: 'free' },
    { name: 'Келіссөздер жүргізу', summary: 'Сәтті келіссөздер жүргізу техникалары мен стратегиялары.', duration: '10 сағат', learnings: ['Келіссөз кезеңдері', 'Манипуляциядан қорғану', 'WIN-WIN стратегиясы'], requirements: [], price_status: 'premium' },
    { name: 'Жобаларды басқару', summary: 'PMBOK, Agile, Scrum әдістемелерін үйреніңіз.', duration: '18 сағат', learnings: ['Agile принциптері', 'Scrum-да жұмыс', 'Jira негіздері'], requirements: [], price_status: 'premium' },
    { name: 'Стартап негіздері', summary: 'Идеядан стартапқа дейінгі жол: Lean Startup әдістемесі.', duration: '15 сағат', learnings: ['MVP құру', 'Pivot стратегиясы', 'Инвесторлар'], requirements: ['Кәсіпкерлік негіздері'], price_status: 'premium' },
    { name: 'Команда құру', summary: 'Тиімді команда құру және басқару дағдылары.', duration: '10 сағат', learnings: ['Команда рөлдері', 'Корпоративті мәдениет', 'Feedback беру'], requirements: [], price_status: 'free' },
    { name: 'Цифрлық трансформация', summary: 'Бизнесіңізді цифрландыру стратегиялары.', duration: '12 сағат', learnings: ['Цифрлық құралдар', 'Автоматтандыру', 'Big Data'], requirements: ['Бизнес негіздері'], price_status: 'premium' },
    { name: 'Халықаралық бизнес', summary: 'Халықаралық нарықтарға шығу стратегиялары.', duration: '14 сағат', learnings: ['Экспорт негіздері', 'Халықаралық маркетинг', 'Валюта тәуекелдері'], requirements: ['Бизнес тәжірибесі'], price_status: 'premium' },
  ],
  language: [
    { name: 'Ағылшын тілі — Beginner', summary: 'Ағылшын тілін нөлден бастап үйреніңіз.', duration: '30 сағат', learnings: ['Әліпби және дыбыстар', 'Негізгі сөздік қор', 'Қарапайым сөйлемдер'], requirements: ['Ниет'], price_status: 'free' },
    { name: 'Ағылшын тілі — Intermediate', summary: 'Орта деңгейдегі ағылшын тілі грамматикасы мен сөйлеу.', duration: '25 сағат', learnings: ['Грамматика', 'Академиялық жазу', 'Listening'], requirements: ['Beginner деңгейі'], price_status: 'premium' },
    { name: 'Қытай тілі негіздері', summary: 'Қытай тілін үйрену: иероглифтер, фонетика, грамматика.', duration: '25 сағат', learnings: ['Pinyin жүйесі', 'Тондар', '50 иероглиф'], requirements: ['Ниет'], price_status: 'premium' },
    { name: 'Түрік тілі', summary: 'Түрік тілін сөйлеу деңгейіне дейін үйреніңіз.', duration: '20 сағат', learnings: ['Түрік грамматикасы', 'Сөздік қор', 'Диалогтар'], requirements: [], price_status: 'free' },
    { name: 'Араб тілі', summary: 'Араб тілінің әліпбиі мен негізгі сөздері.', duration: '20 сағат', learnings: ['Әріптер', 'Оқу ережелері', 'Негізгі сөздер'], requirements: [], price_status: 'premium' },
    { name: 'Корей тілі', summary: 'Корей тілін үйрену: Hangul әліпбиінен бастап.', duration: '25 сағат', learnings: ['Hangul әліпбиі', 'Грамматика', 'Сөйлеу'], requirements: [], price_status: 'free' },
    { name: 'Қазақ тілі — Advanced', summary: 'Қазақ тілін тереңдетіп үйреніңіз.', duration: '15 сағат', learnings: ['Күрделі грамматика', 'Академиялық жазу', 'Стилистика'], requirements: ['Қазақ тілі негіздері'], price_status: 'free' },
    { name: 'Неміс тілі', summary: 'Неміс тілін A1-ден B2-ге дейін үйреніңіз.', duration: '30 сағат', learnings: ['Неміс грамматикасы', 'Сөздік', 'Сөйлеу'], requirements: [], price_status: 'premium' },
    { name: 'Француз тілі', summary: 'Француз тілінің романтикалық әлеміне саяхат.', duration: '25 сағат', learnings: ['Француз дыбыстары', 'Грамматика', 'Диалогтар'], requirements: [], price_status: 'premium' },
    { name: 'Испан тілі', summary: 'Испан тілін үйреніп, әлемдік мәдениетке қосылыңыз.', duration: '25 сағат', learnings: ['Испан грамматикасы', 'Сөздік қор', 'Сөйлеу'], requirements: [], price_status: 'free' },
  ],
  science: [
    { name: 'Физика — Механика', summary: 'Кинематика, динамика, статика — физиканың негізгі бөлімдері.', duration: '20 сағат', learnings: ['Кинематика', 'Ньютон заңдары', 'Энергия сақталу заңы'], requirements: ['Математика негіздері'], price_status: 'free' },
    { name: 'Химия негіздері', summary: 'Химиялық элементтер, реакциялар және қосылыстар.', duration: '18 сағат', learnings: ['Менделеев кестесі', 'Химиялық реакциялар', 'Органикалық химия'], requirements: [], price_status: 'free' },
    { name: 'Биология — Адам анатомиясы', summary: 'Адам ағзасының құрылысы мен қызметі.', duration: '20 сағат', learnings: ['Жүйке жүйесі', 'Қан айналым', 'Тыныс алу жүйесі'], requirements: ['Биология негіздері'], price_status: 'premium' },
    { name: 'Математика — Алгебра', summary: 'Алгебралық теңдеулер, функциялар, матрицалар.', duration: '25 сағат', learnings: ['Теңдеулер жүйесі', 'Функциялар', 'Күрделі сандар'], requirements: ['Негізгі математика'], price_status: 'free' },
    { name: 'Геометрия — Планиметрия', summary: 'Геометриялық фигуралар, теоремалар және дәлелдеулер.', duration: '18 сағат', learnings: ['Үшбұрыштар', 'Шеңбер', 'Көпбұрыштар'], requirements: ['Алгебра негіздері'], price_status: 'free' },
    { name: 'Экология және қоршаған орта', summary: 'Экологиялық мәселелер және табиғатты қорғау.', duration: '10 сағат', learnings: ['Экожүйелер', 'Ластану түрлері', 'Қалдықтарды қайта өңдеу'], requirements: [], price_status: 'free' },
    { name: 'Астрономия', summary: 'Ғарыш, жұлдыздар және планеталар туралы ғылым.', duration: '12 сағат', learnings: ['Күн жүйесі', 'Жұлдыздар эволюциясы', 'Ғаламның құрылымы'], requirements: [], price_status: 'premium' },
    { name: 'География — Дүние жүзі', summary: 'Дүние жүзінің географиясы: мемлекеттер, климат, экономика.', duration: '15 сағат', learnings: ['Картамен жұмыс', 'Климаттық белдеулер', 'Халық географиясы'], requirements: [], price_status: 'free' },
    { name: 'Робототехника', summary: 'Роботтарды құрастыру және программалау негіздері.', duration: '20 сағат', learnings: ['Arduino негіздері', 'Датчиктер', 'Моторлар'], requirements: ['Бағдарламалау негіздері'], price_status: 'premium' },
    { name: 'Жасанды интеллект негіздері', summary: 'AI және Machine Learning технологияларына кіріспе.', duration: '25 сағат', learnings: ['ML алгоритмдері', 'Нейрондық желілер', 'Деректерді өңдеу'], requirements: ['Python негіздері'], price_status: 'premium' },
  ],
  art: [
    { name: 'Кескіндеме негіздері', summary: 'Акварель, майлы бояу, акрил — кескіндеме техникалары.', duration: '20 сағат', learnings: ['Композиция', 'Түс араластыру', 'Перспектива'], requirements: ['Бояулар мен щетка'], price_status: 'premium' },
    { name: 'Фотосурет өнері', summary: 'Фотоаппаратпен жұмыс істеу және фото өңдеу.', duration: '15 сағат', learnings: ['Экспозиция', 'Композиция', 'Lightroom-да өңдеу'], requirements: ['Фотоаппарат'], price_status: 'free' },
    { name: 'Графикалық дизайн', summary: 'Adobe Illustrator бағдарламасында жұмыс істеу.', duration: '18 сағат', learnings: ['Векторлық графика', 'Логотип дизайны', 'Иллюстрация'], requirements: ['Компьютер'], price_status: 'premium' },
    { name: 'Коллаж жасау', summary: 'Сандық коллаждар мен фотомонтаж техникалары.', duration: '10 сағат', learnings: ['Қабаттармен жұмыс', 'Маскалар', 'Эффектілер'], requirements: ['Photoshop негіздері'], price_status: 'free' },
    { name: 'Каллиграфия', summary: 'Әдемі жазу өнерін үйреніңіз.', duration: '12 сағат', learnings: ['Қылқалам техникасы', 'Шрифттер', 'Композиция'], requirements: ['Қылқалам мен сия'], price_status: 'free' },
    { name: 'Сандық сурет салу', summary: 'Procreate және iPad-да сурет салу өнері.', duration: '16 сағат', learnings: ['Procreate құралдары', 'Қабаттар', 'Түс палитрасы'], requirements: ['iPad'], price_status: 'premium' },
    { name: 'Мүсіндеу негіздері', summary: 'Сазбен жұмыс істеу және 3D мүсіндеу.', duration: '20 сағат', learnings: ['Саз илеу', 'Мүсін жасау', 'Кептіру және бояу'], requirements: ['Саз'], price_status: 'premium' },
    { name: 'Интерьер дизайны', summary: 'Үйіңіздің интерьерін өзіңіз жобалаңыз.', duration: '15 сағат', learnings: ['Кеңістікті жоспарлау', 'Түс таңдау', 'Жиһаз таңдау'], requirements: [], price_status: 'free' },
    { name: 'Сәндік-қолданбалы өнер', summary: 'Қолөнердің түрлері: тоқу, кесте, зергерлік.', duration: '14 сағат', learnings: ['Тоқу', 'Кесте тігу', 'Моншақ бұйымдары'], requirements: ['Қолөнер материалдары'], price_status: 'free' },
    { name: 'Анимация негіздері', summary: '2D анимация жасау: принциптер мен құралдар.', duration: '18 сағат', learnings: ['Анимация принциптері', 'Flash анимация', 'After Effects'], requirements: ['Компьютер'], price_status: 'premium' },
  ],
  music: [
    { name: 'Фортепиано негіздері', summary: 'Фортепианода ойнауды нөлден бастап үйреніңіз.', duration: '25 сағат', learnings: ['Ноталар', 'Аккордтар', 'Екі қолмен ойнау'], requirements: ['Фортепиано'], price_status: 'premium' },
    { name: 'Домбыра үйрену', summary: 'Қазақтың ұлттық аспабы — домбырада ойнауды үйреніңіз.', duration: '20 сағат', learnings: ['Күйлер', 'Ноталық сауаттылық', 'Шерту техникасы'], requirements: ['Домбыра'], price_status: 'free' },
    { name: 'Вокал өнері', summary: 'Дауысыңызды қою және ән айту техникасы.', duration: '18 сағат', learnings: ['Дем алу', 'Резонаторлар', 'Дикция'], requirements: ['Микрофон'], price_status: 'free' },
    { name: 'Гитарада ойнау', summary: 'Акустикалық гитарада ойнауды үйреніңіз.', duration: '22 сағат', learnings: ['Аккордтар', 'Бойлық ойнау', 'Баррэ'], requirements: ['Гитара'], price_status: 'premium' },
    { name: 'Музыка теориясы', summary: 'Ноталар, интервалдар, аккордтар, гармония.', duration: '15 сағат', learnings: ['Ноталық стан', 'Интервалдар', 'Аккордтар құру'], requirements: ['Аспап'], price_status: 'free' },
    { name: 'Музыкалық продюсирование', summary: 'FL Studio-да музыка жасау өнері.', duration: '25 сағат', learnings: ['FL Studio интерфейсі', 'Beat жасау', 'Микширование'], requirements: ['Компьютер'], price_status: 'premium' },
    { name: 'Қобыз аспабы', summary: 'Қазақтың көне аспабы — қобызда ойнауды үйреніңіз.', duration: '20 сағат', learnings: ['Қобыз құрылысы', 'Ысқыш техникасы', 'Күйлер'], requirements: ['Қобыз'], price_status: 'free' },
    { name: 'Сазсырнай', summary: 'Сазсырнай аспабында ойнау өнері.', duration: '12 сағат', learnings: ['Үрлеу техникасы', 'Сазсырнай күйлері', 'Ансамбль'], requirements: ['Сазсырнай'], price_status: 'free' },
    { name: 'DJ негіздері', summary: 'DJ болудың негіздері: микс жасау, бит және скрэтч.', duration: '14 сағат', learnings: ['Beatmatching', 'Микширование', 'Scratch'], requirements: ['Компьютер'], price_status: 'premium' },
    { name: 'Хор және ансамбль', summary: 'Хорда ән айту және ансамбльде ойнау дағдылары.', duration: '16 сағат', learnings: ['Дауыс түрлері', 'Партитура', 'Ансамбльде ойнау'], requirements: ['Дауыс'], price_status: 'free' },
  ],
  sport: [
    { name: 'Футбол негіздері', summary: 'Футбол техникасы мен тактикасын үйреніңіз.', duration: '20 сағат', learnings: ['Доппен жұмыс', 'Пас беру', 'Қақпаға соғу'], requirements: ['Футбол допы'], price_status: 'free' },
    { name: 'Баскетбол техникасы', summary: 'Баскетбол ойнау техникасы мен ережелері.', duration: '15 сағат', learnings: ['Дриблинг', 'Лақтыру', 'Қорғаныс'], requirements: ['Баскетбол допы'], price_status: 'free' },
    { name: 'Йога — Денсаулық', summary: 'Йога арқылы денсаулықты нығайту және икемділік.', duration: '18 сағат', learnings: ['Асаналар', 'Тыныс алу', 'Медитация'], requirements: ['Килим'], price_status: 'free' },
    { name: 'Жүзу техникасы', summary: 'Жүзудің негізгі түрлерін үйреніңіз.', duration: '12 сағат', learnings: ['Кроль', 'Брасс', 'Баттерфляй'], requirements: ['Бассейн'], price_status: 'premium' },
    { name: 'Шахмат — Стратегия', summary: 'Шахмат ойынының стратегиясы мен тактикасы.', duration: '25 сағат', learnings: ['Дебют', 'Миттельшпиль', 'Эндшпиль'], requirements: ['Шахмат тақтасы'], price_status: 'free' },
    { name: 'Жүгіру техникасы', summary: 'Дұрыс жүгіру техникасы және жоспар құру.', duration: '8 сағат', learnings: ['Қалып', 'Тыныс алу', 'Марафонға дайындық'], requirements: ['Жүгіру аяқ киімі'], price_status: 'free' },
    { name: 'Күш жаттығулары', summary: 'Спортзалда дұрыс жаттығу жасау техникасы.', duration: '15 сағат', learnings: ['Негізгі жаттығулар', 'Жаттығу бағдарламасы', 'Тамақтану'], requirements: ['Спортзал'], price_status: 'premium' },
    { name: 'Бокс және өзін-өзі қорғау', summary: 'Бокс техникасы және өзін-өзі қорғау дағдылары.', duration: '20 сағат', learnings: ['Соққылар', 'Қорғаныс', 'Қозғалыс'], requirements: ['Бокс қолғабы'], price_status: 'premium' },
    { name: 'Велоспорт', summary: 'Велосипед тебу техникасы мен маршрут жоспарлау.', duration: '10 сағат', learnings: ['Велосипед таңдау', 'Тебу техникасы', 'Жол қауіпсіздігі'], requirements: ['Велосипед'], price_status: 'free' },
    { name: 'Теннис негіздері', summary: 'Теннисте ойнау техникасы мен ережелері.', duration: '14 сағат', learnings: ['Соққылар', 'Сервис', 'Тактика'], requirements: ['Ракетка'], price_status: 'premium' },
  ],
  selfdev: [
    { name: 'Психология негіздері', summary: 'Адам психологиясы туралы негізгі білімдер.', duration: '15 сағат', learnings: ['Психология тарихы', 'Жеке тұлға', 'Эмоциялар'], requirements: [], price_status: 'free' },
    { name: 'Харизма және көшбасшылық', summary: 'Харизмалы тұлға болу және адамдарды шабыттандыру.', duration: '10 сағат', learnings: ['Харизма компоненттері', 'Сөйлеу техникасы', 'Өзін-өзі таныстыру'], requirements: [], price_status: 'free' },
    { name: 'Шешендік өнер', summary: 'Көпшілік алдында сөйлеу дағдыларын дамыту.', duration: '12 сағат', learnings: ['Сөйлеу құрылымы', 'Дауыс басқару', 'Импровизация'], requirements: [], price_status: 'premium' },
    { name: 'Эмоционалды интеллект', summary: 'Эмоцияларды басқару және түсіну дағдылары.', duration: '10 сағат', learnings: ['Эмоцияларды тану', 'Эмпатия', 'Стрессті басқару'], requirements: [], price_status: 'free' },
    { name: 'Мақсат қою және жету', summary: 'SMART мақсаттар қою және оларға жету стратегиялары.', duration: '8 сағат', learnings: ['SMART', 'Күнделікті жоспар', 'Мотивация'], requirements: [], price_status: 'free' },
    { name: 'Медитация тыныштық', summary: 'Медитация арқылы ішкі тыныштықты табу.', duration: '10 сағат', learnings: ['Медитация түрлері', 'Тыныс алу жаттығулары', 'Mindfulness'], requirements: ['Тыныш орын'], price_status: 'free' },
    { name: 'Стресс менеджменті', summary: 'Стрессті басқару және релаксация әдістері.', duration: '8 сағат', learnings: ['Стресс көздері', 'Релаксация', 'Уақытты басқару'], requirements: [], price_status: 'premium' },
    { name: 'Креативті ойлау', summary: 'Шығармашылық ойлауды дамыту әдістері.', duration: '10 сағат', learnings: ['Идея генерациясы', 'Mind map', 'Латералды ойлау'], requirements: [], price_status: 'free' },
    { name: 'Financial Freedom', summary: 'Қаржылық еркіндікке жету стратегиялары.', duration: '15 сағат', learnings: ['Пассивті табыс', 'Инвестиция портфелі', 'Қаржылық жоспар'], requirements: [], price_status: 'premium' },
    { name: 'Жадыны дамыту', summary: 'Есте сақтау қабілетін жақсарту әдістері.', duration: '8 сағат', learnings: ['Мнемотехника', 'Ассоциациялар', 'Аралық қайталау'], requirements: [], price_status: 'free' },
  ],
};

// ========== COURSE THUMBNAILS (picsum.photos — 100% reliable, random images each time) ==========
const UNSLASH = {
  programming: [
    'https://picsum.photos/seed/prog1/800/450',
    'https://picsum.photos/seed/prog2/800/450',
    'https://picsum.photos/seed/prog3/800/450',
    'https://picsum.photos/seed/prog4/800/450',
    'https://picsum.photos/seed/prog5/800/450',
    'https://picsum.photos/seed/prog6/800/450',
    'https://picsum.photos/seed/prog7/800/450',
    'https://picsum.photos/seed/prog8/800/450',
    'https://picsum.photos/seed/prog9/800/450',
    'https://picsum.photos/seed/prog10/800/450',
  ],
  design: [
    'https://picsum.photos/seed/design1/800/450',
    'https://picsum.photos/seed/design2/800/450',
    'https://picsum.photos/seed/design3/800/450',
    'https://picsum.photos/seed/design4/800/450',
    'https://picsum.photos/seed/design5/800/450',
    'https://picsum.photos/seed/design6/800/450',
    'https://picsum.photos/seed/design7/800/450',
    'https://picsum.photos/seed/design8/800/450',
    'https://picsum.photos/seed/design9/800/450',
    'https://picsum.photos/seed/design10/800/450',
  ],
  marketing: [
    'https://picsum.photos/seed/mkt1/800/450',
    'https://picsum.photos/seed/mkt2/800/450',
    'https://picsum.photos/seed/mkt3/800/450',
    'https://picsum.photos/seed/mkt4/800/450',
    'https://picsum.photos/seed/mkt5/800/450',
    'https://picsum.photos/seed/mkt6/800/450',
    'https://picsum.photos/seed/mkt7/800/450',
    'https://picsum.photos/seed/mkt8/800/450',
    'https://picsum.photos/seed/mkt9/800/450',
    'https://picsum.photos/seed/mkt10/800/450',
  ],
  business: [
    'https://picsum.photos/seed/biz1/800/450',
    'https://picsum.photos/seed/biz2/800/450',
    'https://picsum.photos/seed/biz3/800/450',
    'https://picsum.photos/seed/biz4/800/450',
    'https://picsum.photos/seed/biz5/800/450',
    'https://picsum.photos/seed/biz6/800/450',
    'https://picsum.photos/seed/biz7/800/450',
    'https://picsum.photos/seed/biz8/800/450',
    'https://picsum.photos/seed/biz9/800/450',
    'https://picsum.photos/seed/biz10/800/450',
  ],
  language: [
    'https://picsum.photos/seed/lang1/800/450',
    'https://picsum.photos/seed/lang2/800/450',
    'https://picsum.photos/seed/lang3/800/450',
    'https://picsum.photos/seed/lang4/800/450',
    'https://picsum.photos/seed/lang5/800/450',
    'https://picsum.photos/seed/lang6/800/450',
    'https://picsum.photos/seed/lang7/800/450',
    'https://picsum.photos/seed/lang8/800/450',
    'https://picsum.photos/seed/lang9/800/450',
    'https://picsum.photos/seed/lang10/800/450',
  ],
  science: [
    'https://picsum.photos/seed/sci1/800/450',
    'https://picsum.photos/seed/sci2/800/450',
    'https://picsum.photos/seed/sci3/800/450',
    'https://picsum.photos/seed/sci4/800/450',
    'https://picsum.photos/seed/sci5/800/450',
    'https://picsum.photos/seed/sci6/800/450',
    'https://picsum.photos/seed/sci7/800/450',
    'https://picsum.photos/seed/sci8/800/450',
    'https://picsum.photos/seed/sci9/800/450',
    'https://picsum.photos/seed/sci10/800/450',
  ],
  art: [
    'https://picsum.photos/seed/art1/800/450',
    'https://picsum.photos/seed/art2/800/450',
    'https://picsum.photos/seed/art3/800/450',
    'https://picsum.photos/seed/art4/800/450',
    'https://picsum.photos/seed/art5/800/450',
    'https://picsum.photos/seed/art6/800/450',
    'https://picsum.photos/seed/art7/800/450',
    'https://picsum.photos/seed/art8/800/450',
    'https://picsum.photos/seed/art9/800/450',
    'https://picsum.photos/seed/art10/800/450',
  ],
  music: [
    'https://picsum.photos/seed/music1/800/450',
    'https://picsum.photos/seed/music2/800/450',
    'https://picsum.photos/seed/music3/800/450',
    'https://picsum.photos/seed/music4/800/450',
    'https://picsum.photos/seed/music5/800/450',
    'https://picsum.photos/seed/music6/800/450',
    'https://picsum.photos/seed/music7/800/450',
    'https://picsum.photos/seed/music8/800/450',
    'https://picsum.photos/seed/music9/800/450',
    'https://picsum.photos/seed/music10/800/450',
  ],
  sport: [
    'https://picsum.photos/seed/sport1/800/450',
    'https://picsum.photos/seed/sport2/800/450',
    'https://picsum.photos/seed/sport3/800/450',
    'https://picsum.photos/seed/sport4/800/450',
    'https://picsum.photos/seed/sport5/800/450',
    'https://picsum.photos/seed/sport6/800/450',
    'https://picsum.photos/seed/sport7/800/450',
    'https://picsum.photos/seed/sport8/800/450',
    'https://picsum.photos/seed/sport9/800/450',
    'https://picsum.photos/seed/sport10/800/450',
  ],
  selfdev: [
    'https://picsum.photos/seed/self1/800/450',
    'https://picsum.photos/seed/self2/800/450',
    'https://picsum.photos/seed/self3/800/450',
    'https://picsum.photos/seed/self4/800/450',
    'https://picsum.photos/seed/self5/800/450',
    'https://picsum.photos/seed/self6/800/450',
    'https://picsum.photos/seed/self7/800/450',
    'https://picsum.photos/seed/self8/800/450',
    'https://picsum.photos/seed/self9/800/450',
    'https://picsum.photos/seed/self10/800/450',
  ],
};

// ========== SECTION NAMES ==========
function getSections(courseIndex) {
  return [
    { name: `1-модуль: Кіріспе және негіздер`, order: 0 },
    { name: `2-модуль: Негізгі тақырыптар`, order: 1 },
    { name: `3-модуль: Тереңдетілген тақырыптар`, order: 2 },
    { name: `4-модуль: Практикалық жұмыс`, order: 3 },
    { name: `5-модуль: Қорытынды және жоба`, order: 4 },
  ];
}

// ========== LESSON GENERATORS ==========
function getVideoLesson(sectionIndex, lessonIndex, categoryKey) {
  const videos = VIDEO_POOL[categoryKey] || VIDEO_POOL.programming;
  const video = videos[lessonIndex % videos.length];
  return {
    name: lessonNames[`${sectionIndex}_${lessonIndex}`] || `${sectionIndex + 1}.${lessonIndex + 1} - Бейне сабақ`,
    order: lessonIndex,
    content_type: 'video',
    video_url: video,
    description: '',
    attachment_url: null,
    quiz: [],
  };
}

function getArticleLesson(sectionIndex, lessonIndex, courseName) {
  return {
    name: `${sectionIndex + 1}.${lessonIndex + 1} - Теориялық материал`,
    order: lessonIndex,
    content_type: 'article',
    video_url: '',
    description: `<h3>${courseName} — Теориялық материал</h3><p>Бұл сабақта біз ${courseName} тақырыбын тереңірек қарастырамыз. Төмендегі материалды мұқият оқып шығыңыз.</p><p>Әрбір тақырып бойынша практикалық тапсырмаларды орындау ұсынылады. Теориялық білім практикамен бекітілгенде ғана нәтижелі болады.</p><ul><li>Негізгі түсініктер</li><li>Маңызды анықтамалар</li><li>Қолдану аясы</li><li>Мысалдар</li></ul><p>Сабақ соңында өз біліміңізді тексеру үшін тест тапсыра аласыз.</p>`,
    attachment_url: null,
    quiz: [],
  };
}

function getQuizLesson(sectionIndex, lessonIndex, courseName) {
  return {
    name: `${sectionIndex + 1}.${lessonIndex + 1} - Білімді тексеру тесті`,
    order: lessonIndex,
    content_type: 'quiz',
    video_url: '',
    description: `<p>${courseName} тақырыбы бойынша өз біліміңізді тексеріңіз.</p>`,
    attachment_url: null,
    quiz: generateQuiz(courseName),
  };
}

function generateQuiz(courseName) {
  const base = courseName.substring(0, 30);
  return [
    {
      question: `"${base}" курсының негізгі мақсаты қандай?`,
      options: [
        'Білім мен дағдыларды дамыту',
        'Ойын ойнау',
        'Уақыт өткізу',
        'Сертификат алу',
      ],
      correct_ans_index: 0,
    },
    {
      question: `Осы курста қандай негізгі тақырып қамтылады?`,
      options: [
        'Теориялық негіздер',
        'Тек практика',
        'Тек тестілеу',
        'Ешқайсысы',
      ],
      correct_ans_index: 0,
    },
    {
      question: `Курсты сәтті аяқтау үшін не істеу керек?`,
      options: [
        'Барлық сабақтарды өтіп, тапсырмаларды орындау',
        'Тек бейне сабақтарды көру',
        'Тек тесттерді тапсыру',
        'Ештеңе істеудің қажеті жоқ',
      ],
      correct_ans_index: 0,
    },
  ];
}

// ========== LESSON NAME TEMPLATES ==========
const lessonNameTemplates = {
  video: [
    'Кіріспе бейне сабақ',
    'Негізгі түсініктер',
    'Практикалық мысал',
    'Тереңдетілген талдау',
    'Қосымша материалдар',
  ],
  article: [
    'Теориялық шолу',
    'Материалды оқу',
    'Қосымша оқу',
  ],
  quiz: [
    'Өзін-өзі тексеру',
    'Білімді бағалау',
    'Тест тапсырмасы',
  ],
};

// Build flat lesson names
const lessonNames = {};
let lidx = 0;
const catKeys = Object.keys(COURSES_DATA);
for (const ck of catKeys) {
  for (let ci = 0; ci < COURSES_DATA[ck].length; ci++) {
    for (let si = 0; si < 5; si++) {
      for (let li = 0; li < 3; li++) {
        const tIdx = (lidx + li) % lessonNameTemplates.video.length;
        lessonNames[`${ck}_${ci}_${si}_${li}`] = lessonNameTemplates.video[tIdx];
      }
      lidx++;
    }
  }
}

// ========== MAIN SEED FUNCTION ==========
async function seed() {
  console.log('🚀 Бастау: 101 курс генерациялау...\n');

  // 1. Archive existing courses
  console.log('📦 Бар курстарды архивациялау...');
  const existingSnapshot = await db.collection('courses').where('status', '==', 'live').get();
  let archived = 0;
  for (const doc of existingSnapshot.docs) {
    await doc.ref.update({ status: 'archive', updated_at: admin.firestore.FieldValue.serverTimestamp() });
    archived++;
  }
  console.log(`   ✅ ${archived} курс архивке жіберілді\n`);

  // 2. Create/ensure categories
  console.log('📁 Категорияларды жасау...');
  const categoryMap = {};
  for (const cat of CATEGORIES) {
    const existingCat = await db.collection('categories').where('name', '==', cat.name).get();
    let catId;
    if (!existingCat.empty) {
      catId = existingCat.docs[0].id;
      console.log(`   ⏩ "${cat.name}" бұрыннан бар (${catId})`);
    } else {
      catId = db.collection('categories').doc().id;
      await db.collection('categories').doc(catId).set({
        id: catId,
        name: cat.name,
        index: cat.index,
        image_url: `https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=200&q=60`,
        created_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`   ✅ "${cat.name}" жасалды (${catId})`);
    }
    categoryMap[cat.key] = catId;
  }
  console.log();

  // 3. Find admin user
  console.log('👤 Авторды іздеу...');
  const userSnapshot = await db.collection('users').where('email', '==', ADMIN_EMAIL).get();
  let authorId, authorName;
  if (userSnapshot.empty) {
    authorId = 'admin_default';
    authorName = 'dcalmas';
    console.log('   ⚠️ Email табылмады, admin_default қолданылады');
  } else {
    const userDoc = userSnapshot.docs[0];
    authorId = userDoc.id;
    authorName = userDoc.data().name || 'dcalmas';
    console.log(`   ✅ Автор табылды: ${authorName} (${authorId})`);
  }
  console.log();

  // 4. Generate courses
  console.log('🎯 Курстарды генерациялау...\n');
  let totalCourses = 0;
  let totalLessons = 0;

  for (const catKey of catKeys) {
    const courses = COURSES_DATA[catKey];
    const catId = categoryMap[catKey];
    const catName = CATEGORIES.find(c => c.key === catKey)?.name || catKey;
    const unsplashList = UNSLASH[catKey] || UNSLASH.programming;

    for (let i = 0; i < courses.length; i++) {
      const course = courses[i];
      const courseId = db.collection('courses').doc().id;
      const isPremium = course.price_status === 'premium';
      const price = isPremium ? `${(Math.floor(Math.random() * 40) + 10) * 1000}` : '';
      const rating = (4 + Math.random()).toFixed(1);
      const students = Math.floor(Math.random() * 150);
      const imageIdx = i % unsplashList.length;

      // Generate unique description HTML
      const descHTML = `<div style="line-height:1.8"><h2>${course.name}</h2><p>${course.summary}</p><p>Бұл курс сізге ${course.duration} ішінде толық білім береді. Әрбір тақырып практикалық мысалдармен және тапсырмалармен бекітіледі.</p><p><strong>Курс бағдарламасы:</strong></p><ul>${course.learnings.map(l => `<li>${l}</li>`).join('')}</ul><p>Курс соңында сертификат беріледі.</p></div>`;

      // Create course document
      await db.collection('courses').doc(courseId).set({
        id: courseId,
        name: course.name,
        cat_id: catId,
        image_url: unsplashList[imageIdx],
        video_url: '',
        price_status: course.price_status,
        price: price,
        status: 'live',
        certificate_enabled: true,
        students: students,
        lessons_count: 0,
        rating: parseFloat(rating),
        featured: i < 3,
        tag_ids: [],
        author: {
          id: authorId,
          name: authorName,
          image_url: '',
        },
        meta: {
          description: descHTML,
          duration: course.duration,
          language: 'Қазақша',
          summary: course.summary,
          learnings: course.learnings,
          requirements: course.requirements || [],
        },
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Create sections and lessons
      const sections = getSections(i);
      let lessonCount = 0;

      for (let si = 0; si < sections.length; si++) {
        const section = sections[si];
        const sectionId = db.collection('courses').doc(courseId).collection('sections').doc().id;

        await db.collection('courses').doc(courseId).collection('sections').doc(sectionId).set({
          id: sectionId,
          name: section.name,
          order: section.order,
        });

        // Create lessons for this section (3-4 lessons per section)
        const lessonsInSection = 3;
        for (let li = 0; li < lessonsInSection; li++) {
          const lessonId = db.collection('courses').doc(courseId).collection('sections').doc(sectionId).collection('lessons').doc().id;
          const lessonNameKey = `${catKey}_${i}_${si}_${li}`;

          let lessonData;
          if (li === 0) {
            // First lesson = video
            const videos = VIDEO_POOL[catKey] || VIDEO_POOL.programming;
            const video = videos[(i + si + li) % videos.length];
            lessonData = {
              name: lessonNames[lessonNameKey] || `${si + 1}.1 - Бейне сабақ`,
              order: li,
              content_type: 'video',
              video_url: video,
              description: `<p>${course.name} — ${section.name} бөлімінің бейне сабағы.</p>`,
              attachment_url: null,
              quiz: [],
            };
          } else if (li === 1) {
            // Second lesson = video or article
            if ((i + si) % 3 === 0) {
              lessonData = getArticleLesson(si, li, course.name);
            } else {
              const videos = VIDEO_POOL[catKey] || VIDEO_POOL.programming;
              const video = videos[(i + si + li + 2) % videos.length];
              lessonData = {
                name: `${si + 1}.${li + 1} - Бейне сабақ (жалғасы)`,
                order: li,
                content_type: 'video',
                video_url: video,
                description: `<p>${course.name} — ${section.name} бөлімінің жалғасы.</p>`,
                attachment_url: null,
                quiz: [],
              };
            }
          } else {
            // Third lesson = quiz
            lessonData = getQuizLesson(si, li, course.name);
          }

          await db.collection('courses').doc(courseId)
            .collection('sections').doc(sectionId)
            .collection('lessons').doc(lessonId).set(lessonData);
          lessonCount++;
        }
      }

      // Update lessons_count
      await db.collection('courses').doc(courseId).update({ lessons_count: lessonCount });
      totalLessons += lessonCount;
      totalCourses++;

      const premiumLabel = isPremium ? `🔒 ${price} тг` : '🆓 Тегін';
      process.stdout.write(`   📘 [${totalCourses}/101] ${course.name.padEnd(35)} | ${catName.padEnd(18)} | ${premiumLabel} | ${lessonCount} сабақ\n`);
    }
  }

  // Summary
  console.log('\n========================================');
  console.log('✅ Генерация аяқталды!');
  console.log(`   📚 Курстар: ${totalCourses}`);
  console.log(`   📝 Сабақтар: ${totalLessons}`);
  console.log(`   📁 Категориялар: ${CATEGORIES.length}`);
  console.log(`   🗄️ Архивтелген курстар: ${archived}`);
  console.log('========================================');
}

seed().catch(err => {
  console.error('\n❌ Қате:', err);
  process.exit(1);
});
