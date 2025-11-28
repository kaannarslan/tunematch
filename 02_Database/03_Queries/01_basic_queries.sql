-- FILE: 01_basic_queries

use tunematch

-- 1. USER REGISTRATION
-- Password hashing is handled by the backend before insertion.

insert into Kullanici (name, surname, email, password_hash, birth_date, sex, city)
values ('Test', 'User', 'test@example.com', 'hashed_secret_password', '2000-01-01', 'M', 'Istanbul');

-- 2. USER LOGIN
-- The backend compares the stored hash with the input password.

select user_id, name, surname, password_hash
from Kullanici
where email = 'test@example.com'

-- 3. UPDATE PROFILE

update Kullanici
set city = 'Ankara',
	biography ='Çilekeş severim.',
	profile_photo = 'new_photo_url.jpg'
where user_id = 1;												-- current handled via python param

-- 4. SEARCH

-- a) Search Artist

select artist_id, name, popularity_score
from Artist
where name like '%Mega%'
order by popularity_score desc;

-- b) Search song

select s.song_id, s.title, a.name as artist_name
from Song s
join Artist a on s.artist_id = a.artist_id
where s.title like '%Symphony%'
limit 20;

-- 5. ADD FAVORITE ARTIST

insert into User_Favorite_Artist (user_id, artist_id, level)
values (1, 15, 10) 												-- User 1 adds Artist 15 with level 10
on DUPLICATE key update level = 10;

-- 6. HOMEPAGE STATISTICS

select name, popularity_score
from Artist
order by popularity_score desc
limit 5;

