-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: exam_entry
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `exam_entry`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `exam_entry` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `exam_entry`;

--
-- Table structure for table `admin_log`
--

DROP TABLE IF EXISTS `admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_log`
--

LOCK TABLES `admin_log` WRITE;
/*!40000 ALTER TABLE `admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `admission`
--

DROP TABLE IF EXISTS `admission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(11) NOT NULL,
  `generated_date` varchar(250) NOT NULL,
  `subject_list` varchar(250) NOT NULL,
  `exam_date` varchar(250) NOT NULL,
  `description` text NOT NULL,
  `instructions` text NOT NULL,
  `provider` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_admission_batch_id` (`batch_id`),
  CONSTRAINT `fk_admission_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admission`
--

LOCK TABLES `admission` WRITE;
/*!40000 ALTER TABLE `admission` DISABLE KEYS */;
/*!40000 ALTER TABLE `admission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(11) NOT NULL,
  `exam_date` varchar(250) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_attendance_batch_id` (`batch_id`),
  CONSTRAINT `fk_attendance_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch`
--

DROP TABLE IF EXISTS `batch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_code` varchar(100) NOT NULL,
  `deg_id` int(11) NOT NULL,
  `academic_year` varchar(50) NOT NULL,
  `level` int(11) NOT NULL,
  `sem` int(11) NOT NULL,
  `application_open` timestamp NOT NULL DEFAULT current_timestamp(),
  `description` varchar(500) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`batch_id`),
  KEY `fk_batch_deg_id` (`deg_id`),
  CONSTRAINT `fk_batch_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch`
--

LOCK TABLES `batch` WRITE;
/*!40000 ALTER TABLE `batch` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch_curriculum_lecturer`
--

DROP TABLE IF EXISTS `batch_curriculum_lecturer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_curriculum_lecturer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(11) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `m_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_batch_curriculum_lecturer_m_id` (`m_id`),
  KEY `fk_batch_curriculum_lecturer_sub_id` (`sub_id`),
  KEY `fk_batch_curriculum_lecturer_batch_id` (`batch_id`),
  CONSTRAINT `fk_batch_curriculum_lecturer_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`),
  CONSTRAINT `fk_batch_curriculum_lecturer_m_id` FOREIGN KEY (`m_id`) REFERENCES `manager_detail` (`m_id`),
  CONSTRAINT `fk_batch_curriculum_lecturer_sub_id` FOREIGN KEY (`sub_id`) REFERENCES `curriculum` (`sub_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_curriculum_lecturer`
--

LOCK TABLES `batch_curriculum_lecturer` WRITE;
/*!40000 ALTER TABLE `batch_curriculum_lecturer` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch_curriculum_lecturer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batch_time_periods`
--

DROP TABLE IF EXISTS `batch_time_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batch_time_periods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` int(11) NOT NULL,
  `user_type` enum('5','4','3','2') NOT NULL,
  `end_date` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `mail_sent` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `batch_id` (`batch_id`,`user_type`),
  CONSTRAINT `fk_batch_time_periods_batch_id` FOREIGN KEY (`batch_id`) REFERENCES `batch` (`batch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batch_time_periods`
--

LOCK TABLES `batch_time_periods` WRITE;
/*!40000 ALTER TABLE `batch_time_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `batch_time_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `curriculum`
--

DROP TABLE IF EXISTS `curriculum`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `curriculum` (
  `sub_id` int(11) NOT NULL AUTO_INCREMENT,
  `sub_code` varchar(100) NOT NULL,
  `sub_name` varchar(150) NOT NULL,
  `sem_no` int(2) NOT NULL,
  `deg_id` int(11) NOT NULL,
  `level` int(3) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`sub_id`),
  KEY `fk_curriculam_deg_id` (`deg_id`),
  CONSTRAINT `fk_curriculam_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `curriculum`
--

LOCK TABLES `curriculum` WRITE;
/*!40000 ALTER TABLE `curriculum` DISABLE KEYS */;
/*!40000 ALTER TABLE `curriculum` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `degree`
--

DROP TABLE IF EXISTS `degree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `degree` (
  `deg_id` int(11) NOT NULL AUTO_INCREMENT,
  `deg_name` varchar(500) NOT NULL,
  `short` varchar(50) NOT NULL,
  `levels` varchar(100) NOT NULL,
  `no_of_sem_per_year` varchar(10) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`deg_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `degree`
--

LOCK TABLES `degree` WRITE;
/*!40000 ALTER TABLE `degree` DISABLE KEYS */;
/*!40000 ALTER TABLE `degree` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dep_deg`
--

DROP TABLE IF EXISTS `dep_deg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dep_deg` (
  `d_id` int(11) NOT NULL,
  `deg_id` int(11) NOT NULL,
  PRIMARY KEY (`d_id`,`deg_id`),
  KEY `fk_dep_deg_deg_id` (`deg_id`),
  CONSTRAINT `fk_dep_deg_d_id` FOREIGN KEY (`d_id`) REFERENCES `department` (`d_id`),
  CONSTRAINT `fk_dep_deg_deg_id` FOREIGN KEY (`deg_id`) REFERENCES `degree` (`deg_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dep_deg`
--

LOCK TABLES `dep_deg` WRITE;
/*!40000 ALTER TABLE `dep_deg` DISABLE KEYS */;
/*!40000 ALTER TABLE `dep_deg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `department`
--

DROP TABLE IF EXISTS `department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `department` (
  `d_id` int(11) NOT NULL AUTO_INCREMENT,
  `d_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`d_id`),
  KEY `fk_department_user_id` (`user_id`),
  CONSTRAINT `fk_department_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `department`
--

LOCK TABLES `department` WRITE;
/*!40000 ALTER TABLE `department` DISABLE KEYS */;
/*!40000 ALTER TABLE `department` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `eligibility_log`
--

DROP TABLE IF EXISTS `eligibility_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `eligibility_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `exam` int(11) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `status_from` varchar(50) NOT NULL,
  `status_to` varchar(50) NOT NULL,
  `remark` text NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_eligibility_log_user_id` (`user_id`),
  KEY `fk_eligibility_log_s_id` (`s_id`),
  KEY `fk_eligibility_log_sub_id` (`sub_id`),
  CONSTRAINT `fk_eligibility_log_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`),
  CONSTRAINT `fk_eligibility_log_sub_id` FOREIGN KEY (`sub_id`) REFERENCES `curriculum` (`sub_id`),
  CONSTRAINT `fk_eligibility_log_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `eligibility_log`
--

LOCK TABLES `eligibility_log` WRITE;
/*!40000 ALTER TABLE `eligibility_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `eligibility_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entry_summary`
--

DROP TABLE IF EXISTS `entry_summary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entry_summary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `s_id` int(11) NOT NULL,
  `academic_year` varchar(50) NOT NULL,
  `level` int(11) NOT NULL,
  `sem` int(11) NOT NULL,
  `proper_subs` text DEFAULT NULL,
  `medical_subs` text DEFAULT NULL,
  `resit_subs` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_entry_summary_s_id` (`s_id`),
  CONSTRAINT `fk_entry_summary_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entry_summary`
--

LOCK TABLES `entry_summary` WRITE;
/*!40000 ALTER TABLE `entry_summary` DISABLE KEYS */;
/*!40000 ALTER TABLE `entry_summary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fac_dep`
--

DROP TABLE IF EXISTS `fac_dep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fac_dep` (
  `f_id` int(11) NOT NULL,
  `d_id` int(11) NOT NULL,
  PRIMARY KEY (`f_id`,`d_id`),
  KEY `fk_fac_dep_d_id` (`d_id`),
  CONSTRAINT `fk_fac_dep_d_id` FOREIGN KEY (`d_id`) REFERENCES `department` (`d_id`),
  CONSTRAINT `fk_fac_dep_f_id` FOREIGN KEY (`f_id`) REFERENCES `faculty` (`f_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fac_dep`
--

LOCK TABLES `fac_dep` WRITE;
/*!40000 ALTER TABLE `fac_dep` DISABLE KEYS */;
/*!40000 ALTER TABLE `fac_dep` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculty`
--

DROP TABLE IF EXISTS `faculty`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faculty` (
  `f_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`f_id`),
  KEY `fk_faculty_user_id` (`user_id`),
  CONSTRAINT `fk_faculty_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculty`
--

LOCK TABLES `faculty` WRITE;
/*!40000 ALTER TABLE `faculty` DISABLE KEYS */;
/*!40000 ALTER TABLE `faculty` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manager`
--

DROP TABLE IF EXISTS `manager`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager` (
  `m_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`m_id`,`user_id`),
  KEY `fk_manager_user_id` (`user_id`),
  CONSTRAINT `fk_manager_m_id` FOREIGN KEY (`m_id`) REFERENCES `manager_detail` (`m_id`),
  CONSTRAINT `fk_manager_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manager`
--

LOCK TABLES `manager` WRITE;
/*!40000 ALTER TABLE `manager` DISABLE KEYS */;
/*!40000 ALTER TABLE `manager` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `manager_detail`
--

DROP TABLE IF EXISTS `manager_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `manager_detail` (
  `m_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(500) NOT NULL,
  `contact_no` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`m_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `manager_detail`
--

LOCK TABLES `manager_detail` WRITE;
/*!40000 ALTER TABLE `manager_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `manager_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `role_id` varchar(50) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('1','admin'),('2','dean'),('3','hod'),('4','lecturer'),('5','student');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student`
--

DROP TABLE IF EXISTS `student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student` (
  `s_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  PRIMARY KEY (`s_id`,`user_id`),
  KEY `fk_student_user_id` (`user_id`),
  CONSTRAINT `fk_student_s_id` FOREIGN KEY (`s_id`) REFERENCES `student_detail` (`s_id`),
  CONSTRAINT `fk_student_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student`
--

LOCK TABLES `student` WRITE;
/*!40000 ALTER TABLE `student` DISABLE KEYS */;
/*!40000 ALTER TABLE `student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_detail`
--

DROP TABLE IF EXISTS `student_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_detail` (
  `s_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `index_num` varchar(50) NOT NULL,
  `contact_no` varchar(100) NOT NULL,
  `batch_ids` varchar(150) NOT NULL,
  `f_id` int(11) NOT NULL,
  `status` varchar(100) NOT NULL DEFAULT 'true',
  PRIMARY KEY (`s_id`),
  KEY `fk_student_detail_f_id` (`f_id`),
  CONSTRAINT `fk_student_detail_f_id` FOREIGN KEY (`f_id`) REFERENCES `faculty` (`f_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_detail`
--

LOCK TABLES `student_detail` WRITE;
/*!40000 ALTER TABLE `student_detail` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students_log`
--

DROP TABLE IF EXISTS `students_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `students_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `exam` int(11) NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_student_log_user_id` (`user_id`),
  CONSTRAINT `fk_student_log_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students_log`
--

LOCK TABLES `students_log` WRITE;
/*!40000 ALTER TABLE `students_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `students_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(250) NOT NULL,
  `email` varchar(500) NOT NULL,
  `password` varchar(250) NOT NULL,
  `role_id` varchar(50) NOT NULL,
  `reset_token` varchar(255) DEFAULT NULL,
  `token_expiration` timestamp DEFAULT current_timestamp(),
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_until` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`user_id`),
  KEY `fk_user_role_id` (`role_id`),
  CONSTRAINT `fk_user_role_id` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'exam_entry'
--

--
-- Dumping routines for database 'exam_entry'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddMedicalResitStudents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `AddMedicalResitStudents`(

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddNewBatchStudentColumns` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `AddNewBatchStudentColumns`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN

    DECLARE i INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE add_column_sql TEXT;



    SET add_column_sql = CONCAT('ALTER TABLE batch_', p_batch_id, '_students ');



    WHILE i < JSON_LENGTH(p_subjects) DO

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', i, '].sub_id')));



        IF i > 0 THEN

            SET add_column_sql = CONCAT(add_column_sql, ',');

        END IF;

        SET add_column_sql = CONCAT(add_column_sql, ' ADD COLUMN sub_', sub_id, ' VARCHAR(50) NOT NULL');

        

        SET i = i + 1;

    END WHILE;



    -- Execute add column SQL
    SET @stmt = add_column_sql;

    PREPARE stmt FROM @stmt;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `AddStudentsToBatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `AddStudentsToBatch`(IN `p_batch_id` INT, IN `p_new_students` TEXT)
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
SET @stmt = insert_query;

    PREPARE stmt FROM @stmt;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `ApplyExam` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `ApplyExam`(

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

    DECLARE student_deadline TIMESTAMP;

    DECLARE open_date TIMESTAMP;

    

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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckForDuplicateDegree` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckForDuplicateDegree`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_deg_id` INT, OUT `p_exists` INT)
BEGIN

    SELECT COUNT(*) INTO p_exists

    FROM degree

    WHERE (deg_name = p_deg_name OR short = p_short) AND deg_id != p_deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckIfDegreeExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckIfDegreeExists`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), OUT `p_exists` INT)
BEGIN

    SELECT COUNT(*) INTO p_exists

    FROM degree

    WHERE deg_name = p_deg_name OR short = p_short;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckIfDepartmentExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckIfDepartmentExists`(IN `p_d_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)
BEGIN

    SELECT COUNT(*) INTO p_exists

    FROM department d

    LEFT JOIN user u ON d.user_id = u.user_id

    WHERE d.d_name = p_d_name OR u.user_name = p_email OR u.email = p_email;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckIfFacultyExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckIfFacultyExists`(IN `p_f_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` INT)
BEGIN

    SELECT COUNT(*) INTO p_exists

    FROM faculty f

    LEFT JOIN user u ON f.user_id = u.user_id

    WHERE f.f_name = p_f_name OR u.user_name = p_email;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckIndexNoExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckIndexNoExists`(IN `p_index_no` VARCHAR(255), OUT `p_exists` BOOLEAN)
BEGIN

    IF p_index_no = '' THEN

        SELECT FALSE INTO p_exists; 

    ELSE

        SELECT EXISTS (SELECT 1 FROM student_detail WHERE index_num = p_index_no) INTO p_exists;

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckSubjectExist` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckSubjectExist`(IN `p_batch_id` INT(11), IN `p_sub_id` INT(11), IN `p_user_id` INT(11), OUT `p_exists` BOOLEAN)
BEGIN

    SELECT COUNT(*) > 0 INTO p_exists 

    FROM batch_curriculum_lecturer bcl 

    JOIN manager m

    ON bcl.m_id=m.m_id

    WHERE bcl.batch_id = p_batch_id AND bcl.sub_id = p_sub_id AND m.user_id=p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CheckUserExists` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CheckUserExists`(IN `p_user_name` VARCHAR(255), IN `p_email` VARCHAR(255), OUT `p_exists` BOOLEAN)
BEGIN

    SELECT COUNT(*) > 0 INTO p_exists 

    FROM user 

    WHERE user_name = p_user_name OR email = p_email;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateBatchStudentsTable` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateBatchStudentsTable`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN

    DECLARE i INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE columns_sql TEXT;



    SET columns_sql = 'id INT AUTO_INCREMENT PRIMARY KEY, s_id INT(11) NOT NULL, applied_to_exam VARCHAR(50) DEFAULT "false"';



    WHILE i < JSON_LENGTH(p_subjects) DO

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', i, '].sub_id')));

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateBatchSubjectTables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateBatchSubjectTables`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN

    DECLARE i INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE create_table_sql TEXT;



    WHILE i < JSON_LENGTH(p_subjects) DO

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', i, '].sub_id')));

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
        SET @stmt = create_table_sql;

        PREPARE stmt FROM @stmt;

        EXECUTE stmt;

        DEALLOCATE PREPARE stmt;

        SET i = i + 1;

    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateCurriculum` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateCurriculum`(IN `p_sub_code` VARCHAR(100), IN `p_sub_name` VARCHAR(150), IN `p_sem_no` INT, IN `p_deg_id` INT, IN `p_level` INT, IN `p_status` VARCHAR(50))
BEGIN

    INSERT INTO curriculum (sub_code, sub_name, sem_no, deg_id, level, status)

    VALUES (p_sub_code, p_sub_name, p_sem_no, p_deg_id, p_level, p_status);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateDegree` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateDegree`(IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_levels` VARCHAR(255), IN `p_no_of_sem_per_year` VARCHAR(10), IN `p_status` VARCHAR(50), OUT `p_deg_id` INT)
BEGIN

    INSERT INTO degree(deg_name, short, levels, no_of_sem_per_year, status)

    VALUES (p_deg_name, p_short, p_levels, p_no_of_sem_per_year, p_status);

    SET p_deg_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateDepartment`(IN `p_d_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50), OUT `p_d_id` INT)
BEGIN

    INSERT INTO department(d_name, user_id, contact_no, status)

    VALUES (p_d_name, p_user_id, p_contact_no, p_status);

    SET p_d_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateDepartmentUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateDepartmentUser`(IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)
BEGIN

    INSERT INTO user(user_name, email, password, role_id)

    VALUES (p_email, p_email, p_password, '3');

    SET p_user_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateFaculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateFaculty`(IN `p_f_name` VARCHAR(255), IN `p_user_id` INT, IN `p_contact_no` VARCHAR(50), IN `p_status` VARCHAR(50))
BEGIN

    INSERT INTO faculty (f_name, user_id, contact_no, status)

    VALUES (p_f_name, p_user_id, p_contact_no, p_status);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateFacultyUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateFacultyUser`(IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), OUT `p_user_id` INT)
BEGIN

    INSERT INTO user(user_name, email, password, role_id)

    VALUES (p_email, p_email, p_password, '2');

    

    SET p_user_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `CreateNewBatchSubjectTables` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `CreateNewBatchSubjectTables`(IN `p_batch_id` INT, IN `p_subjects` JSON)
BEGIN

    DECLARE i INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE create_table_sql TEXT;



    WHILE i < JSON_LENGTH(p_subjects) DO

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', i, '].sub_id')));

        

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

        SET @stmt = create_table_sql;

        PREPARE stmt FROM @stmt;

        EXECUTE stmt;

        DEALLOCATE PREPARE stmt;

        

        SET i = i + 1;

    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteBatchCurriculumLecturerRows` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `DeleteBatchCurriculumLecturerRows`(IN `p_batch_id` INT)
BEGIN

    DELETE FROM batch_curriculum_lecturer WHERE batch_id = p_batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DeleteBatchSubjectEntries` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `DeleteBatchSubjectEntries`(IN `p_batch_id` INT)
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `DropOldBatchTablesAndColumns` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `DropOldBatchTablesAndColumns`(IN `p_batch_id` INT, IN `p_old_subjects` JSON)
BEGIN

    DECLARE i INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE drop_table_sql TEXT;

    DECLARE drop_column_sql TEXT;



    SET drop_column_sql = CONCAT('ALTER TABLE batch_', p_batch_id, '_students ');



    WHILE i < JSON_LENGTH(p_old_subjects) DO

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_old_subjects, CONCAT('$[', i, '].sub_id')));

        

        -- Drop old tables

        SET drop_table_sql = CONCAT('DROP TABLE IF EXISTS batch_', p_batch_id, '_sub_', sub_id);
        
        SET @stmt = drop_table_sql;

        PREPARE stmt FROM @stmt;

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
    SET @stmt = drop_column_sql;

    PREPARE stmt FROM @stmt;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `FetchStudentEligibilityByBatchIdAndSId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `FetchStudentEligibilityByBatchIdAndSId`(IN `p_batch_id` INT, IN `p_s_id` INT)
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `FetchStudentsWithSubjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `FetchStudentsWithSubjects`(IN `p_batch_id` INT)
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `FetchStudentWithSubjectsByUserId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `FetchStudentWithSubjectsByUserId`(IN `batch_id` INT, IN `user_id` INT)
BEGIN
  -- Declare variables
  DECLARE dynamic_students_table VARCHAR(255);
  DECLARE query_students TEXT;
  DECLARE query_subjects TEXT;
  DECLARE uid INT;
  DECLARE bid INT;

  -- Assign IN parameters to local variables for EXECUTE USING
  SET uid = user_id;
  SET bid = batch_id;

  -- Set the dynamic table name
  SET dynamic_students_table = CONCAT('batch_', batch_id, '_students');

  -- Query to get student details
  SET @query_students = CONCAT(
    'SELECT sd.s_id, sd.name, u.user_name, sd.index_num ',
    'FROM student_detail sd ',
    'JOIN student s ON s.s_id = sd.s_id ',
    'JOIN user u ON u.user_id = s.user_id ',
    'WHERE u.user_id = ?'
  );

  PREPARE stmt FROM @query_students;
  EXECUTE stmt USING @uid;
  DEALLOCATE PREPARE stmt;

  -- Query to get subjects and attendance
  SET query_subjects = CONCAT(
    'SELECT bcl.sub_id, c.sub_name, c.sub_code ',
    'FROM batch_curriculum_lecturer bcl ',
    'JOIN curriculum c ON c.sub_id = bcl.sub_id ',
    'LEFT JOIN ', dynamic_students_table, ' bs ON bs.s_id = ? ',
    'WHERE bcl.batch_id = ?'
  );

  SET @stmt3 = query_subjects;
  PREPARE stmt3 FROM @stmt3;
  EXECUTE stmt3 USING @uid, @bid;
  DEALLOCATE PREPARE stmt3;
END ;;

DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `FillProperSummary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `FillProperSummary`(IN p_batch_id INT)
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

    

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GenerateIndexNumbers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GenerateIndexNumbers`(IN `p_batch_id` INT, IN `p_course` VARCHAR(50), IN `p_batch` VARCHAR(50), IN `p_startsFrom` INT)
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveBatches` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveBatches`(IN `p_deg_id` INT)
BEGIN

    SET @query = CONCAT(

        'SELECT b.batch_id, b.batch_code FROM batch b INNER JOIN admission a ON b.batch_id=a.batch_id WHERE b.deg_id = ',p_deg_id,'  AND b.status = ''true'' ORDER BY b.batch_code DESC'

    );

    PREPARE stmt FROM @query;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveBatchesWithinDeadline` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveBatchesWithinDeadline`(IN `p_deg_id` INT, IN `p_role_id` VARCHAR(50))
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
        SET @stmt = sql_query;

        PREPARE stmt FROM @stmt;

        EXECUTE stmt;

        DEALLOCATE PREPARE stmt;

    ELSE

        -- Handle cases where pre_role_id is NULL

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid role ID provided';

    END IF;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveDegrees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveDegrees`(`department_ids` TEXT)
BEGIN

    SET @query = CONCAT('SELECT deg_id, short FROM dep_deg WHERE d_id IN (', department_ids, ') AND status = ''true''');

    PREPARE stmt FROM @query;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveDegreesInDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveDegreesInDepartment`(IN `p_d_id` INT)
BEGIN

    SELECT 

        deg.deg_id,

        deg.deg_name,

        deg.levels,

        deg.short

    FROM degree deg

    LEFT JOIN dep_deg dd ON deg.deg_id = dd.deg_id

    WHERE dd.d_id = p_d_id AND deg.status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveDepartmentsWithDegreesCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveDepartmentsWithDegreesCount`(IN `p_f_id` INT)
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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetActiveFacultiesWithDepartmentsCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetActiveFacultiesWithDepartmentsCount`()
BEGIN

    SELECT 

        f.f_id,

        f.f_name,

        COUNT(fd.d_id) AS departments_count

    FROM faculty f

    LEFT JOIN fac_dep fd ON f.f_id = fd.f_id

    WHERE f.status = 'true'

    GROUP BY f.f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAdminDetails`(IN `p_user_id` INT)
BEGIN

    SELECT 

        email, user_name, role_id

    FROM 

        user

    WHERE 

        user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAdminSummary` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAdminSummary`()
BEGIN

    SELECT 

        (SELECT COUNT(*) FROM batch) AS batch_count,

        (SELECT COUNT(*) FROM curriculum) AS curriculum_count,

        (SELECT COUNT(*) FROM degree) AS degree_count,

        (SELECT COUNT(*) FROM department) AS department_count,

        (SELECT COUNT(*) FROM faculty) AS faculty_count,

        (SELECT COUNT(*) FROM manager) AS manager_count,

        (SELECT COUNT(*) FROM student) AS student_count,

        (SELECT COUNT(*) FROM manager) AS manager_count;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllActiveBatchesProgesses` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllActiveBatchesProgesses`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllActiveManagers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllActiveManagers`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllBatchDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;

CREATE PROCEDURE `GetAllBatchDetails`()
BEGIN

    DECLARE done INT DEFAULT 0;
    DECLARE batchId INT;
    DECLARE batchCode VARCHAR(100);
    DECLARE academicYear VARCHAR(50);
    DECLARE levelNo INT(11);
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

    -- Drop the temporary table if it exists
    DROP TEMPORARY TABLE IF EXISTS temp_batch_details;

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

        -- Get degree name
        SELECT deg_name INTO degName
        FROM degree d
        JOIN batch b ON d.deg_id = b.deg_id
        WHERE b.batch_id = batchId
        LIMIT 1;

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

END ;;

DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllBatches` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllBatches`()
BEGIN

    SELECT * FROM batch;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllCurriculums` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllCurriculums`()
BEGIN

    SELECT * 

    FROM curriculum 

    WHERE status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllCurriculumsWithExtraDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllCurriculumsWithExtraDetails`()
BEGIN

    SELECT 

        curriculum.*,

        degree.deg_name AS degree_name

    FROM curriculum

    JOIN degree ON curriculum.deg_id = degree.deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllDegrees` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllDegrees`()
BEGIN

    SELECT * 

    FROM degree 

    WHERE status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllDegreesWithDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllDegreesWithDetails`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllDepartments` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllDepartments`()
BEGIN

    SELECT * 

    FROM department

    WHERE status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllDepartmentsWithDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllDepartmentsWithDetails`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllFaculties` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllFaculties`()
BEGIN

    SELECT * 

    FROM faculty 

    WHERE status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllFacultiesWithDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllFacultiesWithDetails`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllLevelsInDegree` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllLevelsInDegree`(IN `p_deg_id` INT)
BEGIN

    SELECT 

        deg.deg_id,

        deg.deg_name,

        deg.levels

    FROM degree deg

    WHERE deg.deg_id = p_deg_id AND deg.status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllManagers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllManagers`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllStudents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllStudents`()
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAllSubjectsForManager` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAllSubjectsForManager`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAppliedStudentsByBatchAndSubject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAppliedStudentsByBatchAndSubject`(IN `p_user_id` INT, IN `p_batch_id` INT, IN `p_sub_id` INT, IN `p_role_id` VARCHAR(50))
BEGIN

    DECLARE p_m_id INT;

    DECLARE batch_status VARCHAR(50);

    DECLARE lecturer_deadline TIMESTAMP;



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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetAppliedStudentsForSubjectOfFacOrDep` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetAppliedStudentsForSubjectOfFacOrDep`(IN `p_batch_id` INT, IN `p_sub_id` INT, IN `p_role_id` VARCHAR(50))
BEGIN

    DECLARE batch_status VARCHAR(50);

    DECLARE deadline TIMESTAMP;

    DECLARE previous_deadline TIMESTAMP;



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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchAdmissionDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchAdmissionDetails`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchCount`()
BEGIN

    SELECT COUNT(*) AS batch_count FROM batch;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchDetails`(IN `p_batch_id` INT)
BEGIN

    SELECT * FROM batch WHERE batch_id = p_batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchesByFacultyId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchesByFacultyId`(IN `p_f_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchFullDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchFullDetails`(IN `p_batch_id` INT)
BEGIN

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
    SET @stmt = query;

    PREPARE stmt FROM @stmt;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetBatchOpenDate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetBatchOpenDate`(IN `p_batch_id` INT)
BEGIN

    SELECT

    	application_open

    FROM

        batch

    WHERE

       	batch_id = p_batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCurriculumByBatchId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetCurriculumByBatchId`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCurriculumByDegLevSem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetCurriculumByDegLevSem`(IN `p_deg_id` INT, IN `p_level` INT, IN `p_sem_no` INT)
BEGIN

    SELECT * 

    FROM curriculum 

    WHERE 

        deg_id = p_deg_id 

        AND level = p_level 

        AND sem_no = p_sem_no 

        AND status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCurriculumById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetCurriculumById`(IN `p_sub_id` INT)
BEGIN

    SELECT 

        curriculum.*,

        dep_deg.d_id,

        fac_dep.f_id

    FROM curriculum

    INNER JOIN dep_deg ON curriculum.deg_id = dep_deg.deg_id

    INNER JOIN fac_dep ON dep_deg.d_id = fac_dep.d_id

    WHERE sub_id = p_sub_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCurriculumsByDid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetCurriculumsByDid`(IN `p_hod_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetCurriculumsByLecId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetCurriculumsByLecId`(IN `p_m_id` INT)
BEGIN

    SELECT curriculum.* 

    FROM curriculum 

    JOIN batch_curriculum_lecture 

    ON curriculum.sub_id = batch_curriculum_lecture.sub_id 

    WHERE batch_curriculum_lecture.m_id = p_m_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDeadlinesForBatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDeadlinesForBatch`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegFacDepDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegFacDepDetails`(IN `p_degree_name_short` VARCHAR(50))
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeById`(IN `p_deg_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeByShort` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeByShort`(IN `p_short` VARCHAR(50))
BEGIN

    SELECT deg_name 

    FROM degree 

    WHERE short = p_short;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeCount`(OUT `p_degree_count` INT)
BEGIN

    SELECT COUNT(*) INTO p_degree_count

    FROM degree;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeCountByDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeCountByDepartment`(IN `p_d_id` INT, OUT `p_degree_count` INT)
BEGIN

    SELECT COUNT(DISTINCT deg_id) INTO p_degree_count

    FROM dep_deg

    WHERE d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeCountByLevel` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeCountByLevel`(IN `p_levels` VARCHAR(255), OUT `p_degree_count` INT)
BEGIN

    SELECT COUNT(*) INTO p_degree_count

    FROM degree

    WHERE levels = p_levels;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreeDetailsByDegid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreeDetailsByDegid`(IN `p_deg_id` INT, OUT `p_exists` INT)
BEGIN

    SELECT COUNT(*) INTO p_exists

    FROM degree

    WHERE deg_id = p_deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDegreesByDepartmentId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDegreesByDepartmentId`(IN `p_d_id` INT)
BEGIN

    SELECT 

        degree.* 

    FROM degree 

    INNER JOIN dep_deg ON degree.deg_id = dep_deg.deg_id 

    WHERE dep_deg.d_id = p_d_id 

      AND degree.status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentById`(IN `p_d_id` INT)
BEGIN

    SELECT 

        d.*, 

        fd.f_id, 

        u.user_name AS email 

    FROM department d 

    INNER JOIN fac_dep fd ON d.d_id = fd.d_id 

    LEFT JOIN user u ON u.user_id = d.user_id 

    WHERE d.d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentCount`(OUT `p_department_count` INT)
BEGIN

    SELECT COUNT(*) INTO p_department_count

    FROM department;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentCountByFaculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentCountByFaculty`(IN `p_f_id` INT, OUT `p_department_count` INT)
BEGIN

    SELECT COUNT(DISTINCT d_id) INTO p_department_count

    FROM fac_dep

    WHERE f_id = p_f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentDetails`(IN `p_user_id` INT)
BEGIN

    SELECT 

        u.email, u.user_name, d.d_name AS name, u.role_id

    FROM 

        user u

    INNER JOIN 

        department d ON u.user_id = d.user_id

    WHERE 

        u.user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentDetailsByDid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentDetailsByDid`(IN `p_d_id` INT)
BEGIN

    SELECT d.d_id, d.user_id

    FROM department d

    WHERE d.d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDepartmentsByFacultyId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDepartmentsByFacultyId`(IN `p_f_id` INT)
BEGIN

    SELECT 

        department.* 

    FROM department 

    INNER JOIN fac_dep ON department.d_id = fac_dep.d_id 

    WHERE fac_dep.f_id = p_f_id 

      AND department.status = 'true';

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetDynamicTableData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetDynamicTableData`(IN `batch_id` INT, IN `sub_id` INT)
BEGIN

    SET @query = CONCAT(

        'SELECT s_id, exam_type, eligibility ',

        'FROM batch_', batch_id, '_sub_', sub_id

    );



    PREPARE stmt FROM @query;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetEligibleStudentsBySub` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetEligibleStudentsBySub`(IN `p_batch_id` INT, IN `p_sub_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFacStudentByBatchId` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetFacStudentByBatchId`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFacultyById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetFacultyById`(IN `p_f_id` INT)
BEGIN

    SELECT 

        f.*, 

        u.user_name AS email 

    FROM faculty f 

    LEFT JOIN user u ON u.user_id = f.user_id 

    WHERE f.f_id = p_f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFacultyCount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetFacultyCount`(OUT `p_faculty_count` INT)
BEGIN

    SELECT COUNT(*) INTO p_faculty_count

    FROM faculty;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFacultyDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetFacultyDetails`(IN `p_user_id` INT)
BEGIN

    SELECT 

        u.email, u.user_name, f.f_name AS name, u.role_id

    FROM 

        user u

    INNER JOIN 

        faculty f ON u.user_id = f.user_id

    WHERE 

        u.user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetFacultyDetailsByFid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetFacultyDetailsByFid`(IN `p_f_id` INT)
BEGIN

    SELECT f.f_id, f.user_id

    FROM faculty f

    WHERE f.f_id = p_f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetLastAssignedIndexNumber` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetLastAssignedIndexNumber`(IN `p_course` VARCHAR(50), IN `p_batch` VARCHAR(50))
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetLatestAdmissionTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetLatestAdmissionTemplate`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetLatestAttendanceTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetLatestAttendanceTemplate`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetManagerById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetManagerById`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetManagerDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetManagerDetails`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetNonBatchStudentsByFaculty` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetNonBatchStudentsByFaculty`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetNoOfCurriculums` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetNoOfCurriculums`()
BEGIN

    SELECT COUNT(*) AS curriculum_count FROM curriculum;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetNoOfManagers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetNoOfManagers`()
BEGIN

    SELECT COUNT(*) AS manager_count FROM manager;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetNoOfStudents` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetNoOfStudents`()
BEGIN

    SELECT COUNT(*) AS student_count FROM student;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetRemarksForSubject` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetRemarksForSubject`(IN `p_batch_id` INT, IN `p_sub_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentApplicationDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentApplicationDetails`(IN `p_user_id` INT)
BEGIN

    DECLARE batch_id INT;

    DECLARE batch_end_date TIMESTAMP;



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



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentBatchDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentBatchDetails`(IN `p_batch_ids` TEXT, IN `p_s_id` INT)
BEGIN

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
    SET @stmt = query;

    PREPARE stmt FROM @stmt;

    EXECUTE stmt;

    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentBatchIds` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentBatchIds`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentById` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentById`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentDetails`(IN `p_user_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentDetailsWithSubjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentDetailsWithSubjects`(IN `batchId` INT, IN `userId` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentSubjects` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentSubjects`(IN `p_batch_id` INT, IN `p_s_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetStudentsWithoutIndexNumber` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetStudentsWithoutIndexNumber`(IN `p_batch_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetSubjectsForBatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetSubjectsForBatch`(IN `batch_id` INT)
BEGIN

    SELECT bcl.sub_id, c.sub_code, c.sub_name FROM batch_curriculum_lecturer bcl JOIN curriculum c ON bcl.sub_id=c.sub_id  WHERE bcl.batch_id = batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserByCredentials` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetUserByCredentials`(IN `p_user_name_or_email` VARCHAR(255), OUT `p_user_id` INT, OUT `p_password` VARCHAR(255), OUT `p_role_id` INT)
BEGIN

    SELECT user_id, password, role_id

    INTO p_user_id, p_password, p_role_id

    FROM user

    WHERE user_name = p_user_name_or_email OR email = p_user_name_or_email;



    IF p_user_id IS NULL THEN

        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';

    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `GetUserByResetToken` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `GetUserByResetToken`(IN `p_token` TEXT)
BEGIN

    SELECT user_id

    FROM user

    WHERE reset_token = p_token

      AND token_expiration > NOW();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertBatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertBatch`(IN `p_batch_code` VARCHAR(100), IN `p_description` VARCHAR(500), IN `p_status` VARCHAR(50), IN `p_deg_id` INT, IN `p_application_open` TIMESTAMP, IN `p_academic_year` VARCHAR(50), IN `p_level` INT(11), IN `p_sem_no` INT(11), OUT `p_batch_id` INT)
BEGIN

    INSERT INTO batch (batch_code, description, status, deg_id, application_open, academic_year, level, sem)

    VALUES (p_batch_code, p_description, p_status, p_deg_id, p_application_open, p_academic_year, p_level, p_sem_no);

    SET p_batch_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertBatchCurriculumLecturer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertBatchCurriculumLecturer`(IN `p_batch_id` INT, IN `p_subjects` TEXT)
BEGIN

    DECLARE json_length INT;

    DECLARE counter INT DEFAULT 0;

    DECLARE sub_id INT;

    DECLARE m_id INT;



    -- Calculate the number of elements in the JSON array

    SET json_length = JSON_LENGTH(p_subjects);



    -- Loop through each element in the JSON array

    WHILE counter < json_length DO

        -- Extract sub_id and m_id from the JSON array

        SET sub_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', counter, '].sub_id')));

        SET m_id = JSON_UNQUOTE(JSON_EXTRACT(p_subjects, CONCAT('$[', counter, '].m_id')));



        -- Insert into batch_curriculum_lecturer

        INSERT INTO batch_curriculum_lecturer (batch_id, sub_id, m_id)

        VALUES (p_batch_id, sub_id, m_id);



        -- Increment counter

        SET counter = counter + 1;

    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertManager` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertManager`(IN `p_user_id` INT, IN `p_m_id` INT)
BEGIN

    INSERT INTO manager(user_id, m_id) 

    VALUES (p_user_id,p_m_id);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertManagerDetail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertManagerDetail`(IN `p_name` VARCHAR(255), IN `p_contact_no` VARCHAR(20), IN `p_status` VARCHAR(255), OUT `p_m_id` INT)
BEGIN

    INSERT INTO manager_detail(name, contact_no, status) 

    VALUES (p_name, p_contact_no, p_status);

    SET p_m_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertStudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertStudent`(IN `p_user_id` INT, IN `p_s_id` INT)
BEGIN

    INSERT INTO student(user_id,s_id) 

    VALUES (p_user_id, p_s_id);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertStudentDetail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertStudentDetail`(IN `p_name` VARCHAR(255), IN `p_f_id` INT, IN `p_status` VARCHAR(255), IN `p_index_num` VARCHAR(50), IN `p_contact_no` VARCHAR(100), OUT `p_s_id` INT)
BEGIN

    INSERT INTO student_detail(name, f_id, status, index_num, contact_no) 

    VALUES (p_name, p_f_id, p_status,p_index_num,p_contact_no);

    SET p_s_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `InsertUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `InsertUser`(IN `p_user_name` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_password` VARCHAR(255), IN `p_role_id` INT, OUT `p_user_id` INT)
BEGIN

    INSERT INTO user(user_name, email, password, role_id) 

    VALUES (p_user_name, p_email, p_password, p_role_id);

    SET p_user_id = LAST_INSERT_ID();

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LinkDegreeWithDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `LinkDegreeWithDepartment`(IN `p_d_id` INT, IN `p_deg_id` INT)
BEGIN

    INSERT INTO dep_deg(d_id, deg_id)

    VALUES (p_d_id, p_deg_id);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LinkFacultyDepartment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `LinkFacultyDepartment`(IN `p_f_id` INT, IN `p_d_id` INT)
BEGIN

    INSERT INTO fac_dep(f_id, d_id)

    VALUES (p_f_id, p_d_id);

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LogAdminAction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `LogAdminAction`(IN `p_description` TEXT)
BEGIN

    INSERT INTO admin_log (description, date_time)

    VALUES (p_description, CURRENT_TIMESTAMP());

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LogEligibilityChange` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `LogEligibilityChange`(IN `p_user_id` INT, IN `p_s_id` INT, IN `p_exam` INT, IN `p_sub_id` INT, IN `p_status_from` VARCHAR(50), IN `p_status_to` VARCHAR(50), IN `p_remark` TEXT)
BEGIN

    INSERT INTO eligibility_log (user_id, s_id, exam, sub_id, status_from, status_to, remark, date_time)

    VALUES (p_user_id, p_s_id, p_exam, p_sub_id, p_status_from, p_status_to, p_remark, CURRENT_TIMESTAMP());

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `LogStudentAction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `LogStudentAction`(IN `p_user_id` INT, IN `p_exam` INT)
BEGIN

    INSERT INTO students_log (user_id, exam, date_time)

    VALUES (p_user_id, p_exam, CURRENT_TIMESTAMP());

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `RemoveStudentsFromBatch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `RemoveStudentsFromBatch`(IN `p_batch_id` INT, IN `p_removed_students` TEXT)
BEGIN

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


    SET @stmt = drop_query;

    PREPARE drop_stmt FROM @stmt;

    EXECUTE drop_stmt;

    DEALLOCATE PREPARE drop_stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `StoreResetToken` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `StoreResetToken`(IN `p_user_id` INT, IN `p_hashed_token` TEXT, IN `p_expiration` TIMESTAMP)
BEGIN

    UPDATE user

    SET reset_token = p_hashed_token,

        token_expiration = p_expiration

    WHERE user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateAdmissionData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateAdmissionData`(IN `p_batch_id` INT, IN `p_generated_date` VARCHAR(250), IN `p_subject_list` VARCHAR(250), IN `p_exam_date` VARCHAR(250), IN `p_description` TEXT, IN `p_instructions` TEXT, IN `p_provider` TEXT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateAttendaceData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateAttendaceData`(IN `p_batch_id` INT, IN `p_exam_date` VARCHAR(250), IN `p_description` TEXT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ZERO_IN_DATE,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateBatchDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateBatchDetails`(IN `p_batch_id` INT, IN `p_batch_code` VARCHAR(100), IN `p_description` VARCHAR(500), IN `p_deg_id` INT, IN `p_application_open` TIMESTAMP, IN `p_academic_year` VARCHAR(50), IN `p_level` INT(11), IN `p_sem_no` INT(11))
BEGIN

    UPDATE batch

    SET batch_code = p_batch_code, description = p_description, deg_id = p_deg_id, application_open = p_application_open, academic_year= p_academic_year, level = p_level, sem = p_sem_no

    WHERE batch_id = p_batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateBatchStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateBatchStatus`(IN `p_batch_id` INT, IN `p_status` VARCHAR(50))
BEGIN

    UPDATE batch

    SET status = p_status

    WHERE batch_id = p_batch_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateCurriculum` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateCurriculum`(IN `p_sub_id` INT, IN `p_sub_code` VARCHAR(100), IN `p_sub_name` VARCHAR(150), IN `p_sem_no` INT, IN `p_deg_id` INT, IN `p_level` INT)
BEGIN

    UPDATE curriculum

    SET 

        sub_code = p_sub_code,

        sub_name = p_sub_name,

        sem_no = p_sem_no,

        deg_id = p_deg_id,

        level = p_level

    WHERE sub_id = p_sub_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateCurriculumStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateCurriculumStatus`(IN `p_sub_id` INT, IN `p_status` VARCHAR(50))
BEGIN

    UPDATE curriculum

    SET 

        status = p_status

    WHERE sub_id = p_sub_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDegreeDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDegreeDetails`(IN `p_deg_id` INT, IN `p_deg_name` VARCHAR(255), IN `p_short` VARCHAR(50), IN `p_levels` VARCHAR(255), IN `p_no_of_sem_per_year` VARCHAR(10))
BEGIN

    UPDATE degree

    SET deg_name = p_deg_name,

        short = p_short,

        levels = p_levels,

        no_of_sem_per_year = p_no_of_sem_per_year

    WHERE deg_id = p_deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDegreeStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDegreeStatus`(IN `p_deg_id` INT, IN `p_status` VARCHAR(50))
BEGIN

    UPDATE degree

    SET 

        status = p_status

    WHERE deg_id = p_deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDepartmentDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDepartmentDetails`(IN `p_d_id` INT, IN `p_d_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50))
BEGIN

    UPDATE department

    SET d_name = p_d_name,

        contact_no = p_contact_no

    WHERE d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDepartmentStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDepartmentStatus`(IN `p_d_id` INT, IN `p_status` VARCHAR(50))
BEGIN

    UPDATE department

    SET 

        status = p_status

    WHERE d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDepartmentUser` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDepartmentUser`(IN `p_user_id` INT, IN `p_email` VARCHAR(255))
BEGIN

    UPDATE user

    SET user_name = p_email,

        email = p_email

    WHERE user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateDepDeg` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateDepDeg`(IN `p_d_id` INT, IN `p_deg_id` INT)
BEGIN

    UPDATE dep_deg

    SET d_id = p_d_id

    WHERE deg_id = p_deg_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateEligibility` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateEligibility`(
  IN `p_user_id` INT, 
  IN `p_s_id` INT, 
  IN `p_sub_id` INT, 
  IN `p_batch_id` INT, 
  IN `p_eligibility` VARCHAR(50), 
  IN `p_role_id` VARCHAR(50)
)
BEGIN
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
            SELECT m_id INTO p_m_id FROM manager WHERE user_id = p_user_id;
            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;

            SELECT COUNT(*) INTO @access_count
            FROM batch_curriculum_lecturer
            WHERE m_id = p_m_id AND sub_id = p_sub_id AND batch_id = p_batch_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF;

            SELECT COUNT(*) INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '4' AND end_date > NOW();

            IF @deadline_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cross the dealine of this batch.';
            END IF;

        ELSEIF p_role_id = '3' THEN
            SELECT d_id INTO p_m_id FROM department WHERE user_id = p_user_id;
            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;

            SELECT COUNT(d.d_id) INTO @access_count
            FROM batch b
            INNER JOIN degree deg ON b.deg_id = deg.deg_id
            INNER JOIN dep_deg dd ON deg.deg_id = dd.deg_id
            INNER JOIN department d ON dd.d_id = d.d_id
            WHERE d.user_id = p_user_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF;

            SELECT COUNT(*) INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '3' AND end_date > NOW()
              AND (SELECT COUNT(*) FROM batch_time_periods 
                   WHERE batch_id = p_batch_id AND user_type = '4' AND end_date < NOW()) > 0;

            IF @deadline_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User cross the dealine of this batch.';
            END IF;

        ELSEIF p_role_id = '2' THEN
            SELECT f_id INTO p_m_id FROM faculty WHERE user_id = p_user_id;
            IF p_m_id IS NULL THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not authorized to access this batch.';
            END IF;

            SELECT COUNT(f.f_id) INTO @access_count
            FROM batch b
            INNER JOIN degree deg ON b.deg_id = deg.deg_id
            INNER JOIN dep_deg dd ON deg.deg_id = dd.deg_id
            INNER JOIN fac_dep fd ON dd.d_id = fd.d_id
            INNER JOIN faculty f ON fd.f_id = f.f_id
            WHERE f.user_id = p_user_id;

            IF @access_count = 0 THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User does not have permission to modify this batch.';
            END IF;

            SELECT COUNT(*) INTO @deadline_count
            FROM batch_time_periods
            WHERE batch_id = p_batch_id AND user_type = '2' AND end_date > NOW()
              AND (SELECT COUNT(*) FROM batch_time_periods 
                   WHERE batch_id = p_batch_id AND user_type = '3' AND end_date < NOW()) > 0;

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

    SET @eligibility = p_eligibility;
    SET @s_id = p_s_id;

    PREPARE stmt FROM @query;
    EXECUTE stmt USING @eligibility, @s_id;
    DEALLOCATE PREPARE stmt;

END ;;

DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateFacultyDepartmentLink` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateFacultyDepartmentLink`(IN `p_f_id` INT, IN `p_d_id` INT)
BEGIN

    UPDATE fac_dep

    SET f_id = p_f_id

    WHERE d_id = p_d_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateFacultyDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateFacultyDetails`(IN `p_f_id` INT, IN `p_f_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50))
BEGIN

    UPDATE faculty

    SET f_name = p_f_name,

        contact_no = p_contact_no

    WHERE f_id = p_f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateFacultyStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateFacultyStatus`(IN `p_f_id` INT, IN `p_status` VARCHAR(50))
BEGIN

    UPDATE faculty

    SET 

        status = p_status

    WHERE f_id = p_f_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateManager` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateManager`(IN `p_name` VARCHAR(255), IN `p_email` VARCHAR(255), IN `p_user_name` VARCHAR(255), IN `p_contact_no` VARCHAR(50), IN `p_m_id` INT)
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateManagerStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateManagerStatus`(IN `p_status` VARCHAR(50), IN `p_m_id` INT)
BEGIN

    -- Update manager detail

    UPDATE manager_detail 

    SET 

        status = p_status 

    WHERE m_id = p_m_id;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateStudent` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateStudent`(IN `p_name` VARCHAR(255), IN `p_f_id` INT, IN `p_s_id` INT, IN `p_email` VARCHAR(255), IN `p_user_name` VARCHAR(255), IN `p_contact_no` VARCHAR(100), IN `p_index_num` VARCHAR(50))
BEGIN

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

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateStudentStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateStudentStatus`(IN `p_status` VARCHAR(50), IN `p_s_id` INT)
BEGIN

    -- Update student detail

    UPDATE student_detail 

    SET 

        status = p_status 

    WHERE s_id = p_s_id;



END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateUserDetails` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateUserDetails`(IN `p_user_id` INT, IN `p_email` VARCHAR(255))
BEGIN

    UPDATE user

    SET user_name = p_email,

        email = p_email

    WHERE user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `UpdateUserPassword` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE PROCEDURE `UpdateUserPassword`(IN `p_user_id` INT, IN `p_hashed_password` TEXT)
BEGIN

    UPDATE user

    SET password = p_hashed_password,

        reset_token = NULL,

        token_expiration = NULL

    WHERE user_id = p_user_id;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-03 23:47:22
