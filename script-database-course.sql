-- №3 скрипты создания объектов для приведённой модели
CREATE TABLE SHOPS -- список магазинов с их адресами
(
    id SMALLINT NOT NULL,
    name VARCHAR(200) NOT NULL, -- название магазина
    region VARCHAR(200) NOT NULL, -- его регион
    city VARCHAR(200) NOT NULL, -- город
    address VARCHAR(200) NOT NULL, -- адрес
    manager_id SMALLINT DEFAULT NULL, -- ссылка на сотрудника (директора магазина)
    PRIMARY KEY(id)
);

CREATE TABLE EMPLOYEES -- список всех сотрудников компании
(
    id SMALLINT NOT NULL,
    first_name VARCHAR(100) NOT NULL, -- имя сотрудника
    last_name VARCHAR(100) NOT NULL, -- его фамилия
    phone VARCHAR(50) NOT NULL, -- телефон
    e_mail VARCHAR(50) NOT NULL, -- почта
    job_name VARCHAR(50) NOT NULL, -- должность
    shop_id SMALLINT DEFAULT NULL, -- ссылка на магазин, в котором работает сотрудник, иначе NULL,
    -- если сотрудник не закреплён за конкретным магазином
    PRIMARY KEY(id)
);
-- создание внешних ключей для таблиц SHOPS и EMPLOYEES
ALTER TABLE SHOPS ADD CONSTRAINT
    manager_id FOREIGN KEY(manager_id) REFERENCES EMPLOYEES(id) ON DELETE CASCADE;
ALTER TABLE EMPLOYEES ADD CONSTRAINT
    shop_id FOREIGN KEY(shop_id) REFERENCES SHOPS(id) ON DELETE CASCADE;

CREATE TABLE PURCHASES -- покупки
(
    id SMALLINT NOT NULL,
    datetime TIMESTAMP NOT NULL, -- дата и время совершения покупки
    amount SMALLINT NOT NULL, -- уплаченная покупателем сумма покупки с учётом скидок
    seller_id SMALLINT DEFAULT NULL, -- ссылка на сотрудника, который совершил продажу,
    -- иначе NULL, если покупка совершенна без продавца
    PRIMARY KEY(id),
    FOREIGN KEY(seller_id) REFERENCES EMPLOYEES(id) ON DELETE CASCADE
);

CREATE TABLE PURCHASE_RECEIPTS -- чеки покупок
(
    purchase_id SMALLINT NOT NULL,
    ordinal_number SMALLINT NOT NULL, -- порядковый номер позиции в чеке
    product_id SMALLINT NOT NULL, -- ссылка на товар
    quantity SMALLINT NOT NULL, -- количество купленного товара
    amount_full SMALLINT NOT NULL, -- полная стоимость товара (без скидок)
    amount_discount SMALLINT NOT NULL, -- предоставленная скидка, в %
    PRIMARY KEY(purchase_id, ordinal_number),
    FOREIGN KEY(purchase_id) REFERENCES PURCHASES(id) ON DELETE CASCADE
);

CREATE TABLE PRODUCTS -- товарный каталог
(
    id SMALLINT NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL, -- код товара
    name VARCHAR(200)NOT NULL, -- название товара
    PRIMARY KEY(id)
);
-- создание внешнего ключа в PURCHASE_RECEIPTS с таблицей PRODUCTS
ALTER TABLE PURCHASE_RECEIPTS ADD CONSTRAINT
    product_id FOREIGN KEY(product_id) REFERENCES PRODUCTS(id)
        ON DELETE CASCADE;

-- №4 скрипты заполнения таблиц тестовыми данными (сеть магазинов "Лента")
-- тестовые данные для SHOPS
INSERT INTO SHOPS (id, name, region, city, address)
VALUES (1, 'Лента', 'Краснодарский край', 'Краснодар', 'Российская, 257'),
       (2, 'Лента', 'Московская область', 'Москва', 'Берников переулок, 2'),
       (3, 'Лента', 'Новосибирская область', 'Новосибирск', 'Проезд Энергетиков, 9');

