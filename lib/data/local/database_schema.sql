CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL CHECK (price > 0),
  icon_key TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL
);

CREATE TABLE cart_items (
  product_id INTEGER PRIMARY KEY,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE favorites (
  product_id INTEGER PRIMARY KEY,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_count INTEGER NOT NULL,
  total INTEGER NOT NULL,
  address TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  product_name TEXT NOT NULL,
  unit_price INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE app_settings (
  setting_key TEXT PRIMARY KEY,
  setting_value TEXT NOT NULL
);

INSERT INTO products
  (id, name, category, price, icon_key, description, image_url)
VALUES
  (1, 'Сымсыз құлаққап', 'Электроника', 12990, 'headphones',
   'Күнделікті қолдануға ыңғайлы сымсыз құлаққап.',
   'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=600&q=80'),
  (2, 'Ақылды сағат', 'Электроника', 24990, 'watch',
   'Уақытты және белсенділікті бақылауға арналған сағат.',
   'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=600&q=80'),
  (3, 'Спорттық аяқкиім', 'Киім', 18990, 'directions_run',
   'Жеңіл әрі ыңғайлы спорттық аяқкиім.',
   'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80'),
  (4, 'Қалаға арналған рюкзак', 'Аксессуарлар', 9990, 'backpack',
   'Күнделікті заттарды алып жүруге арналған рюкзак.',
   'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=600&q=80'),
  (5, 'Үстел шамы', 'Үйге арналған', 7990, 'light',
   'Оқу мен жұмысқа арналған шағын үстел шамы.',
   'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=600&q=80'),
  (6, 'Bluetooth динамигі', 'Электроника', 15990, 'speaker',
   'Музыка тыңдауға арналған ықшам динамик.',
   'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=600&q=80');

PRAGMA user_version = 1;
