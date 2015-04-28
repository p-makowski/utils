<?php 

if(!class_exists('Mage_Shell_Abstract')) {
    $tries        = 0;
    $parentDir    = DIRECTORY_SEPARATOR . '..';
    $abstractPath =  $parentDir . DIRECTORY_SEPARATOR .'htdocs' . DIRECTORY_SEPARATOR . 'shell' . DIRECTORY_SEPARATOR . 'abstract.php';

    while (! file_exists(dirname(__FILE__) . $abstractPath) && $tries++ < 8) {
        $abstractPath = $parentDir . $abstractPath;
    }

    require_once dirname(__FILE__) . $abstractPath;
}