-- тестовые данные для EMPLOYEES
INSERT INTO EMPLOYEES (id, first_name, last_name, phone, e_mail, job_name, shop_id)
VALUES (1, 'Юрий', 'Синицын', '+7(981)165-89-49', 'yuri95@mail.ru', 'Директор', 1),
       (2, 'Антон', 'Карантиров', '+7(926)414-83-88', 'anton.karantirov@mail.ru', 'Продавец', 1),
       (3, 'Римма', 'Голубцова', '+7(961)474-63-96', 'rimma1878@ymail.ru', 'Продавец', NULL),
       (4, 'Ева', 'Савельева', '+7(975)794-54-25', 'eva16@mail.ru', 'Управляющий', 1),
       (5, 'Марина', 'Балашова', '+7(912)286-39-37', 'marina5965@mail.ru', 'Бухгалтер', 1),
       (6, 'Екатерина', 'Боярова', '+7(977)820-88-82', 'ekaterina1961@mail.ru', 'Уборщик', NULL),

       (7, 'Семен', 'Винокуров', '+7(995)984-18-24', 'semen1982@mail.ru', 'Директор', 2),
       (8, 'Семен', 'Сазонов', '+7(921)670-79-77', 'semen99@mail.ru', 'Продавец', NULL),
       (9, 'Евгений', 'Дудкин', '+7(906)561-67-77', 'evgeniy1962@mail.ru', 'Продавец', 2),
       (10, 'Ксения', 'Шалимова', '+7(958)987-54-92', 'kseniya.alimova@mail.ru', 'Управляющий', NULL),
       (11, 'Евгения', 'Снегирёва', '+7(987)638-35-82', 'evgeniya4143@mail.ru', 'Бухгалтер', 2),
       (12, 'Дарья', 'Ивкина', '+7(935)689-43-93', 'darya93@mail.ru', 'Уборщик', 2),

       (13, 'Марина', 'Чеснокова', '+7(967)587-30-57', 'marina77@mail.ru', 'Директор', 3),
       (14, 'Аркадий', 'Лагутов', '+7(986)519-30-70', 'arkadiy22@mail.ru', 'Продавец', 3),
       (15, 'Федор', 'Эрдниев', '+7(918)759-71-21', 'fedor2118@mail.ru', 'Продавец', 3),
       (16, 'Семен', 'Иньков', '+7(910)787-82-10', 'semen6240@mail.ru', 'Управляющий', 3),
       (17, 'Юлия', 'Енютина', '+7(905)360-34-99', 'yuliya.enyutina@mail.ru', 'Бухгалтер', NULL),
       (18, 'Дмитрий', 'Юдин', '+7(976)653-57-56', 'dmitriy6432@mail.ru', 'Уборщик', NULL);

-- заполнение стобца manager_id для таблицы SHOPS
UPDATE SHOPS SET manager_id = 1 WHERE id = 1;
UPDATE SHOPS SET manager_id = 7 WHERE id = 2;
UPDATE SHOPS SET manager_id = 13 WHERE id = 3;
SELECT * FROM SHOPS;
SELECT * FROM EMPLOYEES;

-- тестовые данные для PURCHASES
INSERT INTO PURCHASES (id, datetime, amount, seller_id)
VALUES (1, '2024-05-01 09:35:10', 100, NULL),
       (2, '2024-05-03 11:24:08', 70, NULL),
       (3, '2024-05-05 10:57:59', 75, 2),
       (4, '2024-05-07 14:55:33', 85, 2),
       (5, '2024-05-09 18:11:11', 90, 8),
       (6, '2024-05-11 09:35:10', 130, 9),
       (7, '2024-05-13 20:00:29', 150, 9),
       (8, '2024-05-16 21:30:27', 135, 9),
       (9, '2024-05-19 16:24:43', 200, 9),
       (10, '2024-05-22 15:54:34', 210, 14),
       (11, '2024-05-25 13:36:21', 160, NULL),
       (12, '2024-05-28 12:23:12', 65, NULL);
