-- Total Loans

select count(*) as 'Total Loan' from Loans

--Total Active Loan
select count(*) as 'Total Active Loan' from Loans
where loanEndDate>GETDATE()

--Total loan amount disbursed by type (Home, Car, Personal…)
select LoanType,format(sum(LoanAmount),'$0,,M') from Loans
group by LoanType

--select LoanType,LoanAmount from Loans


-- Avg interest rate per loan type
select LoanType,round(AVG(InterestRate),2)as 'Average Interest Rate' from Loans
group by LoanType


-- Upcoming maturity trends (loans ending this year)

select FORMAT(LoanEndDate, 'MMM') as Month , count(*) as 'loans ending this year by month' from Loans
where YEAR(loanEndDate)=YEAR(GETDATE())
group by FORMAT(LoanEndDate, 'MMM')

--relation between interestRate , loanAmount

SELECT LoanID,format(LoanAmount,'0,K') as 'Loan Amount',round(InterestRate,2) as 'InterestRate'FROM Loans


--Loans per AccountType 
select AccountType , count( LoanID)as 'Number of Loan' , AVG(LoanAmount)as 'Average Amount of Loan' from Customers C inner join Loans L
on C.CustomerID =L.CustomerID
inner join Accounts A on C.CustomerID=A.CustomerID
group by AccountType

-- use in direct query
create view loans_by_account as
select AccountType ,  LoanID ,LoanAmount ,interestRate from Customers C inner join Loans L
on C.CustomerID =L.CustomerID
inner join Accounts A on C.CustomerID=A.CustomerID


---Customers with loans but no recent transactions → potential default risk
create view potential_default_risk as
SELECT  count(L.LoanID) as'countofriskloans'
FROM Loans L
JOIN Customers C ON L.CustomerID = C.CustomerID
JOIN Accounts A ON L.CustomerID = A.CustomerID
LEFT JOIN Transactions T ON A.AccountID = T.AccountID
    AND T.TransactionDate >= DATEADD(MONTH, -6, GETDATE())
WHERE T.TransactionID IS NULL AND L.LoanEndDate > GETDATE();


-- rank loan amount (get top loans )
create VIEW high_amount AS
SELECT 
  Row_Number() OVER (ORDER BY LoanAmount DESC) AS RowNum,
  LoanID,
  LoanAmount
FROM Loans;

select * from high_amount


--get year
CREATE VIEW loans_By_year AS
SELECT
  LoanID,
  LoanStartDate,
  YEAR(LoanStartDate) AS LoanYear
FROM Loans;

select * from loans_By_year


-- loan amount ,interest rate by account type
select AccountType,sum(LoanAmount),avg(InterestRate),LoanID from Customers c inner join Loans l
on c.CustomerID=l.CustomerID inner join Accounts A on c.CustomerID=A.CustomerID