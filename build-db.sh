sqlite-utils insert data.db books ./data/popular-history-books.tsv --tsv --pk isbn_10
sqlite-utils insert data.db books_tags ./data/books-tags.csv --csv
sqlite-utils insert data.db quotes ./data/quotes.tsv --tsv
sqlite-utils insert data.db tags ./data/tags.csv --csv --pk pk_tag_id
sqlite-utils insert data.db cats ./data/cats.csv --csv --pk pk_cat_id
