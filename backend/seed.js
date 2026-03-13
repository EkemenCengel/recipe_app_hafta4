require('dotenv').config();
const mongoose = require('mongoose');
const connectDB = require('./config/db');
const Recipe = require('./models/Recipe');
const User = require('./models/User');

const recipes = [
  {
    title: 'Mercimek Çorbası',
    category: 'Çorba',
    ingredients: ['1 su bardağı kırmızı mercimek', '1 adet soğan', '1 yemek kaşığı salça', 'Tuz', 'Nane'],
    steps: ['Mercimekleri yıkayın.', 'Soğanı kavurun.', 'Salçayı ekleyin.', 'Mercimek ve suyu ekleyip kaynatın.', 'Blenderdan geçirin.'],
    duration: 35,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&q=80&w=400',
    rating: 4.3,
    reviews: 35000
  },
  {
    title: 'Karnıyarık',
    category: 'Ana Yemek',
    ingredients: ['4 adet patlıcan', '300g kıyma', '2 adet soğan', '2 diş sarımsak', '1 yemek kaşığı salça', 'Tuz', 'Karabiber'],
    steps: ['Patlıcanları alacalı soyup kızartın.', 'Soğan ve sarımsağı kavurun.', 'Kıymayı ekleyin.', 'Harcı patlıcanlara doldurup fırınlayın.'],
    duration: 60,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1599020791404-5f43db544865?auto=format&fit=crop&q=80&w=400',
    rating: 4.8,
    reviews: 60000
  },
  {
    title: 'Lahmacun',
    category: 'Ara Sıcak',
    ingredients: ['Un', 'Su', 'Maya', '300g kıyma', '2 adet domates', '2 adet biber', 'Maydanoz', 'Tuz', 'Baharatlar'],
    steps: ['Hamuru yoğurup dinlendirin.', 'İç harcı hazırlayın.', 'Hamurları açıp harcı yayın.', 'Fırında veya tavada pişirin.'],
    duration: 90,
    servings: 10,
    image: 'https://images.unsplash.com/photo-1627308595171-d2b512c00a9d?auto=format&fit=crop&q=80&w=400',
    rating: 4.5,
    reviews: 90000
  },
  {
    title: 'Baklava',
    category: 'Tatlı',
    ingredients: ['Baklavalık yufka', 'Ceviz veya fıstık', 'Tereyağı', 'Şerbet (Su ve şeker)'],
    steps: ['Yufkaları aralarına yağ sürerek tepsiye dizin.', 'Ortasına ceviz serpin.', 'Dilimleyip fırınlayın.', 'Sıcak tatlıya soğuk şerbet dökün.'],
    duration: 120,
    servings: 12,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
    rating: 5.0,
    reviews: 120000
  },
  {
    title: 'İskender Kebap',
    category: 'Ana Yemek',
    ingredients: ['Döner eti', 'Pide', 'Tereyağı', 'Domates sosu', 'Yoğurt'],
    steps: ['Pideleri küp doğrayıp tabağa dizin.', 'Üzerine etleri koyun.', 'Domates sosunu gezdirin.', 'Kızgın tereyağı dökün.', 'Yanında yoğurtla servis yapın.'],
    duration: 45,
    servings: 2,
    image: 'https://images.unsplash.com/photo-1598514982205-f36b96d1ea8d?auto=format&fit=crop&q=80&w=400',
    rating: 4.9,
    reviews: 80000
  },
  {
    title: 'Sütlaç',
    category: 'Tatlı',
    ingredients: ['1 litre süt', '1 su bardağı şeker', 'Yarım çay bardağı pirinç', '2 yemek kaşığı nişasta', 'Vanilya'],
    steps: ['Pirinci haşlayın.', 'Süt ve şekeri ekleyip kaynatın.', 'Nişastayı suyla açıp süte ekleyin.', 'Kıvam alana kadar pişirin.', 'Kaselere pay edip fırında üzerini kızartın.'],
    duration: 45,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400', // Reusing dessert image for demo
    rating: 4.6,
    reviews: 45000
  },
  {
    title: 'Kuru Fasulye',
    category: 'Ana Yemek',
    ingredients: ['2 su bardağı kuru fasulye', '1 soğan', '200g kuşbaşı et', '2 yemek kaşığı salça', 'Sıvı yağ', 'Tuz'],
    steps: ['Fasulyeleri akşamdan ıslatın.', 'Eti kavurun, soğanları ekleyin.', 'Salçayı katıp kavurmaya devam edin.', 'Fasulyeleri süzelek ekleyin.', 'Sıcak su ilave edip düdüklüde pişirin.'],
    duration: 50,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1548943487-a2e4142f615e?auto=format&fit=crop&q=80&w=400',
    rating: 4.7,
    reviews: 55000
  },
  {
    title: 'Pirinç Pilavı',
    category: 'Ara Sıcak',
    ingredients: ['2 su bardağı baldo pirinç', '2 yemek kaşığı tereyağı', '2 yemek kaşığı sıvı yağ', 'Tuz', 'Sıcak su'],
    steps: ['Pirinci yıkayıp ılık tuzlu suda bekletin.', 'Tencerede yağları eritip pirinci kavurun.', 'Üzerine sıcak su ve tuz ekleyin.', 'Suyunu çekene kadar kısık ateşte pişirin.', 'Demlenmeye bırakın.'],
    duration: 25,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1631515243349-e0cb45bb3d15?auto=format&fit=crop&q=80&w=400',
    rating: 4.5,
    reviews: 30000
  },
  {
    title: 'Ezogelin Çorbası',
    category: 'Çorba',
    ingredients: ['1 çay bardağı kırmızı mercimek', '1 yemek kaşığı bulgur', '1 yemek kaşığı pirinç', '1 soğan', '1 tatlı kaşığı nane', 'Salça'],
    steps: ['Soğanları kavurup salça ekleyin.', 'Yıkanmış bakliyatları tencereye alın.', 'Sıcak su ilave edin.', 'Baharatları katıp kaynamaya bırakın.'],
    duration: 40,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&q=80&w=400',
    rating: 4.4,
    reviews: 20000
  },
  {
    title: 'Tavuk Şiş',
    category: 'Ana Yemek',
    ingredients: ['500g tavuk göğsü', 'Yoğurt', 'Salça', 'Sıvı yağ', 'Kekik', 'Pul biber'],
    steps: ['Tavukları küp doğrayın.', 'Sos malzemeleriyle marine edin.', 'Şişlere dizin.', 'Mangalda veya fırında pişirin.'],
    duration: 35,
    servings: 3,
    image: 'https://images.unsplash.com/photo-1626200419189-3b567b458ae5?auto=format&fit=crop&q=80&w=400',
    rating: 4.8,
    reviews: 48000
  },
  {
    title: 'İçli Köfte',
    category: 'Ara Sıcak',
    ingredients: ['2 su bardağı ince bulgur', '1 çay bardağı irmik', 'Sicak su', '200g kıyma', 'Ceviz'],
    steps: ['Bulgur ve irmiği ıslatın.', 'İç harcı için kıymayı kavurup soğutun.', 'Hamuru yoğurun.', 'Küçük parçalar alıp içlerini doldurun.', 'Kızgın yağda veya haşlayarak pişirin.'],
    duration: 90,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1626200419189-3b567b458ae5?auto=format&fit=crop&q=80&w=400',
    rating: 4.9,
    reviews: 70000
  },
  {
    title: 'Mantı',
    category: 'Ana Yemek',
    ingredients: ['Un', 'Su', 'Tuz', 'Yumurta', '200g kıyma', 'Soğan', 'Karabiber'],
    steps: ['Hamuru sertçe yoğurun.', 'İç harcını çiğden hazırlayın.', 'Hamuru ince açıp karelere kesin.', 'İç koyup kapatın.', 'Suda haşlayıp sarımsaklı yoğurtla servis yapın.'],
    duration: 120,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?auto=format&fit=crop&q=80&w=400',
    rating: 5.0,
    reviews: 130000
  },
  {
    title: 'Mücver',
    category: 'Ara Sıcak',
    ingredients: ['3 adet kabak', '2 adet yumurta', 'Yarım su bardağı un', 'Dereotu', 'Taze soğan', 'Tuz'],
    steps: ['Kabakları rendeleyip suyunu sıkın.', 'Diğer malzemeleri ekleyip karıştırın.', 'Tavada yağ kızdırın.', 'Karışımdan kaşıkla dökerek kızartın.'],
    duration: 30,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1548943487-a2e4142f615e?auto=format&fit=crop&q=80&w=400',
    rating: 4.3,
    reviews: 25000
  },
  {
    title: 'Künefe',
    category: 'Tatlı',
    ingredients: ['250g tel kadayıf', '150g tuzsuz peynir', '100g tereyağı', 'Şerbet'],
    steps: ['Kadayıfı tereyağıyla harmanlayın.', 'Tepsinin altına yarısını bastırın.', 'Ortasına peyniri serin.', 'Kalan kadayıfı üzerine kapatın.', 'Ocakta iki yüzü kızarana kadar pişirin, şerbeti dökün.'],
    duration: 40,
    servings: 2,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
    rating: 4.9,
    reviews: 95000
  },
  {
    title: 'Adana Kebap',
    category: 'Ana Yemek',
    ingredients: ['500g kuzu kıyma', 'Kuyruk yağı', 'Kırmızı taze biber', 'Pul biber', 'Tuz'],
    steps: ['Malzemeleri zırhla veya elinizle iyice yoğurun.', 'Geniş şişlere saplayın.', 'Mangal ateşinde pişirin.', 'Lavaş ve soğan piyazıyla servis edin.'],
    duration: 45,
    servings: 3,
    image: 'https://images.unsplash.com/photo-1598514982205-f36b96d1ea8d?auto=format&fit=crop&q=80&w=400',
    rating: 4.8,
    reviews: 85000
  },
  {
    title: 'Zeytinyağlı Yaprak Sarma',
    category: 'Ara Sıcak',
    ingredients: ['Asma yaprağı', 'Pirinç', 'Soğan', 'Zeytinyağı', 'Kuş üzümü', 'Çam fıstığı', 'Nane', 'Limon'],
    steps: ['Soğanları yağda kavurun, fıstıkları ekleyin.', 'Pirinci ekleyip kavurun.', 'Baharatları koyup demleyin.', 'Yapraklara içi sarın.', 'Tencereye dizip limon dilimleriyle pişirin.'],
    duration: 120,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1627308595171-d2b512c00a9d?auto=format&fit=crop&q=80&w=400',
    rating: 4.7,
    reviews: 62000
  },
  {
    title: 'Hünkar Beğendi',
    category: 'Ana Yemek',
    ingredients: ['Közlenmiş patlıcan', 'Süt', 'Tereyağı', 'Un', 'Kaşar peyniri', 'Kuşbaşı et', 'Domates', 'Biber'],
    steps: ['Eti domates ve biberle kavurup soteleyin.', 'Ayrı bir yerde un kavurup sütle beşamel sos yapın.', 'Patlıcanı ve kaşarı sosa katın (Beğendi).', 'Tabağa beğendi yayılıp ortasına eti koyun.'],
    duration: 60,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1599020791404-5f43db544865?auto=format&fit=crop&q=80&w=400',
    rating: 4.9,
    reviews: 58000
  },
  {
    title: 'Şekerpare',
    category: 'Tatlı',
    ingredients: ['2 yumurta', '125g tereyağı', 'Yarım su bardağı pudra şekeri', 'İrmik', 'Un', 'Şerbet', 'Fındık'],
    steps: ['Hamur malzemelerini yoğurun.', 'Ceviz büyüklüğünde parçalar koparıp yuvarlayın.', 'Ortalarına fındık batırın.', 'Fırında pişirin.', 'Fırından çıkan sıcak tatlıya ılık şerbet dökün.'],
    duration: 45,
    servings: 8,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
    rating: 4.5,
    reviews: 32000
  },
  {
    title: 'Çiğ Köfte (Etsiz)',
    category: 'Ara Sıcak',
    ingredients: ['2 su bardağı ince siyah bulgur', 'İsot', 'Salça', 'Ceviz', 'Nar ekşisi', 'Zeytinyağı', 'Limon'],
    steps: ['Bulguru sıcak suyla ıslatın.', 'Salça, isot ve baharatlarla iyice yoğurun.', 'Zeytinyağı, ceviz ve nar ekşisini katıp yoğurmaya devam edin.', 'Elinizle sıkarak şekil verin.', 'Marul ve limonla sunun.'],
    duration: 45,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1626200419189-3b567b458ae5?auto=format&fit=crop&q=80&w=400',
    rating: 4.6,
    reviews: 80000
  },
  {
    title: 'Fırın Sütlaç',
    category: 'Tatlı',
    ingredients: ['Süt', 'Şeker', 'Pirinç', 'Nişasta'],
    steps: ['Sütlaç pişirin.', 'Isıya dayanıklı kaplara doldurun.', 'Fırın tepsisine biraz su koyup kapları yerleştirin.', 'Üzerleri yanana kadar yüksek ısıda fırınlayın.'],
    duration: 45,
    servings: 6,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
    rating: 4.8,
    reviews: 42000
  },
  {
    title: 'Tarhana Çorbası',
    category: 'Çorba',
    ingredients: ['3 yemek kaşığı tarhana', '1 tatlı kaşığı salça', 'Nane', 'Tereyağı', 'Su', 'Tuz'],
    steps: ['Tarhanayı biraz soğuk suda çözdürün.', 'Tencerede yağı eritip nane ve salçayı hafif kavurun.', 'Suyu ve tarhanayı ekleyip sürekli karıştırarak kaynatın.', 'Kıvam alınca ocağı kapatın.'],
    duration: 20,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&q=80&w=400',
    rating: 4.7,
    reviews: 67000
  },
  {
    title: 'Karnıyarık (Etli)',
    category: 'Ana Yemek',
    ingredients: ['Patlıcan', 'Kuşbaşı et', 'Domates', 'Biber', 'Soğan', 'Sarımsak'],
    steps: ['Patlıcanları kızartın.', 'Eti biber ve soğanla soteleyin.', 'Patlıcanların içini açın ve etli harcı doldurun.', 'Tepsiye dizip üzerine domates sosu ile fırınlayın.'],
    duration: 65,
    servings: 4,
    image: 'https://images.unsplash.com/photo-1599020791404-5f43db544865?auto=format&fit=crop&q=80&w=400',
    rating: 4.6,
    reviews: 58000
  },
  {
    title: 'Güllaç',
    category: 'Tatlı',
    ingredients: ['1 paket güllaç yaprağı', '2 litre süt', '2.5 su bardağı şeker', 'Ceviz', 'Gül suyu', 'Nar'],
    steps: ['Süt ve şekeri ılıtın.', 'Güllaç yapraklarını şerbetle ıslatarak tepsiye dizin.', 'Ara kata bol ceviz dökün.', 'Üzerini kalan yapraklarla örtün.', 'Şerbeti döküp dinlendirin. Narla süsleyin.'],
    duration: 30,
    servings: 8,
    image: 'https://images.unsplash.com/photo-1590080875515-8a3a8dc5735e?auto=format&fit=crop&q=80&w=400',
    rating: 4.9,
    reviews: 98000
  }
];

const seedDB = async () => {
    try {
        await connectDB();
        
        // Clear collections
        await Recipe.deleteMany({});
        await User.deleteMany({});
        console.log('Database cleared');

        // Insert recipes
        await Recipe.insertMany(recipes);
        console.log('Recipes seeded successfully');

        process.exit();
    } catch (error) {
        console.error('Error seeding data:', error);
        process.exit(1);
    }
}

seedDB();
