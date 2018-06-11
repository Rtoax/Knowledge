CREATE TABLE customer ( 
    customer_id serial , 
    title char(4) ,
    fname varchar(32) , 
    lname varchar(32) NOT NULL, 
    addressline varchar(64) , 
    town varchar(32) , 
    zipcode char(10) NOT NULL, 
    phone varchar(16) , 
    CONSTRAINT customer_pk PRIMARY KEY(customer_id) 
);

CREATE TABLE item ( 
    item_id serial , 
    description varchar(64) NOT NULL, 
    cost_price numeric(7,2) , 
    sell_price numeric(7,2) , 
    CONSTRAINT item_pk PRIMARY KEY(item_id) 
);

CREATE TABLE orderinfo ( 
    orderinfo_id serial , 
    customer_id integer NOT NULL, 
    date_placed date NOT NULL, 
    date_shipped date , 
    shipping numeric(7,2) , 
    CONSTRAINT orderinfo_pk PRIMARY KEY(orderinfo_id) 
); 

CREATE TABLE stock ( 
    item_id integer NOT NULL, 
    quantity integer NOT NULL, 
    CONSTRAINT stock_pk PRIMARY KEY(item_id) 
);

CREATE TABLE orderline ( 
    orderinfo_id integer NOT NULL,
    item_id integer NOT NULL, 
    quantity integer NOT NULL, 
    CONSTRAINT orderline_pk PRIMARY KEY(orderinfo_id, item_id) 
); 

CREATE TABLE barcode ( 
    barcode_ean char(13) NOT NULL, 
    item_id integer NOT NULL, 
    CONSTRAINT barcode_pk PRIMARY KEY(barcode_ean) 
);








