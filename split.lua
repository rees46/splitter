--
-- Created by IntelliJ IDEA.
-- User: mkechinov
-- Date: 15/03/2017
-- Time: 22:00
-- To change this template use File | Settings | File Templates.
--

-- require 'config'

local redis = require 'redis'
local client = redis.connect('127.0.0.1', 6379)

-- Returns next segment ID
local function nextSegment(client, shop_key, experiment, max)
    local key = 'c_' .. shop_key .. '_' .. experiment
    local current = client:get(key)
    if current == nil then
        current = 0
    else
        current = tonumber(current) + 1
        if current >= max then
            current = 0
        end
    end
    client:setex(key, 86400, current)
    return current
end

-- Генерирует уникальную сессию
local function generateSsid()
    local uuid = require "resty.jit-uuid"
    return uuid()
end

-- Возвращает букву по номеру сегмента
local function letterBySegment(segment)
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    return letters:sub(segment + 1, segment + 1)
end

-- Ищет сегмент в БД по сессии и возвращает его
local function loadSegmentBySsid(shop_key, experiment, ssid)
   return client:get(shop_key .. '_' .. experiment .. '_' .. ssid)
end

-- Сохраняет сегмент в БД
local function saveSegment(client, shop_key, experiment, ssid, segment)
    local key = shop_key .. '_' .. experiment .. '_' .. ssid
    client:setex(key, 86400, segment)
end


-- Получаем переменные из запроса
local shop_key, experiment, total_segments = ngx.var.arg_shop_key, ngx.var.arg_experiment, tonumber(ngx.var.arg_total_segments)

if shop_key then

    if experiment and total_segments then

        local ssid, segment = ngx.var.cookie_ssid, tonumber(ngx.var['cookie_' .. shop_key .. '_' .. experiment])

        if ssid and segment then

            -- Поискать по сессии сегмент в редисе
            local real_segment = loadSegmentBySsid(shop_key, experiment, ssid)

            -- Если сегмент найден в БД
            if real_segment == nil or tonumber(real_segment) < 0 or tonumber(real_segment) >= total_segments then

                -- Перегенерируем новую сессию
                ssid = generateSsid()

                -- Получаем новый сегмент для сессии
                segment = nextSegment(client, shop_key, experiment, total_segments)

            -- Если реального сегмента в БД нет
            else

                -- Если сегмент из БД не соответствует тому, что пришло
                if real_segment ~= segment then

                    -- Используем сегмент из БД
                    segment = real_segment

                end

            end

        -- Если пришла только сессия
        elseif ssid then

            -- Пытаемся найти ее сегмент в БД
            segment = loadSegmentBySsid(shop_key, experiment, ssid)

            -- Не найден в БД, поэтому генерируем новый
            if segment == nil then
                segment = nextSegment(client, shop_key, experiment, total_segments)
            else
                -- Приводим к числу
                segment = tonumber(segment)

                -- Если некорректный, значит перегенерируем
                if segment < 0 or segment >= total_segments then
                    segment = nextSegment(client, shop_key, experiment, total_segments)
                end

            end

        -- Нет вообще ничего
        else

            -- Генерируем новую сессию
            ssid = generateSsid()

            -- Генерируем новый сегмент
            segment = nextSegment(client, shop_key, experiment, total_segments)

        end

        -- Сохраняем (продлеваем) сегмент на необходимое время в БД
        saveSegment(client, shop_key, experiment, ssid, segment)

        -- Сохраняем куку на длину сессии
        ngx.header['Set-Cookie'] = {
            shop_key .. '_' .. experiment .. '=' .. segment .. '; path=/',
            'ssid=' .. ssid .. '; path=/'
        }

        -- Вернуть букву сегмента
        ngx.say(letterBySegment(segment))
        ngx.exit(200)

    else
        ngx.header["X-Message"] = 'Experiment or total segments not set'
        ngx.exit(ngx.HTTP_BAD_REQUEST)
    end

else
    ngx.header["X-Message"] = 'Incorrect shop key'
    ngx.exit(ngx.HTTP_FORBIDDEN)
end
