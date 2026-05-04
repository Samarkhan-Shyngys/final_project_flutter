import '../../domain/entities/product.dart';

const List<Product> kProducts = [
  Product(id:'p1',  name:'Картофель',             unit:'кг',   category:'vegetables', emoji:'🥔', price:45,  minOrder:5),
  Product(id:'p2',  name:'Морковь',               unit:'кг',   category:'vegetables', emoji:'🥕', price:38,  minOrder:3),
  Product(id:'p3',  name:'Капуста белокочанная',  unit:'кг',   category:'vegetables', emoji:'🥦', price:32,  minOrder:5),
  Product(id:'p4',  name:'Лук репчатый',          unit:'кг',   category:'vegetables', emoji:'🧅', price:29,  minOrder:3),
  Product(id:'p5',  name:'Свёкла',                unit:'кг',   category:'vegetables', emoji:'🟣', price:35,  minOrder:3),
  Product(id:'p6',  name:'Огурцы тепличные',      unit:'кг',   category:'vegetables', emoji:'🥒', price:85,  minOrder:2),
  Product(id:'p7',  name:'Яблоки',                unit:'кг',   category:'fruits',     emoji:'🍎', price:65,  minOrder:5),
  Product(id:'p8',  name:'Бананы',                unit:'кг',   category:'fruits',     emoji:'🍌', price:72,  minOrder:3),
  Product(id:'p9',  name:'Апельсины',             unit:'кг',   category:'fruits',     emoji:'🍊', price:95,  minOrder:3),
  Product(id:'p10', name:'Груши',                 unit:'кг',   category:'fruits',     emoji:'🍐', price:89,  minOrder:3),
  Product(id:'p11', name:'Мыло хозяйственное',    unit:'шт',   category:'supplies',   emoji:'🧼', price:25,  minOrder:5),
  Product(id:'p12', name:'Средство для посуды',   unit:'л',    category:'supplies',   emoji:'🫧', price:120, minOrder:2),
  Product(id:'p13', name:'Перчатки латексные',    unit:'пара', category:'supplies',   emoji:'🧤', price:45,  minOrder:5),
  Product(id:'p14', name:'Мешки для мусора 60л',  unit:'уп',   category:'supplies',   emoji:'🗑️', price:85,  minOrder:2),
  Product(id:'p15', name:'Жидкое мыло',           unit:'л',    category:'supplies',   emoji:'🧴', price:95,  minOrder:2),
];
