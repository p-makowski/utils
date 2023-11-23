#!/bin/bash

### Script used to dump lightweight database for docker image upload
#INTERVAL="620 DAY"
LIMIT="1000"
MAGERUN=./bin/n98.phar
DB_DUMP_FILENAME=magento-light-db.sql

## get mysql string
MYSQL_STRING=$($MAGERUN db:info MySQL-Cli-String)
echo "..MySQL String: ${MYSQL_STRING}"

rm -f $DB_DUMP_FILENAME
echo "..Removed old file: ${DB_DUMP_FILENAME}"

declare -a ROW_ID_TABLES
ROW_ID_TABLES[0]="catalog_product_entity"
ROW_ID_TABLES[1]="catalog_product_entity_datetime"
ROW_ID_TABLES[2]="catalog_product_entity_decimal"
ROW_ID_TABLES[3]="catalog_product_entity_gallery"
ROW_ID_TABLES[4]="catalog_product_entity_int"
ROW_ID_TABLES[5]="catalog_product_entity_media_gallery_value"
ROW_ID_TABLES[6]="catalog_product_entity_media_gallery_value_to_entity"
ROW_ID_TABLES[7]="catalog_product_entity_text"
ROW_ID_TABLES[8]="catalog_product_entity_tier_price"
ROW_ID_TABLES[9]="catalog_product_entity_varchar"
ROW_ID_TABLES_LENGTH=${#ROW_ID_TABLES[@]}

declare -a SKU_TABLES
SKU_TABLES[0]="inventory_source_item"
SKU_TABLES_LENGTH=${#SKU_TABLES[@]}

declare -a STRIP_TABLES
STRIP_TABLES[0]="@development"
STRIP_TABLES[1]="@search"
STRIP_TABLES[2]="@idx"
STRIP_TABLES[3]="@replica"
STRIP_TABLES[4]="@klarna"
STRIP_TABLES[5]="@mailchimp"
STRIP_TABLES[6]="@sessions"
STRIP_TABLES[7]="@aggregated"
STRIP_TABLES[8]="@temp"
STRIP_TABLES[9]="magento_operation"
STRIP_TABLES[10]="magento_bulk"
STRIP_TABLES[11]="customweb_*"
STRIP_TABLES_LENGTH=${#STRIP_TABLES[@]}


## find IDs of relatively new products
echo "....Find IDs"
#SELECT="SELECT entity_id FROM catalog_product_entity WHERE updated_at > DATE_SUB(CURDATE(), INTERVAL ${INTERVAL}) ORDER BY updated_at DESC LIMIT 1"
SELECT="SELECT MIN(entity_id) FROM (SELECT entity_id FROM catalog_product_entity ORDER BY entity_id DESC LIMIT ${LIMIT}) AS subquery"
COMMAND_ENTITY_ID=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
ENTITY_ID=$(eval ${COMMAND_ENTITY_ID[@]})
echo "..Entity ID: ${ENTITY_ID}"

SELECT="SELECT MIN(row_id) FROM catalog_product_entity WHERE entity_id=${ENTITY_ID}"
COMMAND_MIN_ROW_ID=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
MIN_ROW_ID=$(eval ${COMMAND_MIN_ROW_ID[@]})
echo "..Min Row ID: ${MIN_ROW_ID}"

SELECT="SELECT count(*) FROM catalog_product_entity WHERE row_id >= ${MIN_ROW_ID}"
COMMAND_ROWS_COUNT=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
ROWS_COUNT=$(eval ${COMMAND_ROWS_COUNT[@]})
echo "..Rows count: ${ROWS_COUNT}"

SELECT="SELECT count(*) FROM catalog_product_entity"
COMMAND_TOTAL_ROWS=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
TOTAL_ROWS_COUNT=$(eval ${COMMAND_TOTAL_ROWS[@]})
echo "..Total Rows count: ${TOTAL_ROWS_COUNT}"

SELECT="SELECT row_id FROM catalog_product_entity WHERE row_id >= ${MIN_ROW_ID}"
COMMAND_ROW_IDS_ARRAY=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
readarray -t ROW_IDS_ARRAY < <(eval ${COMMAND_ROW_IDS_ARRAY[@]})
declare ROW_IDS_ARRAY
printf -v joined '%s,' "${ROW_IDS_ARRAY[@]}"
ROW_IDS_COMMA_SEP="${joined%,}"

SELECT="SELECT sku FROM catalog_product_entity WHERE row_id >= ${MIN_ROW_ID}"
COMMAND_SKUS_ARRAY=( $MYSQL_STRING --execute=\"${SELECT}\" --skip-column-names --silent )
readarray -t SKUS_ARRAY < <(eval ${COMMAND_SKUS_ARRAY[@]})
declare SKUS_ARRAY
printf -v SKUS_JOINED '%s,' "${SKUS_ARRAY[@]}"
SKUS_COMMA_SEP=$(echo "${SKUS_JOINED%,}")


## dump stripped version without Welpixel and catalog related tables
echo "....Dump stripped"
STRIP="${STRIP_TABLES[@]} ${ROW_ID_TABLES[@]} ${SKU_TABLES[@]}"
CMD=( $MAGERUN db:dump --set-gtid-purged-off --no-single-transaction --no-tablespaces --git-friendly --strip=\"${STRIP}\" --exclude=\"weltpixel_license\" --exclude=\"weltpixel_quickviewmessages\" --exclude=\"weltpixel_quickviewmessages_product_cl\" --exclude=\"weltpixel_quickviewmessages_rule_cl\" --exclude=\"weltpixel_quickviewmessages_rule_idx\" $DB_DUMP_FILENAME )
IMPORT_RESULT=$(eval ${CMD[@]})
echo $IMPORT_RESULT


## dump catalog_product_entity* with fresh products only
echo "....Dump ROW_ID tables"
for (( j=0; j<${ROW_ID_TABLES_LENGTH}; j++ ));
do
    printf "%d %s\n" $j "${ROW_ID_TABLES[$j]}"
    echo -en '\n\n\n' >> $DB_DUMP_FILENAME
    echo -en "\n-- CUSTOM DUMP " >> $DB_DUMP_FILENAME
    echo -en "\n-- ${ROW_ID_TABLES[$j]}\n" >> $DB_DUMP_FILENAME
    COMMAND=$($MAGERUN db:dump -i ${ROW_ID_TABLES[$j]} --no-tablespaces --no-single-transaction --set-gtid-purged-off --only-command .tmp.sql | head -c -108)
    COMMAND2=${COMMAND}" --where=\"row_id >= ${MIN_ROW_ID}\" | LANG=C LC_CTYPE=C LC_ALL=C sed -E 's/DEFINER[ ]*=[ ]*\`[^\`]+\`@\`[^\`]+\`/DEFINER=CURRENT_USER/g' > '${ROW_ID_TABLES[$j]}.sql'"
    echo "..Executing"
    eval $COMMAND2
    cat ${ROW_ID_TABLES[$j]}.sql >> $DB_DUMP_FILENAME
done

echo "....Dump SKUS tables"
for (( j=0; j<${SKU_TABLES_LENGTH}; j++ ));
do
    printf "%d %s\n" $j "${SKU_TABLES[$j]}"
    echo -en '\n\n\n' >> $DB_DUMP_FILENAME
    echo -en "\n-- CUSTOM DUMP " >> $DB_DUMP_FILENAME
    echo -en "\n-- ${SKU_TABLES[$j]}\n" >> $DB_DUMP_FILENAME
    COMMAND=$($MAGERUN db:dump -i ${SKU_TABLES[$j]} --no-tablespaces --no-single-transaction --set-gtid-purged-off --only-command .tmp.sql | head -c -108)
    COMMAND2=${COMMAND}" --where=\"sku IN (${SKUS_COMMA_SEP})\" | LANG=C LC_CTYPE=C LC_ALL=C sed -E 's/DEFINER[ ]*=[ ]*\`[^\`]+\`@\`[^\`]+\`/DEFINER=CURRENT_USER/g' > '${SKU_TABLES[$j]}.sql'"
    echo "..Executing"
    eval $COMMAND2
    cat ${SKU_TABLES[$j]}.sql >> $DB_DUMP_FILENAME
done


echo "....Compressing"
rm -f $DB_DUMP_FILENAME.gz
gzip -c $DB_DUMP_FILENAME > $DB_DUMP_FILENAME.gz


echo "....DONE"
echo "Import command: $MAGERUN db:import --optimize $DB_DUMP_FILENAME"
echo "Import command: $MAGERUN db:import -c gzip $DB_DUMP_FILENAME.gz"


#bin/n98.phar db:dump --set-gtid-purged-off --no-single-transaction --no-tablespaces --git-friendly  var/db-docker-smaller.sql
#bin/n98.phar db:import --optimize var/db-docker-smaller.sql