SELECT * FROM PURCHASES;

-- тестовые данные для PRODUCTS
INSERT INTO PRODUCTS (id, code, name)
VALUES (1, 'QMY1', 'Товар №1' ),
       (2, 'K5E2', 'Товар №2' ),
       (3, 'DAH3', 'Товар №3' ),
       (4, 'YRX4', 'Товар №4' ),
       (5, 'UHC5', 'Товар №5' ),
       (6, 'EFE6', 'Товар №6' );
SELECT * FROM PRODUCTS;

-- тестовые данные для PURCHASE RECEIPTS
INSERT INTO PURCHASE_RECEIPTS (purchase_id, ordinal_number, product_id, quantity, amount_full, amount_discount)
VALUES (1, 1, 1, 8, 150, 20),
       (2, 2, 3, 4, 100, 20),
       (3, 3, 5, 12, 105, 20),
       (4, 4, 1, 11, 115, 20),
       (5, 5, 3, 10, 120, 20),
       (6, 6, 5, 5, 150, 20),
       (7, 7, 1, 4, 155, 20),
       (8, 8, 3, 1, 220, 20),
       (9, 9, 5, 3, 220, 20),
       (10, 10, 1, 2, 230, 20),
       (11, 11, 3, 5, 180, 20),
       (12, 12, 5, 6, 85, 20);
SELECT * FROM PURCHASE_RECEIPTS;

-- №1 с целью повышения эффективности магазинов отделу маркетинга необходимы следующие
-- отчёты за предыдущий месяц. Отчёт формируется на дату запуска за предыдущий календарный месяц
-- a. Коды и названия товаров, по которым не было покупок
SELECT PRODUCTS.code, PRODUCTS.name
FROM PRODUCTS
         LEFT JOIN PURCHASE_RECEIPTS ON PURCHASE_RECEIPTS.product_id = PRODUCTS.id
         LEFT JOIN PURCHASES ON PURCHASE_RECEIPTS.purchase_id = PURCHASES.id
-- сбор операций по датам за месяц май 2024 г, включая некупленные товары
WHERE (datetime BETWEEN '2024-05-01' AND '2024-06-01' OR datetime IS NULL)
  AND datetime IS NULL -- отбор только некупленных товаров за май
ORDER BY PRODUCTS.name ASC;

-- b1. имена и фамилии продавцов, которые не совершили ни одной продажи
CREATE TEMPORARY TABLE no_sales AS
(
	SELECT SHOPS.region, EMPLOYEES.first_name, EMPLOYEES.last_name, PURCHASES.seller_id, COUNT(PURCHASES.seller_id) AS count_of_trades, SUM(quantity*(amount_full-(amount_full/100*amount_discount))) AS Revenue
	FROM SHOPS
	FULL JOIN EMPLOYEES ON SHOPS.id = EMPLOYEES.shop_id
	FULL JOIN PURCHASES ON PURCHASES.seller_id = EMPLOYEES.id
	FULL JOIN PURCHASE_RECEIPTS ON PURCHASE_RECEIPTS.purchase_id = PURCHASES.id
	WHERE EMPLOYEES.job_name = 'Продавец' AND PURCHASES.seller_id IS NULL
	GROUP BY SHOPS.region, EMPLOYEES.first_name, EMPLOYEES.last_name, PURCHASES.seller_id
	ORDER BY count_of_trades
);
-- b2. самые эффективные продавцы (по полученной выручке)
CREATE TEMPORARY TABLE effective_sellers AS
(
	SELECT SHOPS.region, EMPLOYEES.first_name, EMPLOYEES.last_name, PURCHASES.seller_id, COUNT(PURCHASES.seller_id) AS count_of_trades, SUM(quantity*(amount_full-(amount_full/100*amount_discount))) AS Revenue
	FROM SHOPS
	FULL JOIN EMPLOYEES ON SHOPS.id = EMPLOYEES.shop_id
	FULL JOIN PURCHASES ON PURCHASES.seller_id = EMPLOYEES.id
	FULL JOIN PURCHASE_RECEIPTS ON PURCHASE_RECEIPTS.purchase_id = PURCHASES.id
	WHERE EMPLOYEES.job_name = 'Продавец' AND datetime BETWEEN '2024-05-01' AND '2024-06-01'
	GROUP BY SHOPS.region, EMPLOYEES.first_name, EMPLOYEES.last_name, PURCHASES.seller_id
	ORDER BY revenue
);
-- объединение всех продавцов, если revenue = NULL, то продавец не совершал ни однойпродажи
SELECT * FROM no_sales
UNION
SELECT * FROM effective_sellers
ORDER BY revenue DESC;

