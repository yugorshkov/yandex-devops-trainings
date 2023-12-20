# Тренировки по DevOps. Итоговый проект
Как развернуть ***почти*** корректно работающее приложение. 

## Постановка задачи
<details>

<summary>Предыстория</summary>

1 декабря, в 23:59 по московскому времени мы запускаем наш новый сервис - API хранилища истории сессий нашего онлайн кинотеатра «Фильмопоиск». Дату запуска сдвинуть нельзя, наш PR уже активно продвигает этот запуск. От тебя потребуется развернуть продуктовую инсталляцию этого сервиса.  

Наш подрядчик "Horns&Hooves Soft inc" пишет для нас этот новый сервис. Неделю назад
подрядчик провёл демонстрационную презентацию. На ней он показал почти корректно
работающее приложение, и презентовал HTTP эндпоинт, который отвечает на GET /ping кодом 200, если приложение работает корректно и кодом 500, если нет.  

Мы попросили внести небольшие изменения: нужно, чтобы запрос GET /long_dummy в 75%
случаев работал быстрее секунды, при этом нас устроит закешированный ответ не старше минуты. На презентации он работал дольше. Кроме того, подрядчик сообщил, что потребуется внести некоторые технологические изменения для повышения удобства эксплуатации, а так же починить несколько некритичных багов для повышения стабильности в работе.  

Вчера должна была состояться приёмка, но подрядчик на связь не вышел и перестал отвечать на письма, сообщения и звонки. Нам удалось выяснить, что у подрядчика возникли серьёзные форс-мажорные обстоятельства. Скорее всего получится возобновить взаимодействие не раньше 2 декабря, то есть уже после согласованной даты запуска. Подрядчик не успел предоставить документацию к приложению, и не смог развернуть у нас своё приложение в срок, как ранее обещал. Тот стенд, на котором проводилась демонстрация, уже успели разобрать. К счастью, у нашего менеджера остался email с бинарником приложения, который использовали на демо.  

https://storage.yandexcloud.net/final-homework/bingo – вот ссылка на этот бинарник.  

Твоя задача развернуть отказоустойчивую инсталляцию приложения из имеющегося бинарника до даты запуска продукта. Планируется стабильная нагрузка в 60 RPS, пиковая в 120 RPS.

В эту пятницу, 24 ноября, выходит из отпуска наш тестировщик Петя, который работал с подрядчиком и умеет тестировать это приложение. Он сможет проверить твою и инсталляцию и подсказать, что с ней не так, чтобы тебе было удобнее готовиться к финальному запуску.

Петя интроверт, не любит живое общение, поэтому он обещал сделать автоматику и помогать тебе с помощью специального сервиса - https://devops.yactf.ru

Посредством этого сервиса он и будет принимать решение о том, насколько тебе удалось справиться с требованиями технического задания.

</details>

<details>

<summary>Требования</summary>

