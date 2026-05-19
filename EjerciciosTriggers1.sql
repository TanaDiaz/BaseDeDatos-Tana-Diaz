create table customers_audit (
idaudit int auto_increment not null primary key,
operacion char(6),
user varchar(50),
last_date_modified datetime,

customer_id int,
customer_name varchar(100),
email varchar(100),
phone varchar(20)
);

 Definir un trigger que se dispare después de insertar en la tabla de customers y que
inserte la información necesaria en customers_audit.

delimiter //
create trigger papitapapituli after insert on customers for each row
begin

insert into customers_audit (operacion, user, last_date_modified, customer_id, customer_name, email, phone)
values ('insert', user(), now(), new.customer_id, new.customer_name, new.email, new.phone);

end//
delimiter ;


delimiter //

create trigger papuslipus before update on customers for each row
begin
insert into customers_audit (customerNumber,contactLastName,contactFirstName,addressLine1,city,state,postalCode,country,salesRepEmployeeNumber,creditLimit)
values (old.customerNumber,old.customerName,old.contactLastName,old.contactFirstName,old.phone,old.addressLine1,old.addressLine2,old.city,old.state,old.postalCode,old.country,old.salesRepEmployeeNumber,old.creditLimit));
end//

delimiter ;


- Definir un trigger que, antes de borrar una fila en la tabla de customers, inserte los
datos anteriores en la tabla customes_audit.

create trigger tapiachiqui before delete on customers for each row
begin
insert into customers_audit(customerNumber,contactLastName,contactFirstName,addressLine1,city,state,postalCode,country,salesRepEmployeeNumber,creditLimit))
values(old.customerNumber,old.contactLastName,old.contactFirstName,old.addressLine1,old.city,old.state,old.postalCode,old.country,old.salesRepEmployeeNumber,old.creditLimit)
);