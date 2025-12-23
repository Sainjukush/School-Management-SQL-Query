---Q1
----For each teacher, show their name and all the subjects they teaach (in a single row).

WITH cte AS (
SELECT
u.name AS teacher_name,
s.name AS subject
FROM teachers t
JOIN users u ON u.id = t.user_id
JOIN teacher_grade_subject_maps tgsm ON t.id =
tgsm.teacher_id
JOIN grade_subject_maps gsm ON tgsm.grade_subject_map_id
= gsm.id
JOIN subjects s ON gsm.subject_id = s.id
)
SELECT
teacher_name, string_agg(subject, ', ')
FROM cte
GROUP BY teacher_name
ORDER BY teacher_name;

--Q2
---For each grade, show all the subjects offered (in a single row).

WITH cte AS (
SELECT g.name AS grades, s.name AS list_of_subjects
FROM grades g
JOIN grade_subject_maps gsm ON g.id = gsm.grade_id
JOIN subjects s ON gsm.subject_id = s.id
)
SELECT grades, string_agg(list_of_subjects, ', ')
FROM cte
GROUP BY grades
ORDER BY grades;

-----Q3
-----For each student, show their name and the subjects they are evaluated in (no duplicates).

WITH cte AS (SELECT u.name AS name_of_student, su.name AS
list_of_subjects
FROM students s
JOIN users u ON u.id = s.user_id
JOIN evaluations e ON e.student_id = s.id
JOIN subjects su ON su.id = e.subject_id
)
SELECT name_of_student, string_agg(DISTINCT list_of_subjects,
', ')
FROM cte
GROUP BY name_of_student
ORDER BY name_of_student;

-----Q4
-----Q5
-----Show the trend of merit points per year for each grade.

SELECT
g.name AS grade,
EXTRACT(YEAR FROM m.created_at) AS year,SUM(m.point) AS total_merit_points
FROM merit_points m
JOIN students s ON m.student_id = s.id
JOIN grades g ON s.grade_id = g.id
GROUP BY g.name, EXTRACT(YEAR FROM m.created_at)
ORDER BY g.name, year;

-----Q6
-----Create a report of leave balances vs. leave requests for teachers.

SELECT
	u.name AS teacher_name,
	lb.sick_leave ,
	COUNT(l.id) AS total_leave_requests
	
FROM teachers t

JOIN users u ON t.user_id = u.id
LEFT JOIN leave_requests l ON l.requester_id = t.id
join leave_balances lb on lb.employee_id = t.id

GROUP BY u.name, lb.sick_leave
ORDER BY teacher_name;

-----Q7
-----Identify the most common condition/plan among students (from conditions_and_plans).

select condition, count(condition) as
total_repeated
from condition_and_plans cap
group by condition
order by total_repeated desc
limit 10;

-----Q8
-----List students with BMI calculation using height and weight in physical_records.

select
u.name as student_name,
p.height as height,
p.weight as weight,
round(weight/height^2) as BMI
from physical_records p
join students s on p.student_id = s.id
join users u on u.id = s.user_id
ORDER BY student_name ;

-----Q9
-----Generate a top 10 revenue-like report: instead of money, rank subjects by how many students are enrolled across grades.

SELECT
sub.name AS subject,
COUNT(DISTINCT e.student_id) AS total_students
FROM evaluations e
JOIN subjects sub ON e.subject_id = sub.id
GROUP BY sub.name
ORDER BY total_students DESC
LIMIT 10;

-----Q10
-----Find students who have evaluations but no attendance records.

SELECT DISTINCT u.name AS student_name
FROM students s
JOIN users u ON s.user_id = u.id
JOIN evaluations e ON e.student_id = s.id
LEFT JOIN attendance a ON a.student_id = s.id
WHERE a.id IS NULL;

-----Q11
-----Show parents with multiple children enrolled in different grades.

SELECT
u.name AS parent_name,
COUNT(DISTINCT s.id) AS children_count,
COUNT(DISTINCT g.id) AS grades_count
FROM parents p
JOIN users u ON u.id = p.user_id
JOIN student_parent_maps spm ON p.id = spm.parent_id
JOIN students s ON spm.student_id = s.id
JOIN grades g ON s.grade_id = g.id
GROUP BY u.name
HAVING COUNT(DISTINCT g.id) > 1;

