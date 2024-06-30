<?php

namespace ${NAMESPACE};

enum Path: string
{
    case ROOT = __DIR__ . '/../';
    case CONFIG = self::ROOT->value . 'config/';
    case PUBLIC = self::ROOT->value . 'public/';

    function getPath(string $path): string
    {
        return $this->value . ltrim($path, '/');
    }
}
