--1)Start by getting a feel for the stream table and the chat table. Select the first 10 rows from each of the two tables.
SELECT *
FROM stream
LIMIT 10;

SELECT *
FROM chat
LIMIT 10;

--What are the column names?
--- STREAM: time, device_id, login, channel, country, player, game
--- CHAT: time, device_id, login, channel, country, player, game, stream_format, subscriber


--2)What are the unique games in the stream table?
SELECT DISTINCT game
FROM stream;

-- League of legends, DayZ, Dota 2, Heroes of the Storm, Counter-Strike: Global Offensive, Hearthstone: Heroes of Warcraft, The Binding of Isaac: Rebirth, Agar.io, Gaming Talk Shows,
--Rocket League, World of Tanks, ARK: Survival Evolved, SpeedRunners, Breaking Point, Duck Game, Devil May Cry 4: Special Edition, Block N Load, Fallout 3, Batman: Arkham Knight


--3)What are the unique channels in the stream table?
SELECT DISTINCT channel
FROM stream;

--frank, george, estelle, morty, kramer, jerry, helen, newman, elaine, susan


--4)Create a list of games and their number of viewers using GROUP BY.
SELECT game,
  COUNT(*)
FROM stream
GROUP BY 1
ORDER BY 2 DESC;

--What are the most popular games in the stream table? League of Legends


--5)These are some big numbers from the game League of Legends (also known as LoL). Create a list of countries and their number of LoL viewers using WHERE and GROUP BY.
SELECT country,
  COUNT(*) AS viewers
FROM stream
WHERE game = 'League of Legends'
GROUP BY 1
ORDER BY 2 DESC;

--Where are these LoL stream viewers located? Most of them in th US


--6)The player column contains the source the user is using to view the stream (site, iphone, android, etc). Create a list of players and their number of streamers.
SELECT player,
  COUNT(*) AS streamers
FROM stream
GROUP BY 1
ORDER BY 2 DESC;


--7)Create a new column named genre for each of the games. Group the games into their genres: Multiplayer Online Battle Arena (MOBA), First Person Shooter (FPS), Survival, and Other.
---Using CASE, your logic should be:
    --If League of Legends → MOBA
    --If Dota 2 → MOBA
    --If Heroes of the Storm → MOBA
    --If Counter-Strike: Global Offensive → FPS
    --If DayZ → Survival
    --If ARK: Survival Evolved → Survival
    --Else → Other
---Use GROUP BY and ORDER BY to showcase only the unique game titles.
SELECT game,
  CASE
    WHEN game = 'League of Legends' THEN 'MOBA'
    WHEN game = 'Dota 2' THEN 'MOBA'
    WHEN game = 'Heroes of the Storm' THEN 'MOBA'
    WHEN game = 'Counter-Strike: Global Offensive' THEN 'FPS'
    WHEN game = 'DayZ' THEN 'Survival'
    WHEN game = 'ARK: Survival Evolved' THEN 'Survival'
    ELSE 'Other'
  END AS 'genre',
  COUNT(*)
FROM stream
GROUP BY 1
ORDER BY 3 DESC;


--8)Let’s write a query that returns two columns:
    --The hours of the time column
    --The view count for each hour
---Lastly, filter the result with only the users in your country using a WHERE clause.
SELECT STRFTIME('%H', time) AS 'hour',
  COUNT(*) AS 'viewers'
FROM stream
WHERE country = 'ES'
GROUP BY 1
ORDER BY 2 DESC;


--9)The stream table and the chat table share a column: device_id. Let’s join the two tables on that column.
SELECT *
FROM stream
JOIN chat
  ON stream.device_id = chat.device_id;



