from dotenv import load_dotenv
import base64
import requests
import mysql.connector
from mysql.connector import Error
import os

load_dotenv()

SPOTIFY_CLIENT_ID = os.getenv("SPOTIFY_CLIENT_ID")
SPOTIFY_CLIENT_SECRET = os.getenv("SPOTIFY_CLIENT_SECRET")

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

#===============
# DB CONNECTION
#===============

def get_db_connection():
    return mysql.connector.connect(
        host = DB_HOST,
        user = DB_USER,
        password = DB_PASSWORD,
        database = DB_NAME,
        charset = "utf8mb4",
    )

#===============
# SPOTIFY AUTH
#===============

def get_acces_token() -> str:
    url = "https://accounts.spotify.com/api/token"
    auth_str = f"{SPOTIFY_CLIENT_ID}:{SPOTIFY_CLIENT_SECRET}"
    b64_auth = base64.b64encode(auth_str.encode()).decode()
    headers = {"Authorization": f"Basic {b64_auth}"}
    data = {"grant_type": "client_credentials"}

    resp = requests.post(url, headers=headers, data=data)
    resp.raise_for_status()
    return resp.json()["access_token"]

# ==========================
# HELPER: NORMALIZE DATE
# ==========================

def normalize_date(release_date : str | None) -> str | None :
    if not release_date:
        return None
    if len(release_date) == 4:      #YYYY
        return release_date + "-01-01"
    if len(release_date) == 7:      #YYYY-MM
        return release_date + "-01"
    if len(release_date) == 10:     #YYYY-MM-DD
        return release_date
    return None

# ==========================
# MAIN FETCH + INSERT LOGIC
# ==========================

def fetch_and_store_artist(artist_name: str):
    print(f"Searching artist: {artist_name} ...")
    token = get_acces_token()
    headers = {"Authorization": f"Bearer {token}"}

    # 1) Search Artist
    search_url = "https://api.spotify.com/v1/search"
    params = {"q": artist_name, "type": "artist", "limit": 1}

    r = requests.get(search_url, headers=headers, params=params)
    r.raise_for_status()
    items = r.json()["artists"]["items"]

    if not items:
        print(f"No artist found for '{artist_name}' ")
        return

    artist = items[0]
    spotify_artist_id = artist["id"]
    name = artist["name"]
    popularity = artist["popularity"]
    genres = artist.get("genres", [])

    print(f"Found artist: {name} (Spotify ID: {spotify_artist_id})")

    conn = get_db_connection()
    cur = conn.cursor()

    # 2) add/update artist

    cur.execute(
        """
               INSERT INTO Artist (name, country, popularity_score, spotify_id)
               VALUES (%s, %s, %s, %s)
               ON DUPLICATE KEY UPDATE
                   name = VALUES(name),
                   popularity_score = VALUES(popularity_score)
               """,
        (name, None, popularity, spotify_artist_id),
    )
    conn.commit()

    # DB'deki artist_id'yi al
    cur.execute(
        "SELECT artist_id FROM Artist WHERE spotify_id = %s",
        (spotify_artist_id,),
    )
    artist_db_id = cur.fetchone()[0]

    # 3) Genre and Artist_Genre
    for g in genres:
        cur.execute("INSERT IGNORE INTO Genre (name) VALUES (%s)", (g,))
        conn.commit()
        cur.execute("SELECT genre_id FROM Genre WHERE name = %s", (g,))
        genre_id = cur.fetchone()[0]

        cur.execute(
            "INSERT IGNORE INTO Artist_Genre (artist_id, genre_id) VALUES (%s, %s)",
            (artist_db_id, genre_id),
        )
        conn.commit()

    print(f"Inserted/updated artist + {len(genres)} genres")

    # 4) Albums
    albums_url = f"https://api.spotify.com/v1/artists/{spotify_artist_id}/albums"
    params = {
        "include_groups": "album,single",
        "market": "US",
        "limit": 20,
    }
    r = requests.get(albums_url, headers=headers, params=params)
    r.raise_for_status()
    albums = r.json()["items"]

    print(f"Found {len(albums)} albums/singles")

    for album in albums:
        album_spotify_id = album["id"]
        album_title = album["name"]
        album_release = normalize_date(album.get("release_date"))
        images = album.get("images") or []
        cover_url = images[0]["url"] if images else None

        # Albüm var mı?
        cur.execute(
            "SELECT album_id FROM Album WHERE title = %s AND artist_id = %s",
            (album_title, artist_db_id),
        )
        row = cur.fetchone()
        if row:
            album_db_id = row[0]
        else:
            cur.execute(
                """
                INSERT INTO Album (title, artist_id, release_date, cover_url)
                VALUES (%s, %s, %s, %s)
                """,
                (album_title, artist_db_id, album_release, cover_url),
            )
            conn.commit()
            album_db_id = cur.lastrowid

        # 5) Songs
        tracks_url = f"https://api.spotify.com/v1/albums/{album_spotify_id}/tracks"
        t_resp = requests.get(tracks_url, headers=headers, params={"limit": 50})
        t_resp.raise_for_status()
        tracks = t_resp.json()["items"]

        for track in tracks:
            track_spotify_id = track["id"]
            track_title = track["name"]
            duration_ms = track.get("duration_ms")
            duration_seconds = int(duration_ms / 1000) if duration_ms else None

            cur.execute(
                """
                INSERT INTO Song
                    (title, artist_id, album_id, duration_seconds, release_date, spotify_id)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                    title = VALUES(title),
                    duration_seconds = VALUES(duration_seconds),
                    album_id = VALUES(album_id),
                    release_date = VALUES(release_date)
                """,
                (
                    track_title,
                    artist_db_id,
                    album_db_id,
                    duration_seconds,
                    album_release,
                    track_spotify_id,
                ),
            )
        conn.commit()
        print(f"  Inserted/updated {len(tracks)} tracks from album '{album_title}'")

    cur.close()
    conn.close()
    print("Done.")

# ==========================
# ENTRY POINT
# ==========================
if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print('Usage: python spotify_fetcher.py "Artist Name"')
        sys.exit(1)

    artist_name_arg = " ".join(sys.argv[1:])
    fetch_and_store_artist(artist_name_arg)