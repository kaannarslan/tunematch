# TuneMatch 🎵

TuneMatch is a music-based matching platform built as a database course project.  
It combines **Spotify data** (artists, albums, tracks, genres) with a **relational schema** and basic **social/matching features** (follows, matches, listening history, preferences).

This repo contains:

- Full **database schema** (`MySQL + InnoDB`)
- **Data generation** scripts using the **Spotify Web API**
- Project structure placeholders for **backend** and **frontend**
- Example SQL queries and test utilities

---

## 🧱 Tech Stack

- **Database:** MySQL 8.x (InnoDB, utf8mb4)
- **DB Client:** DBeaver (recommended)
- **Backend scripts:** Python 3.10+ (for now: data generation)
- **External API:** Spotify Web API (Client Credentials Flow)

---

## 📁 Project Structure

```text
BIL372_TuneMatch
├── 01_Documentation
│   ├── Ara_Rapor.pdf
│   └── Son_Rapor.pdf
│
├── 02_Database
│   ├── 01_Schema
│   │   ├── create_database.sql
│   │   ├── create_tables.sql
│   │   └── create_indexes.sql
│   │
│   ├── 02_Data
│   │   ├── CSV
│   │   │   ├── genres.csv
│   │   │   ├── artists.csv
│   │   │   ├── songs.csv
│   │   │   └── users.csv
│   │   └── load_data.sql
│   │
│   ├── 03_Queries
│   │   ├── 01_basic_queries.sql
│   │   ├── 02_match_algorithm.sql
│   │   ├── 03_statistics.sql
│   │   └── 04_test_queries.sql
│   │
│   └── 04_DBeaver_Projects
│       └── tunematch.dbeaver
│
├── 03_Scripts
│   ├── data_generation
│   │   ├── spotify_fetcher.py
│   │   ├── requirements.txt
│   │   └── (local) .env  ← NOT committed, used for secrets
│   │
│   └── data_loading
│       └── load_csv_to_db.py
│
├── 04_Backend
├── 05_Frontend
└── 06_Tests
    └── test_queries.sql


