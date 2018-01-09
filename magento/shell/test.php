<?php
chdir(dirname(__FILE__));echo PHP_EOL;error_reporting(E_ALL);ini_set('display_errors', 1);echo 'here';

if(!class_exists('Mage_Shell_Abstract')) {
    $tries     = 0;
    $parentDir = DIRECTORY_SEPARATOR . '..';
    $magePath  = DIRECTORY_SEPARATOR . 'shell' . DIRECTORY_SEPARATOR . 'abstract.php';

    $mage =  $parentDir . $magePath;
    while (! file_exists(dirname(__FILE__) . $mage) && $tries++ < 10) {
        $mage = $parentDir . $mage;
    }

    if (!file_exists(dirname(__FILE__) . $mage)) {
        /* local AJA project */
        $tries = 0;
        $mage  = DIRECTORY_SEPARATOR . 'htdocs' . $magePath;

        while (! file_exists(dirname(__FILE__) . $mage) && $tries++ < 10) {
            $mage = $parentDir . $mage;
        }
    }

    require_once dirname(__FILE__) . $mage;
}


class ClassMy extends Mage_Shell_Abstract {

    public function run()
    {
        echo "works" . PHP_EOL;
    }
}

echo 'before' . PHP_EOL;
$class = new ClassMy();
$class->run();
echo PHP_EOL;