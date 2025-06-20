--build the categories info incl book count. Can limit to certain no of books if required, currently unlimited at 6000
--still has a problem with shape and funny quotes going on, need to fix this
--on command line: sqlite3 data.db < sql-query/buildcats.sql > sql-query/result/buildcats.json
--or to output valid json rather than escaped json within the arrays:
--sqlite3 data.db < sql-query/buildcats.sql | jq '.[] |= with_entries(.value |= (fromjson? // .))' > sql-query/result/buildcats.json
.mode json
with books_all as (
-- get XXX most recent books but make all reviewed and prize books included 
  select
    books.isbn_10,
    hb_publish_date,
    review_url,
    group_concat(tags.tag_emoji, ' ') as 'css filter classes',
    CASE
      WHEN group_concat(cats.pk_cat_id) LIKE '%cat-07%' THEN 'true'
      /* test to see if a prize book */
      ELSE null
    END as prize_check
  from
    books
    join books_tags on books.isbn_10 = books_tags.isbn_10
    join tags on books_tags.tag_id = tags.pk_tag_id
    join cats on tags.fk_cat_id = cats.pk_cat_id
  group by
    books.isbn_10
  order by
    review_url desc,
    prize_check desc,
    hb_publish_date desc
  limit
    6000
),
books_all_isbn_10 as (
-- just get the isbns from most recent books
  select
    isbn_10
  from
    books_all
),
tags_count as (
  /* find out which tags are used by those books */
  select
    tag_id,
    cast(count(tag_id) as text) as tag_count,
    tag_emoji,
    tag_text,
    emoji_unicode,
    tag_sort,
    fk_cat_id,
    cat_text as category
  from
    books_tags
    join tags on books_tags.tag_id = tags.pk_tag_id
    join cats on tags.fk_cat_id = cats.pk_cat_id
  where
    books_tags.isbn_10 in books_all_isbn_10
  group by
    tag_id
)
select
-- finally build the table in the shape required!
  cat_text as category,
  cat_sort as sort_order,
  json_group_array(tags_count.tag_emoji order by tag_sort asc, tag_text asc) as tag_emoji,
  json_group_array(tags_count.tag_text order by tag_sort asc, tag_text asc) as tag_name,
  json_group_array(tags_count.emoji_unicode order by tag_sort asc, tag_text asc) as emoji_unicode,
  json_group_array(tags_count.tag_count order by tag_sort asc, tag_text asc) as tag_count
from
  cats
  join tags_count on cats.pk_cat_id = tags_count.fk_cat_id
group by
  cat_text
order by
  cat_sort asc
