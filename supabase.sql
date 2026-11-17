-- =========================================================
-- Admin Panel: хүснэгт ба эхний өгөгдөл (Supabase / PostgreSQL)
-- =========================================================

-- Нууц үг bcrypt-ээр шифрлэхэд хэрэгтэй өргөтгөл
create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------
-- 1. content_drafts — ноорог постууд
-- ---------------------------------------------------------
create table if not exists public.content_drafts (
  id          bigint generated always as identity primary key,
  title       text        not null,
  body        text,
  status      text        not null default 'draft'
              check (status in ('draft', 'review', 'published')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.content_drafts enable row level security;

insert into public.content_drafts (title, body, status) values
  ('Говийн аялал 2027',        'Өмнөговь, Хонгорын элс, Ёлын амаар дамжих 7 хоногийн аялал.', 'draft'),
  ('Хөвсгөл нуурын зун',       'Зуны улиралд Хөвсгөлд очих шилдэг 5 шалтгаан.',               'review'),
  ('Наадмын аяллын хөтөлбөр',  'Улаанбаатарт Наадам үзэх 3 өдрийн багц аялал.',               'published');

-- ---------------------------------------------------------
-- 2. bookings — аяллын захиалгууд
-- ---------------------------------------------------------
create table if not exists public.bookings (
  id              bigint generated always as identity primary key,
  customer_name   text        not null,
  customer_email  text        not null,
  customer_phone  text,
  tour_name       text        not null,
  travel_date     date        not null,
  people_count    integer     not null default 1 check (people_count > 0),
  total_price     numeric(12,2) not null default 0 check (total_price >= 0),
  status          text        not null default 'pending'
                  check (status in ('pending', 'confirmed', 'cancelled')),
  created_at      timestamptz not null default now()
);

alter table public.bookings enable row level security;

insert into public.bookings
  (customer_name, customer_email, customer_phone, tour_name, travel_date, people_count, total_price, status)
values
  ('Бат-Эрдэнэ', 'bat@example.com',    '99112233', 'Говийн аялал 2027',       '2027-06-10', 2, 3200000.00, 'confirmed'),
  ('Сарангэрэл', 'saraa@example.com',  '88112244', 'Хөвсгөл нуурын зун',      '2027-07-05', 4, 5600000.00, 'pending'),
  ('John Smith', 'john@example.com',   '95556677', 'Наадмын аяллын хөтөлбөр', '2027-07-11', 1, 1500000.00, 'cancelled');

-- ---------------------------------------------------------
-- 3. users — админ панелд нэвтрэх хэрэглэгчид
-- ---------------------------------------------------------
create table if not exists public.users (
  id             bigint generated always as identity primary key,
  email          text        not null unique,
  password_hash  text        not null,          -- bcrypt hash, жинхэнэ нууц үг биш
  created_at     timestamptz not null default now()
);

alter table public.users enable row level security;

-- Анхны хэрэглэгч (нууц үгийг bcrypt-ээр шифрлэнэ)
insert into public.users (email, password_hash) values
  ('tsengelmaa16@gmail.com', extensions.crypt('pass', extensions.gen_salt('bf')))
on conflict (email) do nothing;
