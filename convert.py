import csv

with open('movies.dat', encoding = 'latin-1') as f_in, \
     open('movies.csv', 'w', newline = '', encoding = 'utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['movieId', 'title', 'genres'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts)

with open('ratings.dat', encoding = 'latin-1') as f_in, \
     open('ratings.csv', 'w', newline='', encoding = 'utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['userId', 'movieId', 'rating', 'timestamp'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts)

with open('users.dat', encoding = 'latin-1') as f_in, \
     open('users.csv', 'w', newline='', encoding = 'utf-8') as f_out:
    writer = csv.writer(f_out)
    writer.writerow(['userId', 'gender', 'age', 'occupation'])
    for line in f_in:
        parts = line.strip().split('::')
        writer.writerow(parts[:4])