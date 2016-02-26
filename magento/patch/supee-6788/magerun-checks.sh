LOG_FILE="supee-6788-magerun.log"

echo -e "\nTEMPLATE VARS"
n98-magerun.phar dev:template-vars

echo -e "\nSQL INJECTIONS"
n98-magerun.phar dev:possi

echo -e "\nINCOMPATIBLE MODULES (ADMIN ROUTING)"
n98-magerun.phar dev:old-admin-routing

echo -e "\nTEMPLATES WITHOUT FORM KEY"
find . -type f -name 'register.phtml' -o -name 'resetforgottenpassword.phtml' | egrep -v "^(./vendor/vaimo/magento-enterprise/|./vendor/vaimo/magento/|./htdocs/)"
