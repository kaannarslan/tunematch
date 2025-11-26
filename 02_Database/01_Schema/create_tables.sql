-- ============================================
-- 1. USER
-- ============================================
create table Kullanici(
	user_id INT primary key auto_increment,
	name VARCHAR(50) not null,
	surname VARCHAR(50) not null,
	email VARCHAR(50) unique not null,
	password_hash VARCHAR(255) not null,
	birth_date DATE,
	sex ENUM('M', 'F', 'Other'),
	city VARCHAR(50),
	profile_photo VARCHAR(255),
	biography TEXT,
	kayit_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
	CHECK (birth_date > '1920-01-01')
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 2. GENRE
-- ============================================
create table Genre(
	genre_id INT primary key auto_increment,
	name VARCHAR(50) unique not null
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 3. ARTIST
-- ============================================
create table Artist(
	artist_id INT primary key auto_increment,
	name VARCHAR(100) not null,
	country VARCHAR(50),
	popularity_score INT ,
	spotify_id VARCHAR(50) unique,
	check (popularity_score between 0 and 100)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 4. ALBUM
-- ============================================
CREATE TABLE Album (
    album_id     INT PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(150) NOT NULL,
    artist_id    INT NOT NULL,
    release_date DATE,
    cover_url    VARCHAR(255),
    CONSTRAINT fk_album_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 5. SONG
-- ============================================
CREATE TABLE Song (
    song_id          INT PRIMARY KEY AUTO_INCREMENT,
    title            VARCHAR(200) NOT NULL,
    artist_id        INT NOT NULL,
    album_id         INT NULL,
    duration_seconds INT,
    release_date     DATE,
    spotify_id       VARCHAR(50) UNIQUE,
    CONSTRAINT fk_song_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_song_album
        FOREIGN KEY (album_id)
        REFERENCES Album(album_id)
        ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 6. ARTIST_GENRE  (many-to-many)
-- ============================================
CREATE TABLE Artist_Genre (
    artist_id INT NOT NULL,
    genre_id  INT NOT NULL,
    PRIMARY KEY (artist_id, genre_id),
    CONSTRAINT fk_ag_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ag_genre
        FOREIGN KEY (genre_id)
        REFERENCES Genre(genre_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 7. LISTENING_HISTORY  (user <-> song)
-- ============================================
CREATE TABLE Listening_History (
    user_id        INT NOT NULL,
    song_id        INT NOT NULL,
    play_count     INT NOT NULL DEFAULT 1,
    last_played    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP()
                                 ON UPDATE CURRENT_TIMESTAMP(),
    favorite       BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_id, song_id),
    CONSTRAINT fk_lh_user
        FOREIGN KEY (user_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_lh_song
        FOREIGN KEY (song_id)
        REFERENCES Song(song_id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 8. USER_FAVORITE_ARTIST
-- ============================================
CREATE TABLE User_Favorite_Artist (
    user_id   INT NOT NULL,
    artist_id INT NOT NULL,
    level     INT,
    added_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (user_id, artist_id),
    CONSTRAINT fk_ufa_user
        FOREIGN KEY (user_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ufa_artist
        FOREIGN KEY (artist_id)
        REFERENCES Artist(artist_id)
        ON DELETE CASCADE,
    CHECK (level BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 9. USER_LIKED_GENRE
-- ============================================
CREATE TABLE User_Liked_Genre (
    user_id      INT NOT NULL,
    genre_id     INT NOT NULL,
    preference   INT,
    PRIMARY KEY (user_id, genre_id),
    CONSTRAINT fk_ulg_user
        FOREIGN KEY (user_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_ulg_genre
        FOREIGN KEY (genre_id)
        REFERENCES Genre(genre_id)
        ON DELETE CASCADE,
    CHECK (preference BETWEEN 1 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 10. MATCH
-- ============================================
CREATE TABLE Match_Table (
    match_id            INT PRIMARY KEY AUTO_INCREMENT,
    user1_id            INT NOT NULL,
    user2_id            INT NOT NULL,
    compatibility_score DECIMAL(5,2) NOT NULL,
    matched_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    status              ENUM('pending','accepted','rejected')
                            NOT NULL DEFAULT 'pending',
    CONSTRAINT fk_match_user1
        FOREIGN KEY (user1_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_match_user2
        FOREIGN KEY (user2_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CHECK (user1_id < user2_id),
    CHECK (compatibility_score BETWEEN 0 AND 100),
    CONSTRAINT uq_match_pair UNIQUE (user1_id, user2_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- 11. FOLLOW
-- ============================================
CREATE TABLE Follow (
    follower_id  INT NOT NULL,
    following_id INT NOT NULL,
    followed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP(),
    PRIMARY KEY (follower_id, following_id),
    CONSTRAINT fk_follow_follower
        FOREIGN KEY (follower_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_follow_following
        FOREIGN KEY (following_id)
        REFERENCES Kullanici(user_id)
        ON DELETE CASCADE,
    CHECK (follower_id <> following_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================
-- FOR TESTING
-- ============================================
SELECT * FROM Artist;
SELECT * FROM Album;
SELECT * FROM Song;
SELECT * FROM Genre;
SELECT * FROM Artist_Genre;

-- ============================================
-- FOR DELETE TESTS
-- ============================================
DELETE FROM Artist_Genre;
DELETE FROM Song;
DELETE FROM Album;
DELETE FROM Genre;
DELETE FROM Artist;

-- Eğer diğer tablolarda veri varsa:
DELETE FROM Listening_History;
DELETE FROM User_Favorite_Artist;
DELETE FROM User_Liked_Genre;
DELETE FROM Match_Table;
DELETE FROM Follow;

