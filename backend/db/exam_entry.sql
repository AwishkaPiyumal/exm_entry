-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 28, 2025 at 06:21 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `exam_entry`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddMedicalResitStudents` (IN `p_batch_id` INT, IN `p_sub_id` INT, IN `p_s_id` INT, IN `p_exam_type` VARCHAR(50))   BEGIN
    DECLARE table_name VARCHAR(255);
    DECLARE record_count INT;
    DECLARE v_academic_year VARCHAR(50);
    DECLARE v_level INT;
    DECLARE v_sem INT;
    DECLARE existing_entry_count INT;
    DECLARE existing_subs TEXT;
    DECLARE new_subs TEXT;

    -- Get batch information
    SELECT academic_year, level, sem 
    INTO v_academic_year, v_level, v_sem
    FROM batch 
    WHERE batch_id = p_batch_id;

    -- Construct the dynamic table name
    SET table_name = CONCAT('batch_', p_batch_id, '_sub_', p_sub_id);

    -- Check if the table exists
    SET @check_table_query = CONCAT('SHOW TABLES LIKE "', table_name, '"');
    PREPARE stmt FROM @check_table_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- If table doesn't exist, raise an error
    IF FOUND_ROWS() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The specified table does not exist.';
    END IF;

    -- Check if the student record already exists
    SET @check_record_query = CONCAT(
        'SELECT COUNT(*) INTO @record_count 
         FROM ', table_name, ' 
         WHERE s_id = ', p_s_id
    );
    PREPARE stmt FROM @check_record_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- If the record does not exist, insert the student
    IF @record_count = 0 THEN
        SET @insert_query = CONCAT(
            'INSERT INTO ', table_name, ' (s_id, eligibility, exam_type) 
             VALUES (', p_s_id, ', "true", "', p_exam_type, '")'
        );
        PREPARE stmt FROM @insert_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;

    -- Check if an entry already exists in entry_summary for this student and academic year
    SELECT COUNT(*) INTO existing_entry_count
    FROM entry_summary
    WHERE s_id = p_s_id 
      AND academic_year = v_academic_year 
      AND level = v_level 
      AND sem = v_sem;

    -- If entry exists, update the appropriate column
    IF existing_entry_count > 0 THEN
        IF p_exam_type = 'R' THEN
            -- For resit students
            SELECT COALESCE(resit_subs, '') INTO existing_subs
            FROM entry_summary
            WHERE s_id = p_s_id 
              AND academic_year = v_academic_year 
              AND level = v_level 
              AND sem = v_sem;

            -- Prepare new subjects list
            IF existing_subs = '' THEN
                SET new_subs = CAST(p_sub_id AS CHAR);
            ELSE
                SET new_subs = CONCAT(existing_subs, ',', CAST(p_sub_id AS CHAR));
            END IF;

            -- Update resit_subs
            UPDATE entry_summary 
            SET resit_subs = new_subs
            WHERE s_id = p_s_id 
              AND academic_year = v_academic_year 
              AND level = v_level 
              AND sem = v_sem;

        ELSEIF p_exam_type = 'M' THEN
            -- For medical students
            SELECT COALESCE(medical_subs, '') INTO existing_subs
            FROM entry_summary
            WHERE s_id = p_s_id 
              AND academic_year = v_academic_year 
              AND level = v_level 
              AND sem = v_sem;

            -- Prepare new subjects list
            IF existing_subs = '' THEN
                SET new_subs = CAST(p_sub_id AS CHAR);
            ELSE
                SET new_subs = CONCAT(existing_subs, ',', CAST(p_sub_id AS CHAR));
            END IF;

            -- Update medical_subs
            UPDATE entry_summary 
            SET medical_subs = new_subs
            WHERE s_id = p_s_id 
              AND academic_year = v_academic_year 
              AND level = v_level 
              AND sem = v_sem;
        END IF;
    ELSE
        -- If no entry exists, insert a new record
        IF p_exam_type = 'R' THEN
            INSERT INTO entry_summary (
                s_id, 
                academic_year, 
                level, 
                sem, 
                proper_subs, 
                medical_subs, 
                resit_subs
            ) VALUES (
                p_s_id,
                v_academic_year,
                v_level,
                v_sem,
                NULL,
                NULL,
                CAST(p_sub_id AS CHAR)
            );
        ELSEIF p_exam_type = 'M' THEN
            INSERT INTO entry_summary (
                s_id, 
                academic_year, 
                level, 
                sem, 
                proper_subs, 
                medical_subs, 
                resit_subs
            ) VALUES (
                p_s_id,
                v_academic_year,
                v_level,
                v_sem,
                NULL,
                CAST(p_sub_id AS CHAR),
                NULL
            );
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddNewBatchStudentColumns` (IN `p_batch_id` INT, IN `p_subjects` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE add_column_sql TEXT;

    SET add_column_sql = CONCAT('ALTER TABLE batch_', p_batch_id, '_students ');

    WHILE i < JSON_LENGTH(p_subjects) DO
        SET sub_id = JSON_VALUE(p_subjects, CONCAT('$[', i, '].sub_id'));

        IF i > 0 THEN
            SET add_column_sql = CONCAT(add_column_sql, ',');
        END IF;
        SET add_column_sql = CONCAT(add_column_sql, ' ADD COLUMN sub_', sub_id, ' VARCHAR(50) NOT NULL');
        
        SET i = i + 1;
    END WHILE;

    -- Execute add column SQL
    PREPARE stmt FROM add_column_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `AddStudentsToBatch` (IN `p_batch_id` INT, IN `p_new_students` TEXT)   BEGIN
    DECLARE student_id VARCHAR(255);
    DECLARE temp_students TEXT;
    DECLARE insert_query TEXT;

    -- Initialize the temporary students string
    SET temp_students = p_new_students;

    -- Update student_detail to add batch_id
    WHILE LOCATE(',', temp_students) > 0 DO
        SET student_id = SUBSTRING_INDEX(temp_students, ',', 1);
        SET temp_students = SUBSTRING(temp_students, LOCATE(',', temp_students) + 1);

        UPDATE student_detail
        SET batch_ids = 
            CASE
                WHEN batch_ids IS NULL OR batch_ids = '' THEN p_batch_id
                ELSE CONCAT(batch_ids, ',', p_batch_id)
            END
        WHERE s_id = student_id;
    END WHILE;

    -- Handle the last student ID in the list
    SET student_id = temp_students;
    UPDATE student_detail
    SET batch_ids = 
        CASE
            WHEN batch_ids IS NULL OR batch_ids = '' THEN p_batch_id
            ELSE CONCAT(batch_ids, ',', p_batch_id)
        END
    WHERE s_id = student_id;

    -- Generate dynamic INSERT query for batch_{batch_id}_students
    SET insert_query = CONCAT(
        'INSERT INTO batch_', 
        p_batch_id, 
        '_students (s_id, applied_to_exam) VALUES '
    );

    SET temp_students = p_new_students;

    WHILE LOCATE(',', temp_students) > 0 DO
        SET student_id = SUBSTRING_INDEX(temp_students, ',', 1);
        SET temp_students = SUBSTRING(temp_students, LOCATE(',', temp_students) + 1);

        SET insert_query = CONCAT(insert_query, '(', student_id, ', "false"), ');
    END WHILE;

    -- Handle the last student ID in the list for the INSERT query
    SET student_id = temp_students;
    SET insert_query = CONCAT(insert_query, '(', student_id, ', "false")');

    -- Execute the INSERT query
    PREPARE stmt FROM insert_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ApplyExam` (IN `p_user_id` INT, IN `p_removed_subjects` VARCHAR(255), OUT `out_batch_id` INT)   ae:BEGIN
    DECLARE p_s_id INT;
    DECLARE p_batch_id INT;
    DECLARE p_applied_to_exam VARCHAR(50);
    DECLARE done INT DEFAULT FALSE;
    DECLARE sub_col_name VARCHAR(255);
    DECLARE current_sub_id VARCHAR(10);
    DECLARE attendance_value INT;
    DECLARE eligibility_value VARCHAR(50);
    DECLARE student_deadline DATETIME;
    DECLARE open_date DATETIME;
    
    -- New variables for entry_summary
    DECLARE v_batch_code VARCHAR(100);
    DECLARE v_academic_year VARCHAR(50);
    DECLARE v_level INT;
    DECLARE v_sem INT;
    DECLARE v_proper_subs TEXT DEFAULT '';
    DECLARE existing_entry_count INT;

    -- Cursor for getting all subject columns (sub_* columns)
    DECLARE sub_cursor CURSOR FOR 
        SELECT COLUMN_NAME 
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = CONCAT('batch_', p_batch_id, '_students') 
          AND COLUMN_NAME LIKE 'sub_%';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Step 1: Get s_id from student table using user_id
    SELECT s_id INTO p_s_id
    FROM student
    WHERE user_id = p_user_id;

    IF p_s_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Student ID not found for the given user_id.';
    END IF;

    -- Step 2: Get batch_ids from student_detail and extract the last batch_id
    SELECT CAST(SUBSTRING_INDEX(batch_ids, ',', -1) AS UNSIGNED) INTO p_batch_id
    FROM student_detail
    WHERE s_id = p_s_id;

    IF p_batch_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch ID not found for the student.';
    END IF;

    -- Set the OUT parameter with the batch_id
    SET out_batch_id = p_batch_id;

    -- Get batch information
    SELECT batch_code, level, sem, academic_year 
    INTO v_batch_code, v_level, v_sem, v_academic_year
    FROM batch 
    WHERE batch_id = p_batch_id;

    -- Step 3: Check student deadline
    SELECT end_date INTO student_deadline
    FROM batch_time_periods
    WHERE batch_id = p_batch_id AND user_type = '5'; -- User type '5' is for students

    IF NOW() > student_deadline THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The application deadline for this batch has passed.';
    END IF;
    
    -- Step 4: Check application open date
    SELECT application_open INTO open_date
    FROM batch
    WHERE batch_id = p_batch_id; 

    IF NOW() < open_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The application not opened yet.';
    END IF;

    -- Step 5: Check if student already applied to exam
    SET @table_name = CONCAT('batch_', p_batch_id, '_students');
    
    -- Check if the dynamic table exists
    SET @check_table_query = CONCAT('SHOW TABLES LIKE "', @table_name, '"');
    PREPARE stmt FROM @check_table_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- If table doesn't exist, raise an error
    IF FOUND_ROWS() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The batch table does not exist.';
    END IF;

    -- Check if the student has already applied to the exam
    SET @check_applied_query = CONCAT(
        'SELECT applied_to_exam INTO @p_applied_to_exam FROM ', @table_name, ' WHERE s_id = ', p_s_id
    );
    PREPARE stmt FROM @check_applied_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- If already applied, exit the procedure
    IF @p_applied_to_exam = 'true' THEN
        LEAVE ae;
    END IF;

    -- Step 6: Iterate over all subject columns for the batch
    OPEN sub_cursor;

    subject_loop: LOOP
        FETCH sub_cursor INTO sub_col_name;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Extract the subject ID from the column name (e.g., 'sub_5' -> '5')
        SET current_sub_id = SUBSTRING(sub_col_name, 5);
        
        -- Check if this subject should be skipped
        IF p_removed_subjects IS NOT NULL AND FIND_IN_SET(current_sub_id, p_removed_subjects) > 0 THEN
            -- Skip this subject
            ITERATE subject_loop;
        END IF;

        -- Get the attendance value for the subject
        SET @attendance_query = CONCAT(
            'SELECT ', sub_col_name, ' INTO @attendance_value 
            FROM ', @table_name, ' 
            WHERE s_id = ', p_s_id
        );
        PREPARE stmt FROM @attendance_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Determine eligibility based on attendance
        IF @attendance_value >= 80 THEN
            SET eligibility_value = 'true';
        ELSE
            SET eligibility_value = 'false';
        END IF;

        -- Insert eligibility value into respective subject table (if not exists)
        SET @insert_query = CONCAT(
            'INSERT IGNORE INTO batch_', p_batch_id, '_sub_', current_sub_id, 
            ' (s_id, eligibility, exam_type) VALUES (', p_s_id, ', "', eligibility_value, '", "P")'
        );
        PREPARE stmt FROM @insert_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Collect proper subjects (not skipped)
        IF v_proper_subs = '' THEN
            SET v_proper_subs = current_sub_id;
        ELSE
            SET v_proper_subs = CONCAT(v_proper_subs, ',', current_sub_id);
        END IF;
    END LOOP;

    CLOSE sub_cursor;

    -- Step 7: Update applied_to_exam to 'true' for the student
    SET @update_query = CONCAT(
        'UPDATE ', @table_name, ' 
         SET applied_to_exam = "true" 
         WHERE s_id = ', p_s_id
    );
    PREPARE stmt FROM @update_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Step 8: Handle entry_summary
    -- Check if an entry already exists
    SELECT COUNT(*) INTO existing_entry_count
    FROM entry_summary
    WHERE s_id = p_s_id 
      AND academic_year = v_academic_year 
      AND level = v_level 
      AND sem = v_sem;

    -- If entry exists, update proper_subs
    IF existing_entry_count > 0 THEN
        UPDATE entry_summary 
        SET proper_subs = v_proper_subs
        WHERE s_id = p_s_id 
          AND academic_year = v_academic_year 
          AND level = v_level 
          AND sem = v_sem;
    ELSE
        -- If no entry exists, insert a new record
        INSERT INTO entry_summary (
            s_id, 
            academic_year, 
            level, 
            sem, 
            proper_subs, 
            medical_subs, 
            resit_subs
        ) VALUES (
            p_s_id,
            v_academic_year,
            v_level,
            v_sem,
            v_proper_subs,
            NULL,
            NULL
        );
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckForDuplicateDegree` (IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_deg_id` INT, OUT `p_exists` INT)   BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM degree
    WHERE (deg_name = p_deg_name OR short = p_short) AND deg_id != p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfDegreeExists` (IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), OUT `p_exists` INT)   BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM degree
    WHERE deg_name = p_deg_name OR short = p_short;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfDepartmentExists` (IN `p_d_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)   BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM department d
    LEFT JOIN user u ON d.user_id = u.user_id
    WHERE d.d_name = p_d_name OR u.user_name = p_email OR u.email = p_email;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfFacultyExists` (IN `p_f_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)   BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM faculty f
    LEFT JOIN user u ON f.user_id = u.user_id
    WHERE f.f_name = p_f_name OR u.user_name = p_email;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIndexNoExists` (IN `p_index_no` VARCHAR(255), OUT `p_exists` BOOLEAN)   BEGIN
    IF p_index_no = '' THEN
        SELECT FALSE INTO p_exists; 
    ELSE
        SELECT EXISTS (SELECT 1 FROM student_detail WHERE index_num = p_index_no) INTO p_exists;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckSubjectExist` (IN `p_batch_id` INT(11), IN `p_sub_id` INT(11), IN `p_user_id` INT(11), OUT `p_exists` BOOLEAN)   BEGIN
    SELECT COUNT(*) > 0 INTO p_exists 
    FROM batch_curriculum_lecturer bcl 
    JOIN manager m
    ON bcl.m_id=m.m_id
    WHERE bcl.batch_id = p_batch_id AND bcl.sub_id = p_sub_id AND m.user_id=p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckUserExists` (IN `p_user_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` BOOLEAN)   BEGIN
    SELECT COUNT(*) > 0 INTO p_exists 
    FROM user 
    WHERE user_name = p_user_name OR email = p_email;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBatchStudentsTable` (IN `p_batch_id` INT, IN `p_subjects` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE columns_sql TEXT;

    SET columns_sql = 'id INT AUTO_INCREMENT PRIMARY KEY, s_id INT(11) NOT NULL, applied_to_exam VARCHAR(50) DEFAULT "false"';

    WHILE i < JSON_LENGTH(p_subjects) DO
        SET sub_id = JSON_VALUE(p_subjects, CONCAT('$[', i, '].sub_id'));
        SET columns_sql = CONCAT(columns_sql, ', sub_', sub_id, ' VARCHAR(50) NOT NULL');
        SET i = i + 1;
    END WHILE;

    SET @create_table_sql = CONCAT(
        'CREATE TABLE IF NOT EXISTS batch_', 
        p_batch_id, 
        '_students (', 
        columns_sql, 
        ')'
    );

    PREPARE stmt FROM @create_table_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBatchSubjectTables` (IN `p_batch_id` INT, IN `p_subjects` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE create_table_sql TEXT;

    WHILE i < JSON_LENGTH(p_subjects) DO
        SET sub_id = JSON_VALUE(p_subjects, CONCAT('$[', i, '].sub_id'));
        SET create_table_sql = CONCAT(
            'CREATE TABLE IF NOT EXISTS batch_', 
            p_batch_id, 
            '_sub_', 
            sub_id, 
            ' (
             	id INT AUTO_INCREMENT PRIMARY KEY,
                s_id INT(11) NOT NULL,
                eligibility VARCHAR(50) NOT NULL,
            	exam_type VARCHAR(10) NOT NULL,
            	UNIQUE (s_id)
            )'
        );
        PREPARE stmt FROM create_table_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SET i = i + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateCurriculum` (IN `p_sub_code` VARCHAR(100), IN `p_sub_name` VARCHAR(150), IN `p_sem_no` INT, IN `p_deg_id` INT, IN `p_level` INT, IN `p_status` VARCHAR(50))   BEGIN
    INSERT INTO curriculum (sub_code, sub_name, sem_no, deg_id, level, status)
    VALUES (p_sub_code, p_sub_name, p_sem_no, p_deg_id, p_level, p_status);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDegree` (IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_levels` VARCHAR(255), IN `p_no_of_sem_per_year` VARCHAR(10), IN `p_status` VARCHAR(50), OUT `p_deg_id` INT)   BEGIN
    INSERT INTO degree(deg_name, short, levels, no_of_sem_per_year, status)
    VALUES (p_deg_name, p_short, p_levels, p_no_of_sem_per_year, p_status);
    SET p_deg_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDepartment` (IN `p_d_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50), OUT `p_d_id` INT)   BEGIN
    INSERT INTO department(d_name, user_id, contact_no, status)
    VALUES (p_d_name, p_user_id, p_contact_no, p_status);
    SET p_d_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDepartmentUser` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)   BEGIN
    INSERT INTO user(user_name, email, password, role_id)
    VALUES (p_email, p_email, p_password, '3');
    SET p_user_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateFaculty` (IN `p_f_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50))   BEGIN
    INSERT INTO faculty (f_name, user_id, contact_no, status)
    VALUES (p_f_name, p_user_id, p_contact_no, p_status);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateFacultyUser` (IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)   BEGIN
    INSERT INTO user(user_name, email, password, role_id)
    VALUES (p_email, p_email, p_password, '2');
    
    SET p_user_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateNewBatchSubjectTables` (IN `p_batch_id` INT, IN `p_subjects` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE create_table_sql TEXT;

    WHILE i < JSON_LENGTH(p_subjects) DO
        SET sub_id = JSON_VALUE(p_subjects, CONCAT('$[', i, '].sub_id'));
        
        SET create_table_sql = CONCAT(
            'CREATE TABLE batch_', 
            p_batch_id, 
            '_sub_', 
            sub_id, 
            ' (
                s_id INT(11) NOT NULL,
                eligibility VARCHAR(50) NOT NULL
            )'
        );
        PREPARE stmt FROM create_table_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SET i = i + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBatchCurriculumLecturerRows` (IN `p_batch_id` INT)   BEGIN
    DELETE FROM batch_curriculum_lecturer WHERE batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBatchSubjectEntries` (IN `p_batch_id` INT)   BEGIN
    DECLARE sub_id INT;
    DECLARE done INT DEFAULT FALSE;

    -- Cursor declaration
    DECLARE cursor_subjects CURSOR FOR 
        SELECT sub_id 
        FROM batch_curriculum_lecturer 
        WHERE batch_id = p_batch_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Start transaction
    START TRANSACTION;

    -- Open cursor
    OPEN cursor_subjects;

    subject_loop: LOOP
        FETCH cursor_subjects INTO sub_id;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Construct the dynamic table name
        SET @table_name = CONCAT('batch_', p_batch_id, '_sub_', sub_id);

        -- Delete all rows from the dynamically constructed table
        SET @delete_query = CONCAT('DELETE FROM ', @table_name);
        PREPARE delete_stmt FROM @delete_query;
        EXECUTE delete_stmt;
        DEALLOCATE PREPARE delete_stmt;
    END LOOP;

    -- Close cursor
    CLOSE cursor_subjects;

    -- Commit transaction
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DropOldBatchTablesAndColumns` (IN `p_batch_id` INT, IN `p_old_subjects` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE drop_table_sql TEXT;
    DECLARE drop_column_sql TEXT;

    SET drop_column_sql = CONCAT('ALTER TABLE batch_', p_batch_id, '_students ');

    WHILE i < JSON_LENGTH(p_old_subjects) DO
        SET sub_id = JSON_VALUE(p_old_subjects, CONCAT('$[', i, '].sub_id'));
        
        -- Drop old tables
        SET drop_table_sql = CONCAT('DROP TABLE IF EXISTS batch_', p_batch_id, '_sub_', sub_id);
        PREPARE stmt FROM drop_table_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Prepare column drop SQL
        IF i > 0 THEN
            SET drop_column_sql = CONCAT(drop_column_sql, ',');
        END IF;
        SET drop_column_sql = CONCAT(drop_column_sql, ' DROP COLUMN sub_', sub_id);
        
        SET i = i + 1;
    END WHILE;

    -- Execute column drop SQL
    PREPARE stmt FROM drop_column_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentEligibilityByBatchIdAndSId` (IN `p_batch_id` INT, IN `p_s_id` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_sub_id INT;
    DECLARE cur CURSOR FOR
        SELECT sub_id
        FROM batch_curriculum_lecturer
        WHERE batch_id = p_batch_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Temporary table to collect results
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_eligibility_results (
        sub_id INT,
        eligibility VARCHAR(50)
    );

    -- Iterate over all subjects for the batch
    OPEN cur;

    subject_loop: LOOP
        FETCH cur INTO temp_sub_id;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Construct dynamic query to fetch eligibility
        SET @query = CONCAT(
            'INSERT INTO temp_eligibility_results (sub_id, eligibility) ',
            'SELECT ', temp_sub_id, ' AS sub_id, COALESCE(bsub.eligibility, "N/A") ',
            'FROM batch_', p_batch_id, '_sub_', temp_sub_id, ' bsub ',
            'WHERE bsub.s_id = ', p_s_id
        );

        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;

    -- Fetch all data from the temporary table
    SELECT * FROM temp_eligibility_results;

    -- Drop the temporary table
    DROP TEMPORARY TABLE temp_eligibility_results;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentsWithSubjects` (IN `p_batch_id` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE temp_sub_id INT;
    DECLARE cur CURSOR FOR
        SELECT sub_id
        FROM curriculum
        WHERE sub_id IN (
            SELECT sub_id
            FROM batch_curriculum_lecturer
            WHERE batch_id = p_batch_id
        );

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Temporary table to collect results
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_results (
        s_id INT,
        name VARCHAR(255),
        index_num VARCHAR(255),
        user_name VARCHAR(255),
        exam_type VARCHAR(50),
        sub_id INT,
        eligibility VARCHAR(50)
    );

    -- Iterate over all subjects for the batch
    OPEN cur;

    subject_loop: LOOP
        FETCH cur INTO temp_sub_id;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        SET @query = CONCAT(
            'INSERT INTO temp_results (s_id, name, index_num, user_name, exam_type, sub_id, eligibility) ',
            'SELECT sd.s_id, sd.name, sd.index_num, u.user_name, bsub.exam_type, ', temp_sub_id, ' AS sub_id, bsub.eligibility ',
            'FROM batch_', p_batch_id, '_sub_', temp_sub_id, ' bsub ',
            'JOIN student_detail sd ON bsub.s_id = sd.s_id ',
            'JOIN student st ON sd.s_id = st.s_id ',
            'JOIN user u ON st.user_id = u.user_id'
        );

        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE cur;

    -- Fetch all data from the temporary table
    SELECT * FROM temp_results ORDER BY index_num ASC;

    -- Drop the temporary table
    DROP TEMPORARY TABLE temp_results;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentWithSubjectsByUserId` (IN `batch_id` INT, IN `user_id` INT)   BEGIN
  -- Declare variables for dynamic table and column names
  DECLARE dynamic_students_table VARCHAR(255);
  DECLARE query_students TEXT;
  DECLARE query_subjects TEXT;

  -- Set the dynamic table name for students
  SET dynamic_students_table = CONCAT('batch_', batch_id, '_students');

  -- Get the student details from the student_detail table, joined with student table to get user_name
  SET query_students = 'SELECT sd.s_id, sd.name, u.user_name, sd.index_num ' 
                       'FROM student_detail sd '
                       'JOIN student s ON s.s_id = sd.s_id '
                       'JOIN user u ON u.user_id = s.user_id '
                       'WHERE u.user_id = ?';

  -- Execute the query to fetch student data
  PREPARE stmt FROM query_students;
  EXECUTE stmt USING user_id;
  DEALLOCATE PREPARE stmt;

  -- Fetch all subjects and attendance from the dynamic students table
  SET query_subjects = CONCAT(
    'SELECT bcl.sub_id, c.sub_name, c.sub_code ',
    'FROM batch_curriculum_lecturer bcl ',
    'JOIN curriculum c ON c.sub_id = bcl.sub_id ',
    'LEFT JOIN ', dynamic_students_table, ' bs ON bs.s_id = ? ',
    'WHERE bcl.batch_id = ?'
  );

  -- Execute the query to fetch subjects and attendance
  PREPARE stmt3 FROM query_subjects;
  EXECUTE stmt3 USING user_id, batch_id;
  DEALLOCATE PREPARE stmt3;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `FillProperSummary` (IN `p_batch_id` INT)   BEGIN
    DECLARE v_batch_code VARCHAR(100);
    DECLARE v_description VARCHAR(500);
    DECLARE v_deg_id INT;
    DECLARE v_no_of_sem_per_year VARCHAR(10);
    DECLARE v_academic_year VARCHAR(50);
    DECLARE v_sem VARCHAR(10);
    
    -- 1. Get batch information and extract academic_year and sem
    SELECT batch_code, deg_id, description 
    INTO v_batch_code, v_deg_id, v_description
    FROM batch 
    WHERE batch_id = p_batch_id;
    
    -- Get the number of semesters per year from degree table
    SELECT no_of_sem_per_year 
    INTO v_no_of_sem_per_year
    FROM degree 
    WHERE deg_id = v_deg_id;
    
    -- Extract academic_year (first four characters of batch_code)
    SET v_academic_year = LEFT(v_batch_code, 4);
    
    -- Extract sem based on no_of_sem_per_year
    IF CAST(v_no_of_sem_per_year AS UNSIGNED) < 10 THEN
        SET v_sem = RIGHT(v_batch_code, 1);
    ELSE
        SET v_sem = RIGHT(v_batch_code, 2);
    END IF;
    
    -- 2. First execute the INSERT operation
    SET @insert_query = CONCAT('
        INSERT INTO entry_summary (s_id, academic_year, sem, proper_subs, medical_subs, resit_subs)
        SELECT 
            s.s_id, 
            ''', v_academic_year, ''', 
            ''', v_sem, ''', 
            ''', v_description, ''',
            '''', -- Empty medical_subs
            ''''  -- Empty resit_subs
        FROM 
            batch_', p_batch_id, '_students s
        WHERE 
            NOT EXISTS (
                SELECT 1 
                FROM entry_summary e
                WHERE e.s_id = s.s_id 
                AND e.academic_year = ''', v_academic_year, '''
                AND e.sem = ''', v_sem, '''
            )
    ');
    
    PREPARE stmt FROM @insert_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- 3. Then execute the UPDATE operation separately
    SET @update_query = CONCAT('
        UPDATE entry_summary e
        JOIN batch_', p_batch_id, '_students s ON e.s_id = s.s_id
        SET e.proper_subs = ''', v_description, '''
        WHERE e.academic_year = ''', v_academic_year, '''
        AND e.sem = ''', v_sem, '''
    ');
    
    PREPARE stmt FROM @update_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateIndexNumbers` (IN `p_batch_id` INT, IN `p_course` VARCHAR(50), IN `p_batch` VARCHAR(50), IN `p_startsFrom` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE student_s_id INT;
    DECLARE student_user_name VARCHAR(250);
    DECLARE index_counter INT DEFAULT p_startsFrom;
    DECLARE cursor_students CURSOR FOR SELECT s_id, user_name FROM temp_students;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Temporary table to hold students without index numbers
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_students (
        s_id INT,
        user_name VARCHAR(250)
    );

    -- Construct and execute the query to populate the temporary table
    SET @query = CONCAT(
        'INSERT INTO temp_students (s_id, user_name) ',
        'SELECT sd.s_id, u.user_name ',
        'FROM batch_', p_batch_id, '_students bs ',
        'JOIN student_detail sd ON bs.s_id = sd.s_id ',
        'JOIN student st ON sd.s_id = st.s_id ',
        'JOIN user u ON st.user_id = u.user_id ',
        'WHERE bs.applied_to_exam = "true" AND (sd.index_num IS NULL OR sd.index_num = "") ',
        'ORDER BY u.user_name ASC'
    );
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Open cursor on the temporary table
    OPEN cursor_students;

    -- Iterate through the students and assign index numbers
    subject_loop: LOOP
        FETCH cursor_students INTO student_s_id, student_user_name;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Generate the new index number
        SET @new_index = CONCAT(p_course, " ", p_batch, LPAD(index_counter, 3, '0'));

        -- Update the student's index number
        UPDATE student_detail
        SET index_num = @new_index
        WHERE s_id = student_s_id;

        -- Increment the index counter
        SET index_counter = index_counter + 1;
    END LOOP;

    -- Close cursor
    CLOSE cursor_students;

    -- Fetch and return the updated students
    SELECT sd.s_id, sd.index_num, u.user_name
    FROM student_detail sd
    JOIN student st ON sd.s_id = st.s_id
    JOIN user u ON st.user_id = u.user_id
    WHERE sd.index_num LIKE CONCAT(p_course, " ", p_batch, "%")
    AND sd.index_num IS NOT NULL AND sd.index_num != ""
    ORDER BY sd.index_num ASC;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_students;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveBatches` (IN `p_deg_id` INT)   BEGIN
    SET @query = CONCAT(
        'SELECT b.batch_id, b.batch_code FROM batch b INNER JOIN admission a ON b.batch_id=a.batch_id WHERE b.deg_id = ',p_deg_id,'  AND b.status = ''true'' ORDER BY b.batch_code DESC'
    );
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveBatchesWithinDeadline` (IN `p_deg_id` INT, IN `p_role_id` VARCHAR(50))   BEGIN
    DECLARE pre_role_id VARCHAR(50) DEFAULT NULL;
    DECLARE sql_query TEXT;

    -- Determine the previous role ID based on p_role_id
    IF p_role_id = '3' THEN 
        SET pre_role_id = '4';
    ELSEIF p_role_id = '2' THEN 
        SET pre_role_id = '3';
    ELSE
        SET pre_role_id = NULL;  -- Explicitly handle unexpected role_id values
    END IF;

    -- If pre_role_id is NULL, raise an error
    IF pre_role_id IS NOT NULL THEN 
        -- Construct the SQL query
        SET sql_query = CONCAT(
            'SELECT b.batch_id, b.batch_code, b.academic_year, b.level, b.sem 
            FROM batch b 
            INNER JOIN batch_time_periods btp ON b.batch_id = btp.batch_id 
            WHERE b.deg_id = ', p_deg_id, ' 
            AND b.status = ''true'' 
            AND btp.user_type = ''', p_role_id, ''' 
            AND btp.end_date > NOW() 
            AND EXISTS (
                SELECT 1 
                FROM batch_time_periods 
                WHERE batch_time_periods.batch_id = b.batch_id 
                AND batch_time_periods.user_type = ''', pre_role_id, ''' 
                AND batch_time_periods.end_date < NOW()
            ) 
            ORDER BY b.batch_code DESC'
        );

        -- Prepare, execute, and clean up the query
        PREPARE stmt FROM sql_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        -- Handle cases where pre_role_id is NULL
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid role ID provided';
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDegrees` (`department_ids` TEXT)   BEGIN
    SET @query = CONCAT('SELECT deg_id, short FROM dep_deg WHERE d_id IN (', department_ids, ') AND status = ''true''');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDegreesInDepartment` (IN `p_d_id` INT)   BEGIN
    SELECT 
        deg.deg_id,
        deg.deg_name,
        deg.levels,
        deg.short
    FROM degree deg
    LEFT JOIN dep_deg dd ON deg.deg_id = dd.deg_id
    WHERE dd.d_id = p_d_id AND deg.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDepartmentsWithDegreesCount` (IN `p_f_id` INT)   BEGIN
    SELECT 
        d.d_id,
        d.d_name,
        COUNT(dd.deg_id) AS degrees_count
    FROM department d
    LEFT JOIN dep_deg dd ON d.d_id = dd.d_id
    LEFT JOIN fac_dep fd ON d.d_id = fd.d_id
    WHERE fd.f_id = p_f_id AND d.status = 'true'
    GROUP BY d.d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveFacultiesWithDepartmentsCount` ()   BEGIN
    SELECT 
        f.f_id,
        f.f_name,
        COUNT(fd.d_id) AS departments_count
    FROM faculty f
    LEFT JOIN fac_dep fd ON f.f_id = fd.f_id
    WHERE f.status = 'true'
    GROUP BY f.f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminDetails` (IN `p_user_id` INT)   BEGIN
    SELECT 
        email, user_name, role_id
    FROM 
        user
    WHERE 
        user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAdminSummary` ()   BEGIN
    SELECT 
        (SELECT COUNT(*) FROM batch) AS batch_count,
        (SELECT COUNT(*) FROM curriculum) AS curriculum_count,
        (SELECT COUNT(*) FROM degree) AS degree_count,
        (SELECT COUNT(*) FROM department) AS department_count,
        (SELECT COUNT(*) FROM faculty) AS faculty_count,
        (SELECT COUNT(*) FROM manager) AS manager_count,
        (SELECT COUNT(*) FROM student) AS student_count,
        (SELECT COUNT(*) FROM manager) AS manager_count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveBatchesProgesses` ()   BEGIN
    SELECT 
        b.batch_id, 
        b.batch_code,
        b.application_open,
        GROUP_CONCAT(CONCAT_WS(' ; ', btp.user_type, btp.end_date) ORDER BY btp.end_date DESC SEPARATOR ', ') AS btp_data, 
        a.id AS admission_id, 
        att.id AS attendance_id
    FROM batch b
    LEFT JOIN batch_time_periods btp ON b.batch_id = btp.batch_id
    LEFT JOIN admission a ON b.batch_id = a.batch_id
    LEFT JOIN attendance att ON b.batch_id = att.batch_id
    WHERE b.status = 'true'
    GROUP BY b.batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllActiveManagers` ()   BEGIN
    SELECT 
        md.name, 
        u.email, 
        md.contact_no, 
        md.status,
        md.m_id 
    FROM 
        manager m
    INNER JOIN 
        manager_detail md ON m.m_id = md.m_id
    INNER JOIN 
        user u ON m.user_id = u.user_id
    WHERE 
        md.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllBatchDetails` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE batchId INT;
    DECLARE batchCode VARCHAR(100);
    DECLARE academicYear VARCHAR(50);
 	DECLARE	levelNo INT(11);
    DECLARE semNo INT(11);    
    DECLARE shortCode VARCHAR(50);
    DECLARE degName VARCHAR(500);
    DECLARE batchStatus VARCHAR(50);
    DECLARE studentCount INT DEFAULT 0; -- Default student count to 0

    -- Declare cursor to fetch all batches, including those without students
    DECLARE batch_cursor CURSOR FOR 
        SELECT batch_id, batch_code, status, academic_year, level, sem FROM batch;

    -- Declare continue handler for cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Temporary table to store results
    CREATE TEMPORARY TABLE temp_batch_details (
        batch_id INT,
        batch_code VARCHAR(100),
        academic_year VARCHAR(50),
        level INT(11),
        sem INT(11),
        degree_name VARCHAR(500),
        student_count INT,
        batch_status VARCHAR(50)
    );

    -- Open the cursor
    OPEN batch_cursor;

    -- Start fetching batches
    read_loop: LOOP
        FETCH batch_cursor INTO batchId, batchCode, batchStatus, academicYear, levelNo, semNo;

        IF done THEN
            LEAVE read_loop;
        END IF;

    
        SELECT deg_name INTO degName
        FROM degree d
        JOIN batch b ON d.deg_id = b.deg_id
        WHERE b.batch_id = batchId
        LIMIT 1;  -- In case of multiple matches, select the first one

        -- Count the number of students who applied to the exam from the specific batch students table
        SET @query = CONCAT('SELECT COUNT(*) INTO @studentCount FROM batch_', batchId, '_students');
        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Insert the results into the temporary table
        INSERT INTO temp_batch_details (batch_id, batch_code, academic_year, level, sem, degree_name, student_count, batch_status)
        VALUES (batchId, batchCode, academicYear, levelNo, semNo, degName, @studentCount, batchStatus);

    END LOOP;

    -- Close the cursor
    CLOSE batch_cursor;

    -- Return all results from the temporary table
    SELECT * FROM temp_batch_details;

    -- Drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_batch_details;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllBatches` ()   BEGIN
    SELECT * FROM batch;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllCurriculums` ()   BEGIN
    SELECT * 
    FROM curriculum 
    WHERE status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllCurriculumsWithExtraDetails` ()   BEGIN
    SELECT 
        curriculum.*,
        degree.deg_name AS degree_name
    FROM curriculum
    JOIN degree ON curriculum.deg_id = degree.deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllDegrees` ()   BEGIN
    SELECT * 
    FROM degree 
    WHERE status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllDegreesWithDetails` ()   BEGIN
    SELECT 
        dg.deg_id,
        dg.deg_name,
        dg.short,
        dg.levels,
        dg.no_of_sem_per_year,
        dg.status,
        d.d_id,
        d.d_name AS department_name,
        f.f_id,
        f.f_name AS faculty_name
    FROM degree dg 
    LEFT JOIN dep_deg dd ON dg.deg_id = dd.deg_id 
    LEFT JOIN department d ON dd.d_id = d.d_id 
    LEFT JOIN fac_dep fd ON d.d_id = fd.d_id 
    LEFT JOIN faculty f ON fd.f_id = f.f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllDepartments` ()   BEGIN
    SELECT * 
    FROM department
    WHERE status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllDepartmentsWithDetails` ()   BEGIN
    SELECT 
        d.*, 
        u.user_name AS email, 
        f.f_name AS faculty_name, 
        COUNT(DISTINCT dd.deg_id) AS degree_count 
    FROM department d 
    LEFT JOIN user u ON d.user_id = u.user_id 
    LEFT JOIN fac_dep fd ON d.d_id = fd.d_id 
    LEFT JOIN faculty f ON fd.f_id = f.f_id 
    LEFT JOIN dep_deg dd ON d.d_id = dd.d_id 
    GROUP BY d.d_id, d.d_name, f.f_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllFaculties` ()   BEGIN
    SELECT * 
    FROM faculty 
    WHERE status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllFacultiesWithDetails` ()   BEGIN
    SELECT 
        f.*, 
        u.user_name AS email, 
        COUNT(DISTINCT fd.d_id) AS department_count, 
        COUNT(DISTINCT dd.deg_id) AS degree_count 
    FROM faculty f 
    LEFT JOIN user u ON f.user_id = u.user_id 
    LEFT JOIN fac_dep fd ON f.f_id = fd.f_id 
    LEFT JOIN dep_deg dd ON fd.d_id = dd.d_id 
    GROUP BY f.f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllLevelsInDegree` (IN `p_deg_id` INT)   BEGIN
    SELECT 
        deg.deg_id,
        deg.deg_name,
        deg.levels
    FROM degree deg
    WHERE deg.deg_id = p_deg_id AND deg.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllManagers` ()   BEGIN
    SELECT 
        u.user_id, 
        u.user_name, 
        md.name, 
        u.email, 
        md.contact_no, 
        md.status,
        md.m_id 
    FROM 
        user u
    INNER JOIN 
        manager m ON u.user_id = m.user_id
    INNER JOIN 
        manager_detail md ON m.m_id = md.m_id
    WHERE 
        u.role_id = 4;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllStudents` ()   BEGIN
    SELECT 
        u.user_id, 
        u.user_name, 
        sd.name, 
        sd.f_id, 
        u.email, 
        sd.status,
        sd.s_id,
        sd.index_num,
        sd.contact_no
    FROM 
        user u
    INNER JOIN 
        student s ON u.user_id = s.user_id
    INNER JOIN 
        student_detail sd ON s.s_id = sd.s_id
    WHERE 
        u.role_id = 5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAllSubjectsForManager` (IN `p_user_id` INT)   BEGIN
    DECLARE p_m_id INT;

    -- Step 1: Get manager ID (m_id) from user ID
    SELECT m_id INTO p_m_id
    FROM manager
    WHERE user_id = p_user_id;

    IF p_m_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Manager ID not found for the given user ID.';
    END IF;

    -- Step 2: Fetch all subjects (sub_id, sub_code, sub_name) for the manager's active batches
    -- but only if the lecturer deadline has not passed
    SELECT
        c.sub_id,
        c.sub_code,
        c.sub_name,
        bcl.batch_id,
        btp.end_date AS deadline
    FROM
        batch_curriculum_lecturer bcl
    INNER JOIN
        batch b ON b.batch_id = bcl.batch_id
    INNER JOIN
        curriculum c ON c.sub_id = bcl.sub_id
    INNER JOIN
        batch_time_periods btp ON btp.batch_id = bcl.batch_id
    WHERE
        bcl.m_id = p_m_id
        AND b.status = 'true'
        AND btp.user_type = '4' -- Lecturer user type
        AND btp.end_date > NOW() -- Deadline has not passed
        AND b.application_open < NOW(); -- open date has passed
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAppliedStudentsByBatchAndSubject` (IN `p_user_id` INT, IN `p_batch_id` INT, IN `p_sub_id` INT, IN `p_role_id` VARCHAR(50))   BEGIN
    DECLARE p_m_id INT;
    DECLARE batch_status VARCHAR(50);
    DECLARE lecturer_deadline DATETIME;

    -- Step 1: Check batch status
    SELECT status INTO batch_status
    FROM batch
    WHERE batch_id = p_batch_id;

    IF batch_status != 'true' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch is not active.';
    END IF;

    -- Step 2: Verify lecturer access and deadline
    IF p_role_id != '1' THEN -- Not an admin
        -- Retrieve manager ID for the user
        SELECT m_id INTO p_m_id
        FROM manager
        WHERE user_id = p_user_id;

        IF p_m_id IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
        END IF;

        -- Verify the user is assigned to the batch and subject
        SELECT COUNT(*)
        INTO @access_count
        FROM batch_curriculum_lecturer
        WHERE m_id = p_m_id AND sub_id = p_sub_id AND batch_id = p_batch_id;

        IF @access_count = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to view this batch.';
        END IF;

        -- Check if the lecturer's deadline has passed
        SELECT end_date INTO lecturer_deadline
        FROM batch_time_periods
        WHERE batch_id = p_batch_id AND user_type = '4'; -- '4' is the lecturer user type

        IF NOW() > lecturer_deadline THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The deadline for accessing this batch has passed.';
        END IF;
    END IF;

    -- Step 3: Retrieve applied student details
    -- Fetch batch students with attendance
    SET @batch_students_query = CONCAT(
        'SELECT sd.name, sd.s_id, u.user_name, bs.sub_', p_sub_id, ' AS attendance, bsub.eligibility ',
        'FROM batch_', p_batch_id, '_students bs ',
        'JOIN batch_', p_batch_id, '_sub_', p_sub_id, ' bsub ON bs.s_id = bsub.s_id ',
        'JOIN student_detail sd ON sd.s_id = bs.s_id ',
        'JOIN student st ON st.s_id = bs.s_id ',
        'JOIN user u ON st.user_id = u.user_id ',
        'WHERE bs.sub_', p_sub_id, ' IS NOT NULL AND bsub.eligibility IS NOT NULL'
    );

    -- Fetch medical/resit students with exam_type as "attendance"
    SET @non_batch_students_query = CONCAT(
        'SELECT sd.name, sd.s_id, u.user_name, bsub.exam_type AS attendance, bsub.eligibility ',
        'FROM batch_', p_batch_id, '_sub_', p_sub_id, ' bsub ',
        'JOIN student_detail sd ON sd.s_id = bsub.s_id ',
        'JOIN student st ON st.s_id = bsub.s_id ',
        'JOIN user u ON st.user_id = u.user_id ',
        'WHERE bsub.s_id NOT IN (SELECT s_id FROM batch_', p_batch_id, '_students)'
    );

    -- Combine both queries
    SET @final_query = CONCAT('(', @batch_students_query, ') UNION ALL (', @non_batch_students_query, ')');

    PREPARE stmt FROM @final_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAppliedStudentsForSubjectOfFacOrDep` (IN `p_batch_id` INT, IN `p_sub_id` INT, IN `p_role_id` VARCHAR(50))   BEGIN
    DECLARE batch_status VARCHAR(50);
    DECLARE deadline DATETIME;
    DECLARE previous_deadline DATETIME;

    -- Step 1: Check batch status
    SELECT status INTO batch_status
    FROM batch
    WHERE batch_id = p_batch_id;

    IF batch_status != 'true' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch is not active.';
    END IF;

    -- Verify department access and deadline
    IF p_role_id = '3' THEN 
        SELECT end_date INTO deadline
        FROM batch_time_periods
        WHERE batch_id = p_batch_id AND user_type = '3'; 
        
        SELECT end_date INTO previous_deadline
        FROM batch_time_periods
        WHERE batch_id = p_batch_id AND user_type = '4'; 

        IF NOW() > deadline OR NOW() < previous_deadline THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This is not a accessing period of this batch.';
        END IF;
    END IF;
    
    -- Verify faculty access and deadline
    IF p_role_id = '2' THEN 
        SELECT end_date INTO deadline
        FROM batch_time_periods
        WHERE batch_id = p_batch_id AND user_type = '2'; 
        
        SELECT end_date INTO previous_deadline
        FROM batch_time_periods
        WHERE batch_id = p_batch_id AND user_type = '3'; 

        IF NOW() > deadline OR NOW() < previous_deadline THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This is not a accessing period of this batch.';
        END IF;
    END IF;

    -- Step 3: Retrieve applied student details
    -- Fetch batch students with attendance
    SET @batch_students_query = CONCAT(
        'SELECT sd.name, sd.s_id, u.user_name, bs.sub_', p_sub_id, ' AS attendance, bsub.eligibility ',
        'FROM batch_', p_batch_id, '_students bs ',
        'JOIN batch_', p_batch_id, '_sub_', p_sub_id, ' bsub ON bs.s_id = bsub.s_id ',
        'JOIN student_detail sd ON sd.s_id = bs.s_id ',
        'JOIN student st ON st.s_id = bs.s_id ',
        'JOIN user u ON st.user_id = u.user_id ',
        'WHERE bs.sub_', p_sub_id, ' IS NOT NULL AND bsub.eligibility IS NOT NULL'
    );

    -- Fetch medical/resit students with exam_type as "attendance"
    SET @non_batch_students_query = CONCAT(
        'SELECT sd.name, sd.s_id, u.user_name, bsub.exam_type AS attendance, bsub.eligibility ',
        'FROM batch_', p_batch_id, '_sub_', p_sub_id, ' bsub ',
        'JOIN student_detail sd ON sd.s_id = bsub.s_id ',
        'JOIN student st ON st.s_id = bsub.s_id ',
        'JOIN user u ON st.user_id = u.user_id ',
        'WHERE bsub.s_id NOT IN (SELECT s_id FROM batch_', p_batch_id, '_students)'
    );

    -- Combine both queries
    SET @final_query = CONCAT('(', @batch_students_query, ') UNION ALL (', @non_batch_students_query, ')');

    PREPARE stmt FROM @final_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchAdmissionDetails` (IN `p_batch_id` INT)   BEGIN
    SELECT 
        id, 
        batch_id, 
        generated_date, 
        subject_list, 
        exam_date, 
        description, 
        instructions,
        provider
    FROM 
        admission
    WHERE 
        batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchCount` ()   BEGIN
    SELECT COUNT(*) AS batch_count FROM batch;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchDetails` (IN `p_batch_id` INT)   BEGIN
    SELECT * FROM batch WHERE batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchesByFacultyId` (IN `p_f_id` INT)   BEGIN
    SELECT 
        b.batch_id, 
        b.batch_code, 
        b.academic_year, 
        b.level, 
        b.sem, 
        d.deg_name,
        d.short,
        btp.end_date
    FROM 
        fac_dep fd
    JOIN 
        dep_deg dd ON fd.d_id = dd.d_id
    JOIN 
        degree d ON dd.deg_id = d.deg_id
    JOIN 
        batch b ON b.deg_id = d.deg_id
    LEFT JOIN
        batch_time_periods btp 
        ON b.batch_id = btp.batch_id 
        AND btp.user_type = '2'  
    WHERE 
        fd.f_id = p_f_id 
        AND b.status = 'true'
    ORDER BY 
        LENGTH(d.short);  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchFullDetails` (IN `p_batch_id` INT)   BEGIN
    DECLARE query TEXT;

    -- Construct the query to fetch batch details
    SET query = CONCAT(
    'SELECT b.batch_id, b.batch_code, b.academic_year, b.level, b.sem, d.deg_name, dept.d_name, fac.f_name ',
    'FROM batch b ',
    'JOIN degree d ON b.deg_id = d.deg_id ',
    'JOIN dep_deg dd ON d.deg_id = dd.deg_id ',
    'JOIN department dept ON dd.d_id = dept.d_id ',
    'JOIN fac_dep fd ON dept.d_id = fd.d_id ',
    'JOIN faculty fac ON fd.f_id = fac.f_id ',
    'WHERE b.batch_id = ', p_batch_id
);

    -- Execute the constructed query
    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetBatchOpenDate` (IN `p_batch_id` INT)   BEGIN
    SELECT
    	application_open
    FROM
        batch
    WHERE
       	batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurriculumByBatchId` (IN `p_batch_id` INT)   BEGIN
    SELECT 
        c.sub_code, 
        c.sub_name, 
        c.sub_id 
    FROM 
        batch_curriculum_lecturer bcl 
    INNER JOIN 
        curriculum c 
    ON 
        bcl.sub_id = c.sub_id 
    WHERE 
        bcl.batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurriculumByDegLevSem` (IN `p_deg_id` INT, IN `p_level` INT, IN `p_sem_no` INT)   BEGIN
    SELECT * 
    FROM curriculum 
    WHERE 
        deg_id = p_deg_id 
        AND level = p_level 
        AND sem_no = p_sem_no 
        AND status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurriculumById` (IN `p_sub_id` INT)   BEGIN
    SELECT 
        curriculum.*,
        dep_deg.d_id,
        fac_dep.f_id
    FROM curriculum
    INNER JOIN dep_deg ON curriculum.deg_id = dep_deg.deg_id
    INNER JOIN fac_dep ON dep_deg.d_id = fac_dep.d_id
    WHERE sub_id = p_sub_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurriculumsByDid` (IN `p_hod_id` INT)   BEGIN
    SELECT 
        curriculum.sub_id, 
        curriculum.sub_name, 
        curriculum.sem_no, 
        curriculum.deg_id, 
        curriculum.level, 
        curriculum.status
    FROM curriculum
    INNER JOIN dep_deg ON curriculum.deg_id = dep_deg.deg_id
    INNER JOIN dep_hod ON dep_deg.d_id = dep_hod.d_id
    WHERE 
        dep_hod.m_id = p_hod_id 
        AND curriculum.status = 'Active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetCurriculumsByLecId` (IN `p_m_id` INT)   BEGIN
    SELECT curriculum.* 
    FROM curriculum 
    JOIN batch_curriculum_lecture 
    ON curriculum.sub_id = batch_curriculum_lecture.sub_id 
    WHERE batch_curriculum_lecture.m_id = p_m_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDeadlinesForBatch` (IN `p_batch_id` INT)   BEGIN
    SELECT
    	btp.user_type,
        btp.end_date AS deadline
    FROM
        batch_time_periods btp
    INNER JOIN
        batch b ON b.batch_id = btp.batch_id
    WHERE
        b.status = 'true'
        AND b.batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegFacDepDetails` (IN `p_degree_name_short` VARCHAR(50))   BEGIN
    SELECT 
        d.deg_id, 
        dd.d_id, 
        fd.f_id 
    FROM 
        degree d
    INNER JOIN 
        dep_deg dd ON d.deg_id = dd.deg_id
    INNER JOIN 
        fac_dep fd ON dd.d_id = fd.d_id
    WHERE 
        d.short = p_degree_name_short;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeById` (IN `p_deg_id` INT)   BEGIN
    SELECT 
        dg.*,
        d.d_id,
        f.f_id
    FROM degree dg 
    LEFT JOIN dep_deg dd ON dg.deg_id = dd.deg_id 
    LEFT JOIN department d ON dd.d_id = d.d_id 
    LEFT JOIN fac_dep fd ON d.d_id = fd.d_id 
    LEFT JOIN faculty f ON fd.f_id = f.f_id
    WHERE dg.deg_id = p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeByShort` (IN `p_short` VARCHAR(50))   BEGIN
    SELECT deg_name 
    FROM degree 
    WHERE short = p_short;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeCount` (OUT `p_degree_count` INT)   BEGIN
    SELECT COUNT(*) INTO p_degree_count
    FROM degree;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeCountByDepartment` (IN `p_d_id` INT, OUT `p_degree_count` INT)   BEGIN
    SELECT COUNT(DISTINCT deg_id) INTO p_degree_count
    FROM dep_deg
    WHERE d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeCountByLevel` (IN `p_levels` VARCHAR(255), OUT `p_degree_count` INT)   BEGIN
    SELECT COUNT(*) INTO p_degree_count
    FROM degree
    WHERE levels = p_levels;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreeDetailsByDegid` (IN `p_deg_id` INT, OUT `p_exists` INT)   BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM degree
    WHERE deg_id = p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDegreesByDepartmentId` (IN `p_d_id` INT)   BEGIN
    SELECT 
        degree.* 
    FROM degree 
    INNER JOIN dep_deg ON degree.deg_id = dep_deg.deg_id 
    WHERE dep_deg.d_id = p_d_id 
      AND degree.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentById` (IN `p_d_id` INT)   BEGIN
    SELECT 
        d.*, 
        fd.f_id, 
        u.user_name AS email 
    FROM department d 
    INNER JOIN fac_dep fd ON d.d_id = fd.d_id 
    LEFT JOIN user u ON u.user_id = d.user_id 
    WHERE d.d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentCount` (OUT `p_department_count` INT)   BEGIN
    SELECT COUNT(*) INTO p_department_count
    FROM department;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentCountByFaculty` (IN `p_f_id` INT, OUT `p_department_count` INT)   BEGIN
    SELECT COUNT(DISTINCT d_id) INTO p_department_count
    FROM fac_dep
    WHERE f_id = p_f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentDetails` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.email, u.user_name, d.d_name AS name, u.role_id
    FROM 
        user u
    INNER JOIN 
        department d ON u.user_id = d.user_id
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentDetailsByDid` (IN `p_d_id` INT)   BEGIN
    SELECT d.d_id, d.user_id
    FROM department d
    WHERE d.d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDepartmentsByFacultyId` (IN `p_f_id` INT)   BEGIN
    SELECT 
        department.* 
    FROM department 
    INNER JOIN fac_dep ON department.d_id = fac_dep.d_id 
    WHERE fac_dep.f_id = p_f_id 
      AND department.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDynamicTableData` (IN `batch_id` INT, IN `sub_id` INT)   BEGIN
    SET @query = CONCAT(
        'SELECT s_id, exam_type, eligibility ',
        'FROM batch_', batch_id, '_sub_', sub_id
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetEligibleStudentsBySub` (IN `p_batch_id` INT, IN `p_sub_id` INT)   BEGIN
    -- Declare the dynamic table name
    DECLARE dynamic_table_name VARCHAR(255);

    -- Construct the table name dynamically
    SET dynamic_table_name = CONCAT('batch_', p_batch_id, '_sub_', p_sub_id);

    -- Check if the dynamic table exists
    SET @check_table_query = CONCAT(
        'SELECT COUNT(*) INTO @table_exists FROM information_schema.tables ',
        'WHERE table_schema = DATABASE() AND table_name = "', dynamic_table_name, '"'
    );
    PREPARE stmt FROM @check_table_query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- If table does not exist, raise an error
    IF @table_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'The dynamic table does not exist.';
    END IF;

    -- Construct the query to fetch data
    SET @query = CONCAT(
    'SELECT bs.s_id, bs.exam_type, sd.index_num ',
    'FROM ', dynamic_table_name, ' bs ',
    'JOIN student_detail sd ON bs.s_id = sd.s_id ',
    'WHERE bs.eligibility = "true"'
);


    -- Execute the constructed query
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacStudentByBatchId` (IN `p_batch_id` INT)   BEGIN
    SELECT 
        sd.s_id,
        sd.name,
        u.user_name
    FROM 
        student_detail sd
    INNER JOIN 
        student s ON sd.s_id = s.s_id
    INNER JOIN 
        user u ON s.user_id = u.user_id
    INNER JOIN 
        fac_dep fd ON sd.f_id = fd.f_id
    INNER JOIN 
        dep_deg dd ON fd.d_id = dd.d_id
	INNER JOIN 
        batch b ON b.deg_id = dd.deg_id
    WHERE 
        b.batch_id = p_batch_id AND sd.status = 'true';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacultyById` (IN `p_f_id` INT)   BEGIN
    SELECT 
        f.*, 
        u.user_name AS email 
    FROM faculty f 
    LEFT JOIN user u ON u.user_id = f.user_id 
    WHERE f.f_id = p_f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacultyCount` (OUT `p_faculty_count` INT)   BEGIN
    SELECT COUNT(*) INTO p_faculty_count
    FROM faculty;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacultyDetails` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.email, u.user_name, f.f_name AS name, u.role_id
    FROM 
        user u
    INNER JOIN 
        faculty f ON u.user_id = f.user_id
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetFacultyDetailsByFid` (IN `p_f_id` INT)   BEGIN
    SELECT f.f_id, f.user_id
    FROM faculty f
    WHERE f.f_id = p_f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLastAssignedIndexNumber` (IN `p_course` VARCHAR(50), IN `p_batch` VARCHAR(50))   BEGIN
    DECLARE last_index_num VARCHAR(50);

    -- Fetch the last assigned index number for the given course and batch
    SELECT SUBSTRING_INDEX(index_num, ' ', -1) INTO last_index_num
    FROM student_detail
    WHERE index_num LIKE CONCAT(p_course, " ", p_batch, "%")
    ORDER BY index_num DESC
    LIMIT 1;

    -- If no index number is found, return 0
    IF last_index_num IS NULL THEN
        SELECT 0 AS last_assigned_index;
    ELSE
        SELECT CAST(last_index_num AS UNSIGNED) AS last_assigned_index;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLatestAdmissionTemplate` (IN `p_batch_id` INT)   BEGIN
    DECLARE recordExists INT;

    -- Check if a record with the given batch_id exists
    SELECT COUNT(*) INTO recordExists
    FROM admission
    WHERE batch_id = p_batch_id;

    IF recordExists > 0 THEN
        -- If a record exists, return exist=true and the record data
        SELECT 
            TRUE AS exist,
            JSON_OBJECT(
                'id', id,
                'batch_id', batch_id,
                'generated_date', generated_date,
                'subject_list', subject_list,
                'exam_date', exam_date,
                'description', description,
                'instructions', instructions,
                'provider', provider
            ) AS data
        FROM admission
        WHERE batch_id = p_batch_id
        LIMIT 1;
    ELSE
        -- If no record exists, return exist=false and the latest template data
        SELECT 
            FALSE AS exist,
            JSON_OBJECT(
                'description', description,
                'instructions', instructions,
                'provider', provider
            ) AS data
        FROM admission
        ORDER BY id DESC
        LIMIT 1;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetLatestAttendanceTemplate` (IN `p_batch_id` INT)   BEGIN
    DECLARE recordExists INT;

    -- Check if a record with the given batch_id exists
    SELECT COUNT(*) INTO recordExists
    FROM attendance
    WHERE batch_id = p_batch_id;

    IF recordExists > 0 THEN
        -- If a record exists, return exist=true and the record data
        SELECT 
            TRUE AS exist,
            JSON_OBJECT(
                'id', id,
                'batch_id', batch_id,
                'exam_date', exam_date,
                'description', description
            ) AS data
        FROM attendance
        WHERE batch_id = p_batch_id
        LIMIT 1;
    ELSE
        -- If no record exists, return exist=false and the latest template data
        SELECT 
            FALSE AS exist,
            JSON_OBJECT(
                'description', description
            ) AS data
        FROM attendance
        ORDER BY id DESC
        LIMIT 1;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManagerById` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.user_id, 
        u.user_name, 
        md.name, 
        u.email, 
        md.contact_no, 
        md.status,
        md.m_id 
    FROM 
        user u
    INNER JOIN 
        manager m ON u.user_id = m.user_id
    INNER JOIN 
        manager_detail md ON m.m_id = md.m_id
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetManagerDetails` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.email, u.user_name, md.name, u.role_id
    FROM 
        user u
    INNER JOIN 
        manager m ON u.user_id = m.user_id
    INNER JOIN 
        manager_detail md ON m.m_id = md.m_id
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNonBatchStudentsByFaculty` (IN `p_batch_id` INT)   BEGIN
    DECLARE p_f_id INT;
    DECLARE table_name VARCHAR(255);

    -- Step 1: Get the faculty ID (f_id) for the given batch_id
    SELECT fd.f_id INTO p_f_id
    FROM batch b
    JOIN degree deg ON b.batch_code REGEXP CONCAT('^[0-9]{4}', deg.short, '[0-9]{2}$')
    JOIN dep_deg dd ON deg.deg_id = dd.deg_id
    JOIN fac_dep fd ON fd.d_id = dd.d_id
    JOIN faculty f ON fd.f_id = f.f_id
    WHERE b.batch_id = p_batch_id
    LIMIT 1;

    -- Debug: Check faculty ID
    SELECT p_f_id AS faculty_id;

    IF p_f_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Faculty ID not found for the given batch ID.';
    END IF;

    -- Step 2: Construct the batch_students table name dynamically
    SET table_name = CONCAT('batch_', p_batch_id, '_students');

    -- Debug: Check the dynamic table existence
    SET @check_table_query = CONCAT('SHOW TABLES LIKE "', table_name, '"');
    PREPARE check_stmt FROM @check_table_query;
    EXECUTE check_stmt;
    DEALLOCATE PREPARE check_stmt;

    -- Step 3: Fetch students not present in the batch_students table but belong to the same faculty
    SET @query = CONCAT(
        'SELECT u.user_name, sd.s_id 
         FROM student_detail sd 
         INNER JOIN student s ON sd.s_id = s.s_id 
         INNER JOIN user u ON s.user_id = u.user_id 
         WHERE sd.s_id NOT IN (SELECT s_id FROM ', table_name, ')
         AND sd.f_id = ', p_f_id
    );

    -- Debug: Log the constructed query
    SELECT @query AS constructed_query;

    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNoOfCurriculums` ()   BEGIN
    SELECT COUNT(*) AS curriculum_count FROM curriculum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNoOfManagers` ()   BEGIN
    SELECT COUNT(*) AS manager_count FROM manager;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetNoOfStudents` ()   BEGIN
    SELECT COUNT(*) AS student_count FROM student;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRemarksForSubject` (IN `p_batch_id` INT, IN `p_sub_id` INT)   BEGIN
    SELECT 
       el.date_time, 
       el.remark, 
       el.status_to, 
       el.status_from, 
       el.s_id, 
       el.user_id,
       u.user_name
    FROM 
        eligibility_log el
    INNER JOIN
    	user u ON el.user_id = u.user_id
    WHERE 
        sub_id = p_sub_id AND exam = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentApplicationDetails` (IN `p_user_id` INT)   BEGIN
    DECLARE batch_id INT;
    DECLARE batch_end_date DATETIME;

    -- Get the latest batch ID
    SELECT 
        CAST(SUBSTRING_INDEX(batch_ids, ',', -1) AS UNSIGNED) INTO batch_id
    FROM 
        student_detail sd
    INNER JOIN 
        student s 
    ON 
        sd.s_id = s.s_id
    WHERE 
        s.user_id = p_user_id;

    IF batch_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch ID is missing for the user';
    END IF;

    -- Check batch end date before proceeding
    SELECT end_date INTO batch_end_date
    FROM batch_time_periods
    WHERE batch_id = batch_id AND user_type = '5'
    ORDER BY end_date DESC
    LIMIT 1;

    IF batch_end_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch end date not found';
    END IF;

    IF NOW() > batch_end_date THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch has already ended';
    END IF;

    -- Get student and faculty details
    SELECT 
        sd.name, 
        sd.index_num, 
        s.s_id, 
        u.user_name, 
        f.f_name 
    FROM 
        faculty f
    INNER JOIN 
        student_detail sd 
    ON 
        f.f_id = sd.f_id
    INNER JOIN 
        student s 
    ON 
        sd.s_id = s.s_id
    INNER JOIN 
        user u 
    ON 
        s.user_id = u.user_id
    WHERE 
        u.user_id = p_user_id;

    -- Get subjects for the batch (including batch ID)
    SELECT 
        c.sub_code, 
        c.sub_name, 
        c.sub_id, 
        bcl.batch_id 
    FROM 
        curriculum c
    INNER JOIN 
        batch_curriculum_lecturer bcl 
    ON 
        c.sub_id = bcl.sub_id
    WHERE 
        bcl.batch_id = batch_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentBatchDetails` (IN `p_batch_ids` TEXT, IN `p_s_id` INT)   BEGIN
    DECLARE batch_id VARCHAR(255);
    DECLARE temp_batch_ids TEXT;
    DECLARE query TEXT;
    DECLARE is_first BOOLEAN DEFAULT TRUE;

    -- Initialize temporary variable with batch_ids
    SET temp_batch_ids = p_batch_ids;

    -- Start constructing the query
    SET query = '';

    -- Loop through the comma-separated batch IDs
    WHILE LOCATE(',', temp_batch_ids) > 0 DO
        SET batch_id = SUBSTRING_INDEX(temp_batch_ids, ',', 1);
        SET temp_batch_ids = SUBSTRING(temp_batch_ids, LOCATE(',', temp_batch_ids) + 1);

        IF NOT is_first THEN
            SET query = CONCAT(query, ' UNION ');
        END IF;

        SET query = CONCAT(
            query,
            'SELECT b.batch_id, b.batch_code, b.academic_year, b.level, b.sem, b.application_open, s.applied_to_exam, d.deg_name, ',
            '(CASE WHEN EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "true" ELSE "false" END) AS admission_ready, ',
            'bt.end_date AS deadline, ',
            'CASE ',
            '  WHEN s.applied_to_exam = "true" AND EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "done" ',
            '  WHEN s.applied_to_exam = "true" AND NOT EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "pending" ',
            '  WHEN NOW() > bt.end_date AND s.applied_to_exam = "false" THEN "expired" ',
            '  ELSE "active" ',
            'END AS status ',
            'FROM batch_', batch_id, '_students s ',
            'JOIN batch b ON b.batch_id = ', batch_id, ' ',
            'JOIN degree d ON b.deg_id = d.deg_id ',
            'LEFT JOIN batch_time_periods bt ON bt.batch_id = ', batch_id, ' AND bt.user_type = "5" ',
            'WHERE s.s_id = ', p_s_id, ' '
        );

        SET is_first = FALSE;
    END WHILE;

    -- Handle the last batch ID
    SET batch_id = temp_batch_ids;

    IF NOT is_first THEN
        SET query = CONCAT(query, ' UNION ');
    END IF;

    SET query = CONCAT(
        query,
        'SELECT b.batch_id, b.batch_code, b.academic_year, b.level, b.sem, b.application_open, s.applied_to_exam, d.deg_name, ',
        '(CASE WHEN EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "true" ELSE "false" END) AS admission_ready, ',
        'bt.end_date AS deadline, ',
        'CASE ',
        '  WHEN s.applied_to_exam = "true" AND EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "done" ',
        '  WHEN s.applied_to_exam = "true" AND NOT EXISTS (SELECT 1 FROM admission WHERE batch_id = ', batch_id, ') THEN "pending" ',
        '  WHEN NOW() > bt.end_date AND s.applied_to_exam = "false" THEN "expired" ',
        '  ELSE "active" ',
        'END AS status ',
        'FROM batch_', batch_id, '_students s ',
        'JOIN batch b ON b.batch_id = ', batch_id, ' ',
        'JOIN degree d ON b.deg_id = d.deg_id ',
        'LEFT JOIN batch_time_periods bt ON bt.batch_id = ', batch_id, ' AND bt.user_type = "5" ',
        'WHERE s.s_id = ', p_s_id, ' '
    );

    -- Execute the constructed query
    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentBatchIds` (IN `p_user_id` INT)   BEGIN
    SELECT 
        sd.batch_ids,
        s.s_id 
    FROM 
        user u
    INNER JOIN 
        student s ON u.user_id = s.user_id
    INNER JOIN 
        student_detail sd ON s.s_id = sd.s_id 
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentById` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.user_id, 
        u.user_name, 
        sd.name, 
        u.email, 
        sd.status,
        sd.s_id,
        sd.f_id,
        sd.index_num,
        sd.contact_no
    FROM 
        user u
    INNER JOIN 
        student s ON u.user_id = s.user_id
    INNER JOIN 
        student_detail sd ON s.s_id = sd.s_id 
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentDetails` (IN `p_user_id` INT)   BEGIN
    SELECT 
        u.email, u.user_name, sd.name, u.role_id
    FROM 
        user u
    INNER JOIN 
        student s ON u.user_id = s.user_id
    INNER JOIN 
        student_detail sd ON s.s_id = sd.s_id
    WHERE 
        u.user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentDetailsWithSubjects` (IN `batchId` INT, IN `userId` INT)   BEGIN
    -- Variable declarations
    DECLARE sub_id INT;
    DECLARE studentId INT DEFAULT NULL;
    DECLARE done INT DEFAULT FALSE;

    -- Cursor declaration
    DECLARE cursor_subjects CURSOR FOR 
        SELECT sub_id 
        FROM batch_curriculum_lecturer 
        WHERE batch_id = batchId;

    -- Handler for when the cursor reaches the end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Fetch studentId for the given userId
    SELECT s_id INTO studentId
    FROM student 
    WHERE user_id = userId;

    -- If studentId is NULL, throw an error
    IF studentId IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Student ID not found for the provided user ID.';
    END IF;

    -- Create a temporary table to store subjects
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_subjects (
        sub_id INT,
        eligibility VARCHAR(50)
    );

    -- Open the cursor to iterate over subjects
    OPEN cursor_subjects;

    subject_loop: LOOP
        FETCH cursor_subjects INTO sub_id;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Check if the dynamic table exists
        SET @table_name = CONCAT('batch_', batchId, '_sub_', sub_id);

        SET @exists_query = CONCAT(
            'SELECT COUNT(*) INTO @table_exists FROM information_schema.tables ',
            'WHERE table_name = "', @table_name, '" AND table_schema = DATABASE()'
        );

        PREPARE exists_stmt FROM @exists_query;
        EXECUTE exists_stmt;
        DEALLOCATE PREPARE exists_stmt;

        -- If the table exists, fetch eligibility for the student
        IF @table_exists > 0 THEN
            SET @insert_query = CONCAT(
                'INSERT INTO temp_subjects (sub_id, eligibility) ',
                'SELECT ', sub_id, ', eligibility FROM ', @table_name, 
                ' WHERE s_id = ', studentId
            );

            PREPARE stmt FROM @insert_query;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;

    CLOSE cursor_subjects;

    -- Retrieve final student details with subjects
    SELECT 
        sd.s_id,
        sd.name,
        sd.index_num,
        u.user_name,
        GROUP_CONCAT(CONCAT('{ "sub_id": "', ts.sub_id, '", "eligibility": "', ts.eligibility, '" }')) AS subjects
    FROM
        student_detail sd
    JOIN
        student st ON sd.s_id = st.s_id
    JOIN
        user u ON st.user_id = u.user_id
    LEFT JOIN
        temp_subjects ts ON ts.sub_id IS NOT NULL
    WHERE
        sd.s_id = studentId
    GROUP BY 
        sd.s_id, sd.name, sd.index_num, u.user_name;

    -- Cleanup temporary tables
    DROP TEMPORARY TABLE IF EXISTS temp_subjects;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentSubjects` (IN `p_batch_id` INT, IN `p_s_id` INT)   BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE sub_id INT;
    DECLARE temp_description TEXT;

    -- Cursor to loop through sub_ids extracted from the description field
    DECLARE sub_cursor CURSOR FOR 
        SELECT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(description, ',', n.n), ',', -1) AS UNSIGNED) AS sub_id
        FROM batch
        JOIN (
            SELECT @row := @row + 1 AS n FROM 
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
             SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL 
             SELECT 8 UNION ALL SELECT 9) t1,
            (SELECT 0 UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL 
             SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL 
             SELECT 8 UNION ALL SELECT 9) t2,
            (SELECT @row := 0) t3
        ) n
        WHERE batch_id = p_batch_id 
        AND n.n <= CHAR_LENGTH(description) - CHAR_LENGTH(REPLACE(description, ',', '')) + 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Temporary table to store valid subjects
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_subjects (sub_id INT);

    -- Open the cursor
    OPEN sub_cursor;

    subject_loop: LOOP
        FETCH sub_cursor INTO sub_id;

        IF done THEN
            LEAVE subject_loop;
        END IF;

        -- Check if the student exists in the specific subject table
        SET @check_query = CONCAT(
            'SELECT COUNT(*) INTO @exists 
             FROM batch_', p_batch_id, '_sub_', sub_id, 
            ' WHERE s_id = ', p_s_id
        );

        PREPARE stmt FROM @check_query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- If the student exists, add the sub_id to the temporary table
        IF @exists > 0 THEN
            INSERT INTO temp_subjects VALUES (sub_id);
        END IF;
    END LOOP;

    CLOSE sub_cursor;

    -- Fetch the results
    SELECT * FROM temp_subjects;

    -- Drop the temporary table
    DROP TEMPORARY TABLE temp_subjects;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetStudentsWithoutIndexNumber` (IN `p_batch_id` INT)   BEGIN
    DECLARE table_name_students VARCHAR(255);

    -- Construct the dynamic table name for the batch students
    SET table_name_students = CONCAT('batch_', p_batch_id, '_students');

    -- Check if the table exists
    SET @check_table_query = CONCAT('SELECT COUNT(*) INTO @exists FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = "', table_name_students, '"');
    PREPARE check_table_stmt FROM @check_table_query;
    EXECUTE check_table_stmt;
    DEALLOCATE PREPARE check_table_stmt;

    IF @exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The batch students table does not exist.';
    END IF;

    -- Fetch the count of students who applied to the exam and don't have an index number
    SET @query_count = CONCAT(
        'SELECT COUNT(*) AS students_without_index 
         FROM ', table_name_students, ' bs
         JOIN student_detail sd ON sd.s_id = bs.s_id 
         WHERE bs.applied_to_exam = "true" AND (sd.index_num IS NULL OR sd.index_num = "")'
    );

    PREPARE stmt_count FROM @query_count;
    EXECUTE stmt_count;
    DEALLOCATE PREPARE stmt_count;

    -- Fetch the user_name of students who don't have an index number
    SET @query_names = CONCAT(
        'SELECT u.user_name 
         FROM ', table_name_students, ' bs
         JOIN student_detail sd ON sd.s_id = bs.s_id 
         JOIN student st ON st.s_id = sd.s_id
         JOIN user u ON u.user_id = st.user_id
         WHERE bs.applied_to_exam = "true" AND (sd.index_num IS NULL OR sd.index_num = "")'
    );

    PREPARE stmt_names FROM @query_names;
    EXECUTE stmt_names;
    DEALLOCATE PREPARE stmt_names;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSubjectsForBatch` (IN `batch_id` INT)   BEGIN
    SELECT bcl.sub_id, c.sub_code, c.sub_name FROM batch_curriculum_lecturer bcl JOIN curriculum c ON bcl.sub_id=c.sub_id  WHERE bcl.batch_id = batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByCredentials` (IN `p_user_name_or_email` VARCHAR(255), OUT `p_user_id` INT, OUT `p_password` VARCHAR(255), OUT `p_role_id` INT)   BEGIN
    SELECT user_id, password, role_id
    INTO p_user_id, p_password, p_role_id
    FROM user
    WHERE user_name = p_user_name_or_email OR email = p_user_name_or_email;

    IF p_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetUserByResetToken` (IN `p_token` TEXT)   BEGIN
    SELECT user_id
    FROM user
    WHERE reset_token = p_token
      AND token_expiration > NOW();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertBatch` (IN `p_batch_code` VARCHAR(100), IN `p_description` VARCHAR(500), IN `p_status` VARCHAR(50), IN `p_deg_id` INT, IN `p_application_open` DATETIME, IN `p_academic_year` VARCHAR(50), IN `p_level` INT(11), IN `p_sem_no` INT(11), OUT `p_batch_id` INT)   BEGIN
    INSERT INTO batch (batch_code, description, status, deg_id, application_open, academic_year, level, sem)
    VALUES (p_batch_code, p_description, p_status, p_deg_id, p_application_open, p_academic_year, p_level, p_sem_no);
    SET p_batch_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertBatchCurriculumLecturer` (IN `p_batch_id` INT, IN `p_subjects` TEXT)   BEGIN
    DECLARE json_length INT;
    DECLARE counter INT DEFAULT 0;
    DECLARE sub_id INT;
    DECLARE m_id INT;

    -- Calculate the number of elements in the JSON array
    SET json_length = JSON_LENGTH(p_subjects);

    -- Loop through each element in the JSON array
    WHILE counter < json_length DO
        -- Extract sub_id and m_id from the JSON array
        SET sub_id = JSON_VALUE(p_subjects, CONCAT('$[', counter, '].sub_id'));
        SET m_id = JSON_VALUE(p_subjects, CONCAT('$[', counter, '].m_id'));

        -- Insert into batch_curriculum_lecturer
        INSERT INTO batch_curriculum_lecturer (batch_id, sub_id, m_id)
        VALUES (p_batch_id, sub_id, m_id);

        -- Increment counter
        SET counter = counter + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertManager` (IN `p_user_id` INT, IN `p_m_id` INT)   BEGIN
    INSERT INTO manager(user_id, m_id) 
    VALUES (p_user_id,p_m_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertManagerDetail` (IN `p_name` VARCHAR(255), IN `p_contact_no` VARCHAR(20), IN `p_status` VARCHAR(255), OUT `p_m_id` INT)   BEGIN
    INSERT INTO manager_detail(name, contact_no, status) 
    VALUES (p_name, p_contact_no, p_status);
    SET p_m_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertStudent` (IN `p_user_id` INT, IN `p_s_id` INT)   BEGIN
    INSERT INTO student(user_id,s_id) 
    VALUES (p_user_id, p_s_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertStudentDetail` (IN `p_name` VARCHAR(255), IN `p_f_id` INT, IN `p_status` VARCHAR(255), IN `p_index_num` VARCHAR(50), IN `p_contact_no` VARCHAR(100), OUT `p_s_id` INT)   BEGIN
    INSERT INTO student_detail(name, f_id, status, index_num, contact_no) 
    VALUES (p_name, p_f_id, p_status,p_index_num,p_contact_no);
    SET p_s_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertUser` (IN `p_user_name` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_role_id` INT, OUT `p_user_id` INT)   BEGIN
    INSERT INTO user(user_name, email, password, role_id) 
    VALUES (p_user_name, p_email, p_password, p_role_id);
    SET p_user_id = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LinkDegreeWithDepartment` (IN `p_d_id` INT, IN `p_deg_id` INT)   BEGIN
    INSERT INTO dep_deg(d_id, deg_id)
    VALUES (p_d_id, p_deg_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LinkFacultyDepartment` (IN `p_f_id` INT, IN `p_d_id` INT)   BEGIN
    INSERT INTO fac_dep(f_id, d_id)
    VALUES (p_f_id, p_d_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LogAdminAction` (IN `p_description` TEXT)   BEGIN
    INSERT INTO admin_log (description, date_time)
    VALUES (p_description, CURRENT_TIMESTAMP());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LogEligibilityChange` (IN `p_user_id` INT, IN `p_s_id` INT, IN `p_exam` INT, IN `p_sub_id` INT, IN `p_status_from` VARCHAR(50), IN `p_status_to` VARCHAR(50), IN `p_remark` TEXT)   BEGIN
    INSERT INTO eligibility_log (user_id, s_id, exam, sub_id, status_from, status_to, remark, date_time)
    VALUES (p_user_id, p_s_id, p_exam, p_sub_id, p_status_from, p_status_to, p_remark, CURRENT_TIMESTAMP());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LogStudentAction` (IN `p_user_id` INT, IN `p_exam` INT)   BEGIN
    INSERT INTO students_log (user_id, exam, date_time)
    VALUES (p_user_id, p_exam, CURRENT_TIMESTAMP());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RemoveStudentsFromBatch` (IN `p_batch_id` INT, IN `p_removed_students` TEXT)   BEGIN
    DECLARE drop_query TEXT;

    -- Update student_detail to remove the batch_id for each student
    SET @update_query = CONCAT(
        'UPDATE student_detail SET batch_ids = CASE ',
        'WHEN TRIM(BOTH \',\' FROM REPLACE(CONCAT(\',\', batch_ids, \',\'), CONCAT(\',\', ', p_batch_id, ', \',\'), \',\')) = \'\' THEN \'\' ',
        'ELSE TRIM(BOTH \',\' FROM REPLACE(CONCAT(\',\', batch_ids, \',\'), CONCAT(\',\', ', p_batch_id, ', \',\'), \',\')) ',
        'END WHERE s_id IN (', p_removed_students, ')'
    );

    PREPARE update_stmt FROM @update_query;
    EXECUTE update_stmt;
    DEALLOCATE PREPARE update_stmt;

    -- Delete students from the batch_{batch_id}_students table
    SET drop_query = CONCAT(
        'DELETE FROM batch_', p_batch_id, '_students WHERE s_id IN (', p_removed_students, ')'
    );

    PREPARE drop_stmt FROM drop_query;
    EXECUTE drop_stmt;
    DEALLOCATE PREPARE drop_stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `StoreResetToken` (IN `p_user_id` INT, IN `p_hashed_token` TEXT, IN `p_expiration` DATETIME)   BEGIN
    UPDATE user
    SET reset_token = p_hashed_token,
        token_expiration = p_expiration
    WHERE user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAdmissionData` (IN `p_batch_id` INT, IN `p_generated_date` VARCHAR(250), IN `p_subject_list` VARCHAR(250), IN `p_exam_date` VARCHAR(250), IN `p_description` TEXT, IN `p_instructions` TEXT, IN `p_provider` TEXT)   BEGIN
    -- Check if the batch_id already exists in the admission table
    IF EXISTS (SELECT 1 FROM admission WHERE batch_id = p_batch_id) THEN
        -- Update existing row
        UPDATE admission
        SET 
            generated_date = p_generated_date,
            subject_list = p_subject_list,
            exam_date = p_exam_date,
            description = p_description,
            instructions = p_instructions,
            provider = p_provider
        WHERE batch_id = p_batch_id;
    ELSE
        -- Insert new row
        INSERT INTO admission (batch_id, generated_date, subject_list, exam_date, description, instructions, provider)
        VALUES (p_batch_id, p_generated_date, p_subject_list, p_exam_date, p_description, p_instructions, p_provider);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateAttendaceData` (IN `p_batch_id` INT, IN `p_exam_date` VARCHAR(250), IN `p_description` TEXT)   BEGIN
    -- Check if the batch_id already exists in the attendance table
    IF EXISTS (SELECT 1 FROM attendance WHERE batch_id = p_batch_id) THEN
        -- Update existing row
        UPDATE attendance
        SET 
            exam_date = p_exam_date,
            description = p_description
        WHERE batch_id = p_batch_id;
    ELSE
        -- Insert new row
        INSERT INTO attendance (batch_id, exam_date, description)
        VALUES (p_batch_id, p_exam_date, p_description);
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBatchDetails` (IN `p_batch_id` INT, IN `p_batch_code` VARCHAR(100), IN `p_description` VARCHAR(500), IN `p_deg_id` INT, IN `p_application_open` DATETIME, IN `p_academic_year` VARCHAR(50), IN `p_level` INT(11), IN `p_sem_no` INT(11))   BEGIN
    UPDATE batch
    SET batch_code = p_batch_code, description = p_description, deg_id = p_deg_id, application_open = p_application_open, academic_year= p_academic_year, level = p_level, sem = p_sem_no
    WHERE batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBatchStatus` (IN `p_batch_id` INT, IN `p_status` VARCHAR(50))   BEGIN
    UPDATE batch
    SET status = p_status
    WHERE batch_id = p_batch_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCurriculum` (IN `p_sub_id` INT, IN `p_sub_code` VARCHAR(100), IN `p_sub_name` VARCHAR(150), IN `p_sem_no` INT, IN `p_deg_id` INT, IN `p_level` INT)   BEGIN
    UPDATE curriculum
    SET 
        sub_code = p_sub_code,
        sub_name = p_sub_name,
        sem_no = p_sem_no,
        deg_id = p_deg_id,
        level = p_level
    WHERE sub_id = p_sub_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateCurriculumStatus` (IN `p_sub_id` INT, IN `p_status` VARCHAR(50))   BEGIN
    UPDATE curriculum
    SET 
        status = p_status
    WHERE sub_id = p_sub_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDegreeDetails` (IN `p_deg_id` INT, IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_levels` VARCHAR(255), IN `p_no_of_sem_per_year` VARCHAR(10))   BEGIN
    UPDATE degree
    SET deg_name = p_deg_name,
        short = p_short,
        levels = p_levels,
        no_of_sem_per_year = p_no_of_sem_per_year
    WHERE deg_id = p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDegreeStatus` (IN `p_deg_id` INT, IN `p_status` VARCHAR(50))   BEGIN
    UPDATE degree
    SET 
        status = p_status
    WHERE deg_id = p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDepartmentDetails` (IN `p_d_id` INT, IN `p_d_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50))   BEGIN
    UPDATE department
    SET d_name = p_d_name,
        contact_no = p_contact_no
    WHERE d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDepartmentStatus` (IN `p_d_id` INT, IN `p_status` VARCHAR(50))   BEGIN
    UPDATE department
    SET 
        status = p_status
    WHERE d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDepartmentUser` (IN `p_user_id` INT, IN `p_email` VARCHAR(255))   BEGIN
    UPDATE user
    SET user_name = p_email,
        email = p_email
    WHERE user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateDepDeg` (IN `p_d_id` INT, IN `p_deg_id` INT)   BEGIN
    UPDATE dep_deg
    SET d_id = p_d_id
    WHERE deg_id = p_deg_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateEligibility` (IN `p_user_id` INT, IN `p_s_id` INT, IN `p_sub_id` INT, IN `p_batch_id` INT, IN `p_eligibility` VARCHAR(50), IN `p_role_id` VARCHAR(50))   BEGIN
    DECLARE p_m_id INT;
    DECLARE batch_status VARCHAR(50);

    -- Step 1: Check batch status
    SELECT status INTO batch_status
    FROM batch
    WHERE batch_id = p_batch_id;

    IF batch_status != 'true' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Batch is not active.';
    END IF;

    -- Step 2: Verify user access
    IF p_role_id != '1' THEN
        IF p_role_id = '4' THEN
            SELECT m_id INTO p_m_id
            FROM manager
            WHERE user_id = p_user_id;

            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;

            SELECT COUNT(*)
            INTO @access_count
            FROM batch_curriculum_lecturer
            WHERE m_id = p_m_id AND sub_id = p_sub_id AND batch_id = p_batch_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF; 
            
            SELECT COUNT(*)
            INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '4' AND end_date > NOW();

            IF @deadline_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cross the dealine of this batch.';
            END IF; 
        ELSEIF  p_role_id = '3' THEN
        	SELECT d_id INTO p_m_id
            FROM department
            WHERE user_id = p_user_id;

            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;
            
        	SELECT COUNT(d.d_id) INTO @access_count FROM batch b 
            INNER JOIN degree deg ON b.deg_id=deg.deg_id
            INNER JOIN dep_deg dd ON deg.deg_id=dd.deg_id
			INNER JOIN department d ON dd.d_id=d.d_id
            WHERE d.user_id=p_user_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF;
            
            SELECT COUNT(*)
            INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '3' AND end_date > NOW() AND (SELECT COUNT(*) FROM batch_time_periods WHERE batch_id = p_batch_id AND user_type = '4' AND end_date < NOW()) > 0;

            IF @deadline_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cross the dealine of this batch.';
            END IF;
        ELSEIF  p_role_id = '2' THEN
        	SELECT f_id INTO p_m_id
            FROM faculty
            WHERE user_id = p_user_id;

            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;
            
        	SELECT COUNT(f.f_id) INTO @access_count FROM batch b 
            INNER JOIN degree deg ON b.deg_id=deg.deg_id
            INNER JOIN dep_deg dd ON deg.deg_id=dd.deg_id
            INNER JOIN fac_dep fd ON dd.d_id=fd.d_id
			INNER JOIN faculty f ON fd.f_id=f.f_id
            WHERE f.user_id=p_user_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF;
            
            SELECT COUNT(*)
            INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '2' AND end_date > NOW() AND (SELECT COUNT(*) FROM batch_time_periods WHERE batch_id = p_batch_id AND user_type = '3' AND end_date < NOW()) > 0;

            IF @deadline_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cross the dealine of this batch.';
            END IF;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
        END IF;
    END IF;

    -- Step 3: Update eligibility
    SET @query = CONCAT(
        'UPDATE batch_', p_batch_id, '_sub_', p_sub_id, 
        ' SET eligibility = ? WHERE s_id = ?'
    );

    PREPARE stmt FROM @query;
    EXECUTE stmt USING p_eligibility, p_s_id;
    DEALLOCATE PREPARE stmt;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateFacultyDepartmentLink` (IN `p_f_id` INT, IN `p_d_id` INT)   BEGIN
    UPDATE fac_dep
    SET f_id = p_f_id
    WHERE d_id = p_d_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateFacultyDetails` (IN `p_f_id` INT, IN `p_f_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50))   BEGIN
    UPDATE faculty
    SET f_name = p_f_name,
        contact_no = p_contact_no
    WHERE f_id = p_f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateFacultyStatus` (IN `p_f_id` INT, IN `p_status` VARCHAR(50))   BEGIN
    UPDATE faculty
    SET 
        status = p_status
    WHERE f_id = p_f_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateManager` (IN `p_name` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_user_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50), IN `p_m_id` INT)   BEGIN
    -- Check if email or user_name already exists for another user
    IF EXISTS (
        SELECT 1 FROM user u
        INNER JOIN manager m ON u.user_id = m.user_id
        WHERE (u.email = p_email OR u.user_name = p_user_name) AND m.m_id != p_m_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email or username already exists';
    END IF;

    -- Update manager detail
    UPDATE manager_detail 
    SET 
        name = p_name, 
        contact_no = p_contact_no
    WHERE m_id = p_m_id;

    -- Update user email and username
    UPDATE user u 
    INNER JOIN manager m ON u.user_id = m.user_id 
    SET 
        u.email = p_email,
        u.user_name = p_user_name
    WHERE m.m_id = p_m_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateManagerStatus` (IN `p_status` VARCHAR(50), IN `p_m_id` INT)   BEGIN
    -- Update manager detail
    UPDATE manager_detail 
    SET 
        status = p_status 
    WHERE m_id = p_m_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStudent` (IN `p_name` VARCHAR(255), IN `p_f_id` INT, IN `p_s_id` INT, IN `p_email` VARCHAR(255), IN `p_user_name` VARCHAR(255), IN `p_contact_no` VARCHAR(100), IN `p_index_num` VARCHAR(50))   BEGIN
    DECLARE exit handler FOR SQLEXCEPTION
    BEGIN
        -- Rollback the transaction if any error occurs
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'An unexpected error occurred';
    END;

    -- Start a transaction
    START TRANSACTION;

    -- Check if email or user_name already exists for another user
    IF EXISTS (
        SELECT 1 
        FROM user u
        INNER JOIN student s ON u.user_id = s.user_id
        WHERE (u.email = p_email OR u.user_name = p_user_name) AND s.s_id != p_s_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email or username already exists';
    END IF;
    
    -- Check if index number already exists for another user
    IF EXISTS (
        SELECT 1 
        FROM student s
        INNER JOIN student_detail sd ON s.s_id = sd.s_id
        WHERE sd.index_num = p_index_num 
          AND sd.index_num IS NOT NULL 
          AND sd.index_num != '' 
          AND s.s_id != p_s_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Index number already exists';
    END IF;

    -- Update student detail
    UPDATE student_detail 
    SET 
        name = p_name, 
        f_id = p_f_id,
        contact_no = p_contact_no,
        index_num = p_index_num
    WHERE s_id = p_s_id;

    -- Update user email and username
    UPDATE user u 
    INNER JOIN student s ON u.user_id = s.user_id 
    SET 
        u.email = p_email,
        u.user_name = p_user_name
    WHERE s.s_id = p_s_id;

    -- Commit the transaction
    COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStudentStatus` (IN `p_status` VARCHAR(50), IN `p_s_id` INT)   BEGIN
    -- Update student detail
    UPDATE student_detail 
    SET 
        status = p_status 
    WHERE s_id = p_s_id;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserDetails` (IN `p_user_id` INT, IN `p_email` VARCHAR(255))   BEGIN
    UPDATE user
    SET user_name = p_email,
        email = p_email
    WHERE user_id = p_user_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateUserPassword` (IN `p_user_id` INT, IN `p_hashed_password` TEXT)   BEGIN
    UPDATE user
    SET password = p_hashed_password,
        reset_token = NULL,
        token_expiration = NULL
    WHERE user_id = p_user_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin_log`
--

CREATE TABLE `admin_log` (
  `id` int(11) NOT NULL,
  `description` text NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_log`
--

INSERT INTO `admin_log` (`id`, `description`, `date_time`) VALUES
(1, 'Student created with user_id=141, s_id=101, name=Kamaal BBD, f_id=8, index_num=, contact_no=3243534545', '2025-01-16 20:07:53'),
(2, 'Student created with user_id=142, s_id=102, name=romee, f_id=8, index_num=IT 17002, contact_no=325354646', '2025-01-16 20:11:12'),
(3, 'Manager created with user_id=143, m_id=7, name=Waseem, contact_no=67876845634', '2025-01-16 20:15:06'),
(4, 'Manager status changed for m_id=3 to status=false', '2025-01-16 21:40:01'),
(5, 'Drop all the entries of batch_id=17', '2025-01-17 06:46:13'),
(6, 'Batch status changed for batch_id=17 to status=false', '2025-01-17 06:46:13'),
(7, 'Drop all the entries of batch_id=17', '2025-01-17 06:54:30'),
(8, 'Batch status changed for batch_id=17 to status=false', '2025-01-17 06:54:30'),
(9, 'Batch updated with batch_id=17, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-01-17 08:38:57'),
(10, 'Batch status changed for batch_id=17 to status=true', '2025-01-17 20:30:28'),
(11, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-01-19T12:11', '2025-01-17 21:10:53'),
(12, 'Medical or Resit Student for batch_id=17, sub_id=16, s_id=13, type=M', '2025-01-18 03:55:08'),
(13, 'Medical or Resit Student for batch_id=17, sub_id=17, s_id=26, type=M', '2025-01-18 03:55:08'),
(14, 'Medical or Resit Student for batch_id=17, sub_id=18, s_id=18, type=R', '2025-01-18 03:55:08'),
(15, 'Medical or Resit Student for batch_id=17, sub_id=19, s_id=18, type=R', '2025-01-18 03:55:08'),
(16, 'Medical or Resit Student for batch_id=17, sub_id=20, s_id=18, type=R', '2025-01-18 03:55:08'),
(17, 'Medical or Resit Student for batch_id=17, sub_id=21, s_id=13, type=M', '2025-01-18 03:55:08'),
(18, 'Batch status changed for batch_id=17 to status=false', '2025-01-18 15:53:30'),
(19, 'Batch status changed for batch_id=17 to status=true', '2025-01-18 15:53:32'),
(20, 'Batch status changed for batch_id=17 to status=false', '2025-01-18 16:31:59'),
(21, 'Degree status changed for deg_id=9 to status=false', '2025-01-18 16:32:38'),
(22, 'Degree status changed for deg_id=9 to status=true', '2025-01-18 16:32:40'),
(23, 'Degree updated for deg_id=9 with deg_name=Applied Mathematics and Computing, short=ASP, levels=1:2:3, no_of_sem_per_year=2', '2025-01-18 16:32:50'),
(24, 'Manager status changed for m_id=1 to status=false', '2025-02-25 08:34:49'),
(25, 'Manager status changed for m_id=1 to status=true', '2025-02-25 09:21:56'),
(26, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-01-20T12:11', '2025-02-25 14:10:46'),
(27, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-02-26T12:11', '2025-02-25 14:12:02'),
(28, 'Batch status changed for batch_id=17 to status=true', '2025-02-25 15:16:47'),
(29, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-02-26T13:06', '2025-02-26 07:32:10'),
(30, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-02-27T13:06', '2025-02-26 08:16:55'),
(31, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-02-26T14:50', '2025-02-26 09:18:30'),
(32, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-01-19T12:10, lecturers_end=2025-02-27T14:50', '2025-02-27 06:05:25'),
(33, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:10, lecturers_end=2025-02-28T14:50', '2025-02-27 07:32:09'),
(34, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T14:50', '2025-02-27 08:01:02'),
(35, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T14:50, hod_end=2025-03-05T17:30, dean_end=2025-03-21T17:30', '2025-02-28 12:00:16'),
(36, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-03-21T17:30, hod_end=2025-02-27T17:33, dean_end=2025-03-08T17:33', '2025-02-28 12:03:35'),
(37, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-03-08T17:33, hod_end=2025-02-28T17:36, dean_end=2025-03-08T17:36', '2025-02-28 12:06:23'),
(38, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-03-08T17:33, hod_end=2025-02-21T17:36, dean_end=2025-03-15T17:36', '2025-02-28 12:15:33'),
(39, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-03-08T17:33, hod_end=2025-03-05T17:36, dean_end=2025-03-10T17:36', '2025-02-28 12:16:03'),
(40, 'Batch created with batch_id=18, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,1,2,2,1,2,1,2,1,2', '2025-03-02 06:54:00'),
(41, 'Batch updated with batch_id=18, sub_ids=13,14,15, m_ids=1,2,4', '2025-03-02 06:54:57'),
(42, 'Batch updated with batch_id=18, sub_ids=13,14,15, m_ids=1,2,4', '2025-03-02 06:59:11'),
(43, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-03T13:35, lecturers_end=2025-03-08T17:33, hod_end=2025-03-05T17:36, dean_end=2025-03-10T17:36', '2025-03-02 08:38:40'),
(44, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-01T17:36, dean_end=2025-03-03T17:36', '2025-03-02 17:41:07'),
(45, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-01T17:36, dean_end=2025-03-02T17:36', '2025-03-02 18:02:48'),
(46, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-01T17:36, dean_end=2025-03-05T17:36', '2025-03-03 06:39:31'),
(47, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-03T17:36, dean_end=2025-03-05T17:36', '2025-03-03 06:42:24'),
(48, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 08:50:38'),
(49, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:16:22'),
(50, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:28:06'),
(51, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:34:05'),
(52, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:38:24'),
(53, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:41:16'),
(54, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:45:38'),
(55, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:56:01'),
(56, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:57:38'),
(57, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 09:58:51'),
(58, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 10:00:17'),
(59, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 10:12:14'),
(60, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 10:13:33'),
(61, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 14:15:41'),
(62, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 14:20:36'),
(63, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 17:14:25'),
(64, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 17:37:43'),
(65, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 17:46:40'),
(66, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:04:38'),
(67, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:07:28'),
(68, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:08:38'),
(69, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:11:00'),
(70, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:16:27'),
(71, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:19:55'),
(72, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:21:54'),
(73, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:25:02'),
(74, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:30:31'),
(75, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:33:27');
INSERT INTO `admin_log` (`id`, `description`, `date_time`) VALUES
(76, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:37:18'),
(77, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:43:50'),
(78, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h1><strong><u>Instructions</u></strong></h1><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:44:41'),
(79, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h1><strong><u>Instructions</u></strong></h1><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:46:40'),
(80, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h1><strong><u>Instructions</u></strong></h1><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:47:53'),
(81, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h1><strong><u>Instructions</u></strong></h1><h2>No candidate shall be admitted to the Examination hall without this card.</h2><h3>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</h3><ol><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:49:14'),
(82, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 18:53:02'),
(83, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 19:11:52'),
(84, 'Admission created or updated for batch_id=17, generated_date=03.03.2025, transformedSubjects=17:16,18:19,20:21,22,23,24:25, transformedDate=2025:2;3, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner in every examination. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Candidates are requested to hand over the admission card to the Supervisor of the last day of the <span style=\"color: rgb(9, 9, 11);\">examination</span>.</p>, instructions=<h3><strong><u>Instructions</u></strong></h3><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-03 19:15:22'),
(85, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T17:36, dean_end=2025-03-05T17:36', '2025-03-03 19:54:02'),
(86, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-05T17:36', '2025-03-04 07:26:58'),
(87, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-04T17:36', '2025-03-04 14:16:21'),
(88, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-06T17:36', '2025-03-05 09:59:13'),
(89, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-05 10:10:18'),
(90, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-04T17:36', '2025-03-05 12:05:12'),
(91, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-06T17:36', '2025-03-05 12:14:01'),
(92, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-04T17:36', '2025-03-05 13:18:43'),
(93, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-06T17:36', '2025-03-05 13:25:21'),
(94, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-04T17:36', '2025-03-05 13:26:51'),
(95, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-06T17:36', '2025-03-05 20:31:06'),
(96, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-04T12:36, dean_end=2025-03-07T17:36', '2025-03-05 20:38:06'),
(97, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-02-27T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:36', '2025-03-05 20:38:13'),
(98, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:36', '2025-03-06 07:23:47'),
(99, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-07 13:33:51'),
(100, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-07 13:35:06'),
(101, 'Student created with user_id=144, s_id=103, name=ffhh, f_id=9, index_num=, contact_no=11111111', '2025-03-07 13:42:37'),
(102, 'Student created with user_id=145, s_id=104, name=dfdf, f_id=8, index_num=, contact_no=erer', '2025-03-07 14:06:38'),
(103, 'Student created with user_id=146, s_id=146, name=rtyrtyty, f_id=8, index_num=, contact_no=sds', '2025-03-12 15:44:24'),
(104, 'Student created with user_id=150, s_id=104, name=222222, f_id=8, index_num=222222, contact_no=222222', '2025-03-12 15:58:58'),
(105, 'Student created with user_id=151, s_id=105, name=3, f_id=10, index_num=3, contact_no=3', '2025-03-12 16:33:45'),
(106, 'Student created with user_id=152, s_id=106, name=4, f_id=10, index_num=, contact_no=4', '2025-03-12 16:33:48'),
(107, 'Student status changed for s_id=105 to status=false', '2025-03-12 16:46:50'),
(108, 'Student status changed for s_id=105 to status=true', '2025-03-12 16:47:05'),
(109, 'Manager created with user_id=153, m_id=153, name=55, contact_no=55', '2025-03-12 16:56:54'),
(110, 'Manager created with user_id=154, m_id=8, name=55, contact_no=55', '2025-03-12 17:00:25'),
(111, 'Manager status changed for m_id=8 to status=false', '2025-03-12 17:00:34'),
(112, 'Manager status changed for m_id=8 to status=true', '2025-03-12 17:00:35'),
(113, 'Faculty created with f_name=sfsdf, user_id=155, email=sdfdf, contact_no=dfdfdf', '2025-03-14 11:48:30'),
(114, 'Faculty created with f_name=ssskk, user_id=156, email=1@1.1hgh, contact_no=fegrgh', '2025-03-14 15:42:06'),
(117, 'Faculty created with f_name=sgfg, user_id=159, email=dfhgfh, contact_no=d234', '2025-03-14 16:05:52'),
(119, 'Faculty created with f_name=tutyu, user_id=161, email=d@nm.b, contact_no=huuiyu89', '2025-03-14 16:09:15'),
(120, 'Faculty created with f_name=gjuhjk, user_id=162, email=dfdf@v.m, contact_no=tyty', '2025-03-14 16:11:41'),
(121, 'Student created with user_id=163, s_id=107, name=ry3, f_id=8, index_num=cfg3, contact_no=3', '2025-03-14 16:30:17'),
(122, 'Student created with user_id=164, s_id=108, name=ry4, f_id=8, index_num=, contact_no=4', '2025-03-14 16:30:21'),
(123, 'Student created with user_id=165, s_id=109, name=dfgfgh, f_id=9, index_num=, contact_no=dfgdfg', '2025-03-14 16:32:12'),
(125, 'Batch students updated for batch_id=18, droped=, inserted=76', '2025-03-14 18:19:08'),
(126, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 11:34:34'),
(127, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 11:35:45'),
(128, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 11:43:23'),
(129, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 11:54:25'),
(130, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 11:57:40'),
(131, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 12:05:12'),
(132, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 12:06:09'),
(133, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 12:07:22'),
(134, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 12:08:46'),
(135, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 12:09:30'),
(136, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 13:01:13'),
(137, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 13:11:18'),
(138, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 13:17:29'),
(139, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 13:19:17'),
(140, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 13:58:00'),
(141, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:10:23'),
(142, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:13:07');
INSERT INTO `admin_log` (`id`, `description`, `date_time`) VALUES
(143, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:15:57'),
(144, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:29:43'),
(145, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:43:36'),
(146, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 14:58:52'),
(147, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:01:46'),
(148, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:11:30'),
(149, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:16:16'),
(150, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:18:01'),
(151, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2;3,2026:0, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:18:42'),
(152, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2;3,2026:0, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:19:53'),
(153, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2;3,2026:0, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:23:56'),
(154, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:26:52'),
(155, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:32:45'),
(156, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:34:34'),
(157, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:35:31'),
(158, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:36:18'),
(159, 'Admission created or updated for batch_id=17, generated_date=05.03.2025, transformedSubjects=16:24,20,21,19,18,22,17,25,23, transformedDate=2025:2;3,2026:0, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-15 15:39:55'),
(160, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:47:19'),
(161, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:50:20'),
(162, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 15:51:30'),
(163, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:05:01'),
(164, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:06:21'),
(165, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:06:58'),
(166, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:09:28'),
(167, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:11:00'),
(168, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:30:56'),
(169, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:34:57'),
(170, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:36:32'),
(171, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:37:56'),
(172, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:46:30'),
(173, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:48:16'),
(174, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:52:55'),
(175, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:53:52'),
(176, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:54:23'),
(177, 'Attendance created or updated for batch_id=17, transformedDate=2025:2, description=<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>', '2025-03-15 16:55:22'),
(178, 'Batch updated with batch_id=17, application_open=2025-03-04T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:23:10'),
(179, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:23:11'),
(180, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:41:26'),
(181, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:42:14'),
(182, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:43:50'),
(183, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:44:58'),
(184, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:45:26'),
(185, 'Batch updated with batch_id=17, application_open=2025-03-19T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:49:32'),
(186, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:49:32'),
(187, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:49:59'),
(188, 'Batch updated with batch_id=17, application_open=2025-03-20T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:49:59'),
(189, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:51:58'),
(190, 'Batch updated with batch_id=17, application_open=2025-03-20T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:51:58'),
(191, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:52:20'),
(192, 'Batch updated with batch_id=17, application_open=2025-03-21T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:52:20'),
(193, 'Batch updated with batch_id=17, application_open=2025-03-20T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 09:58:55'),
(194, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 09:58:55'),
(195, 'Batch updated with batch_id=17, application_open=2025-03-21T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 10:00:43'),
(196, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:00:43'),
(197, 'Batch updated with batch_id=17, application_open=2025-03-29T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 10:02:29'),
(198, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:02:29'),
(199, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:04:39'),
(200, 'Batch updated with batch_id=17, application_open=2025-03-28T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 10:04:39'),
(201, 'Batch updated with batch_id=17, application_open=2025-03-15T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 10:41:54'),
(202, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-08T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:47:42'),
(203, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:48:33'),
(204, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-08T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:50:50'),
(205, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:53:40'),
(206, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-08T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 10:55:28'),
(207, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 11:07:55'),
(208, 'Batch updated with batch_id=17, application_open=2025-03-15T14:52, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 11:16:26'),
(209, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 11:16:26'),
(210, 'Batch students updated for batch_id=17, droped=, inserted=11,12', '2025-03-16 13:35:27'),
(211, 'Batch students updated for batch_id=17, droped=11,12, inserted=', '2025-03-16 13:40:29'),
(212, 'Batch updated with batch_id=17, application_open=2025-03-17T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 13:40:59'),
(213, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 13:40:59'),
(214, 'Batch updated with batch_id=17, application_open=2025-03-17T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 13:41:08'),
(215, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-06T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 13:41:08'),
(216, 'Batch updated with batch_id=17, application_open=2025-03-15T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 13:41:24'),
(217, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-06T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 13:41:24'),
(218, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-06T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 13:51:41'),
(219, 'Batch updated with batch_id=17, application_open=2025-03-19T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 13:51:41'),
(220, 'Batch updated with batch_id=17, application_open=2025-03-22T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 16:28:57'),
(221, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 16:28:57'),
(222, 'Batch updated with batch_id=17, application_open=2025-03-23T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,1,2,1,4,5', '2025-03-16 16:29:07'),
(223, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 16:29:07'),
(224, 'Batch updated with batch_id=17, application_open=2025-03-23T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-16 16:29:16'),
(225, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-07T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 16:29:16'),
(226, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-06T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 16:30:45'),
(227, 'Batch students updated for batch_id=17, droped=, inserted=11,12', '2025-03-16 16:31:22'),
(228, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-18T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 16:33:26'),
(229, 'Batch updated with batch_id=17, application_open=2025-03-18T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-16 16:33:26'),
(230, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-02-28T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 17:55:04'),
(231, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-17T17:33, hod_end=2025-03-06T12:36, dean_end=2025-03-07T17:06', '2025-03-16 18:11:38'),
(232, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-18T12:36, dean_end=2025-03-07T17:06', '2025-03-16 19:30:55'),
(233, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-19T12:36, dean_end=2025-03-18T17:06', '2025-03-16 19:45:39'),
(234, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-17T12:36, dean_end=2025-03-18T17:06', '2025-03-16 19:45:57'),
(235, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-17T12:36, dean_end=2025-03-19T17:06', '2025-03-16 19:46:42'),
(236, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-16T12:36, dean_end=2025-03-19T17:06', '2025-03-16 19:47:50'),
(237, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-16T12:36, dean_end=2025-03-16T17:06', '2025-03-16 19:50:34'),
(238, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 19:53:12'),
(239, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:35:32'),
(240, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:38:37'),
(241, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:40:09'),
(242, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:45:13'),
(243, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:52:23');
INSERT INTO `admin_log` (`id`, `description`, `date_time`) VALUES
(244, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 20:57:23'),
(245, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:01:01'),
(246, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:05:47'),
(247, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:06:37'),
(248, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:14:05'),
(249, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:15:06'),
(250, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:17:10'),
(251, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:18:45'),
(252, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:19:20'),
(253, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:19:29'),
(254, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-16 21:20:18'),
(255, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:31:50'),
(256, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:35:15'),
(257, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:44:40'),
(258, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:48:01'),
(259, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:50:41'),
(260, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:52:22'),
(261, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:55:03'),
(262, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:58:35'),
(263, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 06:59:26'),
(264, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 07:01:01'),
(265, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 07:48:29'),
(266, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 07:49:21'),
(267, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 11:05:52'),
(268, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 12:06:02'),
(269, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 12:39:57'),
(270, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 13:02:37'),
(271, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-17 13:04:46'),
(272, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-21T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-17 14:51:01'),
(273, 'Batch updated with batch_id=17, application_open=2025-03-19T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-17 14:51:01'),
(274, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-17 15:56:47'),
(275, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-16T17:33, hod_end=2025-03-16T12:36, dean_end=2025-03-27T17:06', '2025-03-17 16:10:35'),
(276, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-15T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-17 16:31:40'),
(277, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-18T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-17 17:02:40'),
(278, 'Batch updated with batch_id=17, application_open=2025-03-18T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-17 17:04:57'),
(279, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-19T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-17 17:04:57'),
(280, 'Batch updated with batch_id=17, application_open=2025-03-19T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-18 12:46:40'),
(281, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-17T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-18 12:46:40'),
(282, 'Batch updated with batch_id=17, application_open=2025-03-19T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-18 19:26:55'),
(283, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-27T17:06', '2025-03-18 19:26:55'),
(284, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-23T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-18T17:06', '2025-03-18 19:31:14'),
(285, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-25T12:36, dean_end=2025-03-18T17:06', '2025-03-18 20:04:39'),
(286, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-18T12:36, dean_end=2025-03-18T17:06', '2025-03-18 20:11:55'),
(287, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-19T12:36, dean_end=2025-03-20T17:06', '2025-03-18 20:13:11'),
(288, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-19T12:36, dean_end=2025-03-21T17:06', '2025-03-18 20:14:00'),
(289, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-20T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-18T12:36, dean_end=2025-03-21T17:06', '2025-03-18 20:14:49'),
(290, 'Batch updated with batch_id=17, application_open=2025-03-23T19:10, sub_ids=16,17,18,19,20,21,22,23,24,25, m_ids=1,2,1,4,5,8,2,1,4,5', '2025-03-21 12:46:16'),
(291, 'Batch time period inserted or updated for batch_id=17 to students_end=2025-03-23T13:35, lecturers_end=2025-03-18T17:33, hod_end=2025-03-18T12:36, dean_end=2025-03-21T17:06', '2025-03-21 12:46:16'),
(292, 'Batch created with batch_id=19, application_open=2025-03-23T11:44, sub_ids=13,14,15, m_ids=2,2,4', '2025-03-22 06:14:26'),
(293, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-22 06:37:42'),
(294, 'Admission created or updated for batch_id=17, generated_date=17.03.2025, transformedSubjects=16:17,18,19:20,21:22,23,24,25, transformedDate=2025:2, description=<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>, instructions=<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>, provider=<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>', '2025-03-22 06:39:22'),
(295, 'Batch created with batch_id=20, application_open=2025-03-27T18:17, sub_ids=13,14,15, m_ids=2,5,5', '2025-03-24 12:47:48');
INSERT INTO `admin_log` (`id`, `description`, `date_time`) VALUES
(296, 'Batch created with batch_id=21, application_open=2025-03-25T19:32, sub_ids=13,14,15, m_ids=4,1,7', '2025-03-24 14:02:59'),
(297, 'Batch created with batch_id=22, application_open=2025-03-26T21:49, students_end=2025-03-27T21:49, lecturers_end=2025-03-28T21:49, hod_end=2025-03-29T21:49, dean_end=2025-03-30T21:49, sub_ids=13,14,15, m_ids=2,1,5', '2025-03-24 16:19:50'),
(298, 'Batch updated with batch_id=22, application_open=2025-03-26T21:49, students_end=2025-03-27T21:49, lecturers_end=2025-03-28T21:49, hod_end=2025-03-29T21:49, dean_end=2025-03-30T21:49, sub_ids=13,14,15, m_ids=2,1,5', '2025-03-24 16:20:27'),
(299, 'Batch updated with batch_id=22, application_open=2025-03-27T21:49, students_end=2025-03-27T21:49, lecturers_end=2025-03-28T21:49, hod_end=2025-03-29T21:49, dean_end=2025-03-30T21:49, sub_ids=13,14,15, m_ids=2,1,5', '2025-03-24 16:20:41'),
(300, 'Batch updated with batch_id=22, application_open=2025-03-27T21:49, students_end=2025-03-27T21:49, lecturers_end=2025-03-28T21:49, hod_end=2025-03-30T21:49, dean_end=2025-03-30T21:49, sub_ids=13,14,15, m_ids=2,1,5', '2025-03-24 16:20:55'),
(301, 'Batch created with batch_id=23, application_open=2025-03-26T23:07, students_end=2025-03-27T23:08, lecturers_end=2025-03-28T23:08, hod_end=2025-03-29T23:08, dean_end=2025-03-30T23:08, sub_ids=13,14,15, m_ids=2,4,5', '2025-03-25 17:38:37'),
(302, 'Batch updated with batch_id=23, application_open=2025-03-26T23:07, students_end=2025-03-27T23:08, lecturers_end=2025-03-28T23:08, hod_end=2025-03-29T23:08, dean_end=2025-03-30T23:08, sub_ids=13,14,15, m_ids=2,4,5', '2025-03-25 17:40:29'),
(303, 'Batch created with batch_id=24, application_open=2025-03-28T23:14, students_end=2025-03-29T23:14, lecturers_end=2025-03-29T23:14, hod_end=2025-03-29T23:14, dean_end=2025-03-29T23:14, sub_ids=13,14,15, m_ids=1,2,4', '2025-03-25 17:45:00'),
(304, 'Batch students updated for batch_id=24, droped=, inserted=76,77', '2025-03-26 09:03:01'),
(305, 'Batch students updated for batch_id=24, droped=, inserted=78', '2025-03-26 09:04:52'),
(306, 'Batch students updated for batch_id=24, droped=, inserted=79', '2025-03-26 09:14:25'),
(307, 'Batch time period inserted or updated for batch_id=24 to students_end=2025-03-29T23:14, lecturers_end=2025-03-29T23:14, hod_end=2025-03-29T23:14, dean_end=2025-03-25T23:14', '2025-03-26 09:37:53'),
(308, 'Medical or Resit Student for batch_id=24, sub_id=13, s_id=80, type=M', '2025-03-26 19:41:58'),
(309, 'Medical or Resit Student for batch_id=24, sub_id=15, s_id=80, type=M', '2025-03-26 19:42:48'),
(310, 'Medical or Resit Student for batch_id=24, sub_id=14, s_id=80, type=M', '2025-03-26 19:55:17'),
(311, 'Medical or Resit Student for batch_id=24, sub_id=14, s_id=80, type=R', '2025-03-26 19:56:43'),
(312, 'Medical or Resit Student for batch_id=24, sub_id=13, s_id=80, type=M', '2025-03-26 20:00:42'),
(313, 'Medical or Resit Student for batch_id=24, sub_id=14, s_id=80, type=R', '2025-03-26 20:00:42'),
(314, 'Medical or Resit Student for batch_id=24, sub_id=15, s_id=80, type=M', '2025-03-26 20:00:42');

-- --------------------------------------------------------

--
-- Table structure for table `admission`
--

CREATE TABLE `admission` (
  `id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `generated_date` varchar(250) NOT NULL,
  `subject_list` varchar(250) NOT NULL,
  `exam_date` varchar(250) NOT NULL,
  `description` text NOT NULL,
  `instructions` text NOT NULL,
  `provider` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admission`
--

INSERT INTO `admission` (`id`, `batch_id`, `generated_date`, `subject_list`, `exam_date`, `description`, `instructions`, `provider`) VALUES
(4, 17, '17.03.2025', '16:17,18,19:20,21:22,23,24,25', '2025:2', '<p>Candidates are expected to produce this admission card to the Supervisor/Invigilator/Examiner at the Examination Hall. This form&nbsp;&nbsp;&nbsp;should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The&nbsp;Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>', '<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>', '<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>');

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `exam_date` varchar(250) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`id`, `batch_id`, `exam_date`, `description`) VALUES
(2, 17, '2025:2', '<p>Supervisors are kindly requested to mark absentees clearly \"ABSENT\" and \"✔\" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>');

-- --------------------------------------------------------

--
-- Table structure for table `batch`
--

CREATE TABLE `batch` (
  `batch_id` int(11) NOT NULL,
  `batch_code` varchar(100) NOT NULL,
  `deg_id` int(11) NOT NULL,
  `academic_year` varchar(50) NOT NULL,
  `level` int(11) NOT NULL,
  `sem` int(11) NOT NULL,
  `application_open` datetime NOT NULL DEFAULT current_timestamp(),
  `description` varchar(500) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch`
--

INSERT INTO `batch` (`batch_id`, `batch_code`, `deg_id`, `academic_year`, `level`, `sem`, `application_open`, `description`, `status`) VALUES
(17, '2023IT31', 14, '2023', 3, 1, '2025-03-20 19:10:00', '16,17,18,19,20,21,22,23,24,25', 'true'),
(18, '2027TICT11', 7, '2027', 1, 1, '2025-03-28 13:47:50', '13,14,15', 'true'),
(19, '2023TICT11', 7, '', 0, 0, '2025-03-28 11:44:00', '13,14,15', 'true'),
(20, '2099TICT11', 7, '', 1, 1, '2025-03-27 18:17:00', '13,14,15', 'true'),
(21, '2087TICT11', 7, '', 1, 1, '2025-03-27 19:32:00', '13,14,15', 'true'),
(22, '2067TICT11', 7, '', 1, 1, '2025-03-27 21:49:00', '13,14,15', 'true'),
(23, '2078TICT11', 7, '2078', 1, 1, '2025-03-26 23:07:00', '13,14,15', 'true'),
(24, '2033TICT11', 7, '2033', 1, 1, '2025-03-25 23:14:00', '13,14,15', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_students`
--

CREATE TABLE `batch_17_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) NOT NULL,
  `admission_ready` varchar(50) NOT NULL,
  `sub_16` varchar(50) NOT NULL,
  `sub_17` varchar(50) NOT NULL,
  `sub_18` varchar(50) NOT NULL,
  `sub_19` varchar(50) NOT NULL,
  `sub_20` varchar(50) NOT NULL,
  `sub_21` varchar(50) NOT NULL,
  `sub_22` varchar(50) NOT NULL,
  `sub_23` varchar(50) NOT NULL,
  `sub_24` varchar(50) NOT NULL,
  `sub_25` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_students`
--

INSERT INTO `batch_17_students` (`id`, `s_id`, `applied_to_exam`, `admission_ready`, `sub_16`, `sub_17`, `sub_18`, `sub_19`, `sub_20`, `sub_21`, `sub_22`, `sub_23`, `sub_24`, `sub_25`) VALUES
(1, 7, 'false', 'false', '80', '95.3', '98', '70', '100', '100', '95', '100', '67.7', '75'),
(2, 8, 'false', 'false', '40', '67.8', '100', '80', '89', '76', '56.7', '78.9', '45.6', '0'),
(3, 9, 'false', 'false', '60', '100', '70', '50', '0', '66.7', '67.8', '36.7', '37.8', '67.8'),
(4, 10, 'false', 'false', '50.5', '100', '27.5', '50', '90', '78.9', '76.2', '54.6', '100', '43.5'),
(7, 11, 'true', '', '', '', '', '', '', '', '', '', '', ''),
(8, 12, 'true', '', '', '', '', '', '', '', '', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_16`
--

CREATE TABLE `batch_17_sub_16` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_16`
--

INSERT INTO `batch_17_sub_16` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'true', 'P'),
(13, 'false', 'M'),
(7, 'true', 'P'),
(12, 'false', 'P'),
(11, 'true', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_17`
--

CREATE TABLE `batch_17_sub_17` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_17`
--

INSERT INTO `batch_17_sub_17` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'true', 'P'),
(26, 'true', 'M'),
(7, 'true', 'P'),
(12, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_18`
--

CREATE TABLE `batch_17_sub_18` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_18`
--

INSERT INTO `batch_17_sub_18` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(18, 'true', 'R'),
(7, 'false', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_19`
--

CREATE TABLE `batch_17_sub_19` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_19`
--

INSERT INTO `batch_17_sub_19` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(18, 'true', 'R'),
(7, 'false', 'P'),
(12, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_20`
--

CREATE TABLE `batch_17_sub_20` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_20`
--

INSERT INTO `batch_17_sub_20` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(18, 'false', 'R'),
(7, 'false', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_21`
--

CREATE TABLE `batch_17_sub_21` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_21`
--

INSERT INTO `batch_17_sub_21` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(13, 'false', 'M'),
(7, 'false', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_22`
--

CREATE TABLE `batch_17_sub_22` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_22`
--

INSERT INTO `batch_17_sub_22` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'true', 'P'),
(7, 'true', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_23`
--

CREATE TABLE `batch_17_sub_23` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_23`
--

INSERT INTO `batch_17_sub_23` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'true', 'P'),
(7, 'true', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_24`
--

CREATE TABLE `batch_17_sub_24` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_24`
--

INSERT INTO `batch_17_sub_24` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(7, 'false', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_17_sub_25`
--

CREATE TABLE `batch_17_sub_25` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_17_sub_25`
--

INSERT INTO `batch_17_sub_25` (`s_id`, `eligibility`, `exam_type`) VALUES
(7, 'false', 'P'),
(7, 'false', 'P'),
(12, 'false', 'P'),
(11, 'false', 'P');

-- --------------------------------------------------------

--
-- Table structure for table `batch_18_students`
--

CREATE TABLE `batch_18_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_18_students`
--

INSERT INTO `batch_18_students` (`id`, `s_id`, `applied_to_exam`, `sub_13`, `sub_14`, `sub_15`) VALUES
(1, 76, 'false', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `batch_18_sub_13`
--

CREATE TABLE `batch_18_sub_13` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_18_sub_14`
--

CREATE TABLE `batch_18_sub_14` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_18_sub_15`
--

CREATE TABLE `batch_18_sub_15` (
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_19_students`
--

CREATE TABLE `batch_19_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_19_sub_13`
--

CREATE TABLE `batch_19_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_19_sub_14`
--

CREATE TABLE `batch_19_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_19_sub_15`
--

CREATE TABLE `batch_19_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_20_students`
--

CREATE TABLE `batch_20_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_20_sub_13`
--

CREATE TABLE `batch_20_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_20_sub_14`
--

CREATE TABLE `batch_20_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_20_sub_15`
--

CREATE TABLE `batch_20_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_21_students`
--

CREATE TABLE `batch_21_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_21_sub_13`
--

CREATE TABLE `batch_21_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_21_sub_14`
--

CREATE TABLE `batch_21_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_21_sub_15`
--

CREATE TABLE `batch_21_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_22_students`
--

CREATE TABLE `batch_22_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_22_sub_13`
--

CREATE TABLE `batch_22_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_22_sub_14`
--

CREATE TABLE `batch_22_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_22_sub_15`
--

CREATE TABLE `batch_22_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_23_students`
--

CREATE TABLE `batch_23_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_23_sub_13`
--

CREATE TABLE `batch_23_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_23_sub_14`
--

CREATE TABLE `batch_23_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_23_sub_15`
--

CREATE TABLE `batch_23_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_24_students`
--

CREATE TABLE `batch_24_students` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `applied_to_exam` varchar(50) DEFAULT 'false',
  `sub_13` varchar(50) NOT NULL,
  `sub_14` varchar(50) NOT NULL,
  `sub_15` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_24_students`
--

INSERT INTO `batch_24_students` (`id`, `s_id`, `applied_to_exam`, `sub_13`, `sub_14`, `sub_15`) VALUES
(1, 76, 'true', '', '', ''),
(2, 77, 'false', '', '', ''),
(3, 78, 'false', '', '', ''),
(4, 79, 'false', '', '', '');

-- --------------------------------------------------------

--
-- Table structure for table `batch_24_sub_13`
--

CREATE TABLE `batch_24_sub_13` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_24_sub_13`
--

INSERT INTO `batch_24_sub_13` (`id`, `s_id`, `eligibility`, `exam_type`) VALUES
(2, 76, 'true', 'P'),
(4, 80, 'true', 'M');

-- --------------------------------------------------------

--
-- Table structure for table `batch_24_sub_14`
--

CREATE TABLE `batch_24_sub_14` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_24_sub_14`
--

INSERT INTO `batch_24_sub_14` (`id`, `s_id`, `eligibility`, `exam_type`) VALUES
(7, 80, 'true', 'R');

-- --------------------------------------------------------

--
-- Table structure for table `batch_24_sub_15`
--

CREATE TABLE `batch_24_sub_15` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `eligibility` varchar(50) NOT NULL,
  `exam_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_24_sub_15`
--

INSERT INTO `batch_24_sub_15` (`id`, `s_id`, `eligibility`, `exam_type`) VALUES
(5, 76, 'false', 'P'),
(7, 80, 'true', 'M');

-- --------------------------------------------------------

--
-- Table structure for table `batch_curriculum_lecturer`
--

CREATE TABLE `batch_curriculum_lecturer` (
  `id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `m_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_curriculum_lecturer`
--

INSERT INTO `batch_curriculum_lecturer` (`id`, `batch_id`, `sub_id`, `m_id`) VALUES
(126, 18, 13, 1),
(127, 18, 14, 2),
(128, 18, 15, 4),
(359, 17, 16, 1),
(360, 17, 17, 2),
(361, 17, 18, 1),
(362, 17, 19, 4),
(363, 17, 20, 5),
(364, 17, 21, 8),
(365, 17, 22, 2),
(366, 17, 23, 1),
(367, 17, 24, 4),
(368, 17, 25, 5),
(369, 19, 13, 2),
(370, 19, 14, 2),
(371, 19, 15, 4),
(372, 20, 13, 2),
(373, 20, 14, 5),
(374, 20, 15, 5),
(375, 21, 13, 4),
(376, 21, 14, 1),
(377, 21, 15, 7),
(387, 22, 13, 2),
(388, 22, 14, 1),
(389, 22, 15, 5),
(393, 23, 13, 2),
(394, 23, 14, 4),
(395, 23, 15, 5),
(396, 24, 13, 1),
(397, 24, 14, 2),
(398, 24, 15, 4);

-- --------------------------------------------------------

--
-- Table structure for table `batch_time_periods`
--

CREATE TABLE `batch_time_periods` (
  `id` int(11) NOT NULL,
  `batch_id` int(11) NOT NULL,
  `user_type` enum('5','4','3','2') NOT NULL,
  `end_date` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `mail_sent` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batch_time_periods`
--

INSERT INTO `batch_time_periods` (`id`, `batch_id`, `user_type`, `end_date`, `created_at`, `updated_at`, `mail_sent`) VALUES
(59, 17, '5', '2025-03-23 13:35:00', '2024-12-26 06:41:12', '2025-03-21 12:46:15', 1),
(60, 17, '4', '2025-03-18 17:33:00', '2024-12-26 06:41:12', '2025-03-18 20:04:39', 1),
(99, 17, '3', '2025-03-18 12:36:00', '2025-02-28 12:06:23', '2025-03-18 20:14:49', 1),
(100, 17, '2', '2025-03-21 17:06:00', '2025-02-28 12:06:23', '2025-03-18 20:14:00', 0),
(393, 22, '5', '2025-03-27 21:49:00', '2025-03-24 16:19:50', '2025-03-28 08:35:08', 1),
(394, 22, '4', '2025-03-28 21:49:00', '2025-03-24 16:19:50', '2025-03-24 16:19:50', 0),
(395, 22, '3', '2025-03-30 21:49:00', '2025-03-24 16:19:50', '2025-03-24 16:20:55', 0),
(396, 22, '2', '2025-03-30 21:49:00', '2025-03-24 16:19:50', '2025-03-24 16:19:50', 0),
(409, 23, '5', '2025-03-27 23:08:00', '2025-03-25 17:38:36', '2025-03-26 19:35:04', 1),
(410, 23, '4', '2025-03-28 23:08:00', '2025-03-25 17:38:36', '2025-03-25 17:38:36', 0),
(411, 23, '3', '2025-03-29 23:08:00', '2025-03-25 17:38:36', '2025-03-25 17:38:36', 0),
(412, 23, '2', '2025-03-30 23:08:00', '2025-03-25 17:38:36', '2025-03-25 17:38:36', 0),
(417, 24, '5', '2025-03-29 23:14:00', '2025-03-25 17:45:00', '2025-03-26 09:35:06', 1),
(418, 24, '4', '2025-03-29 23:14:00', '2025-03-25 17:45:00', '2025-03-25 17:45:00', 0),
(419, 24, '3', '2025-03-29 23:14:00', '2025-03-25 17:45:00', '2025-03-25 17:45:00', 0),
(420, 24, '2', '2025-03-25 23:14:00', '2025-03-25 17:45:00', '2025-03-26 09:37:53', 0);

-- --------------------------------------------------------

--
-- Table structure for table `curriculum`
--

CREATE TABLE `curriculum` (
  `sub_id` int(11) NOT NULL,
  `sub_code` varchar(100) NOT NULL,
  `sub_name` varchar(150) NOT NULL,
  `sem_no` int(2) NOT NULL,
  `deg_id` int(11) NOT NULL,
  `level` int(3) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `curriculum`
--

INSERT INTO `curriculum` (`sub_id`, `sub_code`, `sub_name`, `sem_no`, `deg_id`, `level`, `status`) VALUES
(7, 'TICT1114', 'Essentials of ICT', 1, 7, 1, 'false'),
(8, 'TICT1123', 'Mathematics for Technology', 1, 7, 1, 'false'),
(9, 'TICT1134', 'Fundamentals of Computer Programming', 1, 7, 1, 'false'),
(10, 'TICT1142', ' Fundamentals of Web Technologies', 1, 7, 1, 'false'),
(11, 'TICT1152', ' Principles of Management', 1, 7, 1, 'false'),
(12, 'AUX1113', ' English Language I', 1, 7, 1, 'false'),
(13, 'TICT1114(P)', 'Essentials of ICT (P)', 1, 7, 1, 'true'),
(14, 'TICT1134(P)', 'Fundamentals of Computer Programming (P)', 1, 7, 1, 'true'),
(15, 'TICT1142(P)', ' Fundamentals of Web Technologies (P)', 1, 7, 1, 'true'),
(16, 'IT3113(T)', 'Knowledge Based Systems and Logic Programming', 1, 14, 3, 'true'),
(17, 'IT3113(P)', 'Knowledge Based Systems and Logic Programming (P)', 1, 14, 3, 'true'),
(18, 'IT3122', 'Computer Security', 1, 14, 3, 'true'),
(19, 'IT3133', 'Mobile Communication and Computing', 1, 14, 3, 'true'),
(20, 'IT3133(P)', 'Mobile Communication and Computing (P)', 1, 14, 3, 'true'),
(21, 'IT3143', 'Digital Image Processing', 1, 14, 3, 'true'),
(22, 'IT3143(P)', 'Digital Image Processing (P)', 1, 14, 3, 'true'),
(23, 'IT3152', 'Software Quality Assurance', 1, 14, 3, 'true'),
(24, 'IT3162', 'Group Project', 1, 14, 3, 'true'),
(25, 'ACU3112', 'Career Guidance ', 1, 14, 3, 'true'),
(26, 'PM2113', 'Project Schedule Management', 1, 13, 2, 'true'),
(27, 'PM2123', 'Project Communication and Information Management', 1, 13, 2, 'true'),
(28, 'PM2133', 'Project Cost Management', 1, 13, 2, 'true'),
(29, 'PM2143', 'Environmental and Disaster Management', 1, 13, 2, 'true'),
(30, 'PM2153', 'Management Science Applications', 1, 13, 2, 'true'),
(31, 'ENG 2113', 'Proficiency in English – III', 1, 13, 2, 'true'),
(32, 'ACU2112', 'Social Harmony and Active Citizenship', 1, 13, 2, 'true');

-- --------------------------------------------------------

--
-- Table structure for table `degree`
--

CREATE TABLE `degree` (
  `deg_id` int(11) NOT NULL,
  `deg_name` varchar(500) NOT NULL,
  `short` varchar(50) NOT NULL,
  `levels` varchar(100) NOT NULL,
  `no_of_sem_per_year` varchar(10) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `degree`
--

INSERT INTO `degree` (`deg_id`, `deg_name`, `short`, `levels`, `no_of_sem_per_year`, `status`) VALUES
(7, 'Information and Communication Technology (Honours)', 'TICT', '1:2:3:4', '2', 'true'),
(8, 'Environmental Science (Honours)', 'ASB', '1:2:3:4', '2', 'true'),
(9, 'Applied Mathematics and Computing', 'ASP', '1:2:3', '2', 'true'),
(10, 'Computer Science (Honours)', 'CSH', '3:4', '2', 'true'),
(11, 'Information Technology (Honours)', 'ITH', '4', '2', 'true'),
(12, 'Business Management  in Human Resource (Honours)', 'BSHR', '1:2:3:4', '2', 'true'),
(13, 'Business Management in Project Management (Honours)', 'PM', '1:2:3:4', '2', 'true'),
(14, 'Information Technology', 'IT', '1:2:3', '8', 'true'),
(15, 'Business Management in Business Economics', 'BSBE', '1:2:3', '2', 'true'),
(16, 'Business Management in Finance and Accountancy', 'BSFA', '1:2:3', '2', 'true'),
(17, 'Business Management in Management and Entrepreneurship', 'BSME', '1:2:3', '2', 'true'),
(18, 'Business Management in Marketing Management', 'BSMM', '1:2:3', '2', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `d_id` int(11) NOT NULL,
  `d_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`d_id`, `d_name`, `user_id`, `contact_no`, `status`) VALUES
(6, 'Physical Science', 24, '0246784561', 'true'),
(7, 'Bio Science', 25, '0245699555', 'true'),
(8, 'Business Economics', 26, '0246788890', 'true'),
(9, 'English Language Teaching', 27, '0243333419', 'true'),
(10, 'Finance and Accountancy', 28, '0245677779', 'true'),
(11, 'Human Resource Management', 29, '0248790001', 'true'),
(12, 'Management and Entrepreneurship', 30, '0245699111', 'true'),
(13, 'Marketing Management', 31, '0241111891', 'true'),
(14, 'Project Management', 32, '0244456619', 'true'),
(15, 'ICT', 33, '0245566193', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `dep_deg`
--

CREATE TABLE `dep_deg` (
  `d_id` int(11) NOT NULL,
  `deg_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `dep_deg`
--

INSERT INTO `dep_deg` (`d_id`, `deg_id`) VALUES
(6, 9),
(6, 10),
(6, 11),
(6, 14),
(7, 8),
(8, 15),
(10, 16),
(11, 12),
(12, 17),
(13, 18),
(14, 13),
(15, 7);

-- --------------------------------------------------------

--
-- Table structure for table `eligibility_log`
--

CREATE TABLE `eligibility_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `exam` int(11) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `status_from` varchar(50) NOT NULL,
  `status_to` varchar(50) NOT NULL,
  `remark` text NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `eligibility_log`
--

INSERT INTO `eligibility_log` (`id`, `user_id`, `s_id`, `exam`, `sub_id`, `status_from`, `status_to`, `remark`, `date_time`) VALUES
(72, 21, 13, 17, 16, 'true', 'false', 'not attend', '2025-03-05 10:20:02'),
(73, 21, 7, 17, 18, 'true', 'false', 'reason', '2025-03-05 10:20:24'),
(74, 21, 13, 17, 21, 'true', 'false', 'bfjsjkf asnksnfskf ajfksj awijsaidjsd djsdsdsdo wsdijiw', '2025-03-05 20:32:53'),
(75, 21, 13, 17, 21, 'false', 'true', 'cvcxvxv', '2025-03-05 20:33:40'),
(76, 24, 7, 17, 21, 'true', 'false', 'for all', '2025-03-05 20:39:05'),
(77, 24, 7, 17, 21, 'true', 'false', 'for all', '2025-03-05 20:39:05'),
(78, 24, 13, 17, 21, 'true', 'false', 'for all', '2025-03-05 20:39:05'),
(79, 24, 7, 17, 20, 'true', 'false', 'gfhgj', '2025-03-05 20:41:52'),
(80, 24, 18, 17, 20, 'true', 'false', 'imraan', '2025-03-05 20:42:29'),
(82, 21, 13, 17, 16, 'true', 'false', 'hii', '2025-03-16 19:49:14'),
(83, 167, 11, 17, 16, 'false', 'true', 'just', '2025-03-22 06:39:13'),
(84, 167, 76, 24, 13, 'false', 'true', 'hii', '2025-03-27 13:10:50');

-- --------------------------------------------------------

--
-- Table structure for table `entry_summary`
--

CREATE TABLE `entry_summary` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `academic_year` varchar(50) NOT NULL,
  `level` int(11) NOT NULL,
  `sem` int(11) NOT NULL,
  `proper_subs` text DEFAULT NULL,
  `medical_subs` text DEFAULT NULL,
  `resit_subs` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `entry_summary`
--

INSERT INTO `entry_summary` (`id`, `s_id`, `academic_year`, `level`, `sem`, `proper_subs`, `medical_subs`, `resit_subs`) VALUES
(9, 76, '2033', 1, 1, '13,15', NULL, NULL),
(11, 80, '2033', 1, 1, NULL, '13,15', '14');

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `f_id` int(11) NOT NULL,
  `f_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`f_id`, `f_name`, `user_id`, `contact_no`, `status`) VALUES
(8, 'Applied Science', 21, '0246765434', 'true'),
(9, 'Business Studies', 22, '0246865433', 'true'),
(10, 'Technological Studies', 23, '0249060438', 'true'),
(13, 'Applied Science', 137, 'h', 'f'),
(14, 'a', 138, 'h', 'f'),
(15, 'sfsdf', 155, 'dfdfdf', 'true'),
(16, 'ssskk', 156, 'fegrgh', 'true'),
(19, 'sgfg', 159, 'd234', 'true'),
(21, 'tutyu', 161, 'huuiyu89', 'true'),
(22, 'gjuhjk', 162, 'tyty', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `fac_dep`
--

CREATE TABLE `fac_dep` (
  `f_id` int(11) NOT NULL,
  `d_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `fac_dep`
--

INSERT INTO `fac_dep` (`f_id`, `d_id`) VALUES
(8, 6),
(8, 7),
(9, 8),
(9, 9),
(9, 10),
(9, 11),
(9, 12),
(9, 13),
(9, 14),
(10, 15);

-- --------------------------------------------------------

--
-- Table structure for table `manager`
--

CREATE TABLE `manager` (
  `m_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manager`
--

INSERT INTO `manager` (`m_id`, `user_id`) VALUES
(1, 123),
(2, 124),
(3, 125),
(4, 126),
(5, 127),
(7, 143),
(8, 154);

-- --------------------------------------------------------

--
-- Table structure for table `manager_detail`
--

CREATE TABLE `manager_detail` (
  `m_id` int(11) NOT NULL,
  `name` varchar(500) NOT NULL,
  `contact_no` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manager_detail`
--

INSERT INTO `manager_detail` (`m_id`, `name`, `contact_no`, `status`) VALUES
(1, 'S.Vadivel', '94770345120', 'true'),
(2, 'J.Fernando', '94775587965', 'true'),
(3, 'S.Rajesh', '95728754932', 'false'),
(4, 'T.Anuradha', '94753267382', 'true'),
(5, 'N.Sivakumar', '94772584321', 'true'),
(7, 'Waseem', '67876845634', 'true'),
(8, '55', '55', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` varchar(50) NOT NULL,
  `role_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`) VALUES
('1', 'admin'),
('2', 'dean'),
('3', 'hod'),
('4', 'lecturer'),
('5', 'student');

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `s_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`s_id`, `user_id`) VALUES
(7, 34),
(8, 35),
(9, 36),
(10, 37),
(11, 38),
(12, 39),
(13, 40),
(14, 41),
(15, 42),
(16, 43),
(17, 44),
(18, 45),
(19, 46),
(20, 47),
(21, 48),
(22, 49),
(23, 50),
(24, 51),
(25, 52),
(26, 53),
(27, 54),
(28, 55),
(29, 56),
(30, 57),
(31, 58),
(32, 59),
(33, 60),
(34, 61),
(35, 62),
(36, 63),
(37, 64),
(38, 65),
(39, 66),
(40, 67),
(41, 68),
(42, 69),
(43, 70),
(44, 71),
(45, 72),
(46, 73),
(47, 74),
(48, 75),
(49, 76),
(50, 77),
(51, 78),
(52, 79),
(53, 80),
(54, 81),
(55, 82),
(56, 83),
(57, 84),
(58, 85),
(59, 86),
(60, 87),
(61, 88),
(62, 89),
(63, 90),
(64, 91),
(65, 92),
(66, 93),
(67, 94),
(68, 95),
(69, 96),
(70, 97),
(71, 98),
(72, 99),
(73, 100),
(74, 101),
(75, 102),
(76, 103),
(77, 104),
(78, 105),
(79, 106),
(80, 107),
(81, 108),
(82, 109),
(83, 110),
(84, 111),
(85, 112),
(86, 113),
(87, 114),
(88, 115),
(89, 116),
(90, 117),
(91, 118),
(92, 119),
(93, 120),
(94, 121),
(95, 122),
(99, 139),
(100, 140),
(101, 141),
(102, 142),
(103, 144),
(104, 145),
(104, 150),
(105, 151),
(106, 152),
(107, 163),
(108, 164),
(109, 165);

-- --------------------------------------------------------

--
-- Table structure for table `students_log`
--

CREATE TABLE `students_log` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `exam` int(11) NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students_log`
--

INSERT INTO `students_log` (`id`, `user_id`, `exam`, `date_time`) VALUES
(1, 37, 17, '2025-01-16 18:55:42'),
(2, 34, 17, '2025-01-17 21:11:32'),
(3, 34, 17, '2025-02-27 08:02:36'),
(4, 39, 17, '2025-03-18 19:29:47'),
(5, 38, 17, '2025-03-22 06:08:42'),
(6, 103, 24, '2025-03-26 09:27:59'),
(7, 103, 24, '2025-03-26 19:14:21'),
(8, 103, 24, '2025-03-26 19:27:26'),
(9, 103, 24, '2025-03-26 19:28:23'),
(10, 103, 24, '2025-03-26 19:29:43');

-- --------------------------------------------------------

--
-- Table structure for table `student_detail`
--

CREATE TABLE `student_detail` (
  `s_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `index_num` varchar(50) NOT NULL,
  `contact_no` varchar(100) NOT NULL,
  `batch_ids` varchar(150) NOT NULL,
  `f_id` int(11) NOT NULL,
  `status` varchar(100) NOT NULL DEFAULT 'true'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_detail`
--

INSERT INTO `student_detail` (`s_id`, `name`, `index_num`, `contact_no`, `batch_ids`, `f_id`, `status`) VALUES
(1, 'rtyrtyty', '', 'sds', '', 8, 'true'),
(7, 'KELUM B.Η.Τ', 'IT 16001', '11111111111', '17', 8, 'true'),
(8, 'JAYASINGHE M.D.', 'IT 16002', '', '17', 8, 'true'),
(9, 'WICKRAMASINGHE S.N.', 'IT 16003', '1345435', '17', 8, 'true'),
(10, 'KARUNITHAA M.', 'IT 15001', '', '17', 8, 'true'),
(11, 'BANUJA V.', 'IT 16007', '', '17', 8, 'true'),
(12, 'DEWMINI AV', 'IT 16008', '', '17', 8, 'true'),
(13, 'GUNASEKARA HDD ', '', '', '', 8, 'true'),
(14, 'ABEYSINGHEA.AK.C', '', '', '', 8, 'true'),
(15, 'PEIRIS P.PH.B.', '', '', '', 8, 'true'),
(16, 'PERERAKA.S.LD', '', '', '', 8, 'true'),
(17, 'Udisha W.H.I.', '', '', '', 8, 'true'),
(18, 'Imran BM', 'IT 16004', '', '', 8, 'true'),
(19, 'Shanmugarajah D', '', '', '', 8, 'true'),
(20, 'Muniweera K.G.U.K.', '', '', '', 8, 'true'),
(21, 'Lourdes Jellorine C', '', '', '', 8, 'true'),
(22, 'Nalawansa U.K', '', '', '', 8, 'true'),
(23, 'Devakumar P.', '', '', '', 8, 'true'),
(24, 'Senevirathne S.A', '', '', '', 8, 'true'),
(25, 'Jegatheeswaran V.', 'IT 16005', '', '', 8, 'true'),
(26, 'Shahla A.A.F.S.', 'IT 16006', '', '', 8, 'true'),
(27, 'RANAWEERA T.R.M.D.S', '', '', '', 8, 'true'),
(28, 'SUDARAKA R.A.V', '', '', '', 8, 'true'),
(29, 'KARIYAWASAM K.K.S.M.V', '', '', '', 8, 'true'),
(30, 'WEERAKOON W.A.D.L', '', '', '', 8, 'true'),
(31, 'LAKSHIKA R.M.K', '', '', '', 8, 'true'),
(32, 'WICKRAMASINGHE W.M.D.L', '', '', '', 8, 'true'),
(33, 'DISSANAYAKA D.M.I.L', '', '', '', 8, 'true'),
(34, 'CHITHRAKA P.R', '', '', '', 8, 'true'),
(35, 'DISSANAYAKA D.M.S.P ', '', '', '', 8, 'true'),
(36, 'PATHIRANA W.P.S.I', '', '', '', 8, 'true'),
(37, 'KAWMADI L.G.A.S', '', '', '', 8, 'true'),
(38, 'THARUSHI K.H.P', '', '', '', 8, 'true'),
(39, 'CHANDRASIRI W.H.T.S', '', '', '', 8, 'true'),
(40, 'HEMANTHA H.B.G.P.N', '', '', '', 8, 'true'),
(41, 'HERATH H.P.N.I', '', '', '', 8, 'true'),
(42, 'BUDDHIMA H.M.H', '', '', '', 8, 'true'),
(43, 'MANAMPERI G.M.C', '', '', '', 8, 'true'),
(44, 'DHARMASIRI P.C.M', '', '', '', 8, 'true'),
(45, 'THILAKARATHNA D.M.I.D', '', '', '', 8, 'true'),
(46, 'DISSANAYAKA I.L', '', '', '', 8, 'true'),
(47, 'MOHOMMAD P.M.', '', '', '', 8, 'true'),
(48, 'HETTIARACHCHI T.N', '', '', '', 8, 'true'),
(49, 'RAJASINGHA G.R', '', '', '', 8, 'true'),
(50, 'THARUSHI U.K', '', '', '', 8, 'true'),
(51, 'LOKARAJA D.C', '', '', '', 8, 'true'),
(52, 'PAVANI T.D.N', '', '', '', 8, 'true'),
(53, 'RANAPATHI G.S.A', '', '', '', 8, 'true'),
(54, 'SAGARIKA D.T.W.D', '', '', '', 8, 'true'),
(55, 'KARUNARATHNA S.D', '', '', '', 8, 'true'),
(56, 'KUMARI K.L', '', '', '', 8, 'true'),
(57, 'DHARMAPRIYA G.D', '', '', '', 8, 'true'),
(58, 'SANDUNI T.L', '', '', '', 8, 'true'),
(59, 'DASSANAYAKA G.R', '', '', '', 8, 'true'),
(60, 'RANIMIKA T.S', '', '', '', 8, 'true'),
(61, 'SELVAM D.C', '', '', '', 8, 'true'),
(62, 'HETTIGODA K.A', '', '', '', 8, 'true'),
(63, 'RAJAPAKSHA R.D', '', '', '', 8, 'true'),
(64, 'NIWANDANA T.U', '', '', '', 8, 'true'),
(65, 'SENARATHNA R.L', '', '', '', 8, 'true'),
(66, 'L. Hariharan', '', '', '', 8, 'true'),
(67, 'T. Vartheeswaran', '', '', '', 8, 'true'),
(68, 'V. Varaniya', '', '', '', 8, 'true'),
(69, 'M. J. F. Ilma', '', '', '', 8, 'true'),
(70, 'M. S. K. Alwis', '', '', '', 8, 'true'),
(71, 'C. Thanushiga', '', '', '', 8, 'true'),
(72, 'B. Ushanthika', '', '', '', 8, 'true'),
(73, 'J. M. Kumari', '', '', '', 8, 'true'),
(74, 'P. Nivithashini', '', '', '', 8, 'true'),
(75, 'B. Kobika', '', '', '', 8, 'true'),
(76, 'SOORIYAARACHCHI Y.P', '', '', '18,24', 10, 'true'),
(77, 'DARMADASA R.Y', '', '', '24', 10, 'true'),
(78, 'GAYANI D.H', '', '', '24', 10, 'true'),
(79, 'PALLIYAGURU G.M', '', '', '24', 10, 'true'),
(80, 'PIYUMIKA D.S', '', '', '', 10, 'true'),
(81, 'RANATHUNGA D.S', '', '', '', 10, 'true'),
(82, 'KARUNATHILAKA S.D', '', '', '', 10, 'true'),
(83, 'JAYASINHA T.K', '', '', '', 10, 'true'),
(84, 'KALANI F.D', '', '', '', 10, 'true'),
(85, 'SENARATHNA R.L', '', '', '', 10, 'true'),
(86, 'DARMIKAM J.L', '', '', '', 10, 'true'),
(87, 'PERERA G.D', '', '', '', 10, 'true'),
(88, 'TANAKA S.H', '', '', '', 10, 'true'),
(89, 'DASSANAYAKA R.M', '', '', '', 10, 'true'),
(90, 'SHANIKA T.S', '', '', '', 10, 'true'),
(91, 'RANASINHA D.C', '', '', '', 10, 'true'),
(92, 'MIHIRANI K.A', '', '', '', 10, 'true'),
(93, 'RAJAPAKSHA T.N.D.R.S', '', '', '', 10, 'true'),
(94, 'JAYASIRI T.U', '', '', '', 10, 'true'),
(95, 'SENARATHNA R.L.B', '', '', '', 10, 'true'),
(99, 'Ashfak', 'A 22101', '37627446', '', 8, 'true'),
(100, 'Jallu', '', '243243535', '', 8, 'true'),
(101, 'Kamaal BBD', '', '3243534545', '', 8, 'true'),
(102, 'romee', 'IT 17002', '325354646', '', 8, 'true'),
(103, 'ffhh', '', '11111111', '', 9, 'true'),
(104, '222222', '222222', '222222', '', 8, 'true'),
(105, '3', '3', '3', '', 10, 'true'),
(106, '4', '', '4', '', 10, 'true'),
(107, 'ry3', 'cfg3', '3', '', 8, 'true'),
(108, 'ry4', '', '4', '', 8, 'true'),
(109, 'dfgfgh', '', 'dfgdfg', '', 9, 'true');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(250) NOT NULL,
  `email` varchar(500) NOT NULL,
  `password` varchar(250) NOT NULL,
  `role_id` varchar(50) NOT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `token_expiration` datetime DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_until` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `user_name`, `email`, `password`, `role_id`, `reset_token`, `token_expiration`, `failed_attempts`, `lockout_until`) VALUES
(21, 'fasadmin@gmail.com', 'fasadmin@gmail.com', '$2b$10$tjbGkyWyz5diZ58OuKJP/eAZRUhgo8as89PwtIxy5RqVL9zzrCrNq', '2', NULL, NULL, 0, NULL),
(22, 'fbsadmin@gmail.com', 'fbsadmin@gmail.com', '$2b$10$dWkx5Y3EPBMn5CFcSqoda.FQW7KmgYG7RrqJFZI8jQMK7LCBu5jZm', '2', NULL, NULL, 0, NULL),
(23, 'ftsadmin@gmail.com', 'ftsadmin@gmail.com', '$2b$10$hYNq16yVPHrj.5TMPbGvyeck0JsxsOejL2G7TvNi3OmvrilG2MwGm', '2', NULL, NULL, 0, NULL),
(24, 'phyadmin@gmail.com', 'phyadmin@gmail.com', '$2b$10$fRClBW4EyEwAMgdgjUzQlelgw9ujerfLMojPdm8plnvokHf7tIAhm', '3', NULL, NULL, 0, NULL),
(25, 'bioadmin@gmail.com', 'bioadmin@gmail.com', '$2b$10$epgwDYognXrJMTK0ySZ99u5rB/CRzp5GliSYEH4eGU0fpza8nAUwq', '3', NULL, NULL, 0, NULL),
(26, 'beadmin@gmail.com', 'beadmin@gmail.com', '$2b$10$qMUkLMZpb9K5SBSe0GUIi.1KxPwepgTLlG.NdVy4mmmLOltzBKn3m', '3', NULL, NULL, 0, NULL),
(27, 'eltadmin@gmail.com', 'eltadmin@gmail.com', '$2b$10$JmscW9BkeI0TEQ6L6zFSi.ALPt/hbt0uKzxB4fTZFX3Sy1RZ5JWhq', '3', NULL, NULL, 0, NULL),
(28, 'faadmin@gmail.com', 'faadmin@gmail.com', '$2b$10$x37rhTq8.SyIiRKhPUfAqOL042738NzCKDHg28kDgDOlZt7MPR/dm', '3', NULL, NULL, 0, NULL),
(29, 'hrmadmin@gmail.com', 'hrmadmin@gmail.com', '$2b$10$frwkLjZBbd7.LNKgLS8D4u4kNUMQxv2XMCrk/QxsV/O260/cQY8Vm', '3', NULL, NULL, 0, NULL),
(30, 'meadmin@gmail.com', 'meadmin@gmail.com', '$2b$10$4nRtHZfB0i4AWkb8uoD7pOPcPi8iRsMKveRoY1Z4R0u91emDEA6YO', '3', NULL, NULL, 0, NULL),
(31, 'mmadmin@gmail.com', 'mmadmin@gmail.com', '$2b$10$5jO0rlKeVj8lZWjlagGzLeV3BIUOiknntQPjBc8K1cq/hsSKfGPua', '3', NULL, NULL, 0, NULL),
(32, 'pmadmin@gmail.com', 'pmadmin@gmail.com', '$2b$10$EME7.xEfUgZiRZw4eLQ8oe9tasRWGIi/3wqYGBmIxI6DSIyFU7972', '3', NULL, NULL, 0, NULL),
(33, 'ictadmin@gmail.com', 'ictadmin@gmail.com', '$2b$10$D3UvMPr//9bMgZBFRyxT/.oVc18X4HZ9B/GPWsm2sURgU6/Rb.YD2', '3', NULL, NULL, 0, NULL),
(34, '2022/ICT/01', 'bkelum@gmail.com', '$2b$10$7n5bCycYkvSsF1DZGg5ZsuTT7fOJQuk3KRe8wM2LL7D10CmWJOfEK', '5', NULL, NULL, 0, NULL),
(35, '2022/ICT/02', 'mjayasinghe@gmail.com', '$2b$10$5fD/Z5ePoCHFx8HQXF7xN.AeKRPqy3t5sRhxIq.g.jQWfvg8oSSlS', '5', NULL, NULL, 0, NULL),
(36, '2022/ICT/03', 'swickramasinghe@gmail.com', '$2b$10$RvjcHSnhw.bOeJvIEibrRurFpPxWiPKDMVhQK6WSgcqgDQfF0cpkq', '5', NULL, NULL, 0, NULL),
(37, '2022/ICT/05', 'mkarunithaa@gmail.com', '$2b$10$nogcJrKCJ.JbTji9f6u8veTQ6m3DD6pofMUDLleABHbFrBmsAMYVm', '5', NULL, NULL, 0, NULL),
(38, '2022/ICT/06', 'vbanuja@gmail.com', '$2b$10$9H1Rm2iSjV.m05sLaXcRyuIxIj5kPbDcDlCfJoaf2t2km/MzkwJTy', '5', NULL, NULL, 0, NULL),
(39, '2022/ICT/09', 'adewmini@gmail.com', '$2b$10$C5IiMOWgo3KuAX96DK03wuLsHoDUDOqF0AgcDWIDrPSts/Sn6m61q', '5', NULL, NULL, 0, NULL),
(40, '2022/ICT/10', 'hgunasekara@gmail.com', '$2b$10$jLntnXsK2E4tF6vpiLHqg.vYEjxDPR0KXX4coXSTDOKIAlLEYgbtu', '5', NULL, NULL, 0, NULL),
(41, '2022/ICT/11', 'aabeysinghea@gmail.com', '$2b$10$TWtiP5kofH1h5/ADYLfIzOFk78NNIGDnqXFtCOC8TmRGXszUUID2S', '5', NULL, NULL, 0, NULL),
(42, '2022/ICT/12', 'ppeiris@gmail.com', '$2b$10$W.Wl9lkAVQcOySx6y.jWVum.z3DB8nxqxRMJ042htYHJpmZVIBZ2u', '5', NULL, NULL, 0, NULL),
(43, '2022/ICT/13', 'spereraka@gmail.com', '$2b$10$m3e/dKu84MNqF8FCh9DWje59YBnHkjgz.FAmri9TvpJn9SZkTKEc2', '5', NULL, NULL, 0, NULL),
(44, '2020/ICT/01', 'wudisha@gmail.com', '$2b$10$5bk84ZjHaWiFFdnNxItkeOUEFY1qMbghMUCJR2EbZDgc/3wdmtas6', '5', NULL, NULL, 0, NULL),
(45, '2020/ICT/02', 'bimran@gmail.com', '$2b$10$p.vJXU/ViwwW26h/lbdtq.ZpxBdCpJuqPpXO5/5AS/XU0J4pTD8G6', '5', NULL, NULL, 0, NULL),
(46, '2020/ICT/03', 'dshanmugarajah', '$2b$10$b6sPKM8s8NrczR6eGMZ/cONjzraYVHIqtQk7Kr9WbWrl8Q49Nl/RO', '5', NULL, NULL, 0, NULL),
(47, '2020/ICT/05', 'kmuniweera@gmail.com', '$2b$10$putP0n1sIGDlKjaXvkoNTu2to6FF.r2TD1gtHQMuamztyZfRgmUFy', '5', NULL, NULL, 0, NULL),
(48, '2020/ICT/06', 'cjellorine@gmail.com', '$2b$10$7QaUkCeoPJ5qheyRL3UJ.O.ycIIYPABRwSJ8Qb9Yp5HvZSpqShyeG', '5', NULL, NULL, 0, NULL),
(49, '2020/ICT/07', 'unalawansa@gmail.com', '$2b$10$I1Y6.e5a91z2xz5C5beg9uHaXbiL9D43XWx5Iwg/.KWJ6W1GHyXtC', '5', NULL, NULL, 0, NULL),
(50, '2020/ICT/08', 'pdevakumar@gmail.com', '$2b$10$Ao9Q7GHKUO4nAsAUbaSG3.HZNBZuDKDUe/M2EzYn9lHLVs8MiJ0g.', '5', NULL, NULL, 0, NULL),
(51, '2020/ICT/09', 'ssenevirathne@gmail.com', '$2b$10$glrPhKLSsi/Oh1Vl9E5ylOHigTJMPYSaqMmzPPRK39AoF5w7RzIJa', '5', NULL, NULL, 0, NULL),
(52, '2020/ICT/10', 'vjegatheeswaran@gmail.com', '$2b$10$vayLEWC62lD.oWC06ZT9XOdKOND4qja3QYIRegk7e/DTW/qxlOqz6', '5', NULL, NULL, 0, NULL),
(53, '2020/ICT/12', 'ashahla@gmail.com', '$2b$10$ZaP4OQsQM4fCTHnxgmAQnOaZQncN9adBLbwLIivjc4sYYFdr8gQwO', '5', NULL, NULL, 0, NULL),
(54, '2022/ASP/03', 'tranaweera@gmail.com', '$2b$10$A2StP4FRInMKwYMbbKgG1./6Yo/R7d4Gty1tfTtu6Te6ydER614xC', '5', NULL, NULL, 0, NULL),
(55, '2022/ASP/12', 'rsudarak@gmail.com', '$2b$10$J5587sbFAkgMfHsji5fK3eIztcZ9/Te03/O5KiQmA.GvGYbHf.WPG', '5', NULL, NULL, 0, NULL),
(56, '2022/ASP/17', 'kkariyawasam@gmail.com', '$2b$10$ZWpimvEvjUqZtKllpVfoZeDcvWNF4H4OW6/DHx4Gs99kZFBxIOdsy', '5', NULL, NULL, 0, NULL),
(57, '2022/ASP/21', 'wweerakoon@gmail.com', '$2b$10$mlY0OHxt8guwTQ3RUFECY.Jj66PHKm.Z/.lSGeOTASAJ3ZgpVNGIK', '5', NULL, NULL, 0, NULL),
(58, '2022/ASP/25', 'rlakshika@gmail.com', '$2b$10$1bdUJuz09uIpWzoKtLF/JeLB4gUGYOQOkkF4AnGwbsFga7j8I2SOi', '5', NULL, NULL, 0, NULL),
(59, '2022/ASP/27', 'lwickramasinghe@gmail.com', '$2b$10$bN8riE9A5ldzYdDcytypSOEQaQXBJRxZDRBCMd/eLgeE7l8u5HGZ6', '5', NULL, NULL, 0, NULL),
(60, '2022/ASP/32', 'ddissanayaka@gmail.com', '$2b$10$RkbhU4i6iJblC2O0KHcbje/.aPatAfZJm0ePmbz725UEiETqCFahi', '5', NULL, NULL, 0, NULL),
(61, '2022/ASP/37', 'pchithraka@gmail.com', '$2b$10$bbMuRf6hQ0iJb0W1lEfGfuDWORLs6w3m4ZZ.sh8RTKt2yXGUxCnW6', '5', NULL, NULL, 0, NULL),
(62, '2022/ASP/38', 'ddissanayaka123@gmail.com', '$2b$10$E5nXIn8C/byMTvvOt27Tj.5b.Bjmq4I1eNfIuMf6brJj./3MO33Ca', '5', NULL, NULL, 0, NULL),
(63, '2021/ASP/01', 'wpathirana@gmail.com', '$2b$10$rBcJ9Eup5apAtZ1opKCquekV3jm6BxtcmgOs7VwxiDGpzpYzbtQ8m', '5', NULL, NULL, 0, NULL),
(64, '2021/ASP/04', 'lkawmadi@gmail.com', '$2b$10$asBbu4cZQzEqD5bJo8cKKu2xNNsB0xi27ag9tZsOLL6H.tdQISU/m', '5', NULL, NULL, 0, NULL),
(65, '2021/ASP/05', 'ktharushi@gmail.com', '$2b$10$F9lUUUA3YIpWuuey.iHeCuNwxqgNQmyYH41/.r9RtjEudXXlH2Udu', '5', NULL, NULL, 0, NULL),
(66, '2021/ASP/09', 'wchandrasiri@gmail.com', '$2b$10$Ktf3Tw6hu9/R379zmlghce8BAw7LYrvX4lsKdSyQfVXeF4a0pa6x2', '5', NULL, NULL, 0, NULL),
(67, '2021/ASP/12', 'hhemantha@gmail.com', '$2b$10$vCa5PI/kFjXiexzBdm.rOeT12T2/Q99L1qRH8aGSvO9ariRtBo0qm', '5', NULL, NULL, 0, NULL),
(68, '2021/ASP/15', 'hherath@gmail.com', '$2b$10$SN66Mvx2lT9bIh8nj/cKv.qemyl4APllfzkLivgZQ5cfw6YHlI9SG', '5', NULL, NULL, 0, NULL),
(69, '2021/ASP/16', 'hbuddhima@gmail.com', '$2b$10$30A0NrZupTIM9hyR6a28E.jEPrYXMB1yw6ZgGFboh0ElUpCGCoLb2', '5', NULL, NULL, 0, NULL),
(70, '2021/ASP/20', 'gmanamperi@gmail.com', '$2b$10$xRscShrzu0gsLYR8YrQ1kujtH155MexWFrMUEjGplztkULzzEpy7O', '5', NULL, NULL, 0, NULL),
(71, '2021/ASP/24', 'pdharmasiri@gmail.com', '$2b$10$0Lpv8G.uwf5SQnGkMbchZO5rK1qaaFAypO0WQ2aaXpqXIFngIJvC.', '5', NULL, NULL, 0, NULL),
(72, '2021/ASP/29', 'dthilakarathna@gmail.com', '$2b$10$TNUaOYhB1uRek1CvwmuUtehHCyVVo7c1ZxZ8yDBbz/qTBwGN8hItW', '5', NULL, NULL, 0, NULL),
(73, '2021/ASB/01', 'idissanayaka@gmail.com', '$2b$10$MkB25mNJHgSNNSVZQ/ppCu2DvcbN56i752Vqkg4qru2qCTXlggIvu', '5', NULL, NULL, 0, NULL),
(74, '2021/ASB/02', 'pmohommad@gmail.com', '$2b$10$ZSSFOw2TlxSVL0.d2N3SsODmSsw9Uvh0Qd2hKAEOgRDgkuyhF0Jle', '5', NULL, NULL, 0, NULL),
(75, '2021/ASB/03', 'thettiarachchi@gmail.com', '$2b$10$lR8P1GNbdJQB29BMRRaYh.fg1H4LcEB4aec3F.2qKQJQnf6jWU6PK', '5', NULL, NULL, 0, NULL),
(76, '2021/ASB/05', 'grajasingha@gmail.com', '$2b$10$/UTotDPnfr7Fa392wmBr2OxeM2x0qWb8pRwagzVPVxvj1j48jlgfG', '5', NULL, NULL, 0, NULL),
(77, '2021/ASB/06', 'utharushi@gmail.com', '$2b$10$29qIatDczXejjB4/u5PFq.CBA9VN4aVSZ2jpEtXas9iPNB4mQs92m', '5', NULL, NULL, 0, NULL),
(78, '2021/ASB/07', 'dlokaraja@gmail.com', '$2b$10$S/6bAvo5mt/tAe04Y7H6E.cZ24pHzE.PHlEX6Fx.49SaOzEOpuDeq', '5', NULL, NULL, 0, NULL),
(79, '2021/ASB/08', 'tpavani@gmail.com', '$2b$10$1BPdeGxnK2N1qbp/4Gfj7eT9veoARsGl/YZrD7lGW18dCr/3rOz6i', '5', NULL, NULL, 0, NULL),
(80, '2021/ASB/09', 'granapathi@gmail.com', '$2b$10$MMHN1O69EhxOY6bOiulL.uKbFLq0LIkS.dYK19ZCTW6/2gfOarDhq', '5', NULL, NULL, 0, NULL),
(81, '2021/ASB/10', 'tsagarika@gmail.com', '$2b$10$OX4UZ5Pq4g1leY11sHh5bO5Us9kPJFjmITHy9457TdvDApDYxjJCC', '5', NULL, NULL, 0, NULL),
(82, '2021/ASB/12', 'skarunarathna@gmail.com', '$2b$10$TiqOi50nHd5trc0qfwOrEuEbDjcHq.gD3k97d5VuAidK6caM8S.NO', '5', NULL, NULL, 0, NULL),
(83, '2020/ASB/01', 'lkumari@gmail.com', '$2b$10$Xke7ryaJflxMnWUaVxh7DeHCfxYrfKSFvr4ZWchRXbOfZLHZrbwVm', '5', NULL, NULL, 0, NULL),
(84, '2020/ASB/02', 'gdharmapriya@gmail.com', '$2b$10$gufcSWlCckMJ/4TcoEpALedFEf/7p4Y8dXwNSSJVc9.hORsp.wS12', '5', NULL, NULL, 0, NULL),
(85, '2020/ASB/03', 'lsanduni@gmail.com', '$2b$10$9Q4GrdGlVKvbXqFYVMo93ODq3yB/DeolXDsMqhi6S1fgl.WL5syji', '5', NULL, NULL, 0, NULL),
(86, '2020/ASB/05', 'gdassanayaka1@gmail.com', '$2b$10$1pFDm4ihhZAnAAWLENABGeDpeXS1FNYZaj5njIgygbS5UD3AM1LDK', '5', NULL, NULL, 0, NULL),
(87, '2020/ASB/06', 'tranimika@gmail.com', '$2b$10$/yM23Ejf5IyMLh0slKRzcepsj5LAa6R9/qQayHUtohfiJ74385hqO', '5', NULL, NULL, 0, NULL),
(88, '2020/ASB/07', 'dselvam@gmail.com', '$2b$10$FuZMSIkpEuWNVeAep6IfFO8l3eKkogapj5frSAP7MFz2mXQ36UgeG', '5', NULL, NULL, 0, NULL),
(89, '2020/ASB/08', 'khettigoda@gmail.com', '$2b$10$ZdqirPoAeegu5XOCCzwCSuZaGl2uYhDiFtcg3.dPGi9f9HiHmoNj.', '5', NULL, NULL, 0, NULL),
(90, '2020/ASB/09', 'rrajapaksha@gmail.com', '$2b$10$hbGmCDbYW0iEeJuzx3dsKObl7MMs./A26DRbNm2rLf3wSreoECoHC', '5', NULL, NULL, 0, NULL),
(91, '2020/ASB/10', 'tniwandana@gmail.com', '$2b$10$Zm2a1cUCxp.vkn8oJ1xr2eNbAZyb0oOTvkg9lGDyoczI9qp.XANtS', '5', NULL, NULL, 0, NULL),
(92, '2020/ASB/12', 'rsenarathna@gmail.com', '$2b$10$xqsoo8ne5PTqjHhkHVOk5ud6TcmeRuXNiFvvCxyuz/6XXUHnQfmJq', '5', NULL, NULL, 0, NULL),
(93, '2019/ASP/01', 'lhariharan@gmail.com', '$2b$10$cQBUkzwNzVIm3StMQis0HOX8dPPAteMR0A0rNcHXtM/52x5eP9lwW', '5', NULL, NULL, 0, NULL),
(94, '2019/ASP/02', 'tvartheeswaran@gmail.com', '$2b$10$WW6uuKdWv0G/QZ/E8D9OFu/I82FdKWCTQmm4FSURWEKjoiwlRRdGO', '5', NULL, NULL, 0, NULL),
(95, '2019/ASP/03', 'vvaraniya@gmail.com', '$2b$10$y9mpQ0CJLMbFCL0LXr.OY.YbUd4YfJzWVW9Yq2qbn1kCXWqgsjeL6', '5', NULL, NULL, 0, NULL),
(96, '2019/ASP/04', 'filma@gmail.com', '$2b$10$weXduIOIWHh2NP9yFugVuuD6gJNnLRPTFLZulcMrOL2tAE/tKJ6MS', '5', NULL, NULL, 0, NULL),
(97, '2019/ASP/08', 'kalwis@gmail.com', '$2b$10$AiTVMIA515Oa8XVQISVAbe5B1ZX2txX77PXE78.HzDNdbnzNpGeJi', '5', NULL, NULL, 0, NULL),
(98, '2019/ASP/15', 'cthanusiga@gmail.com', '$2b$10$3/RLbPPvrnmvytsBspaL6OLBVeBMI4ydfdXkZq9dpTxaSkcyYApiC', '5', NULL, NULL, 0, NULL),
(99, '2019/ASP/17', 'bushanthika@gmail.com', '$2b$10$gNuT09czYZpBRkk1g/dUBewoqHtFqOGvO/Md56CUqyUegbVnAPU0O', '5', NULL, NULL, 0, NULL),
(100, '2019/ASP/21', 'mkumari@gmail.com', '$2b$10$7hTjllKFlS9QoO0hiri4A.EINvpWisGdAaocdRPxHl.PcJDZuk04G', '5', NULL, NULL, 0, NULL),
(101, '2019/ASP/24', 'pnivithashini@gmail.com', '$2b$10$RT0Nm4qLvBb9TRqIcMhZb.ysc1KIc1nLhj3qh1udtSnjtjsmQYmom', '5', NULL, NULL, 0, NULL),
(102, '2019/ASP/29', 'bkobika@gmail.com', '$2b$10$aJN8.HciWOdcgADvH.MLiuVAmkBxkcwKJXtVCq8XnzkuCZup1ffRW', '5', NULL, NULL, 0, NULL),
(103, '2022/TICT/01', 'ysooriyaarachchi@gmail.com', '$2b$10$gOQomAI3uqTxyM8G3XCcuuyL8LH71YwAUToObhnDho3E8KdoOgUN2', '5', NULL, NULL, 0, NULL),
(104, '2022/TICT/02', 'rdarmadasa@gmail.com', '$2b$10$DY60OL9LSOaM8k5.bdT2uubRYpE6AjsXrBPK0R8I8e5pLJxmCRgYi', '5', NULL, NULL, 0, NULL),
(105, '2022/TICT/03', 'dgayani@gmail.com', '$2b$10$./2YFtPiI7NOetefAH4r1eDGHFe3Q0OpJ1sT9xcM6FTMWgCKslG7q', '5', NULL, NULL, 0, NULL),
(106, '2022/TICT/04', 'gpalliyaguru@gmail.com', '$2b$10$Gs/acUJffd5gv7S3L0JHRO/MnN4b.06zVe7XCoafwG6lNGWOmHpyO', '5', NULL, NULL, 0, NULL),
(107, '2022/TICT/05', 'dpiyumika@gmail.com', '$2b$10$WZprdRElEU9Dsvm5xW2Eue4lh/B8FL/77CY8jtlTwMdsoCO1lb3Xq', '5', NULL, NULL, 0, NULL),
(108, '2022/TICT/06', 'dranathunga@gmail.com', '$2b$10$u8sLf8gT02.hW3KfHX7S9eWFF.X9jkfYKmoem9q9ysc94/C7R5EgO', '5', NULL, NULL, 0, NULL),
(109, '2022/TICT/07', 'skarunathilaka@gmail.com', '$2b$10$VwdvLg9gM/kdtNEkF7NOgeXoDUaor7J.8EHRzGhhHC3Y9aThoNuyC', '5', NULL, NULL, 0, NULL),
(110, '2022/TICT/08', 'tjayasinha@gmail.com', '$2b$10$ugiZs6LROWK24XzyKes/nOGWCGoYc6hryuXYf09ncO5Ns99rIkqwK', '5', NULL, NULL, 0, NULL),
(111, '2022/TICT/9', 'fkalani@gmail.com', '$2b$10$NqeBzZGQNm0ZPyp94lwvNulR7rUDO1cura66tXOyn5xb1aIEAXPCm', '5', NULL, NULL, 0, NULL),
(112, '2022/TICT/11', 'rlsenarathna@gmail.com', '$2b$10$YrwwaKmA3DjwcYuSCF5JoOoXaSbNv9qCOB2RlN5xufpLzf1i/0jEW', '5', NULL, NULL, 0, NULL),
(113, '2021/TICT/01', 'jdarmikam@gmail.com', '$2b$10$RA9Q30rxyThse4U16K0Bq.yzsa3.FfPfeUB8U0jZgXnbyNLkjAsKi', '5', NULL, NULL, 0, NULL),
(114, '2021/TICT/02', 'gperera@gmail.com', '$2b$10$T9YxuQTOXqD2fYS2nZzCVe1wXTgXz4t8h8JFi4f8iXDW8e4Wa4VpG', '5', NULL, NULL, 0, NULL),
(115, '2021/TICT/03', 'stanaka@gmail.com', '$2b$10$GZdhQu9B/qYi3di2BJAoP.tVUZM/siRgfVdAT0.avaKhVflH0h6RW', '5', NULL, NULL, 0, NULL),
(116, '2021/TICT/04', 'rmdassanayaka@gmail.com', '$2b$10$0jA0VFh1QcEuyaidfLXMT.GeoSuOm0G2GMuZm6kCvhWr4fQltgZWu', '5', NULL, NULL, 0, NULL),
(117, '2021/TICT/06', 'tsshanika@gmail.com', '$2b$10$HLxOH0rqZSAkt1st977L0.97dK07LDK6vXEdDM3x.vV6WOoVQve3u', '5', NULL, NULL, 0, NULL),
(118, '2021/TICT/07', 'dc1ranasinha@gmail.com', '$2b$10$SLHO5dtp7O6utgbkHb8RTuiHpbiwczQb58eDUo2NP7z3VTP1KiLsm', '5', NULL, NULL, 0, NULL),
(119, '2021/TICT/08', 'kamihirani@gmail.com', '$2b$10$4lZoqihhCEHvejM5MK9SNuUJZdUSw4SyA4bW90XDQ1sWS/YZYAYBC', '5', NULL, NULL, 0, NULL),
(120, '2021/TICT/09', 'tnrajapaksha', '$2b$10$V1zB.DJpCM3mJIRX2j3qou9v3F59BNYab9JbAB1j2pXAuoZGiO8te', '5', NULL, NULL, 0, NULL),
(121, '2021/TICT/10', 'tujayasiri@gmail.com', '$2b$10$0KYmVCsgZGfyh055XxJ23ubuy9HId2pVuqhxw9zUwkCJE7yO2loAO', '5', NULL, NULL, 0, NULL),
(122, '2021/TICT/11', 'rlbsenarathna@gmail.com', '$2b$10$ODYqeF5PEVzThqh9/oJUROcdlftXuPjRLVmEI1i/rFtmvwZiVaBjq', '5', NULL, NULL, 0, NULL),
(123, 'svadivel@vau.ac.lk', 'svadivel@gmail.com', '$2b$10$mS8bhHqntIOxpm0Or9LJhOb0arT9fXspS0yVaKCU.GVZcxJW0vUBm', '4', NULL, NULL, 0, NULL),
(124, 'jfernando@vau.ac.lk', 'jfernando@gmail.com', '$2b$10$51k8NNI/eimpYJKerHVBZOXPk1K8tkyt1/yO0bDi.P4TkpYY7Qy5i', '4', NULL, NULL, 0, NULL),
(125, 'srajesh@vau.ac.lk', 'srajesh@gmail.com', '$2b$10$aaFfvVcaiijBaq0GWUmz0ehOJEGGbWOYylDr8SbC14yPtyd/yU9MO', '4', NULL, NULL, 0, NULL),
(126, 'tanuradha@vau.ac.lk', 'tanuradha@gmail.com', '$2b$10$r2NXOqkjKf0x./N9DLa6QuzMIbTgqeIg6H6rflSNdbM4LpjyNpvni', '4', NULL, NULL, 0, NULL),
(127, 'nsivakumar@vau.ac.lk', 'nsivakumar@gmail.com', '$2b$10$jgFUkNuoXiR8n1nxUrkHuukjBGYtq5YLmCkPGlciuybfgFPHk3A42', '4', NULL, NULL, 0, NULL),
(137, 'v', 'v', '$2b$10$JVwXxjHQ8.ECfQwE7JYHWu17lsiMpVJzn4cJACerwXWIUKj22VisS', '2', NULL, NULL, 0, NULL),
(138, 'v', 'v', '$2b$10$Nj2MGA7dbnuALUfS9LQn1eZ5mt3hQC2EeyMVZaTTP3ysvdHP1tPyS', '2', NULL, NULL, 0, NULL),
(139, '2019/ASB/03', 'mohamedasfhaq1999@gmail.com', '$2b$10$Ml/Nypvd2c7NKtQj59VaN.G6pq3XsmxioSTYsITHge6juQfvHpIZy', '5', NULL, NULL, 0, NULL),
(140, '2020/ICT/119', 'zzzahrannnldeen2@gmail.commm', '$2b$10$2xr9KDlt5nAssbq8gP0yJO5Zy.mM1h2qxVx1PVQcq0m5sUvQZHEMO', '5', '7ed7c8c7b8ffad13afbb131a99ab20376c8bf8c49ccf625be991dfef8a57792b', '2025-01-19 01:57:17', 6, '2025-01-19 01:58:06'),
(141, '2022/ICT/14', 'Kamaal123@gmail.com', '$2b$10$oTahzYlAPCkgSA9FHOq6h.zVQB5sKDhiDDP9aEh5PdFYigPtntc.y', '5', NULL, NULL, 0, NULL),
(142, '2022/ICT/15', 'romee7@gmail.com', '$2b$10$yt2M0c.uVvPJLrRC.Jvdje6AgjydpIUmd.B37RfwwSk3/AW86kCvW', '5', NULL, NULL, 0, NULL),
(143, 'waseem@vau.ac.lk', 'waseem@gmail.com', '$2b$10$kqUrlyJ3qQYOI7Qi/9Nvf.ldlcCbEju96INyLWJqovXr/VDVIKWf6', '4', NULL, NULL, 0, NULL),
(144, '23534545', '2020ict119@vau.jfn.ac.lk', '$2b$10$vby8SD/WUdDg5nx1ZNY/9.VOMeMx/KQs6Giflv7DH/i3P50KM6YiC', '5', NULL, NULL, 0, NULL),
(145, 'wererer', 'wrewer@dg.v', '$2b$10$b/M0W.p48V4bvxy0/1JZDeEaX5pHBOD4SgZLn13bN3Ps53u6wH8du', '5', NULL, NULL, 0, NULL),
(150, '222222', 'zzzahrannnldeen@gmail.com', '$2b$10$WAXLamE6eFXX1LuYoP/Txe3YBARPYUJb3nwRNL2qdMG4GukSwJFPO', '5', NULL, NULL, 0, NULL),
(151, '3', 'zahranliyasdeen@gmail.com', '$2b$10$Vnz/f.vdYbPTgTBp8lxyxuDp9p6X6Vu9wx/FN2ni27b0qStTolxpa', '5', NULL, NULL, 0, NULL),
(152, '4', 'zzzahrannnldeen2@gmail.com', '$2b$10$x0hqMF/rhcFg2lNa3yjPZOVL0xW/TH3u4esn4.fSwNpNZg1k4eUlm', '5', NULL, NULL, 0, NULL),
(154, '55', '55@5.5', '$2b$10$LDtNk2gcuSqLb7xKnC2BquvRkUuCJuNM.peR7yyHLHQDY8ZthSqwS', '4', NULL, NULL, 0, NULL),
(155, 'sdfdf', 'sdfdf', '$2b$10$HPM82v2KnUqaR0K7p1yfKur0r./e/jb7yFhb94G0rmj6T5QKiZBY2', '2', NULL, NULL, 0, NULL),
(156, '1@1.1hgh', '1@1.1hgh', '$2b$10$I9TD6WZRt/.LHg0XZ2bN..ZxiLNlk6S1/ATfxFpMABcGCxp5/PSJC', '2', NULL, NULL, 0, NULL),
(159, 'dfhgfh', 'dfhgfh', '$2b$10$xYYzZxd0xiX69s/1cCsgJ.UkS82owqCAdNq715nFdPMqm/FbpG3Zm', '2', NULL, NULL, 0, NULL),
(161, 'd@nm.b', 'd@nm.b', '$2b$10$cdfTpvcCxOez.8qKQxnt3OpgU4auY./dqKpDqqBTYN9/zDAsoN0Vu', '2', NULL, NULL, 0, NULL),
(162, 'dfdf@v.m', 'dfdf@v.m', '$2b$10$Wvr3lEm2GfYlz/Wa1CS9l.gcK9Y8WfoDv5USMw.CPalkqKykXbgC6', '2', NULL, NULL, 0, NULL),
(163, '453', 'zahranliyasdeendsfdsf@gmail.com', '$2b$10$z0x6/Wa5NVTJbasGzbcS6.P8OAkXlRRaOALNnfqRtlzZ063MHz4mS', '5', NULL, NULL, 0, NULL),
(164, 'ty4', 'zzzahrannnldeen2sddfdf@gmail.com', '$2b$10$Mx9guNLQyDVP6blYWqwEmOC6AF1PZlHlMy2HPvCVTazn8.SYu8wm6', '5', NULL, NULL, 0, NULL),
(165, 'wredrfded', 'fdgf', '$2b$10$eHuUUp6c3v7O8geRV/03veJCZGtslMEpMI4oRkPJk0ibSUHsw3tbO', '5', NULL, NULL, 0, NULL),
(167, 'admin', 'admin@admin.com', '$2b$10$QT09VD8N7t.sQNNP6PqAkeWxR/Yci2SXiWevM2Ly1ehq8tAObG1zu', '1', NULL, NULL, 0, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_log`
--
ALTER TABLE `admin_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admission`
--
ALTER TABLE `admission`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_admission_batch_id` (`batch_id`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_attendance_batch_id` (`batch_id`);

--
-- Indexes for table `batch`
--
ALTER TABLE `batch`
  ADD PRIMARY KEY (`batch_id`),
  ADD KEY `fk_batch_deg_id` (`deg_id`);

--
-- Indexes for table `batch_17_students`
--
ALTER TABLE `batch_17_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_18_students`
--
ALTER TABLE `batch_18_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_19_students`
--
ALTER TABLE `batch_19_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_19_sub_13`
--
ALTER TABLE `batch_19_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_19_sub_14`
--
ALTER TABLE `batch_19_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_19_sub_15`
--
ALTER TABLE `batch_19_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_20_students`
--
ALTER TABLE `batch_20_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_20_sub_13`
--
ALTER TABLE `batch_20_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_20_sub_14`
--
ALTER TABLE `batch_20_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_20_sub_15`
--
ALTER TABLE `batch_20_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_21_students`
--
ALTER TABLE `batch_21_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_21_sub_13`
--
ALTER TABLE `batch_21_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_21_sub_14`
--
ALTER TABLE `batch_21_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_21_sub_15`
--
ALTER TABLE `batch_21_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_22_students`
--
ALTER TABLE `batch_22_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_22_sub_13`
--
ALTER TABLE `batch_22_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_22_sub_14`
--
ALTER TABLE `batch_22_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_22_sub_15`
--
ALTER TABLE `batch_22_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_23_students`
--
ALTER TABLE `batch_23_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_23_sub_13`
--
ALTER TABLE `batch_23_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_23_sub_14`
--
ALTER TABLE `batch_23_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_23_sub_15`
--
ALTER TABLE `batch_23_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_24_students`
--
ALTER TABLE `batch_24_students`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `batch_24_sub_13`
--
ALTER TABLE `batch_24_sub_13`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_24_sub_14`
--
ALTER TABLE `batch_24_sub_14`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_24_sub_15`
--
ALTER TABLE `batch_24_sub_15`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `s_id` (`s_id`);

--
-- Indexes for table `batch_curriculum_lecturer`
--
ALTER TABLE `batch_curriculum_lecturer`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_batch_curriculum_lecturer_m_id` (`m_id`),
  ADD KEY `fk_batch_curriculum_lecturer_sub_id` (`sub_id`),
  ADD KEY `fk_batch_curriculum_lecturer_batch_id` (`batch_id`);

--
-- Indexes for table `batch_time_periods`
--
ALTER TABLE `batch_time_periods`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `batch_id` (`batch_id`,`user_type`);

--
-- Indexes for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD PRIMARY KEY (`sub_id`),
  ADD KEY `fk_curriculam_deg_id` (`deg_id`);

--
-- Indexes for table `degree`
--
ALTER TABLE `degree`
  ADD PRIMARY KEY (`deg_id`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`d_id`),
  ADD KEY `fk_department_user_id` (`user_id`);

--
-- Indexes for table `dep_deg`
--
ALTER TABLE `dep_deg`
  ADD PRIMARY KEY (`d_id`,`deg_id`),
  ADD KEY `fk_dep_deg_deg_id` (`deg_id`);

--
-- Indexes for table `eligibility_log`
--
ALTER TABLE `eligibility_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_eligibility_log_user_id` (`user_id`),
  ADD KEY `fk_eligibility_log_s_id` (`s_id`),
  ADD KEY `fk_eligibility_log_sub_id` (`sub_id`);

--
-- Indexes for table `entry_summary`
--
ALTER TABLE `entry_summary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_entry_summary_s_id` (`s_id`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`f_id`),
  ADD KEY `fk_faculty_user_id` (`user_id`);

--
-- Indexes for table `fac_dep`
--
ALTER TABLE `fac_dep`
  ADD PRIMARY KEY (`f_id`,`d_id`),
  ADD KEY `fk_fac_dep_d_id` (`d_id`);

--
-- Indexes for table `manager`
--
ALTER TABLE `manager`
  ADD PRIMARY KEY (`m_id`,`user_id`),
  ADD KEY `fk_manager_user_id` (`user_id`);

--
-- Indexes for table `manager_detail`
--
ALTER TABLE `manager_detail`
  ADD PRIMARY KEY (`m_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`s_id`,`user_id`),
  ADD KEY `fk_student_user_id` (`user_id`);

--
-- Indexes for table `students_log`
--
ALTER TABLE `students_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_student_log_user_id` (`user_id`);

--
-- Indexes for table `student_detail`
--
ALTER TABLE `student_detail`
  ADD PRIMARY KEY (`s_id`),
  ADD KEY `fk_student_detail_f_id` (`f_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `fk_user_role_id` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_log`
--
ALTER TABLE `admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=315;

--
-- AUTO_INCREMENT for table `admission`
--
ALTER TABLE `admission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `batch`
--
ALTER TABLE `batch`
  MODIFY `batch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `batch_17_students`
--
ALTER TABLE `batch_17_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `batch_18_students`
--
ALTER TABLE `batch_18_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `batch_19_students`
--
ALTER TABLE `batch_19_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_19_sub_13`
--
ALTER TABLE `batch_19_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_19_sub_14`
--
ALTER TABLE `batch_19_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_19_sub_15`
--
ALTER TABLE `batch_19_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_20_students`
--
ALTER TABLE `batch_20_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_20_sub_13`
--
ALTER TABLE `batch_20_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_20_sub_14`
--
ALTER TABLE `batch_20_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_20_sub_15`
--
ALTER TABLE `batch_20_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_21_students`
--
ALTER TABLE `batch_21_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_21_sub_13`
--
ALTER TABLE `batch_21_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_21_sub_14`
--
ALTER TABLE `batch_21_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_21_sub_15`
--
ALTER TABLE `batch_21_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_22_students`
--
ALTER TABLE `batch_22_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_22_sub_13`
--
ALTER TABLE `batch_22_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_22_sub_14`
--
ALTER TABLE `batch_22_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_22_sub_15`
--
ALTER TABLE `batch_22_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_23_students`
--
ALTER TABLE `batch_23_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_23_sub_13`
--
ALTER TABLE `batch_23_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_23_sub_14`
--
ALTER TABLE `batch_23_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_23_sub_15`
--
ALTER TABLE `batch_23_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batch_24_students`
--
ALTER TABLE `batch_24_students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `batch_24_sub_13`
--
ALTER TABLE `batch_24_sub_13`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `batch_24_sub_14`
--
ALTER TABLE `batch_24_sub_14`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `batch_24_sub_15`
--
ALTER TABLE `batch_24_sub_15`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `batch_curriculum_lecturer`
--
ALTER TABLE `batch_curriculum_lecturer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=399;

--
-- AUTO_INCREMENT for table `batch_time_periods`
--
ALTER TABLE `batch_time_periods`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=425;

--
-- AUTO_INCREMENT for table `curriculum`
--
ALTER TABLE `curriculum`
  MODIFY `sub_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `degree`
--
ALTER TABLE `degree`
  MODIFY `deg_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `d_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `eligibility_log`
--
ALTER TABLE `eligibility_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `entry_summary`
--
ALTER TABLE `entry_summary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `faculty`
--
ALTER TABLE `faculty`
  MODIFY `f_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `manager_detail`
--
ALTER TABLE `manager_detail`
  MODIFY `m_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `students_log`
--
ALTER TABLE `students_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `student_detail`
--
ALTER TABLE `student_detail`
  MODIFY `s_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=168;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admission`
--
ALTER TABLE `admission`
  ADD CONSTRAINT `fk_admission_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`);

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `fk_attendance_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`);

--
-- Constraints for table `batch`
--
ALTER TABLE `batch`
  ADD CONSTRAINT `fk_batch_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`);

--
-- Constraints for table `batch_curriculum_lecturer`
--
ALTER TABLE `batch_curriculum_lecturer`
  ADD CONSTRAINT `fk_batch_curriculum_lecturer_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`),
  ADD CONSTRAINT `fk_batch_curriculum_lecturer_m_id` FOREIGN KEY (`m_id`) REFERENCES `manager_detail` (`m_id`),
  ADD CONSTRAINT `fk_batch_curriculum_lecturer_sub_id` FOREIGN KEY (`sub_id`) REFERENCES `curriculum` (`sub_id`);

--
-- Constraints for table `batch_time_periods`
--
ALTER TABLE `batch_time_periods`
  ADD CONSTRAINT `fk_batch_time_periods_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`);

--
-- Constraints for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD CONSTRAINT `fk_curriculam_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`);

--
-- Constraints for table `department`
--
ALTER TABLE `department`
  ADD CONSTRAINT `fk_department_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `dep_deg`
--
ALTER TABLE `dep_deg`
  ADD CONSTRAINT `fk_dep_deg_d_id` FOREIGN KEY (`d_id`) REFERENCES `department` (`d_id`),
  ADD CONSTRAINT `fk_dep_deg_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`);

--
-- Constraints for table `eligibility_log`
--
ALTER TABLE `eligibility_log`
  ADD CONSTRAINT `fk_eligibility_log_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`),
  ADD CONSTRAINT `fk_eligibility_log_sub_id` FOREIGN KEY (`sub_id`) REFERENCES `curriculum` (`sub_id`),
  ADD CONSTRAINT `fk_eligibility_log_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `entry_summary`
--
ALTER TABLE `entry_summary`
  ADD CONSTRAINT `fk_entry_summary_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`);

--
-- Constraints for table `faculty`
--
ALTER TABLE `faculty`
  ADD CONSTRAINT `fk_faculty_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `fac_dep`
--
ALTER TABLE `fac_dep`
  ADD CONSTRAINT `fk_fac_dep_d_id` FOREIGN KEY (`d_id`) REFERENCES `department` (`d_id`),
  ADD CONSTRAINT `fk_fac_dep_f_id` FOREIGN KEY (`f_id`) REFERENCES `faculty` (`f_id`);

--
-- Constraints for table `manager`
--
ALTER TABLE `manager`
  ADD CONSTRAINT `fk_manager_m_id` FOREIGN KEY (`m_id`) REFERENCES `manager_detail` (`m_id`),
  ADD CONSTRAINT `fk_manager_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `fk_student_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`),
  ADD CONSTRAINT `fk_student_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `students_log`
--
ALTER TABLE `students_log`
  ADD CONSTRAINT `fk_student_log_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- Constraints for table `student_detail`
--
ALTER TABLE `student_detail`
  ADD CONSTRAINT `fk_student_detail_f_id` FOREIGN KEY (`f_id`) REFERENCES `faculty` (`f_id`);

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `fk_user_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