OR

WITH multi_grade_parents AS (
SELECTp.id AS parent_id
FROM parents p
JOIN student_parent_maps spm ON p.id = spm.parent_id
JOIN students s ON spm.student_id = s.id
JOIN grades g ON s.grade_id = g.id
GROUP BY p.id
HAVING COUNT(DISTINCT g.id) > 1
)
SELECT
u.name AS parent_name,
us.name AS student_name,
g.name AS grade
FROM multi_grade_parents mgp
JOIN parents p ON mgp.parent_id = p.id
JOIN users u ON u.id = p.user_id
JOIN student_parent_maps spm ON p.id = spm.parent_id
JOIN students s ON spm.student_id = s.id
JOIN users us ON us.id = s.user_id
JOIN grades g ON s.grade_id = g.id
ORDER BY parent_name, grade;

-----Q12
-----Write a query to detect teachers who gave merit points to students outside their assigned grades.
SELECT DISTINCT
ut.name AS teacher_name,
us.name AS student_name,
g.name AS student_grade,
sum(m.point) as given_point
FROM merit_points m
JOIN teachers t ON m.teacher_id = t.id
JOIN users ut ON t.user_id = ut.id
JOIN students s ON m.student_id = s.id
JOIN users us ON s.user_id = us.id
JOIN grades g ON s.grade_id = g.id

WHERE t.id <> g.id 
group by teacher_name, student_name,student_grade
order by teacher_name

-----Q13
-----Calculate teacher workload: number of grades × number of subjects they handle.

SELECT
u.id,
u.name,
COUNT(DISTINCT g.id) AS grade_count,
COUNT(DISTINCT s.id) AS subject_count,
COUNT(DISTINCT g.id) * COUNT(DISTINCT s.id) AS workLoad
FROM teachers t
JOIN users u ON u.id = t.user_id
JOIN evaluations e ON e.teacher_id = t.id
JOIN grades g ON e.grade_id = g.id
JOIN subjects s ON e.subject_id = s.id
GROUP BY u.id, u.name;

