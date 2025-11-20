CREATE INDEX idx_artist_name ON Artist(name);
CREATE INDEX idx_song_title ON Song(title);
CREATE INDEX idx_song_artist ON Song(artist_id);
CREATE INDEX idx_lh_user  ON Listening_History(user_id);
CREATE INDEX idx_lh_date  ON Listening_History(last_played);
CREATE INDEX idx_match_score ON Match_Table(compatibility_score);