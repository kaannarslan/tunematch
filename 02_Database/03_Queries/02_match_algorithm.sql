	-- FILE: 02_match_algorithm.sql

	-- Test with user ID 1
	set @current_user_id = 1;

	select
		other_user.user_id,
		other_user.name,
		other_user.surname,
		((count(distinct common_artists.artist_id)*10)+(count(distinct common_genres.genre_id)*3)) as compatibility_score

	from Kullanici as other_user

	-- FOR COMMON ARTISTS
	LEFT join	(
		select t2.user_id, t2.artist_id
		from User_Favorite_Artist t1
		join User_Favorite_Artist t2 on t1.artist_id = t2.artist_id
		where t1.user_id = @current_user_id
	) as common_artists on other_user.user_id = common_artists.user_id

	-- FOR COMMON GENRES
	LEFT  join	(
		select t2.user_id, t2.genre_id
		from User_Liked_Genre t1
		join User_Liked_Genre t2 on t1.genre_id = t2.genre_id
		where t1.user_id = @current_user_id
	) as common_genres on other_user.user_id = common_genres.user_id

	where other_user.user_id != @current_user_id
	group by other_user.user_id, other_user.name, other_user.surname
	having compatibility_score > 0
	order by compatibility_score DESC           -- Best matches first
	limit 10;