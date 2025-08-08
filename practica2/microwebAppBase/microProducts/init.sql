
CREATE DATABASE myflaskapp_products;
use myflaskapp_products;


CREATE TABLE products (
    id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name varchar(255),
    price DECIMAL(10,2),
    stock int,
    description varchar(255)
);


INSERT INTO products VALUES(null, "monitor", 200.00, 10, "monitor de 24 pulgadas"),
(null, "teclado", 50.00, 20, "teclado mecanico"),
(null, "mouse", 25.00, 30, "mouse inalambrico"),
(null, "auriculares", 75.00, 15, "auriculares con microfono"),
(null, "webcam", 100.00, 5, "webcam HD"),
(null, "impresora", 150.00, 8, "impresora laser"),
(null, "router", 80.00, 12, "router wifi 6"),
(null, "disco duro", 120.00, 25, "disco duro externo 1TB"),
(null, "memoria USB", 20.00, 50, "memoria USB 64GB"),
(null, "cargador", 30.00, 40, "cargador rapido USB-C");