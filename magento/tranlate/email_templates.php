<?php
/** Email templates have to reside in:   app/locale/nb_NO/template/email/account_new.html 
instead of theme specific directory: app/design/frontend/PACKAGE/THEME/locale/nb_NO/template/email/account_new.html
because of "Mage_Core_Model_Translate::getTemplateFile" does not take care about design fallback at all. 


\Mage_Core_Model_Translate::getTemplateFile 
*/



    /**
     * Retrive translated template file
     *
     * @param string $file
     * @param string $type
     * @param string $localeCode
     * @return string
     */
    public function getTemplateFile($file, $type, $localeCode=null)
    {
        if (is_null($localeCode) || preg_match('/[^a-zA-Z_]/', $localeCode)) {
            $localeCode = $this->getLocale();
        }

        $filePath = Mage::getBaseDir('locale')  . DS
                  . $localeCode . DS . 'template' . DS . $type . DS . $file;

        if (!file_exists($filePath)) { // If no template specified for this locale, use store default
            $filePath = Mage::getBaseDir('locale') . DS
                      . Mage::app()->getLocale()->getDefaultLocale()
                      . DS . 'template' . DS . $type . DS . $file;
        }

        if (!file_exists($filePath)) {  // If no template specified as  store default locale, use en_US
            $filePath = Mage::getBaseDir('locale') . DS
                      . Mage_Core_Model_Locale::DEFAULT_LOCALE
                      . DS . 'template' . DS . $type . DS . $file;
        }

        $ioAdapter = new Varien_Io_File();
        $ioAdapter->open(array('path' => Mage::getBaseDir('locale')));

        return (string) $ioAdapter->read($filePath);
    }
