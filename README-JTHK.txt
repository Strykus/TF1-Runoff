Runoff 0.3.0 - пакет сервера для DESKTOP-JTHK9CO

1. На JTHK должна быть установлена Titanfall 2 с актуальным Northstar.
2. Распакуйте этот пакет в отдельную папку, оставив три ZIP рядом со скриптами.
3. Запустите Install-RunoffServer.cmd и укажите папку Titanfall 2.
   Установка создаёт отдельный профиль RunoffPublic, не заменяя существующие моды.
4. Разрешите Northstar/Titanfall 2 в брандмауэре Windows и пробросьте UDP 37042
   на JTHK на его роутере. Публичная доступность зависит от сети этого компьютера.
5. Запустите Start-RunoffServer.cmd. Сервер регистрируется в списке Northstar
   под именем TF1 Runoff | Navmesh Test. Логи: Titanfall 2/RunoffPublic/logs.

Карта: https://github.com/Strykus/TF1-Runoff/releases/tag/v0.3.0
Для автозагрузки ресурсов клиенты запускают Northstar с параметром:
-customverifiedurl=https://raw.githubusercontent.com/Strykus/TF1-Runoff/main/verified_mods.json
После изменения параметров запуска перезапустите клиент.

Сборка включает исправленные коллизии и навмеш титанов, включая спуск.
Семь маршрутов Atlas проверены в локальной игре; это не проверка публичной сети JTHK.
Оригинальные игровые файлы и Northstar в этот пакет не включены.
