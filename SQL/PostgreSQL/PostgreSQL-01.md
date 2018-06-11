## 初始化数据库

```shell
$ su 
# su - postgres 
postgres$
postgres$ /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
```

如果一切正常，你将在```initdb```命令的```-D```参数指向的位置拥有一个全新的空白数据库。


## 配置连接权限

默认情况下，```PostgreSQL```不允许全面的远程访问。为了赋权给远程连接，你必须编辑配置文件```pg_hba.conf```（位于```/usr/local/pgsql/```）.
例如，希望允许用户neil通过IP地址为192.168.0.3的主机连接到bpsimple数据库，添加以下行到```pg_hba.conf```文件： 
```shell
    host bpsimple neil 192.168.0.3/32 md5
```

## 创建用户

```shell
$ createuser neil
```

## 创建数据库

```shell
$ createdb bpsimple
```

## 链接数据库

```shell
$ psql -U neil -d bpsimple
```

## 建表

```shell
bpsimple=# \i create_tables-bpsimple.sql
```

## 查看数据库

```
\l  --相当于MySQL的： show datasets
```

## 查看多表

```
\dt --相当于mysql的，mysql> show tables
```

## 创建一个表

```sql
CREATE TABLE customer ( 
    customer_id serial, 
    title char(4), 
    fname varchar(32), 
    lname varchar(32) not null, 
    addressline varchar(64), 
    town varchar(32), 
    zipcode char(10) not null, 
    phone varchar(16), 
);
```

## 向表中插入一行数据

```sql
INSERT INTO customer(title, fname, lname, addressline, town, zipcode, phone) 
VALUES('Mr','Neil','Matthew','5 Pasture Lane','Nicetown','NT3 7RT','267 1232'); 

INSERT INTO customer(title, fname, lname, addressline, town, zipcode, phone) 
VALUES('Mr','Richard','Stones','34 Holly Way','Bingham','BG4 2WE','342 5982');
```

## 关联一个表
```sql
SELECT * FROM customer, orderinfo WHERE customer.customer_id = orderinfo.customer_id;
```

/**/



