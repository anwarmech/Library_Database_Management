CREATE DATABASE IF NOT EXISTS Library_Store;

USE Library_Store;

CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress VARCHAR(255),
    publisher_PublisherPhone VARCHAR(255)
);
CREATE TABLE tbl_borrower (
    borrower_CardNo TINYINT PRIMARY KEY,
    borrower_BorrowerName VARCHAR(255),
    borrower_BorrowerAddress VARCHAR(255),
    borrower_BorrowerPhone VARCHAR(255)
);
CREATE TABLE tbl_book (
    book_BookID TINYINT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255),
    FOREIGN KEY (book_PublisherName)
        REFERENCES tbl_publisher (publisher_PublisherName)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE tbl_book_authors (
    book_authors_authorID INT AUTO_INCREMENT PRIMARY KEY,
    book_authors_BookID TINYINT,
    book_authors_AuthorName VARCHAR(255),
    FOREIGN KEY (book_authors_BookID)
        REFERENCES tbl_book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE tbl_library_branch (
    library_branch_BranchID INT AUTO_INCREMENT PRIMARY KEY,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress VARCHAR(255)
);

CREATE TABLE tbl_book_loans (
    book_loans_LoanID INT AUTO_INCREMENT PRIMARY KEY,
    book_loans_BookID TINYINT,
    book_loans_BranchID INT,
    book_loans_CardNo TINYINT,
    book_loans_DateOut VARCHAR(255),
    book_loans_DueDate VARCHAR(255),
    FOREIGN KEY (book_loans_BookID)
        REFERENCES tbl_book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_loans_BranchID)
        REFERENCES tbl_library_branch (library_branch_BranchID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_loans_CardNo)
        REFERENCES tbl_borrower (borrower_CardNo)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT AUTO_INCREMENT PRIMARY KEY,
    book_copies_BookID TINYINT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies TINYINT,
    FOREIGN KEY (book_copies_BookID)
        REFERENCES tbl_book (book_BookID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (book_copies_BranchID)
        REFERENCES tbl_library_branch (library_branch_BranchID)
        ON UPDATE CASCADE ON DELETE CASCADE
);


-- No of copies of the book titled "The Lost Tribe" which are owned by the library branch whose name is "Sharpstown"

WITH cte1 AS (
SELECT 
	* 
FROM 
	tbl_book b 
		LEFT JOIN 
	tbl_book_loans bl ON b.book_bookID=bl.book_loans_bookID) 
SELECT 
    c.book_title, COUNT(c.book_title) AS No_of_copies
FROM
    cte1 c
        LEFT JOIN
    tbl_library_branch lb ON c.book_loans_branchid = lb.library_branch_branchID
WHERE
    lb.library_branch_branchname = 'Sharpstown'
        AND c.book_title = 'The Lost Tribe';

-- No of copies of the book titled "The Lost Tribe" which are owned by the each library branch

WITH cte1 AS (
SELECT 
	* 
FROM 
	tbl_book b 
		LEFT JOIN 
	tbl_book_loans bl ON b.book_bookID=bl.book_loans_bookID) 
SELECT 
	c.book_title, 
	lb.Library_branch_branchName, 
    count(lb.Library_branch_branchName) AS No_of_Copies 
FROM 
	cte1 c 
		LEFT JOIN 
	tbl_library_branch lb ON c.book_loans_branchid=lb.library_branch_branchID
WHERE 
	c.book_title = "The Lost Tribe"
GROUP BY 
	lb.Library_branch_branchName;
 
-- Name of the all borrowers who do not have any books checked out.

SELECT 
    b.borrower_borrowername
FROM
    tbl_borrower b
        LEFT JOIN
    tbl_book_loans bl ON b.borrower_cardNo = bl.book_loans_cardno
WHERE
    bl.book_loans_dateout IS NULL;


-- Book title, Borrower's Name, and the Borrower's Address for each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18

SELECT 
	b.book_title,
	br.borrower_borrowername,
    br.borrower_borroweraddress 
FROM 
	tbl_library_branch lb
		LEFT JOIN 
	tbl_book_loans bl ON lb.library_branch_branchID=bl.book_loans_branchID
		LEFT JOIN 
	tbl_book b ON bl.book_Loans_BookID=b.Book_BookID
		LEFT JOIN 
	tbl_borrower br ON bl.Book_Loans_CardNo=br.borrower_cardno
WHERE 
	lb.library_branch_branchName = "Sharpstown" 
		AND bl.book_loans_duedate = "2/3/18"
;
    
    
-- Branch Name and the total number of books loaned out from that branch 

SELECT 
    lb.library_Branch_Branchname,
    COUNT(bl.book_loans_bookID) AS No_of_Books
FROM
    tbl_library_branch lb
        LEFT JOIN
    tbl_book_loans bl ON lb.Library_branch_branchID = bl.book_loans_branchID
GROUP BY lb.library_Branch_BranchID;


-- Names, addresses, and number of books checked out for all borrowers who have more than five books checked out

WITH cte1 AS (
SELECT 
	br.borrower_BorrowerName,
    count(bl.book_loans_BookID) AS No_of_books 
FROM 
	tbl_borrower br 
		LEFT JOIN 
	tbl_book_loans bl ON br.borrower_cardNo=bl.book_loans_cardNo 
GROUP BY br.borrower_BorrowerName) 
SELECT 
    cte1.borrower_borrowerName,
    br.borrower_borrowerAddress,
    No_of_books
FROM
    cte1
        LEFT JOIN
    tbl_borrower br ON cte1.borrower_borrowerName = br.borrower_borrowerName
WHERE
    No_of_books > 5
ORDER BY No_of_books;


-- Title and the number of copies owned by the library branch whose name is "Central" For each book authored by "Stephen King"

SELECT 
    b.Book_Title, 
    COUNT(b.Book_Title) AS No_of_copies
FROM
    tbl_book_authors ba
        LEFT JOIN
    tbl_book b ON ba.book_authors_bookid = b.book_bookID
        LEFT JOIN
    tbl_book_loans bl ON b.book_bookID = bl.book_loans_bookID
        LEFT JOIN
    tbl_library_branch lb ON lb.library_branch_branchID = bl.book_loans_branchID
WHERE
    ba.book_authors_authorname = 'Stephen King'
        AND lb.library_branch_branchname = 'Central'
GROUP BY 
	b.Book_Title;