-- с. выручка в разрезе регионов. Упорядочите результат по убыванию выручки.
CREATE TEMPORARY TABLE region_revenue AS
(
	SELECT SHOPS.region, SUM(quantity*(amount_full-(amount_full/100*amount_discount))) AS Revenue
	FROM SHOPS
	FULL JOIN EMPLOYEES ON SHOPS.id = EMPLOYEES.shop_id
	FULL JOIN PURCHASES ON PURCHASES.seller_id = EMPLOYEES.id
	FULL JOIN PURCHASE_RECEIPTS ON PURCHASE_RECEIPTS.purchase_id = PURCHASES.id
	WHERE EMPLOYEES.job_name = 'Продавец' AND datetime BETWEEN '2024-05-01' AND '2024-06-01'
	GROUP BY SHOPS.region
	ORDER BY revenue DESC
);
-- сделка продовца с id 8 прошла в Новосибирской области
UPDATE region_revenue SET revenue = revenue + 1000 WHERE region = 'Новосибирская область';
DELETE FROM region_revenue WHERE region IS NULL;
SELECT * FROM region_revenue;

-- №2 выяснилось, что в результате программного сбоя в части магазинов в некоторые дни
-- полная стоимость покупки не бьётся с её разбивкой по товарам.
-- Выведите такие магазины и дни, в которые в них случился сбой,
-- а также сумму расхождения между полной стоимостью покупки и суммой по чеку.
CREATE TEMPORARY TABLE software_failure AS
( -- пусть сбой случился во всех магазинах, исключения дни операций, когда участвовал
-- покупатель сам себя обслуживал и когда продовец не прикреплен к магазину
-- check_amount - сумма покупки (взята со столбца amount в PURCHASES)
-- full_price - полная стоимость покупки
-- amount_of_difference - сумма расхождения
	SELECT SHOPS.region, PURCHASES.datetime AS wrong_datetime, PURCHASES.amount AS check_amount, SUM(quantity*(amount_full-amount_full/100*amount_discount)) AS full_price
	FROM SHOPS
	FULL JOIN EMPLOYEES ON SHOPS.id = EMPLOYEES.shop_id
	FULL JOIN PURCHASES ON PURCHASES.seller_id = EMPLOYEES.id
	FULL JOIN PURCHASE_RECEIPTS ON PURCHASE_RECEIPTS.purchase_id = PURCHASES.id
	WHERE EMPLOYEES.job_name = 'Продавец' AND datetime IS NOT NULL
	AND region IS NOT NULL
	GROUP BY SHOPS.region, PURCHASES.datetime, PURCHASES.amount
	ORDER BY datetime ASC
);
ALTER TABLE software_failure ADD COLUMN amount_of_difference SMALLINT;
UPDATE software_failure SET amount_of_difference = full_price - check_amount;
SELECT * FROM software_failure;