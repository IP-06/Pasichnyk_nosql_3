CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User) REQUIRE u.userId IS UNIQUE;

CREATE CONSTRAINT movie_id_unique IF NOT EXISTS
FOR (m:Movie) REQUIRE m.movieId IS UNIQUE;

CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (g:Genre) REQUIRE g.name IS UNIQUE;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/IP-06/nosql_3/refs/heads/main/import/users.csv' AS row
WITH row WHERE row.userId IS NOT NULL AND trim(row.userId) <> ''
MERGE (u:User {userId: toInteger(row.userId)})
SET u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/IP-06/nosql_3/refs/heads/main/import/movies.csv' AS row
WITH row WHERE row.movieId IS NOT NULL AND trim(row.movieId) <> ''
WITH row,
    CASE
        WHEN row.title IS NOT NULL AND row.title =~ '.*\\(\\d{4}\\)\\s*$'
        THEN toInteger(substring(trim(row.title), size(trim(row.title)) - 5, 4))
        ELSE null
    END AS releaseYear
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET m.title = trim(row.title),
    m.year = releaseYear,
    m.genres = CASE
    WHEN row.genres IS NULL OR trim(row.genres) = '' THEN []
    ELSE [g IN split(row.genres, '|') WHERE trim(g) <> '' | trim(g)]
    END;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/IP-06/nosql_3/refs/heads/main/import/movies.csv' AS row
WITH row WHERE row.movieId IS NOT NULL AND row.genres IS NOT NULL
MATCH (m:Movie {movieId: toInteger(row.movieId)})
UNWIND split(row.genres, '|') AS genreName
WITH m, trim(genreName) AS genreName
WHERE genreName <> ''
MERGE (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);

CALL apoc.periodic.iterate(
  "LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/IP-06/nosql_3/refs/heads/main/import/ratings.csv' AS row
   WITH row WHERE row.userId IS NOT NULL AND row.movieId IS NOT NULL
   RETURN toInteger(row.userId) AS userId,
        toInteger(row.movieId) AS movieId,
        toFloat(row.rating) AS rating,
        toInteger(row.timestamp) AS timestamp",
  "MATCH (u:User {userId: userId})
   MATCH (m:Movie {movieId: movieId})
   MERGE (u)-[r:RATED]->(m)
   SET r.rating = rating,
    r.timestamp = timestamp",
  {batchSize: 5000, parallel: false}
)
YIELD batches, total, errorMessages
RETURN batches, total, errorMessages;