-----Q14
-----Create a dashboard query: for each grade, show student count, average merit points, attendance rate, and number of teachers.
select
g.name as grades,
count(distinct s.id) as student_count,
avg(mp.point) as merit_points,
round( (SUM(CASE WHEN a.status = True THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS attendance_rate,
count(distinct t.id) as total_teachers
from evaluations e
join students s on e.student_id = s.id
join teachers t on e.teacher_id = t.id
join grades g on s.grade_id = g.id
join merit_points mp on s.id = mp.student_id
join attendances a on s.id = a.student_id
group by g.name;

-----Q15
-----Show each subject along with the list of students enrolled and their grade.

SELECT
sub.name AS subject,
STRING_AGG(DISTINCT us.name || ' (' || g.name || ')', ',
') AS students_with_grades
FROM evaluations e
JOIN subjects sub ON e.subject_id = sub.id
JOIN students st ON e.student_id = st.id
JOIN users us ON st.user_id = us.id
JOIN grades g ON st.grade_id = g.id
GROUP BY sub.name
ORDER BY sub.name;

-----Q16
-----Show each teacher and how many students they are teaching across all grades.

SELECT
u.name AS teacher_name,
COUNT(DISTINCT e.student_id) AS total_students
FROM teachers t
JOIN users u ON t.user_id = u.id
JOIN evaluations e ON e.teacher_id = t.id
GROUP BY u.name
ORDER BY total_students DESC;

-----Q17
-----Show each grade with the count of subjects offered and number of teachers teaching there.

SELECT
g.name AS grade,
COUNT(DISTINCT e.subject_id) AS total_subjects,
COUNT(DISTINCT e.teacher_id) AS total_teachers
FROM grades g
JOIN evaluations e ON e.grade_id = g.id
GROUP BY g.name
ORDER BY g.name;

-----Q18
-----Find which subject has the maximum number of students enrolled.

SELECT
sub.name AS subject,
COUNT(DISTINCT e.student_id) AS student_count
FROM evaluations e
JOIN subjects sub ON e.subject_id = sub.id
GROUP BY sub.name
ORDER BY student_count DESC
LIMIT 1;

-----Q19
-----Show those records that is being taught by more than one teacher for the same subject.

with cte as 
(select 
distinct s.name as subject,
g.name as grade,
u.name as teacher,
dense_rank() over(partition by g.name order by s.name  ) as rank
from subjects s 
join grade_subject_maps gsm on s.id = gsm.subject_id 
join grades g on g.id = gsm.grade_id 
join teacher_grade_subject_maps tgsm on tgsm.grade_subject_map_id = gsm.id 
join teachers t on tgsm.teacher_id =t.id 
join users u on u.id = t.user_id 
order by grade
)
select 
subject ,
grade,
teacher,
rank
from cte
WHERE (subject, grade) IN (
    SELECT subject, grade
    FROM cte
    GROUP BY subject, grade
    HAVING COUNT(DISTINCT teacher) >= 2
)
ORDER BY grade, subject, teacher;

-----Q20
-----For each grade, list teachers who teach multiple subjects in that grade.

SELECT
g.name AS grade,
u.name AS teacher_name,
COUNT(DISTINCT s.id) AS subject_count
FROM evaluations e
JOIN grades g ON e.grade_id = g.id
JOIN teachers t ON e.teacher_id = t.id
JOIN users u ON t.user_id = u.id
JOIN subjects s ON e.subject_id = s.id
GROUP BY g.name, u.name
HAVING COUNT(DISTINCT s.id) > 1
ORDER BY g.name, teacher_name;

-----Q21
-----Show a timetable-like view: Grade, Subject, Teacher, Students.

SELECT
g.name AS grade,
sub.name AS subject,
u.name AS teacher,
STRING_AGG(DISTINCT us.name, ', ') AS students
FROM evaluations e
JOIN grades g ON e.grade_id = g.id
JOIN subjects sub ON e.subject_id = sub.id
JOIN teachers t ON e.teacher_id = t.id
JOIN users u ON t.user_id = u.id
JOIN students st ON e.student_id = st.id
JOIN users us ON st.user_id = us.id
GROUP BY g.name, sub.name, u.name
ORDER BY g.name, sub.name;

-----Q22
-----Find teachers who teach across multiple grades.

SELECT
u.name AS teacher_name,
COUNT(DISTINCT e.grade_id) AS grade_count
FROM evaluations e
JOIN teachers t ON e.teacher_id = t.id
JOIN users u ON t.user_id = u.id
GROUP BY u.name
HAVING COUNT(DISTINCT e.grade_id) > 1
ORDER BY grade_count DESC;

-----Q23
-----Show a summary report: total students, total teachers, total subjects, average number of subjects per student.

SELECT
(SELECT COUNT(*) FROM students) AS total_students,
(SELECT COUNT(*) FROM teachers) AS total_teachers,
(SELECT COUNT(*) FROM subjects) AS total_subjects,
(SELECT ROUND(AVG(sub_count),2)
FROM (SELECT COUNT(DISTINCT subject_id) AS sub_count
FROM evaluations
GROUP BY student_id
) x) AS avg_subjects_per_student;

-----Q24
-----For each student, rank their top 3 subjects based on total merit points received.

with cte as
(
select 
u.name as students,
su.name as subjects,
sum(mp.point) as points
from students s
join users u on u.id = s.user_id 
join merit_points mp on mp.student_id = s.id 
join evaluations e on e.student_id = s.id
join subjects su on su.id = e.subject_id 
group by students ,subjects 
), 
cte2 as(
select
students, 
subjects, 
points,
rank()over(partition by students order by subjects desc) as row
from cte
)
select * from cte2
where row <= 3;

-----Q25
-----Use a window function to calculate a running total of merit points per student.

with cte as 
(
select 
u.name as sname,
mp.point as points,
mp.created_at as created_at
from students s
join users u on u.id = s.user_id 
join merit_points mp on s.id = mp.student_id 
)
select 
sname,
created_at,
points,
sum(points)over(
	partition by sname 
	order by created_at
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) as row
from cte;

-----Q26
-----Identify students whose attendance rate falls below the class average using PARTITION BY grade_id.

with cte as (
    select 
        u.name as student,
        g.name as grade,
        count(*) as total,
        sum(case when a.status = true then 1 else 0 end) as atten
    from students s
    join users u on u.id = s.user_id
    join attendances a on s.id = a.student_id
    join grades g on g.id = s.grade_id 
    group by u.name, g.name
),
cte2 as (
    select
        student,
        grade,
        cast(atten as decimal) / (total) as attendance_rate
    from cte
),
cte3 as (
    select 
        student,
        grade,
        attendance_rate,
        avg(attendance_rate) over (partition by grade) as avg_atten
    from cte2
)
select 
    student,
    grade,
    attendance_rate,
    avg_atten,
    case 
        when attendance_rate > avg_atten then 'AboveAverage' 
        else 'BelowAverage' 
    end as result
from cte3
order by grade, student;

-----Q27
-----Show all parents whose children are in different grades (multi-grade families).

WITH cte AS (
    SELECT 
        us.name AS parent,
        g.name AS grade
    FROM student_parent_maps spm
    JOIN parents p ON p.id = spm.parent_id
    JOIN users us ON p.user_id = us.id
    JOIN students s ON s.id = spm.student_id
    JOIN grades g ON g.id = s.grade_id
)
,cte2 as(	
select 
	parent
	from cte
	group by parent
	having count(distinct grade)>1
)
select 
c.parent,
c.grade
from cte2 ct
join cte c on c.parent = ct.parent
order by parent,grade;

-----Q28
-----For each teacher, list the subjects they teach and the count of unique students they evaluate.
-----
select 
u.name as teachers,
s.name as subjects,
count(distinct st.id) as total_students
from teachers t 
join users u on u.id = t.user_id 
join evaluations e on e.teacher_id = t.id
join subjects s on s.id = e.subject_id 
join students st on e.student_id = st.id 
group by teachers, subjects
order by teachers;

-----Q29
-----Find all students who have never received a merit point, but have attendance records.

SELECT 
    u.name AS student,
    g.name AS grade
FROM students s
JOIN users u ON u.id = s.user_id
JOIN grades g ON g.id = s.grade_id
WHERE EXISTS (
    SELECT 1 
    FROM attendances a
    WHERE a.student_id = s.id
)
AND NOT EXISTS (
    SELECT 1 
    FROM merit_points mp
    WHERE mp.student_id = s.id
)
ORDER BY grade, student;

-----Q30
-----Find students who received merit points but were never absent (EXCEPT or NOT EXISTS).

SELECT 
    u.name AS student
FROM students s
JOIN users u ON u.id = s.user_id

WHERE EXISTS (
    SELECT 1
    FROM merit_points mp
    WHERE mp.student_id = s.id
)
AND NOT EXISTS (
    SELECT 1
    FROM attendances a
    WHERE a.student_id = s.id
      AND a.status = false
)
ORDER BY student;

-----Q-----31
-----Show the intersection of students who participated in both CAS activities and have merit points above average.

WITH cas_students AS (
    SELECT DISTINCT s.id AS student_id,
    u.name
    FROM cas_evaluations ce
    JOIN students s ON s.id = ce.student_id
    JOIN users u ON u.id = s.user_id
),
above_avg_merit AS (
    SELECT s.id AS student_id, u.name
    FROM students s
    JOIN users u ON u.id = s.user_id
    JOIN merit_points mp ON mp.student_id = s.id
    GROUP BY s.id, u.name
    HAVING SUM(mp.point) > (
        SELECT AVG(total_points)
        FROM (
            SELECT SUM(point) AS total_points
            FROM merit_points
            GROUP BY student_id
        ) t
    )
)
SELECT c.student_id, c.name
FROM cas_students c
JOIN above_avg_merit m ON c.student_id = m.student_id
ORDER BY c.name;

-----Q32
-----Generate a monthly report showing how many teachers were absent, grouped by grade and subject.

WITH RECURSIVE months AS (
    -- Anchor: first month in attendance records
    SELECT DATE_TRUNC('month', MIN(a.date)) AS month_start
    FROM attendances a

    UNION ALL

    -- Recursive step: add 1 month at a time
    SELECT month_start + INTERVAL '1 month'
    FROM months
    WHERE month_start + INTERVAL '1 month' <= (
        SELECT DATE_TRUNC('month', MAX(a.date)) FROM attendances a
    )
),
teacher_absences AS (
    SELECT 
        t.id AS teacher_id,
        g.name AS grade,
        s.name AS subject,
        DATE_TRUNC('month', a.date) AS month_start
    FROM teachers t
    JOIN evaluations e ON e.teacher_id = t.id
    JOIN subjects s ON s.id = e.subject_id
    JOIN grades g   ON g.id = e.grade_id
    JOIN attendances a ON a.teacher_id = t.id
    WHERE a.status = false
),
monthly_report AS (
    SELECT 
        m.month_start,
        ta.grade,
        ta.subject,
        COUNT(DISTINCT ta.teacher_id) AS absent_teachers
    FROM months m
    LEFT JOIN teacher_absences ta 
           ON ta.month_start = m.month_start
    GROUP BY m.month_start, ta.grade, ta.subject
)
SELECT *
FROM monthly_report
ORDER BY month_start, grade, subject;

-----Q33
-----Suppose evaluations table has millions of rows — how would you optimize a query that joins it with students and teachers?

WITH recent_evaluations AS (
    SELECT id, student_id, teacher_id, subject_id, created_at
    FROM evaluations
    WHERE created_at >= date_trunc('month', CURRENT_DATE)
)
SELECT 
    t.id   AS teacher_id,
    u.name AS teacher_name,
    COUNT(*) AS total_evaluations
FROM recent_evaluations r
JOIN teachers t ON t.id = r.teacher_id
JOIN users u ON u.id = t.user_id
GROUP BY t.id, u.name
ORDER BY total_evaluations DESC;

-----Q34
-----Write a query for a school dashboard showing: total students, avg merit points, attendance rate, active teachers.

WITH total_students AS (
    SELECT COUNT(*)::int AS total_students
    FROM students
),
avg_merit_points AS (
    SELECT COALESCE(AVG(points_per_student), 0)::numeric(10,2) AS avg_merit_points
    FROM (
        SELECT SUM(mp.point) AS points_per_student
        FROM merit_points mp
        GROUP BY mp.student_id
    ) t
),
attendance_rate AS (
    SELECT 
        ROUND(100.0 * SUM(CASE WHEN a.status = true THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) 
        AS attendance_rate
    FROM attendances a
),
active_teachers AS (
    SELECT COUNT(DISTINCT t.id)::int AS active_teachers
    FROM teachers t
    JOIN evaluations e ON e.teacher_id = t.id
)
SELECT 
    ts.total_students,
    am.avg_merit_points,
    ar.attendance_rate,
    atc.active_teachers
FROM total_students ts
CROSS JOIN avg_merit_points am
CROSS JOIN attendance_rate ar
CROSS JOIN active_teachers atc;

-----Q35
--- Student → Parent → User Info
--- Write a recursive or multi-step query to get the chain:
--- student → parent → parent_user.email.

select 
us.name,
u.name as parents,
u.email as parent_mail
from students s
join users us on us.id = s.user_id
join student_parent_maps  spm on spm.student_id = s.id
join parents p on p.id = spm.parent_id
join users u on u.id = p.user_id 
 
OR

WITH student_parent AS (
    SELECT 
        s.id AS student_id,
        us.name AS student_name,
        p.id AS parent_id
    FROM students s
    JOIN users us ON us.id = s.user_id
    JOIN student_parent_maps spm ON spm.student_id = s.id
    JOIN parents p ON p.id = spm.parent_id
),
parent_user AS (
    SELECT 
        p.id AS parent_id,
        u.name AS parent_name,
        u.email AS parent_email
    FROM parents p
    JOIN users u ON u.id = p.user_id
)
SELECT 
    sp.student_name,
    pu.parent_name,
    pu.parent_email
FROM student_parent sp
JOIN parent_user pu ON sp.parent_id = pu.parent_id;

