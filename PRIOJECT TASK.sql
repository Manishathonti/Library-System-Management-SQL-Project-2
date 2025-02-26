   --TABLES
SELECT*FROM branch
SELECT*FROM books
SELECT*FROM employees
SELECT*FROM members
SELECT*FROM issued_status
SELECT*FROM return_status

--PROJECT TASK

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"U
 INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher) 
 VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott')


 --Task 2: Update an Existing Member's Address
 UPDATE members
 SET member_address= '125 Oak St'
 WHERE member_id= 'C103';


 --Task 3: Delete a Record from the Issued Status Table -- Objective: 
    --Delete the record with issued_id = 'IS121' from the issued_status table.
 DELETE FROM issued_status
 WHERE issued_id = 'IS121';

 --Task 4: Retrieve All Books Issued by a Specific Employee
   -- Objective: Select all books issued by the employee with emp_id = 'E101'.
 SELECT *FROM employees
 WHERE emp_id = 'E101'

 --Task 5: List Members Who Have Issued More Than One Book
 -- Objective: Use GROUP BY to find members who have issued more than one book.
 SELECT issued_emp_id,
    COUNT(*) AS members
 FROM issued_status
 GROUP BY 1
 HAVING COUNT(*)>1;


 --Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results
 -- each book and total book_issued_cnt**
 CREATE TABLE  book_issued_cnt as
 SELECT books.isbn,
        books.book_title,
       count(issued_status.issued_book_isbn)
 FROM books
 join
 issued_status
 on books.isbn = issued_status.issued_book_isbn
 GROUP BY books.isbn;
 
 SELECT *FROM book_issued_cnt


 --Task 7. Retrieve All Books in a Specific Category:
  SELECT *
  FROM books
  WHERE category = 'Classic';
 
 --Task 8: Find Total Rental Income by Category:
  ---for all books issued or not
  SELECT  category,sum(rental_price) 
  from books 
  GROUP by category;
   ---only for issued books
	SELECT 
	b.category,
	SUM(b.rental_price),
	COUNT(*)
	FROM 
	issued_status as ist
	JOIN
	books as b
	ON b.isbn = ist.issued_book_isbn
	GROUP BY 1

  
 --Task 9:List Members Who Registered in the Last 180 Days:
  SELECT*
  FROM members
  WHERE reg_date >= CURRENT_DATE -INTERVAL '180 days';
  
 
 --Task10:List Employees with Their Branch Manager's Name and their branch details:

  SELECT emp1.emp_id,
         emp1.emp_name,
         branch. branch_id, 
		 branch.manager_id ,
		 branch.branch_address ,
		 branch.contact_no,
		 emp2.emp_name as manager_name
  FROM employees as emp1
  join branch on 
  emp1.branch_id = branch.branch_id
  join employees as emp2 on
  emp2.emp_id = branch.manager_id;

 --Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
	 CREATE Table rental_price_threshold as
	 select * from books
	 where rental_price> 6;
	 
	 select * from rental_price_threshold;
	
--Task 12: Retrieve the List of Books Not Yet Returned
	 SELECT issued_status.*
	 FROM issued_status
	 left join return_status on
	 issued_status.issued_id = return_status.issued_id
	 where return_status.return_id is null;

 /*Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). 
--Display the member's_id, member's name, book title, issue date, and days overdue.*/
	SELECT members.member_id,
			members.member_name,
			books.book_title,
			issued_status.issued_date,
			current_date - issued_status.issued_date  as over_due_days
	FROM members
	join issued_status on members.member_id = issued_status.issued_member_id
	join books on books.isbn = issued_status.issued_book_isbn
	left join return_status on return_status.issued_id = issued_status.issued_id
	WHERE current_date - issued_status.issued_date > 30
	order by over_due_days desc;

/*Task 14: Update Book Status on Return
 Write a query to update the status of books in the books table to "Yes" when they are returned 
 (based on entries in the return_status table).*/
 
--TYPE 1
 ---Entering Values MANUALLY
 
   --insert values in return table 
   INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
   VALUES('RS119','IS135',CURRENT_DATE,'Good');

   --fetching details
   SELECT *FROM issued_status
   WHERE issued_book_isbn = '978-0-307-58837-1';

   --update book
   UPDATE books
   SET status ='yes'
   WHERE isbn = '978-0-307-58837-1';

   SELECT*FROM books
   WHERE isbn = '978-0-307-58837-1';

