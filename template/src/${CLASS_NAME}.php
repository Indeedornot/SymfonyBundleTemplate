<?php

namespace ${NAMESPACE};

use Symfony\Component\DependencyInjection\ContainerBuilder;
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;
use Symfony\Component\HttpKernel\Bundle\AbstractBundle;

class ${CLASS_NAME} extends AbstractBundle
{
    public function loadExtension(array $config, ContainerConfigurator $container, ContainerBuilder $builder): void
    {
        $container->import(Path::CONFIG->getPath('{packages}/*.yaml'));
        $container->import(Path::CONFIG->getPath('bundles.php'));
    }
}
