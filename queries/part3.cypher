MATCH (g:Genre {name: 'Thriller'})<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(:User)
WITH m, avg(r.rating) AS avgRating, count(r) AS ratingsCount
WHERE avgRating > 4.0
RETURN m.movieId AS movieId,
    m.title AS title,
    m.year AS year,
    round(avgRating * 100) / 100.0 AS avgRating,
    ratingsCount
ORDER BY avgRating DESC, ratingsCount DESC;

MATCH (u:User)-[r:RATED {rating: 5}]->(m:Movie)
WITH u, count(DISTINCT m) AS fiveStarMoviesCount
WHERE fiveStarMoviesCount > 50
RETURN u.userId AS userId,
    u.gender AS gender,
    u.age AS age,
    u.occupation AS occupation,
    fiveStarMoviesCount
ORDER BY fiveStarMoviesCount DESC;

MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.movieId AS movieId,
    m.title AS title,
    m.year AS year,
    r1.rating AS ratingByUser1,
    r2.rating AS ratingByUser2
ORDER BY m.title;

MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(:User)
WITH g,
    avg(r.rating) AS avgRating,
    count(r) AS ratingsCount,
    count(DISTINCT m) AS moviesCount
WHERE ratingsCount >= 10000
RETURN g.name AS genre,
    round(avgRating * 1000) / 1000.0 AS avgRating,
    ratingsCount,
    moviesCount
ORDER BY avgRating DESC, ratingsCount DESC;

WITH 1 AS targetUserId
MATCH (target:User {userId: targetUserId})-[rTarget:RATED]->(commonMovie:Movie)<-[rOther:RATED]-(other:User)
WHERE other.userId <> targetUserId
    AND rTarget.rating >= 4
    AND rOther.rating >= 4
WITH target, other, count(commonMovie) AS commonHighRatedCount
ORDER BY commonHighRatedCount DESC
LIMIT 20

MATCH (other)-[rRec:RATED]->(recMovie:Movie)
WHERE rRec.rating >= 4
    AND NOT EXISTS {MATCH (target)-[:RATED]->(recMovie)}
RETURN recMovie.movieId AS movieId,
    recMovie.title AS title,
    count(DISTINCT other) AS similarUsersCount,
    sum(commonHighRatedCount) AS similarityScore,
    round(avg(rRec.rating) * 100) / 100.0 AS avgRecRating
ORDER BY similarityScore DESC, similarUsersCount DESC, avgRecRating DESC
LIMIT 10;

MATCH path = shortestPath((u1:User {userId: 1})-[:RATED*..10]-(u2:User {userId: 2}))
WHERE u1 <> u2
RETURN [n IN nodes(path) |
    CASE
    WHEN n:User THEN 'User(' + toString(n.userId) + ')'
    WHEN n:Movie THEN 'Movie(' +coalesce(n.title, '') + ')'
    ELSE reduce(acc = '', lbl IN labels(n) | CASE WHEN acc = '' THEN lbl ELSE acc + ', ' + lbl END)
    END
] AS chain,
length(path) AS hops;