--TYPE 2
---STORED PROCEDURES
   DROP procedure IF EXISTS add_return_records;
   CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_quality VARCHAR(10))
   LANGUAGE plpgsql
   AS $$
   DECLARE
     v_isbn varchar(20);
	 v_book_name varchar(60);
   BEGIN 
      INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
	  VALUES (p_return_id,p_issued_id,CURRENT_DATE,p_quality);

	  SELECT issued_book_isbn,issued_book_name
	  INTO v_isbn,v_book_name
	  FROM issued_status
	  WHERE issued_id = p_issued_id;
	  
	  UPDATE books 
	  SET status = 'yes'
	  WHERE isbn = v_isbn ;              
   END;
   $$;

   CALL add_return_records('RS121','IS136','Good');

	
   SELECT *FROM return_status;
   SELECT*FROM books;

    SELECT *FROM issued_status
	where issued_book_isbn ='978-0-7432-7357-1';


--Task 15: Branch Performance Report
  --Create a query that generates a performance report for each branch, 
  ---showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
  DROP TABLE IF EXISTS branch_report;
   CREATE TABLE branch_report as
   SELECT branch.branch_id,
          branch.manager_id,
		  COUNT(issued_status.issued_id) as num_issued_books,
          COUNT(return_status.return_id)as num_return_books,
		  SUM(books.rental_price) as total_revenue
	FROM issued_status
	join employees on employees.emp_id = issued_status.issued_emp_id
	join branch on branch.branch_id = employees.branch_id
	left join return_status on issued_status.issued_id = return_status.issued_id
	join books on issued_status.issued_book_isbn = books.isbn
	group by 1,2;

	SELECT* FROM branch_report;

--Task 16: CTAS: Create a Table of Active Members
  ---Use the CREATE TABLE AS (CTAS) statement 
  ---create a new table active_members containing members who have issued at least one book in the last 2 months.	
  DROP TABLE IF EXISTS active_members;
	CREATE TABLE active_members as
	SELECT * FROM members 
	WHERE member_id in (SELECT distinct(issued_member_id) FROM issued_status
	       WHERE issued_date >=CURRENT_DATE -INTERVAL '2 months');

    SELECT *FROM active_members	

/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.*/

   SELECT employees.branch_id,
          employees.emp_id,
          employees.emp_name,
          count(issued_status.issued_emp_id)as num_book_issued
   FROM issued_status
   JOIN employees on
   employees.emp_id = issued_status.issued_emp_id
   GROUP BY 1,2,3
   ORDER BY num_book_issued desc
   LIMIT 3;


/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.*/ 
		  
   SELECT members.member_name,
          books.book_title,
		  return_status.book_quality,
		  count(return_status.book_quality) as num_issued_book
   FROM return_status 
   JOIN issued_status 
   ON return_status.issued_id = issued_status.issued_id
   JOIN members
   ON members.member_id = issued_status.issued_member_id
   JOIN books
   ON books.isbn = issued_status.issued_book_isbn
   where book_quality = 'Damaged'
   GROUP BY 1,2,3
   HAVING(count(return_status.book_quality)>2)
   ORDER BY num_issued_book desc;
   
/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/
  
  DROP procedure IF EXISTS book_status;
  CREATE OR REPLACE PROCEDURE book_status(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(10),p_issued_book_isbn VARCHAR(20),p_issued_emp_id VARCHAR(10))
  LANGUAGE plpgsql
  AS
  $$
  DECLARE
      	v_status VARCHAR(20);
  BEGIN 
      SELECT 
	        status 
        INTO
        v_status
	  FROM books
	  WHERE isbn = p_issued_book_isbn;

	  IF v_status ='yes' THEN
	    INSERT INTO issued_status(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		VALUES (p_issued_id,p_issued_member_id,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
		
		UPDATE books
		SET status ='no'
		WHERE isbn = p_issued_book_isbn;
		
		RAISE NOTICE 'Book records added successfully for book isbn : %',p_issued_book_isbn;
	  ELSE 
		RAISE NOTICE 'ERROR:the book is currently not available : %',p_issued_book_isbn;
	  END IF;
  END;
  $$;

  CALL book_status('IS137','C107','978-0-553-29698-2','E103');
  CALL book_status('IS155', 'C108', '978-0-553-29698-2', 'E104');
  CALL book_status('IS156', 'C108', '978-0-375-41398-8', 'E104');


/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50.
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines*/
  DROP TABLE IF EXISTS overdue_books_totalfine;
  CREATE TABLE overdue_books_totalfine as
  SELECT
	   members.member_id,
	   members.member_name,
	   count(issued_status.issued_id) as num_books_issued,
	   count(case when (current_date - issued_status.issued_date)>30 then 1 end) as  num_overdue_books,
	   sum(case when (current_date - issued_status.issued_date)>30 then (current_date - issued_status.issued_date)* 0.50 else 0 end)	  
  FROM 	 members join issued_status 
  on issued_status.issued_member_id = members.member_id
  GROUP BY 1,2;

  SELECT*FROM overdue_books_totalfine
  order by  num_overdue_books desc;

  
	   
			   
			   
              