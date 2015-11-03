LOG_FILE="supee-6788-magerun.log"

n98-magerun.phar dev:template-vars >> $LOG_FILE
n98-magerun.phar dev:possi >> $LOG_FILE
n98-magerun.phar dev:old-admin-routing >> $LOG_FILE
find . -type f -name 'register.phtml' -o -name 'resetforgottenpassword.phtml' | egrep -v "^(./vendor/vaimo/magento-enterprise/|./vendor/vaimo/magento/|./htdocs/)" >> $LOG_FILE
