1.Как вывести следующее/предыдущее значение
Дано
Структура таблиц:

+-----------------------------------------------+
|   transactions                                |
+-----------------------------------------------+
|   id - идентификатор записи (PK)              |
|   transaction_id - идентификатор транзакции   |
|   card_id - номер карты                       |
|   date - дата и время транзакции              |
|   sum - сумма транзакции                      |
|   type - тип транзакции                       |
|   employee - сотрудник                        |
|   doc_id - идентификатор чека                 |
|   cash_id - номер кассы                       |
|   shop_id - номер магазина                    |
|   disc_id - идентификатор скидки              |
+-----------------------------------------------+
Задание
Для каждой строки выведите предыдущее и следующее значение sum для сотрудника. Если предыдущего/следующего значения нет, выведите NULL.

Требования к решению
В решении выведите следующие столбцы

Решение:

id
employee
sum
ld - следующее значение
lg - предыдущее значение
Условия сортировки
Результат отсортируйте по полю id по возрастанию.

SELECT
  id,
  employee,
  sum,
  LAG(sum) OVER (PARTITION BY employee ORDER BY id) AS lg,
  LEAD(sum) OVER (PARTITION BY employee ORDER BY id) AS ld
FROM transactions
ORDER BY id;


2.Как посчитать баланс нарастающим итогом
Дано
Структура таблиц:

+-----------------------------------------------+
|   transactions                                |
+-----------------------------------------------+
|   id - идентификатор записи (PK)              |
|   transaction_id - идентификатор транзакции   |
|   card_id - номер карты                       |
|   date - дата и время транзакции              |
|   sum - сумма транзакции                      |
|   type - тип транзакции                       |
|   employee - сотрудник                        |
|   doc_id - идентификатор чека                 |
|   cash_id - номер кассы                       |
|   shop_id - номер магазина                    |
|   disc_id - идентификатор скидки              |
+-----------------------------------------------+
Задание
Выведите: * дату и время транзакции; * сумму текущего списания/начисления для данной транзакции; * общий баланс (списания - начисления) нарастающим итогом.

Требования к решению
В решении выведите следующие столбцы

date
summ (уже с учетом знака минус, если это списание)
cumsum - рассчитанный нарастающий итог
Условия сортировки
Результат отсортируйте по возрастанию поля date.


Решение:
SELECT t2.date,
       t2.sum AS summ,
       sum (t2.sum)  OVER (ORDER BY t2.transaction_id) AS cumsum
FROM(
   SELECT transaction_id,date,
     CASE
        WHEN TYPE=1 THEN -sum
        ELSE sum
      END
   FROM transactions
   )t2
ORDER BY date


3.Как посчитать прирост
Дано
Структура таблиц:

+-----------------------------------------------+
|   transactions                                |
+-----------------------------------------------+
|   id - идентификатор записи (PK)              |
|   transaction_id - идентификатор транзакции   |
|   card_id - номер карты                       |
|   date - дата и время транзакции              |
|   sum - сумма транзакции                      |
|   type - тип транзакции                       |
|   employee - сотрудник                        |
|   doc_id - идентификатор чека                 |
|   cash_id - номер кассы                       |
|   shop_id - номер магазина                    |
|   disc_id - идентификатор скидки              |
+-----------------------------------------------+
Задание
Для каждого сотрудника посчитайте относительный прирост суммарных списаний по сравнению с предыдущей транзакцией. Начисления из расчета необходимо исключить. Если предыдущей транзакции нет, оставьте столбец пустым.

«Предыдущая» транзакция определяется по временному признаку. Если в один момент времени для одного сотрудника несколько строк в таблице - значит это одна транзакция. Такое происходит из-за разных товарных групп. Агрегируйте их в одну.

Прирост округлите до 2 знака после запятой.

Требования к решению
В решении выведите следующие столбцы

employee
dt - дата и время
lg - сумма списаний в предыдущей транзакции
sm - сумма списаний в текущей транзакции
inc - значение прироста суммы
Условия сортировки
Результат отсортируйте по сотрудникам и по дате-времени по возрастанию.

Решение:

