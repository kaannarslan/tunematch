import time
from spotify_fetcher import fetch_and_store_artist
artists_to_add = [
    # METAL & ROCK
    "Metallica", "Megadeth", "Iron Maiden", "Black Sabbath",
    "Opeth", "System of a Down", "Rammstein", "Queen",
    "Pink Floyd", "AC/DC", "Guns N' Roses", "Nirvana", "Dio", "Rainbow",
    "Ozzy Osbourne", "TOOL", "Motörhead", "Radiohead", "Dream Theater",
    "The Doors", "Anathema", "Red Hot Chili Peppers", "Arctic Monkeys",

    # POP & TÜRKÇE POP
    "The Weeknd", "Taylor Swift", "Dua Lipa", "Billie Eilish",
    "Tarkan", "Sezen Aksu", "Sertab Erener", "Manifest"

    # RAP & HIPHOP
    "Eminem", "2Pac", "Ezhel", "Ceza", "Motive", "Ice Cube", "The Notorious B.I.G",
    "Kanye West", "Post Malone", "50 Cent",

    # INDIE & ALTERNATİF (Türkçe)
    "Duman", "Adamlar", "Mor ve Ötesi", "Hardal", "Çilekeş", "Dolu Kadehi Ters Tut",
    "Gripin", "MFÖ", "Madrigal", "Athena", "Pentagram", "Can Bonomo", "Kargo", "Hayko Cepkin",
    "Şebnem Ferah", "Sakin", "Vega", "Model",

    # ARABESK
    "Müslüm Gürses"
]


def populate():
    print(f"Toplam {len(artists_to_add)} sanatçı eklenecek...")
    print("=" * 40)

    for i, artist in enumerate(artists_to_add, 1):
        try:
            print(f"\n[{i}/{len(artists_to_add)}] İşleniyor: {artist}")
            fetch_and_store_artist(artist)
            time.sleep(1)
        except Exception as e:
            print(f"❌ HATA ({artist}): {e}")

    print("\n" + "=" * 40)
    print("✅ TÜM İŞLEMLER TAMAMLANDI!")


if __name__ == "__main__":
    populate()