*в порядке убывания важности:*
- Отказоустойчивость: сервис должен быть развернут на **двух нодах**, отказ любой из них должен быть незаметен пользователю. Допускается просадка по RPS до стабильного значения в момент отказа любой из нод. При живости обеих нод, инсталяция обязана выдерживать пиковую нагрузку. Так же нужно обеспечить восстановление работоспособности любой отказавшей ноды быстрее, чем за минуту.
- Сервис должен переживать пиковую нагрузку в **120 RPS** в течение 1 минуты, стабильную в **60 RPS**.
- Запросы **POST /operation {"operation": <operation_id: integer>}** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за **400 миллисекунд в 90% случаев при 120 RPS**, гарантируя **не более 1%** ошибок.
- Запросы **GET /db_dummy** должны возвращать незакешированный ответ. Сервер должен
обрабатывать такие запросы и отдавать результат быстрее, чем за **400 миллисекунд в 90% случаев при 120 RPS**, гарантируя **не более 1%** ошибок.
- Запросы **GET /api/movie/{id}** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за **400 миллисекунд в 90% случаев при 120 RPS**, гарантируя **не более 1%** ошибок.
- Запросы **GET /api/customer/{id}** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за **400 миллисекунд в 90% случаев при 120 RPS**, гарантируя **не более 1%** ошибок.
- Запросы **GET /api/session/{id}** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат быстрее, чем за **400 миллисекунд в 90% случаев при 120 RPS**, гарантируя **не более 1%** ошибок.
- Запросы **GET /api/movie** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя **не более 1%** ошибок. Требований по времени ответа нет, планируем делать не более одного такого запроса одновременно.
- Запросы **GET /api/customer** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя **не более 1%** ошибок. Требований по времени ответа нет, планируем делать не более одного такого запроса одновременно.
- Запросы **GET /api/session** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя **не более 5% ошибок**. Требований по времени ответа нет, планируем делать не более одного такого запроса одновременно.
- Запросы **POST /api/session** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя **не более 1%** ошибок. Требований по времени ответа и RPS нет.
- Запросы **DELETE /api/session/{id}** должны возвращать незакешированный ответ. Сервер должен обрабатывать такие запросы и отдавать результат гарантируя **не более 1%** ошибок. Требований по времени ответа и RPS нет.
- **Задача со звёздочкой**: сделать так, чтобы сервис работал на отдельном домене по https протоколу, и по http без редиректа на https (допускается самоподписанный сертификат).
- **Задача со звёздочкой**: сделать http3.
- **Задача со звёздочкой**: сделать так, чтобы запросы **GET /long_dummy** возвращали ответ не старше 1 минуты и отвечали быстрее, чем за 1 секунду в 75% случаев.
- **Задача со звёздочкой**: желательно обеспечить наблюдаемость приложения: графики RPS и ошибок по каждому эндпоинту.
- **Задача со звёздочкой**: автоматизировать развёртывание при помощи devops инструментов, с которыми вы успели познакомиться ранее.

</details>

## Решение
Чтобы развернуть сервис в соответствии с техническим заданием (ТЗ), минимально понадобится следующая конфигурация: сетевой балансировщик, 2 ноды с приложением, еще одна - база данных (БД).
![Схема](https://i.imgur.com/n3qNHkY.png "Конфигурация сервиса")

### Запускаем сервер приложения
Попытка сразу запустить сервер приложения дает поток неинформативных ошибок. Прикрепляем `strace`, разбираемся, что происходит во время запуска программы: сервер при старте ищет конфиг и файл для записи логов. Создаем файлы. После развёртывания БД, необходимо внести параметры подключения в конфиг.

### Установка PostgreSQL
На отдельной ВМ устанавливаем PostgreSQL. Первоначальная настройка будет заключаться в создании новой роли и базы для сервиса, а также открытии доступа к БД из интернета. 

### Тестирование производительности
Нагружаем сервис с помощью `wrk` и оцениваем результаты. Для выполнения требований ТЗ по количеству запросов, которые обрабатываются сервером в секунду, и задержке ответа, настраиваем postgres и оптимизируем обработку запросов:
- ***postgresql.conf***:
    ```
    shared_buffers = 512MB
    work_mem = 16MB
    ```
- создаем индексы по *id* во всех рабочих таблицах

### Отказоустойчивость
Настраиваем systemd для запуска сервера приложения на ВМ, что даёт:
- автоматический запуск приложения при старте ВМ
- автоматический перезапуск приложения в случае сбоя

Ещё один сервис будет выполнять роль autoheal'а. То есть, с заданной периодичностью проверяет, что приложение работает корректно (на **GET /ping**  отвечает **ОК**). Если нет - перезапускает.

### Развёртывание
Инфраструктура сервиса описана в ***main.tf*** для управления через `Terraform`.  
Postgres устанавливается и наполняется данными в ручном режиме, ноду для него можно поднять отдельно через `terraform apply -target postgres`.  
Перед созданием нод с приложением необходимо заменить заглушки вида *<здесь должен быть секретный код>* в ***cloud-init.yaml*** рабочими параметрами. После развёртывания, приложение на каждой ноде будет сконфигурировано и запущено.

## Итоги
<details>

<summary>Результат проверки тестирующей системой</summary>

![](https://i.imgur.com/zKEDCIu.png)

</details>

### Что можно улучшить/доделать:
- [ ] Автоматизировать развёртывание и наполнение БД
- [ ] https
- [ ] http3
- [ ] Кэширование запросов GET /long_dummy
- [ ] Мониторинг приложения