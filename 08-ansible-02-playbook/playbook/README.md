**Описание site.yml**
Плейбук состоит из 3 play
1. Install Java содержит 5 task'ок
   - Установка переменной set_fact
   - Загрузка из локальной папки архива Java с установкой переменной с register
   - Проверка и созданние папки java_home 
   - Разархивирование архива java в папку  
   - Задание переменных окружения из templates
2. Install Elasticsearch содержит 4 task'и
   - Загрузка архива Elasticsearch c сайта https://artifacts.elastic.co
   - Создание директории для Elasticsearch
   - Разархивирование архива Elasticsearch в папку 
   - Задание переменных окружения из templates
3. Install kibana содержит 4 task'и
   - Загрузка архива kibana c сайта https://artifacts.elastic.co
   - Создание директории для kibana
   - Разархивирование архива kibana в папку 
   - Задание переменных окружения из templates