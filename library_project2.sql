-- Library System Management SQL Project

-- CREATE DATABASE library;

-- Create table "Branch"
DROP TABLE IF EXISTS branch;
create table branch(
      branch_id varchar PRIMARY KEY,
	  manager_id varchar,
	  branch_address varchar,
	  contact_no varchar
 );

-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(255),
    category VARCHAR(50),
    rental_price DECIMAL(5,2),
    status VARCHAR(10),
    author VARCHAR(100),
    publisher VARCHAR(100)
);

--Create Table "employee"
DROP TABLE IF EXISTS employees;
 create table employees(
     emp_id	varchar(10) PRIMARY KEY, 
	 emp_name 	varchar(50),
	 position 	varchar(30),
	 salary	DECIMAL(10,2),
	 branch_id 	varchar(10),
	 FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

--Create Table "members"
DROP TABLE IF EXISTS members;
create table members(
 member_id varchar(10)PRIMARY KEY,
 member_name varchar(15),
 member_address varchar(15),
 reg_date date
);

--create Table "issued_status"
DROP TABLE IF EXISTS issued_status;
create table issued_status(
    issued_id	varchar(10)PRIMARY KEY,
	issued_member_id varchar(10),
	issued_book_name varchar(60),
	issued_date date,
	issued_book_isbn varchar(20),
	issued_emp_id varchar(10),
	FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
	FOREIGN KEY (issued_book_isbn)REFERENCES books(isbn),
	FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
);

--Create Table "return_status"
DROP TABLE IF EXISTS return_status;
create table return_status(
    return_id	varchar(10),
	issued_id	varchar(10),
	return_book_name varchar,	
	return_date	date,
	return_book_isbn varchar,
	FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id)
);










