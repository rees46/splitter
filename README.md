# Назначение

Разделитель аудитории для ABC[DEF...Z] тестирования различных сервисов для интернет-магазинов.

Особенности:
 
1. Делит аудиторию на ровное количество частей - не случайным образом, а цикличным перебором: первый посетитель будет в сегменте A, второй в сегменте B, и так далее. Таким образом аудитория гарантировано будет разделена на равные части.
2. Поддерживает до 24 сегментов.
3. Распознает попытку подменить сегмент пользователя (мошенничество с целью перекинуть ) и гарантирует, что выданный пользователю сегмент не будет изменен.
4. Позволяет проводить одновременно несколько экпериментов: пользователь будет в разных сегментах для разных экспериментов. 

# Использование

Важно: библиотека делает синхронный AJAX-запрос для упрощения ее использования на сайте. Время ответа сервера сегментации не более 20ms, поэтому операция не замедлит работу вашего сайта.

Скачать и положить на сервер файл

```r46_splitter.js```


## Вариант с асинхронными запросами

На всех страницах сайта в секцию ```<head>``` разместить код:

```html
<head>
    ...
    <script src="r46_splitter.js"></script>
    <script>
        
        // Идентификатор магазина. Можно получить в личном кабинете REES46.com после регистрации.
        var shop_key = 'o87ahlgj2ptghylutskljhg68';
        
        // Имя эксперимента - любой набор латинских букв и цифр без пробелов и знаков пунктуации
        var experiment = 'recommendations';
        
        // Максимальное число сегментов
        var total_segments = 3;
        
        // Получаем сегмент
        var segment = r46_splitter(shop_key, experiment, total_segments, function(segment) {

            // Используем сегмент
            if(segment == 'A') {
                
                // Исполняем код для сегмента А
                
            } else if (segment == 'B') {
                
                // Исполняем код для сегмента B
                
            } else if (segment == 'C') {
                
                // Исполняем код для сегмента C
                
            } else {
                
                // Возникла проблема на канале связи, поэтому сегмент рассчитать не удалось
                // Можно использовать любой интересующий код.
                
            }
            
        });

    </script>
    ...
</head>
```

## Вариант с синхронными запросами

> Синхронные запросы? Вы что, это же замедлит наш сайт!

Сервис высокоскоростной. Тестирование сервиса на сервере за $50 дало следующий результат: 50000 запросов, 1000 конкурирущих, среднее время ответа: 15ms.

На всех страницах сайта в секцию ```<head>``` разместить код:

```html
<head>
    ...
    <script src="r46_splitter.js"></script>
    <script>
        
        // Идентификатор магазина. Можно получить в личном кабинете REES46.com после регистрации.
        var shop_key = 'o87ahlgj2ptghylutskljhg68';
        
        // Имя эксперимента - любой набор латинских букв и цифр без пробелов и знаков пунктуации
        var experiment = 'recommendations';
        
        // Максимальное число сегментов
        var total_segments = 3;
        
        // Получаем сегмент
        var segment = r46_splitter(shop_key, experiment, total_segments);
        
        // Используем сегмент
        if(segment == 'A') {
            
            // Исполняем код для сегмента А
            
        } else if (segment == 'B') {
            
            // Исполняем код для сегмента B
            
        } else if (segment == 'C') {
            
            // Исполняем код для сегмента C
            
        } else {
            
            // Возникла проблема на канале связи, поэтому сегмент рассчитать не удалось
            // Можно использовать любой интересующий код.
            
        }

    </script>
    ...
</head>
```

# Установка на собственный сервер

Вы можете использовать исходный код делителя на собственном сервере, если не доверяете нашему. Можете использовать любой домен, главное - не основной домен вашего сайта, чтобы исключить возможность подмены кук.

## Подготовка NGINX

1. Установить NGINX с поддержкой Lua >=5.1
```
Если версия ниже 1.9.11, если выше то переходим сразу к пункту 2:
cd /opt 
apt-get source nginx 
git clone https://github.com/openresty/lua-nginx-module.git
nginx -V
Копируем все от --prefix=/usr/share/nginx до первого --add-module, добавляем:
--add-module=/opt/lua-nginx-module --with-ld-opt="-L /usr/local/lib" --with-cc-opt="-I /usr/local/include"
И дальше модули по желанию
make
make install
mv /usr/share/nginx/sbin/nginx /usr/sbin/nginx
Перезагружаем nginx
```
2. Ставим lua:
```
apt-get install lua5.1
Менеджер пакетов для lua:
apt-get install luarocks
luarocks install luasec
```
3. Установить модуль https://github.com/nrk/redis-lua
```
luarocks install redis-lua
```
4. Установить resty.jit-uuid
```
luarocks install lua-resty-jit-uuid
```
5. Установить Redis 3x

## Настройка хоста

Здесь и далее: используйте свой поддомен вместо split.rees46.com

1. Создать поддомен split.rees46.com
2. Создать в NGINX файл хоста. Пример содержимого: split.rees46.com.conf
3. Положить в папку /etc/nginx файл split.lua
4. Хост должен работать и с HTTP и с HTTPS
5. Отключить любое кеширование GET-запросов в location делителя или на уровне DNS (Cloudflare)
6. Перезапустить NGINX
