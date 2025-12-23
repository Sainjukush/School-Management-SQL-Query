# School-Management-SQL-Query  

This repository contains a comprehensive collection of **35 SQL queries (Q1–Q35)** designed to manage, analyze, and report on data within a school database system.  
The queries cover real-world academic scenarios involving students, teachers, grades, subjects, attendance, merit points, parents, and administrative reporting.

This project is intended for **learning, portfolio demonstration, and interview preparation** for SQL and data roles.

---

## Queries Overview

The queries demonstrate a wide range of SQL concepts, from basic joins to advanced analytics using CTEs and window functions.

They include:
- Reporting and aggregation
- Multi-table joins
- Subqueries and EXISTS / NOT EXISTS
- Common Table Expressions (CTEs)
- Window functions
- Ranking and trend analysis
- Real-world dashboard-style queries

---

## List of Queries

1. **Q1:** List each teacher with all subjects they teach (single row per teacher).
2. **Q2:** List each grade with all subjects offered.
3. **Q3:** List each student with subjects they are evaluated in (no duplicates).
4. **Q4:** Show yearly trend of merit points per grade.
5. **Q5:** Report leave balances vs. leave requests for teachers.
6. **Q6:** Identify the most common condition/plan among students.
7. **Q7:** Calculate BMI for students using physical records.
8. **Q8:** Rank top 10 subjects by student enrollment.
9. **Q9:** Find students with evaluations but no attendance records.
10. **Q10:** Show parents with children enrolled in different grades.
11. **Q11:** Calculate teacher workload (grades × subjects).
12. **Q12:** Detect teachers giving merit points outside assigned grades.
13. **Q13:** Dashboard metrics per grade (students, merit points, attendance, teachers).
14. **Q14:** Subject-wise student lists with grades.
15. **Q15:** Count students taught by each teacher.
16. **Q16:** Grade-wise subject and teacher counts.
17. **Q17:** Identify subject with maximum enrollment.
18. **Q18:** Subjects taught by more than one teacher in the same grade.
19. **Q19:** Teachers teaching multiple subjects in a grade.
20. **Q20:** Timetable-style view (Grade, Subject, Teacher, Students).
21. **Q21:** Teachers teaching across multiple grades.
22. **Q22:** Summary report (students, teachers, subjects, averages).
23. **Q23:** Rank top 3 subjects per student by merit points.
24. **Q24:** Running total of merit points per student.
25. **Q25:** Students below class-average attendance (window function).
26. **Q26:** Multi-grade families (parents with children in different grades).
27. **Q27:** Teacher-wise subjects with unique student counts.
28. **Q28:** Students with attendance but no merit points.
29. **Q29:** Students with merit points but no absences.
30. **Q30:** CAS participants with above-average merit points.
31. **Q31:** Monthly teacher absence report by grade and subject.
32. **Q32:** Query optimization example for large evaluation tables.
33. **Q33:** School-wide dashboard metrics.
34. **Q34:** Student → Parent → Parent email mapping.
35. **Q35:** Advanced reporting using recursive and multi-step queries.

---

## Database Requirements

- **Database:** PostgreSQL (recommended)
- **Compatible with:** Any SQL database supporting:
  - CTEs (`WITH`)
  - Window functions
  - `STRING_AGG`
  - `DATE_TRUNC`
  - `EXISTS / NOT EXISTS`

---

## Schema Overview

Main tables used in this project:

- `users` – Base user information (students, teachers, parents)
- `students` – Student-specific data
- `teachers` – Teacher-specific data
- `grades` – Academic grades
- `subjects` – Subjects offered
- `evaluations` – Student–Teacher–Subject–Grade mapping
- `merit_points` – Merit points awarded to students
- `attendances` – Attendance records
- `leave_requests` – Teacher leave applications
- `leave_balances` – Teacher leave balances
- `parents` – Parent records
- `student_parent_maps` – Parent–Student relationships
- `physical_records` – Height and weight records
- `conditions_and_plans` – Student health/learning conditions
- `cas_evaluations` – CAS participation records

---

## Installation and Setup

### 1. Clone the Repository

```bash  
git@github.com:Sainjukush/School-Management-SQL-Query.git
