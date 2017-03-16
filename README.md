# Установка

## Подготовка NGINX

1. Установить NGINX с поддержкой Lua >=5.1.
2. Установить модуль https://github.com/nrk/redis-lua
3. Установить resty.jit-uuid
4. Установить Redis 3x

## Настройка хоста

Здесь и далее: используйте свой поддомен вместо split.rees46.com

1. Создать поддомен split.rees46.com
2. Создать в NGINX файл хоста. Пример содержимого: split.rees46.com.conf
3. Положить в папку /etc/nginx файл split.lua
4. Хост должен работать и с HTTP и с HTTPS
5. Перезапустить NGINX

# Использование


TODO