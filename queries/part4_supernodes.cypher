MATCH (n)
OPTIONAL MATCH (n)-[r]-()
WITH n, labels(n) AS labels, count(r) AS degree
ORDER BY degree DESC
LIMIT 25
RETURN labels,
    coalesce(n.userId, n.movieId, n.name) AS idOrName,
    coalesce(n.title, '') AS title,
    degree;

MATCH (u:User)-[r:RATED]->(:Movie)
WITH u, count(r) AS ratedCount
WITH collect({user: u, cnt: ratedCount}) AS rows,
    percentileCont(ratedCount, 0.25) AS q1,
    percentileCont(ratedCount, 0.75) AS q3
WITH rows, q3 + 1.5 * (q3 - q1) AS upperFence
UNWIND rows AS row
WITH row.user AS u, row.cnt AS ratedCount, upperFence
WHERE ratedCount > upperFence
RETURN u.userId AS userId,
    u.gender AS gender,
    u.age AS age,
    u.occupation AS occupation,
    ratedCount,
    round(upperFence) AS iqrUpperFence
ORDER BY ratedCount DESC;

MATCH (m:Movie)
OPTIONAL MATCH (m)<-[r:RATED]-(:User)
OPTIONAL MATCH (m)-[g:HAS_GENRE]->(:Genre)
WITH m,
    count(DISTINCT r) AS ratingsCount,
    count(DISTINCT g) AS genresCount,
    count(DISTINCT r) + count(DISTINCT g) AS totalDegree
ORDER BY totalDegree DESC
LIMIT 20
RETURN m.movieId AS movieId,
    m.title AS title,
    m.year AS year,
    ratingsCount,
    genresCount,
    totalDegree;