-- Nepal Districts Seed Data
-- All 77 districts across 7 provinces
-- Coordinates are approximate district headquarters locations

USE lifelink_db;

INSERT INTO districts (name, province, latitude, longitude) VALUES

-- Province No. 1 (Koshi Province)
('Taplejung',    'Koshi',        27.3546,  87.6699),
('Panchthar',    'Koshi',        27.1433,  87.7960),
('Ilam',         'Koshi',        26.9115,  87.9249),
('Jhapa',        'Koshi',        26.5369,  87.8970),
('Morang',       'Koshi',        26.6636,  87.4354),
('Sunsari',      'Koshi',        26.6360,  87.1700),
('Dhankuta',     'Koshi',        26.9834,  87.3401),
('Terhathum',    'Koshi',        27.1127,  87.5404),
('Sankhuwasabha','Koshi',        27.5577,  87.2977),
('Bhojpur',      'Koshi',        27.1763,  87.0471),
('Solukhumbu',   'Koshi',        27.6611,  86.6616),
('Okhaldhunga',  'Koshi',        27.3088,  86.4990),
('Khotang',      'Koshi',        27.0248,  86.8299),
('Udayapur',     'Koshi',        26.8843,  86.5340),

-- Madhesh Province
('Saptari',      'Madhesh',      26.5860,  86.9108),
('Siraha',       'Madhesh',      26.6533,  86.2110),
('Dhanusha',     'Madhesh',      26.8200,  85.9300),
('Mahottari',    'Madhesh',      26.6400,  85.7700),
('Sarlahi',      'Madhesh',      26.9600,  85.5800),
('Rautahat',     'Madhesh',      27.0190,  85.2600),
('Bara',         'Madhesh',      27.0510,  85.0200),
('Parsa',        'Madhesh',      27.1400,  84.8800),

-- Bagmati Province
('Sindhuli',     'Bagmati',      27.2550,  85.9690),
('Ramechhap',    'Bagmati',      27.3264,  86.0850),
('Dolakha',      'Bagmati',      27.6700,  86.1200),
('Sindhupalchok','Bagmati',      27.9530,  85.6850),
('Kavrepalanchok','Bagmati',     27.5736,  85.5347),
('Lalitpur',     'Bagmati',      27.6644,  85.3188),
('Bhaktapur',    'Bagmati',      27.6710,  85.4298),
('Kathmandu',    'Bagmati',      27.7172,  85.3240),
('Nuwakot',      'Bagmati',      27.9144,  85.1710),
('Rasuwa',       'Bagmati',      28.1000,  85.3600),
('Dhading',      'Bagmati',      27.8687,  84.9006),
('Makwanpur',    'Bagmati',      27.4333,  85.0167),
('Chitwan',      'Bagmati',      27.5291,  84.3542),

-- Gandaki Province
('Gorkha',       'Gandaki',      28.0000,  84.6333),
('Manang',       'Gandaki',      28.6697,  84.0197),
('Mustang',      'Gandaki',      29.1804,  83.9554),
('Myagdi',       'Gandaki',      28.4740,  83.5680),
('Kaski',        'Gandaki',      28.2096,  83.9856),
('Lamjung',      'Gandaki',      28.2248,  84.3954),
('Tanahu',       'Gandaki',      27.9180,  84.2620),
('Nawalpur',     'Gandaki',      27.6900,  84.1200),
('Syangja',      'Gandaki',      28.0940,  83.8810),
('Parbat',       'Gandaki',      28.2316,  83.7000),
('Baglung',      'Gandaki',      28.2720,  83.5888),

-- Lumbini Province
('Rupandehi',    'Lumbini',      27.5009,  83.4591),
('Kapilvastu',   'Lumbini',      27.5700,  83.0600),
('Arghakhanchi', 'Lumbini',      27.9580,  83.1530),
('Gulmi',        'Lumbini',      28.0860,  83.2630),
('Palpa',        'Lumbini',      27.8650,  83.5460),
('Nawalparasi East','Lumbini',   27.6100,  83.9100),
('Nawalparasi West','Lumbini',   27.7100,  83.6900),
('Rolpa',        'Lumbini',      28.2790,  82.8990),
('Pyuthan',      'Lumbini',      28.1000,  82.8500),
('Dang',         'Lumbini',      28.0500,  82.3300),
('Banke',        'Lumbini',      28.0700,  81.6200),
('Bardiya',      'Lumbini',      28.3400,  81.5100),

-- Karnali Province
('Dolpa',        'Karnali',      29.0500,  82.8300),
('Mugu',         'Karnali',      29.5200,  82.1400),
('Humla',        'Karnali',      29.9600,  81.8200),
('Jumla',        'Karnali',      29.2744,  82.1838),
('Kalikot',      'Karnali',      29.0800,  81.6600),
('Dailekh',      'Karnali',      28.8400,  81.6900),
('Jajarkot',     'Karnali',      28.7050,  82.1950),
('Rukum East',   'Karnali',      28.5860,  82.6220),
('Salyan',       'Karnali',      28.3660,  82.1710),
('Surkhet',      'Karnali',      28.6060,  81.6360),

-- Sudurpashchim Province
('Rukum West',   'Sudurpashchim',28.5500,  82.4700),
('Rolpa West',   'Sudurpashchim',28.8200,  81.1800),
('Achham',       'Sudurpashchim',29.0700,  81.1700),
('Doti',         'Sudurpashchim',29.2600,  80.9600),
('Bajhang',      'Sudurpashchim',29.5500,  81.1800),
('Bajura',       'Sudurpashchim',29.4400,  81.4900),
('Kailali',      'Sudurpashchim',28.6200,  80.5700),
('Kanchanpur',   'Sudurpashchim',28.8400,  80.1300),
('Dadeldhura',   'Sudurpashchim',29.2900,  80.5800),
('Baitadi',      'Sudurpashchim',29.5300,  80.4100),
('Darchula',     'Sudurpashchim',29.8500,  80.5500);
