CREATE DATABASE Banking_Loan_Risk;
USE Banking_Loan_Risk; 

USE Banking_Loan_Risk;

SHOW TABLES;

select * from loan_default;

describe loan_default;

select * from loan_default 
limit 10 ;


#1.What is the total number of loans and the total loan amount in the portfolio? 
#1.The bank wants to understand the size of its loan portfolio. Calculate the total number of loans, total loan amount, and average loan amount.

select  count(loanID) as totoal_no_of_loan , sum(loanamount) as totoal_loan_amt , avg(loanamount) as avg_loan_amt
from loan_default;

## Inference:
# The bank's portfolio consists of 4,923 loans, with a total loan value of 633,247,144 and an average
# loan amount of 128,630.34. This analysis provides an overview of the size and average value of the
# bank's lending portfolio.


#2.Question 2 — Loan Default Analysis  
#2. The bank wants to evaluate its loan repayment risk. Calculate the total number of loans, the number of defaulted loans, and the percentage of loans that have defaulted.      

SELECT
    COUNT(*) AS total_loans,
    (
        SELECT COUNT(*)
        FROM loan_default
        WHERE `Default` = 1
    ) AS defaulted_loans,
    ROUND(
        (
            SELECT COUNT(*)
            FROM loan_default
            WHERE `Default` = 1
        ) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_default;

## Inference:
# Out of 4,923 loans, 574 loans were classified as defaults, resulting in an overall default rate of
# 11.66%. This metric provides a baseline for evaluating the bank's loan repayment risk, and every
# segment analysed below can be compared against it.


#3.Calculate the total number of loans, number of defaulted loans, and default rate percentage for each employment type. 
#Identify which employment type has the highest loan default rate. 
 
SELECT
    l.EmploymentType,
    COUNT(*) AS total_loans,
    COALESCE(d.defaulted_loans, 0) AS defaulted_loans,
    ROUND(
        COALESCE(d.defaulted_loans, 0) * 100.0
        / COUNT(*), 2
    ) AS default_rate_percentage
FROM loan_default l
LEFT JOIN (
    SELECT EmploymentType, COUNT(*) AS defaulted_loans
    FROM loan_default
    WHERE `Default` = 1
    GROUP BY EmploymentType
) d ON l.EmploymentType = d.EmploymentType
GROUP BY l.EmploymentType, d.defaulted_loans;

## Inference:
# The Unemployed segment recorded the highest default rate at 13.62%, while Full-time employees
# recorded 9.91%. This comparison helps identify employment segments that may require further
# repayment-risk assessment, since income stability appears to influence repayment behaviour.
# [Part-time: __%, Self-employed: __%]


#4.The bank wants to understand which loan purposes carry a higher risk of default.
#Calculate the total number of loans, number of defaulted loans, and default rate percentage for each loan purpose. Identify the loan purpose with the highest default rate.

select	loanpurpose , count(*) as total_loans ,
SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
ROUND(SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),2) as  default_rate_percentage
FROM loan_default
GROUP BY loanpurpose;

## Inference:
# Loans taken for "Other" purposes showed the highest default rate of 13.64%. This finding helps the
# bank compare repayment risk across loan purposes and identify categories for further investigation.
# [Lowest-risk purpose: ______ at __%]


#5.The bank wants to understand how borrowers' credit scores are related to loan defaults.
SELECT
    CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        ELSE 'Very Good'
    END AS credit_category,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_default
GROUP BY
CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        ELSE 'Very Good'
    END;

## Inference:
# The [Poor] credit category has the highest default rate at [__%], while the [Very Good] category has
# only [__%]. Default rates [fall / do not fall consistently] as credit scores improve, which shows
# that credit score is [a strong / only a moderate] indicator of repayment risk.
    
SELECT
    MIN(Income) AS min_income,
    MAX(Income) AS max_income
FROM loan_default;
# (Range check only, used to define the income bands in Q6. No inference needed.)

#6.The bank wants to understand whether borrowers' income levels are associated with loan default risk.
select * from loan_default;
select 
case 
when income between 15000 and 49999 then 'Low Income'
when income between 50000 and 79999 then 'Lower-Middle Income'
when income between 80000 and 109999 then 'Upper-Middle Income'
when income between 110000 and 149999 then 'High Income'
END AS income_category,
count(*) as total_loans ,
SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
FROM loan_default
group by
case 
when income between 15000 and 49999 then 'Low Income'
when income between 50000 and 79999 then 'Lower-Middle Income'
when income between 80000 and 109999 then 'Upper-Middle Income'
when income between 110000 and 149999 then 'High Income'
END ; 

## Inference:
# The Low Income group has a default rate of [__%], compared with [__%] for the High Income group.
# Default risk [decreases / shows no clear change] as income rises, indicating a [strong / weak]
# relationship between income level and repayment capacity.

#7.The bank wants to understand whether loan duration is associated with a higher risk of default. 

SELECT
    l.LoanTerm,
    COUNT(*) AS total_loans,
    COALESCE(d.defaulted_loans, 0) AS defaulted_loans,
    ROUND(
        COALESCE(d.defaulted_loans, 0) * 100.0
        / COUNT(*), 2
    ) AS default_rate_percentage
