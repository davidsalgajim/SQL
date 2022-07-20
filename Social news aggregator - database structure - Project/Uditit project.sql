-- CREATING TABLES

CREATE TABLE "users" (
"id" SERIAL,
"username" VARCHAR (25) NOT NULL,
"last_login" TIMESTAMP,
CONSTRAINT "users_pk" PRIMARY KEY ("id"),
CONSTRAINT "unique_username" UNIQUE ("username")
);

CREATE TABLE "topics" (
"id" SERIAL,
"topic" VARCHAR (30) NOT NULL,
"description" VARCHAR(500),
CONSTRAINT "topics_pk" PRIMARY KEY ("id"),
CONSTRAINT "unique_topics" UNIQUE ("topic"));

CREATE TABLE "post" (
"id" SERIAL,
"user_id" INTEGER,
"topic_id" INTEGER,
"title" VARCHAR (100) NOT NULL,
"post_text" TEXT,
"url" VARCHAR,
"post_id_bad" INTEGER,
CONSTRAINT "post_pk" PRIMARY KEY ("id"),
CONSTRAINT "user_post_fk" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
CONSTRAINT "topic_post_fk" FOREIGN KEY ("topic_id") REFERENCES "topics" ON DELETE CASCADE,
CHECK((post_text is NULL and url is not NULL) or (post_text is not NULL and url is NULL))
);

CREATE TABLE "comments" (
"id" SERIAL,
"post_id" INTEGER,
"user_id" INTEGER,
"comment_text" TEXT NOT NULL,
"related_comment" INTEGER,
CONSTRAINT "comments_pk" PRIMARY KEY ("id"),
CONSTRAINT "post_comments_fk" FOREIGN KEY ("post_id") REFERENCES "post" ON DELETE CASCADE,
CONSTRAINT "user_comments_fk" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
CONSTRAINT "related_comments_fk" FOREIGN KEY ("related_comment") REFERENCES "comments" ON DELETE CASCADE
);

CREATE TABLE "votes" (
"user_id" INTEGER,
"post_id" INTEGER,
"vote" INTEGER,
CONSTRAINT "user_votes_fk" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
CONSTRAINT "post_votes_fk" FOREIGN KEY ("post_id") REFERENCES "post" ON DELETE CASCADE,
 PRIMARY KEY("user_id","post_id"));

-- MIGRATING DATA TO EACH TABLE CREATED

-- populate users table
INSERT INTO "users" ("username")
SELECT *
FROM
	(SELECT distinct(username)
	FROM
	"bad_posts") AS t1
UNION
SELECT *
FROM
	(SELECT distinct(username)
	FROM
	"bad_comments") AS t2;

-- populate topics table
INSERT INTO "topics" ("topic")
SELECT distinct(topic)
FROM
"bad_posts";

--populate post table
INSERT INTO "post" ("user_id","topic_id", "title", "post_text", "url","post_id_bad")
SELECT
us.id,
tp.id,
SUBSTR(bp.title,1,100) AS title,
bp.text_content,
CASE
WHEN LENGTH(bp.text_content)>0 THEN NULL
ELSE bp.url
END AS "url",
bp.id
FROM
"bad_posts" bp 
JOIN "topics" tp 
ON bp.topic IN (tp.topic)
JOIN "users" us
ON bp.username IN (us.username);

-- populate comments table
INSERT INTO "comments" ("post_id","user_id", "comment_text")
SELECT
pt.id,
us.id,
bc.text_content
FROM
"bad_comments" bc
FULL OUTER JOIN "bad_posts" bp
ON bc.post_id = bp.id
JOIN "users" us
ON bc.username IN (us.username)
FULL OUTER JOIN "post" pt
ON bc.post_id IN (pt.post_id_bad)
WHERE
LENGTH(bc.text_content) > 0;

-- populate votes table - upvotes

INSERT INTO "votes" ("user_id", "post_id","vote")
SELECT
us.id,
pt.id,
t1.up_vote
FROM
(SELECT
id,
REGEXP_SPLIT_TO_TABLE(upvotes,',') AS username,
1 as up_vote
FROM
"bad_posts") t1
JOIN "post" pt
ON t1.id = pt.post_id_bad
JOIN "users" us
ON t1.username IN (us.username);

-- populate votes table - downvotes

INSERT INTO "votes" ("user_id", "post_id","vote")
SELECT
us.id,
pt.id,
t1.down_vote
FROM
(SELECT
id,
REGEXP_SPLIT_TO_TABLE(downvotes,',') AS username,
-1 as down_vote
FROM
"bad_posts") t1
JOIN "post" pt
ON t1.id = pt.post_id_bad
JOIN "users" us
ON t1.username IN (us.username);

-- eliminate columns and tables that are not longer needed
ALTER TABLE "post" DROP COLUMN post_id_bad;
DROP TABLE "bad_comments";
DROP TABLE "bad_posts";

-- ADDITIONAL INDEX CREATION
CREATE INDEX ON "users" ("last_login","username");
CREATE INDEX ON "post" ("user_id");
CREATE INDEX ON "post" ("topic_id");
CREATE INDEX ON "post" ("user_id","post_text");
CREATE INDEX ON "post" ("topic_id","post_text");
CREATE INDEX ON "post" ("url");
CREATE INDEX ON "comments" ("related_comment");
CREATE INDEX ON "comments" ("user_id","comment_text");
CREATE INDEX ON "votes" ("post_id","vote");





