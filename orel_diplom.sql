-- 1.посчитать сколько всего видеорегистраторов на складе --
SELECT SUM(quantity) FROM quantity;

-- 2.определить коэффициент корреляции между оптовой и розничной ценой --
SELECT CORR (retail_price, stock_price) FROM price;

-- 3.посчитать среднюю розничную цену видеорегистраторов, которые поддерживают 32 канала --
SELECT AVG(retail_price) as avg_retail_price FROM price 
INNER JOIN specifications ON price.id=specifications.id 
WHERE chanel = '32'; 

-- 4.посчитать количество выручки (retail_price - stock_price), если мы продадим все видеорегистраторы в наличии у которых 576 Mbps --
WITH tmp AS (SELECT retail_price, stock_price, quantity, Mbps 
FROM price INNER JOIN specifications ON price.id=specifications.id 
INNER JOIN quantity ON price.id=quantity.id WHERE Mbps = '576') 
SELECT SUM(quantity) * (SUM(retail_price) - SUM(stock_price)) as income FROM tmp;
                                                
-- 5.посчитать TVA (аналог российского НДС, ставка 20%) к каждому id видеорегистратора, посчитать розничную цену видеорегистратора без TVA и вывести таблицу с id, розничной ценой, TVA и ценой без TVA --                                                
SELECT id, retail_price, retail_price / 1.20 as tva, retail_price - retail_price / 1.20 as price_tva_free FROM price; 

-- 6.посчитать по количеству каналов видеоругистратора среднюю розничную цену, среднюю оптовую цену и наличие на складе тех видеорегистраторов, которых на складе больше 5 штук -- 
WITH tmp AS (SELECT price.id, chanel, AVG(retail_price) OVER (PARTITION BY chanel) as avg_retail_price, 
AVG(stock_price) OVER (PARTITION BY chanel) as avg_stock_price 
FROM price INNER JOIN specifications ON price.id=specifications.id)
SELECT chanel, avg_retail_price, avg_stock_price, quantity FROM tmp 
INNER JOIN quantity ON tmp.id=quantity.id WHERE quantity > 5 ORDER BY chanel ASC; 
                                                
-- 7.посчитать минимумальную розничную цену, среднюю розничную цену и максимальную розничную цену видеорегистраторов, у которых 160 Mbps --                                                                                                
SELECT MIN(retail_price) OVER (PARTITION BY Mbps) as min_price, 
AVG(retail_price) OVER (PARTITION BY Mbps) as avg_price, 
MAX(retail_price) OVER (PARTITION BY Mbps) as max_price FROM price 
INNER JOIN specifications ON price.id=specifications.id WHERE Mbps = '160' LIMIT 1;
                                                
                                                
-- 8.видеорегистратор с каким количеством каналов продавался лучше всего в декабре. Вывести ID видеорегистратора, колличество проданных видеорегистраторов, розничную цену, сколько поддерживает каналов --
SELECT id_recorder, SUM(quantity_of_sales) OVER (PARTITION BY id_recorder) as sum_quan, retail_price, chanel 
FROM sales_report_122018 
INNER JOIN specifications ON specifications.id=sales_report_122018.id_recorder 
INNER JOIN price ON price.id=sales_report_122018.id_recorder ORDER BY sum_quan DESC LIMIT 1; 
                                                
                                                
-- 9.определить покупателя, который купил больше всего видеорегистраторов. Вывести название фирмы-покупателя и количество купленных ею видеорегистраторов --
SELECT customer_name, SUM(quantity_of_sales) OVER (PARTITION BY sales_report_122018.id_customer) as sum 
FROM sales_report_122018 INNER JOIN customer ON sales_report_122018.id_customer=customer.id_customer ORDER BY sum DESC LIMIT 1; 
                                                
-- 10.посчитать сколько денег нам заплатил покупатель "Avitek" в декабре за купленные им видеорегистраторы --                                                
WITH tmp AS (SELECT SUM(quantity_of_sales) OVER (PARTITION BY id_recorder) * SUM (retail_price) OVER (PARTITION BY id_recorder) as income FROM customer 
RIGHT JOIN sales_report_122018 ON sales_report_122018.id_customer=customer.id_customer 
RIGHT JOIN price ON sales_report_122018.id_recorder=price.id WHERE customer_name = 'Avitek')
SELECT SUM(income) as income_from_avitek FROM tmp; 
