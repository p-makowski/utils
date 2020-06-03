# source: http://dba.stackexchange.com/questions/1282/how-do-i-get-progress-for-type-db-sql-mysql/1307#1307 (RolandoMySQLDBA)

SELECT CONCAT(db, '.', tb) AS table_name,
       CONCAT(
               ROUND(
                           tbsz / POWER(1024, IF(pw < 0, 0, IF(pw > 4, 4, pw))),
                           3
                   ),
               ' ',
               SUBSTR(' KMGT', IF(pw < 0, 0, IF(pw > 4, 4, pw)) + 1, 1)
           ) AS table_size
FROM (
         SELECT data_length + index_length tbsz, table_schema db, table_name tb
         FROM information_schema.tables
         WHERE engine = 'InnoDB'
     ) AS A,
     (SELECT 2 AS pw) AS B
WHERE db = "{DB_NAME}"
ORDER BY tbsz
DESC LIMIT 50;