SELECT employee, dt, lg, sm, ROUND((sm-lg)/lg::NUMERIC, 2) AS inc
FROM (
    SELECT employee, dt, lag(sm) OVER(PARTITION BY employee ORDER BY dt) AS lg, sm
    FROM (
        SELECT employee, date as dt, SUM(sum) AS sm
        FROM transactions
        WHERE type = 0
        GROUP BY employee, date
        ) t
    ) t2
ORDER BY employee, dt



4. Как смоделировать EXCEPT через JOIN
Дано
Структура таблиц:

+---------------------------------------------------------+
|   products                                              |
+---------------------------------------------------------+
|   product_id - идентификационный номер продукта         |
|   type_id - номер типа продукта                         |
|   availability - наличие на складе                      |
|   cost_price - себестоимость                            |
|   selling_price - цена                                  |
|   color_id - цвет                                       |
|   info - описание                                       |
+---------------------------------------------------------+
+---------------------------------------------------------+
|   product_type                                          |
+---------------------------------------------------------+
|   type_id - номер типа продукта                         |
|   type - тип продукта                                   |
|   description - вид                                     |
+---------------------------------------------------------+
Задание
Смоделируйте EXCEPT с помощью JOIN.

Выведите номера типов продуктов, которые не представлены в таблице products. Данные по категориям содержатся в таблице product_type.

В запросе используйте только JOIN – использование EXCEPT не допускается.

Требования к решению
В решении выведите следующие столбцы

type_id
Условия сортировки
Результат отсортируйте по убыванию поля type_id.

Решение:

SELECT
    pt.type_id
FROM
    product_type pt
LEFT JOIN
    products p ON pt.type_id = p.type_id
WHERE
    p.type_id IS NULL
ORDER BY
    pt.type_id DESC;


5.Как отфильтровать по отсутствию пропусков
Дано
Структура таблиц:

+---------------------------------------------------------+
|   products                                              |
+---------------------------------------------------------+
|   product_id - идентификационный номер продукта         |
|   type_id - номер типа продукта                         |
|   availability - наличие на складе                      |
|   cost_price - себестоимость                            |
|   selling_price - цена                                  |
|   color_id - цвет                                       |
|   info - описание                                       |
+---------------------------------------------------------+
Задание
Выведите все продукты из таблицы products, у которых заполнено описание.

Требования к решению
В решении выведите следующие столбцы

product_id
info
Условия сортировки
Результат отсортируйте по возрастанию поля product_id.

Решение:

SELECT
    product_id,
    info
FROM
    products
WHERE
    info IS NOT NULL 
ORDER BY
    product_id ASC;


6.Как отранжировать без разрывов
Дано
Структура таблиц:

+-----------------------------------------------+
|   transactions                                |
+-----------------------------------------------+
|   id - идентификатор записи (PK)              |
|   transaction_id - идентификатор транзакции   |
|   card_id - номер карты                       |
|   date - дата и время транзакции              |
|   sum - сумма транзакции                      |
|   type - тип транзакции                       |
|   employee - сотрудник                        |
|   doc_id - идентификатор чека                 |
|   cash_id - номер кассы                       |
|   shop_id - номер магазина                    |
|   disc_id - идентификатор скидки              |
+-----------------------------------------------+
Задание
Разбейте данные из таблицы transactions на группы по сотрудникам. Для каждого сотрудника проранжируйте номера чеков.

Расчет ранга должен идти по убыванию индификатора чека.

Если для одного сотрудника встречается несколько одинаковых значений, то им должен быть присвоен одинаковый ранг. При этом следующий ранг должен идти без разрыва, например:

+---------+--------+
|  value  |  rank  |
+---------+--------+
|   10    |    1   |
|    5    |    2   |
|    5    |    2   |
|    1    |    3   |
+---------+--------+
Требования к решению
В решении выведите следующие столбцы

employee
type
doc_id
rnk - рассчитанный ранг
Условия сортировки
Результат отсортируйте по полю employee по убыванию и дополнительно по возрастанию ранга в рамках каждого сотрудника.

Решение:

SELECT
  employee,
  type,
  doc_id,
  DENSE_RANK() OVER(PARTITION BY employee ORDER BY doc_id DESC) AS rnk
FROM transactions
ORDER BY employee DESC, rnk;