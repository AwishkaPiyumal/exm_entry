GRANT EXECUTE ON exam_entry.* TO 'student'@'%';
GRANT EXECUTE ON exam_entry.* TO 'manager'@'%';
GRANT EXECUTE ON exam_entry.* TO 'hod'@'%';
GRANT EXECUTE ON exam_entry.* TO 'dean'@'%';
GRANT EXECUTE ON exam_entry.* TO 'guest'@'%';
GRANT EXECUTE ON exam_entry.* TO 'admin'@'%';

DELIMITER $$
CREATE DEFINER=CURRENT_USER@`%` PROCEDURE `AddMedicalResitStudents`(
    IN `p_batch_id` INT, 
    IN `p_sub_id` INT, 
    IN `p_s_id` INT, 
    IN `p_exam_type` VARCHAR(50)
)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddNewBatchStudentColumns`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddStudentsToBatch`(IN `p_batch_id` INT, IN `p_new_students` TEXT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ApplyExam`(
    IN `p_user_id` INT, 
    IN `p_removed_subjects` VARCHAR(255), -- Comma-separated subject IDs to skip
    OUT `out_batch_id` INT
)
ae:BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckForDuplicateDegree`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_deg_id` INT, OUT `p_exists` INT)
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM degree
    WHERE (deg_name = p_deg_name OR short = p_short) AND deg_id != p_deg_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfDegreeExists`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), OUT `p_exists` INT)
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM degree
    WHERE deg_name = p_deg_name OR short = p_short;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfDepartmentExists`(IN `p_d_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM department d
    LEFT JOIN user u ON d.user_id = u.user_id
    WHERE d.d_name = p_d_name OR u.user_name = p_email OR u.email = p_email;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIfFacultyExists`(IN `p_f_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)
BEGIN
    SELECT COUNT(*) INTO p_exists
    FROM faculty f
    LEFT JOIN user u ON f.user_id = u.user_id
    WHERE f.f_name = p_f_name OR u.user_name = p_email;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckIndexNoExists`(IN `p_index_no` VARCHAR(255), OUT `p_exists` BOOLEAN)
BEGIN
    IF p_index_no = '' THEN
        SELECT FALSE INTO p_exists; 
    ELSE
        SELECT EXISTS (SELECT 1 FROM student_detail WHERE index_num = p_index_no) INTO p_exists;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckSubjectExist`(IN `p_batch_id` INT(11), IN `p_sub_id` INT(11), IN `p_user_id` INT(11), OUT `p_exists` BOOLEAN)
BEGIN
    SELECT COUNT(*) > 0 INTO p_exists 
    FROM batch_curriculum_lecturer bcl 
    JOIN manager m
    ON bcl.m_id=m.m_id
    WHERE bcl.batch_id = p_batch_id AND bcl.sub_id = p_sub_id AND m.user_id=p_user_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CheckUserExists`(IN `p_user_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` BOOLEAN)
BEGIN
    SELECT COUNT(*) > 0 INTO p_exists 
    FROM user 
    WHERE user_name = p_user_name OR email = p_email;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBatchStudentsTable`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateBatchSubjectTables`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateCurriculum`(IN `p_sub_code` VARCHAR(100), IN `p_sub_name` VARCHAR(150), IN `p_sem_no` INT, IN `p_deg_id` INT, IN `p_level` INT, IN `p_status` VARCHAR(50))
BEGIN
    INSERT INTO curriculum (sub_code, sub_name, sem_no, deg_id, level, status)
    VALUES (p_sub_code, p_sub_name, p_sem_no, p_deg_id, p_level, p_status);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDegree`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_levels` VARCHAR(255), IN `p_no_of_sem_per_year` VARCHAR(10), IN `p_status` VARCHAR(50), OUT `p_deg_id` INT)
BEGIN
    INSERT INTO degree(deg_name, short, levels, no_of_sem_per_year, status)
    VALUES (p_deg_name, p_short, p_levels, p_no_of_sem_per_year, p_status);
    SET p_deg_id = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDepartment`(IN `p_d_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50), OUT `p_d_id` INT)
BEGIN
    INSERT INTO department(d_name, user_id, contact_no, status)
    VALUES (p_d_name, p_user_id, p_contact_no, p_status);
    SET p_d_id = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateDepartmentUser`(IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)
BEGIN
    INSERT INTO user(user_name, email, password, role_id)
    VALUES (p_email, p_email, p_password, '3');
    SET p_user_id = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateFaculty`(IN `p_f_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50))
BEGIN
    INSERT INTO faculty (f_name, user_id, contact_no, status)
    VALUES (p_f_name, p_user_id, p_contact_no, p_status);
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateFacultyUser`(IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)
BEGIN
    INSERT INTO user(user_name, email, password, role_id)
    VALUES (p_email, p_email, p_password, '2');
    
    SET p_user_id = LAST_INSERT_ID();
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateNewBatchSubjectTables`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBatchCurriculumLecturerRows`(IN `p_batch_id` INT)
BEGIN
    DELETE FROM batch_curriculum_lecturer WHERE batch_id = p_batch_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteBatchSubjectEntries`(IN `p_batch_id` INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DropOldBatchTablesAndColumns`(IN `p_batch_id` INT, IN `p_old_subjects` JSON)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentEligibilityByBatchIdAndSId`(IN `p_batch_id` INT, IN `p_s_id` INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentWithSubjectsByUserId`(IN `batch_id` INT, IN `user_id` INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FetchStudentsWithSubjects`(IN `p_batch_id` INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `FillProperSummary`(IN p_batch_id INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerateIndexNumbers`(IN `p_batch_id` INT, IN `p_course` VARCHAR(50), IN `p_batch` VARCHAR(50), IN `p_startsFrom` INT)
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveBatches`(IN `p_deg_id` INT)
BEGIN
    SET @query = CONCAT(
        'SELECT b.batch_id, b.batch_code FROM batch b INNER JOIN admission a ON b.batch_id=a.batch_id WHERE b.deg_id = ',p_deg_id,'  AND b.status = ''true'' ORDER BY b.batch_code DESC'
    );
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveBatchesWithinDeadline`(IN `p_deg_id` INT, IN `p_role_id` VARCHAR(50))
BEGIN
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
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDegrees`(`department_ids` TEXT)
BEGIN
    SET @query = CONCAT('SELECT deg_id, short FROM dep_deg WHERE d_id IN (', department_ids, ') AND status = ''true''');
    PREPARE stmt FROM @query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDegreesInDepartment`(IN `p_d_id` INT)
BEGIN
    SELECT 
        deg.deg_id,
        deg.deg_name,
        deg.levels,
        deg.short
    FROM degree deg
    LEFT JOIN dep_deg dd ON deg.deg_id = dd.deg_id
    WHERE dd.d_id = p_d_id AND deg.status = 'true';
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetActiveDepartmentsWithDegreesCount`(IN `p_f_id` INT)
BEGIN
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
DELIMITER ;