FROM loan_default l
LEFT JOIN (
    SELECT LoanTerm, COUNT(*) AS defaulted_loans
    FROM loan_default
    WHERE `Default` = 1
    GROUP BY LoanTerm
) d ON l.LoanTerm = d.LoanTerm
GROUP BY l.LoanTerm, d.defaulted_loans;

## Inference:
# The [__]-month term has the highest default rate at [__%], while the [__]-month term has the lowest
# at [__%]. This suggests loan duration has a [positive / negligible] association with default risk.


#8.The bank wants to understand whether borrowers with a mortgage have a different loan default risk from borrowers without a mortgage. 
select hasmortgage from loan_default;
select	hasmortgage , count(*) as total_loans ,
SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
 ROUND(
        SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
from loan_default
group by hasmortgage;

## Inference:
# Borrowers with a mortgage have a default rate of [__%], compared with [__%] for borrowers without
# one. Having a mortgage is associated with [lower / higher / no meaningful difference in] default risk.

#9.The bank wants to evaluate whether having a co-signer is associated with a lower risk of loan default.

SELECT
    l.HasCoSigner,
    COUNT(*) AS total_loans,
    COALESCE(d.defaulted_loans, 0) AS defaulted_loans,
    ROUND(
        COALESCE(d.defaulted_loans, 0) * 100.0
        / COUNT(*), 2
    ) AS default_rate_percentage
FROM loan_default l
LEFT JOIN (
    SELECT HasCoSigner, COUNT(*) AS defaulted_loans
    FROM loan_default
    WHERE `Default` = 1
    GROUP BY HasCoSigner
) d ON l.HasCoSigner = d.HasCoSigner
GROUP BY l.HasCoSigner, d.defaulted_loans;

## Inference:
# Loans with a co-signer have a default rate of [__%], compared with [__%] for loans without one.
# This indicates that a co-signer [reduces default risk / does not make a meaningful difference].



#10. The bank wants to identify high-risk customer segments by analyzing credit score and employment type together. 
SELECT EmploymentType ,
    CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        ELSE 'Very Good'
    END AS credit_category,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS default_rate_percentage
    from loan_default
group by EmploymentType ,
    CASE
        WHEN CreditScore BETWEEN 300 AND 579 THEN 'Poor'
        WHEN CreditScore BETWEEN 580 AND 669 THEN 'Fair'
        WHEN CreditScore BETWEEN 670 AND 739 THEN 'Good'
        ELSE 'Very Good'
    END ;

## Inference:
# The highest-risk segment is [Employment type] + [Credit category] with a default rate of [__%],
# while the safest is [Employment type] + [Credit category] at [__%]. Analysing the two factors
# together identifies high-risk customers more precisely than either factor alone.

select * from loan_default ;


#11.The bank wants to investigate whether borrowers with a higher Debt-to-Income (DTI) ratio are more likely to default on their loans. 

SELECT
    'Low DTI' AS dti_category,
    COUNT(*) AS total_loans,
    SUM(`Default`) AS defaulted_loans,
    ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
        AS default_rate_percentage
FROM loan_default
WHERE DTIRatio <= 0.20

UNION ALL

SELECT 'Moderate DTI', COUNT(*), SUM(`Default`),
       ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE DTIRatio > 0.20 AND DTIRatio <= 0.30

UNION ALL

SELECT 'High DTI', COUNT(*), SUM(`Default`),
       ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE DTIRatio > 0.30 AND DTIRatio <= 0.40

UNION ALL

SELECT 'Very High DTI', COUNT(*), SUM(`Default`),
       ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE DTIRatio > 0.40
ORDER BY default_rate_percentage DESC;

## Inference:
# Borrowers in the Very High DTI band (above 0.40) have a default rate of [__%], compared with [__%]
# for the Low DTI band (0.20 or below). Default risk [rises / does not rise clearly] with DTI, so a
# DTI cap at approval [would / may not] help control risk.


#12.Which loan amount ranges have the highest default rate? 
select * from loan_default;
select 
CASE 
when loanamount <25000 then 'Below 25K' 
when loanamount <50000 then '25K-49K'
when loanamount <100000 THEN '50K-99K'
ELSE '100K+'
end as loan_amount_category ,
COUNT(*) AS total_loans,
    SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END)
        AS defaulted_loans,
    ROUND(
        SUM(CASE WHEN `Default` = 1 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS defaulted_loans_percentage 
FROM loan_default
group by 
CASE 
when loanamount <25000 then 'Below 25K' 
when loanamount <50000 then '25K-49K'
when loanamount <100000 THEN '50K-99K'
ELSE '100K+'
end 
order by defaulted_loans_percentage desc;

## Inference:
# The [__] loan range has the highest default rate at [__%], while the [__] range has the lowest at
# [__%]. This shows that [larger / smaller] loans carry more default risk, and exposure limits
# should be set with this in mind.


#13.How do interest rate ranges relate to loan default risk? 
SELECT
    'Below 5%' AS interest_rate_category,
    COUNT(*) AS total_loans,
    SUM(`Default`) AS defaulted_loans,
    ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
        AS default_rate_percentage
FROM loan_default
WHERE InterestRate < 5

UNION ALL

SELECT
    '5%-10%',
    COUNT(*),
    SUM(`Default`),
    ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE InterestRate >= 5 AND InterestRate < 10

UNION ALL

SELECT
    '10%-15%',
    COUNT(*),
    SUM(`Default`),
    ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE InterestRate >= 10 AND InterestRate < 15

UNION ALL

SELECT
    '15% and above',
    COUNT(*),
    SUM(`Default`),
    ROUND(SUM(`Default`) * 100.0 / COUNT(*), 2)
FROM loan_default
WHERE InterestRate >= 15

ORDER BY default_rate_percentage DESC;

## Inference:
# Loans with an interest rate of 15% and above have a default rate of [__%], compared with [__%] for
# loans below 5%. Default risk [increases / does not change much] as the interest rate rises, which
# may reflect riskier borrowers being charged higher rates or a heavier repayment burden.

    
#14.Which loans have a loan-to-income ratio higher than the portfolio average, and how much loan exposure do they represent?
SELECT
    COUNT(*) AS total_high_ratio_loans,
    SUM(LoanAmount) AS total_loan_exposure,
    ROUND(AVG(LoanAmount / Income), 2)
        AS avg_loan_to_income_ratio
FROM loan_default
WHERE Income > 0
  AND LoanAmount / Income > (
      SELECT AVG(LoanAmount / Income)
      FROM loan_default
      WHERE Income > 0
  );

## Inference:
# [__] loans have a loan-to-income ratio above the portfolio average, representing a total exposure of
# [__] with an average ratio of [__]. These loans point to borrowers who are heavily leveraged
# relative to their income and should be monitored more closely.
  
  #15.What proportion of the bank's total loan portfolio is represented by its 10 largest loans? 
  SELECT
    COUNT(*) AS number_of_loans,
    SUM(LoanAmount) AS top_10_loan_amount,
    ROUND(
        SUM(LoanAmount) * 100.0 /
        (SELECT SUM(LoanAmount)
         FROM loan_default),
        2
    ) AS portfolio_exposure_percentage
FROM (
    SELECT LoanID, LoanAmount
    FROM loan_default
    ORDER BY LoanAmount DESC, LoanID
    LIMIT 10
) AS top_loans;

## Inference:
# The 10 largest loans total [__], which is [__%] of the bank's entire loan portfolio. This
# [small share indicates low / large share indicates high] concentration risk from individual
# large borrowers.

#16.How is the bank's loan portfolio distributed across different loan amount categories? 

WITH loan_categories AS (
    SELECT
        CASE
            WHEN LoanAmount < 25000 THEN 'Below 25K'
            WHEN LoanAmount < 50000 THEN '25K-49K'
            WHEN LoanAmount < 100000 THEN '50K-99K'
            ELSE '100K+'
        END AS loan_amount_category,
        LoanAmount
    FROM loan_default
),
category_summary AS (
    SELECT
        loan_amount_category,
        COUNT(*) AS total_loans,
        SUM(LoanAmount) AS total_loan_exposure,
        ROUND(AVG(LoanAmount), 2) AS avg_loan_amount
    FROM loan_categories
    GROUP BY loan_amount_category
)
SELECT
    loan_amount_category,
    total_loans,
    total_loan_exposure,
    avg_loan_amount,
    RANK() OVER (
        ORDER BY total_loan_exposure DESC
    ) AS exposure_rank
FROM category_summary
ORDER BY exposure_rank;

## Inference:
# The [__] category holds the largest share of exposure at [__] (rank 1), while the [__] category
# holds the smallest at [__]. This shows which loan sizes account for most of the bank's lending.


/* =====================================================================
   OVERALL CONCLUSION
   =====================================================================
   The bank's portfolio consists of 4,923 loans with a total value of
   about 633.2 million (average loan 128,630) and an overall default rate
   of 11.66% (574 defaults). The analysis shows that default risk varies
   across borrower and loan characteristics:

   - Employment: Unemployed borrowers (13.62%) default more than
     Full-time employees (9.91%).
   - Loan purpose: "Other" purpose loans have the highest default rate
     (13.64%).
   - Credit score, income, DTI ratio, interest rate, loan term, mortgage
     and co-signer: [summarise which of these showed higher default
     rates, e.g. Poor credit, High DTI, High interest rate, No co-signer].
   - Combined view (Q10): pairing credit score with employment type
     reveals high-risk segments more clearly than any single factor.
   - Concentration (Q15, Q16): the top 10 loans make up [__%] of the
     portfolio, and the [__] category holds the most exposure.

   Recommendations:
   1. Apply stricter screening to high-risk segments such as Unemployed
      borrowers, Other-purpose loans and [other high-risk groups].
   2. Set limits on DTI and loan-to-income ratios at approval.
   3. Encourage co-signers as a risk-mitigation tool [if Q9 supports it].
   4. Monitor exposure concentration in large loans.
   ===================================================================== */
