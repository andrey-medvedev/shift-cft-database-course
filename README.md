База данных для сети магазинов "Лента"

---

#### Обзор проекта
Этот проект представляет собой реализацию базы данных для сети магазинов "Лента", выполненную в рамках тестового задания на курс **"Базы данных" от ЦФТ**. Система обеспечивает:
- Учёт магазинов, сотрудников и товаров
- Фиксацию покупок и детализацию чеков
- Формирование аналитических отчётов для отдела маркетинга
- Выявление технических сбоев в работе магазинов

---

#### Структура базы данных
**Диаграмма отношений:**

![image](https://github.com/user-attachments/assets/9770fecb-6014-4149-9e2d-8723eebc5f03)


**Таблицы:**
1. **SHOPS** - информация о магазинах:
   ```sql
   CREATE TABLE SHOPS (
     id SMALLINT PRIMARY KEY,
     name VARCHAR(200) NOT NULL,
     region VARCHAR(200) NOT NULL,
     city VARCHAR(200) NOT NULL,
     address VARCHAR(200) NOT NULL,
     manager_id SMALLINT REFERENCES EMPLOYEES(id) ON DELETE CASCADE
   );
   ```

2. **EMPLOYEES** - данные сотрудников:
   ```sql
   CREATE TABLE EMPLOYEES (
     id SMALLINT PRIMARY KEY,
     first_name VARCHAR(100) NOT NULL,
     last_name VARCHAR(100) NOT NULL,
     job_name VARCHAR(50) NOT NULL, -- 'Продавец', 'Директор' и т.д.
     shop_id SMALLINT REFERENCES SHOPS(id) ON DELETE CASCADE
   );
   ```

3. **PURCHASES** - зафиксированные покупки:
   ```sql
   CREATE TABLE PURCHASES (
     id SMALLINT PRIMARY KEY,
     datetime TIMESTAMP NOT NULL,
     amount SMALLINT NOT NULL, -- сумма со скидкой
     seller_id SMALLINT REFERENCES EMPLOYEES(id) ON DELETE CASCADE
   );
   ```

4. **PURCHASE_RECEIPTS** - детализация чеков:
   ```sql
   CREATE TABLE PURCHASE_RECEIPTS (
     purchase_id SMALLINT REFERENCES PURCHASES(id) ON DELETE CASCADE,
     ordinal_number SMALLINT NOT NULL, -- позиция в чеке
     product_id SMALLINT REFERENCES PRODUCTS(id) ON DELETE CASCADE,
     quantity SMALLINT NOT NULL,
     amount_full SMALLINT NOT NULL, -- стоимость без скидки
     amount_discount SMALLINT NOT NULL, -- % скидки
     PRIMARY KEY(purchase_id, ordinal_number)
   );
   ```

5. **PRODUCTS** - товарный каталог:
   ```sql
   CREATE TABLE PRODUCTS (
     id SMALLINT PRIMARY KEY,
     code VARCHAR(50) UNIQUE NOT NULL,
     name VARCHAR(200) NOT NULL
   );
   ```

---

#### Ключевые задачи и решения

**1. Аналитические отчёты для маркетинга**

a. **Непопулярные товары:**
```sql
SELECT code, name 
FROM PRODUCTS
WHERE id NOT IN (
  SELECT product_id 
  FROM PURCHASE_RECEIPTS
  JOIN PURCHASES ON purchase_id = PURCHASES.id
  WHERE datetime BETWEEN '2024-05-01' AND '2024-06-01'
);
```

b. **Эффективность продавцов:**
```sql
-- Продавцы без продаж
SELECT first_name, last_name 
FROM EMPLOYEES 
WHERE job_name = 'Продавец' 
  AND id NOT IN (SELECT seller_id FROM PURCHASES WHERE seller_id IS NOT NULL)

-- Топ продавцов по выручке
SELECT e.first_name, e.last_name, SUM(pr.quantity * (pr.amount_full - pr.amount_full/100*pr.amount_discount)) AS revenue
FROM EMPLOYEES e
JOIN PURCHASES p ON p.seller_id = e.id
JOIN PURCHASE_RECEIPTS pr ON pr.purchase_id = p.id
GROUP BY e.id
ORDER BY revenue DESC;
```

c. **Выручка по регионам:**
```sql
SELECT s.region, SUM(p.amount) AS revenue
FROM SHOPS s
JOIN PURCHASES p ON p.shop_id = s.id
WHERE p.datetime BETWEEN '2024-05-01' AND '2024-06-01'
GROUP BY s.region
ORDER BY revenue DESC;
```

**2. Выявление программных сбоев**
```sql
SELECT 
  s.region,
  DATE(p.datetime) AS fail_date,
  SUM(pr.quantity * (pr.amount_full - pr.amount_full/100*pr.amount_discount)) - p.amount AS discrepancy
FROM PURCHASES p
JOIN PURCHASE_RECEIPTS pr ON pr.purchase_id = p.id
JOIN EMPLOYEES e ON e.id = p.seller_id
JOIN SHOPS s ON s.id = e.shop_id
GROUP BY s.region, DATE(p.datetime)
HAVING SUM(pr.quantity * (pr.amount_full - pr.amount_full/100*pr.amount_discount)) != p.amount;
```

---

#### Тестовые данные
База содержит реалистичные данные для 3 магазинов в разных регионах:
- 18 сотрудников различных должностей
- 12 зафиксированных покупок
- 6 товаров в каталоге
- 12 позиций в чеках покупок

Пример заполнения:
```sql
INSERT INTO SHOPS VALUES 
(1, 'Лента', 'Краснодарский край', 'Краснодар', 'Российская, 257', 1);

INSERT INTO EMPLOYEES VALUES 
(1, 'Юрий', 'Синицын', 'Директор', 1),
(2, 'Антон', 'Карантиров', 'Продавец', 1);
```

---

#### Как использовать
1. **Инициализация базы:**
   ```bash
   psql -U postgres -f database_schema.sql
   psql -U postgres -f test_data.sql
   ```

2. **Выполнение отчетов:**
   ```bash
   psql -U postgres -d lenta_db -f reports.sql
   ```

3. **Пример вывода отчёта:**
   ```
        region       | revenue 
   ------------------+---------
    Московская область |   2100
    Новосибирская обл.|   1800
    Краснодарский край|   1500
   ```

---

#### Особенности реализации
1. **Нормализация данных:**
   - Разделение сущностей на логические таблицы
   - Использование внешних ключей для обеспечения целостности
   - Уникальные индексы для предотвращения дубликатов

2. **Оптимизация запросов:**
   - Временные таблицы для сложных отчётов
   - Агрегатные функции для расчетов
   - Эффективные JOIN-операции

3. **Технические решения:**
   - Каскадное удаление связанных записей
   - Проверка ограничений при вставке данных
   - Обработка NULL-значений для необязательных связей

---

#### Демонстрация работы
**Выявление расхождений в чеках:**
```
       region       |  fail_date  | discrepancy 
--------------------+-------------+-------------
 Московская область | 2024-05-09 |         230
 Новосибирская обл. | 2024-05-22 |         180
```

**Топ продавцов:**
```
 first_name | last_name | revenue 
------------+-----------+---------
 Евгений    | Дудкин    |    1500
 Антон      | Карантиров|    1200
```
