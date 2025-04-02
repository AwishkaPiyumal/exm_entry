-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 29, 2025 at 06:18 PM
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
-- Database: `mysql`
--

-- --------------------------------------------------------

--
-- Table structure for table `columns_priv`
--

CREATE TABLE `columns_priv` (
  `Host` char(60) NOT NULL DEFAULT '',
  `Db` char(64) NOT NULL DEFAULT '',
  `User` char(80) NOT NULL DEFAULT '',
  `Table_name` char(64) NOT NULL DEFAULT '',
  `Column_name` char(64) NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Column_priv` set('Select','Insert','Update','References') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `db`
--

CREATE TABLE `db` (
  `Host` char(60) NOT NULL DEFAULT '',
  `Db` char(64) NOT NULL DEFAULT '',
  `User` char(80) NOT NULL DEFAULT '',
  `Select_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Insert_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Update_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Delete_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Create_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Drop_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Grant_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `References_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Index_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Alter_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Create_tmp_table_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Lock_tables_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Create_view_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Show_view_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Create_routine_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Alter_routine_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Execute_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Event_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Trigger_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N',
  `Delete_history_priv` enum('N','Y') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT 'N'
) ENGINE=Aria DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `procs_priv`
--

CREATE TABLE `procs_priv` (
  `Host` char(60) NOT NULL DEFAULT '',
  `Db` char(64) NOT NULL DEFAULT '',
  `User` char(80) NOT NULL DEFAULT '',
  `Routine_name` char(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `Routine_type` enum('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY') NOT NULL,
  `Grantor` char(141) NOT NULL DEFAULT '',
  `Proc_priv` set('Execute','Alter Routine','Grant') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=Aria DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tables_priv`
--

CREATE TABLE `tables_priv` (
  `Host` char(60) NOT NULL DEFAULT '',
  `Db` char(64) NOT NULL DEFAULT '',
  `User` char(80) NOT NULL DEFAULT '',
  `Table_name` char(64) NOT NULL DEFAULT '',
  `Grantor` char(141) NOT NULL DEFAULT '',
  `Timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Table_priv` set('Select','Insert','Update','Delete','Create','Drop','Grant','References','Index','Alter','Create View','Show view','Trigger','Delete versioning rows') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '',
  `Column_priv` set('Select','Insert','Update','References') CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT ''
) ENGINE=Aria DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `tables_priv`
--

INSERT INTO `tables_priv` (`Host`, `Db`, `User`, `Table_name`, `Grantor`, `Timestamp`, `Table_priv`, `Column_priv`) VALUES
('%', 'exam_entry', 'student', 'student', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'admission', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'batch', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'batch_curriculum_lecturer', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'batch_time_periods', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'curriculum', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'degree', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'department', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'dep_deg', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'faculty', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'fac_dep', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'manager', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'student_detail', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'student', 'user', 'root@localhost', '0000-00-00 00:00:00', 'Select,Update', ''),
('%', 'exam_entry', 'student', 'students_log', 'root@localhost', '0000-00-00 00:00:00', 'Create', ''),
('%', 'exam_entry', 'manager', 'batch', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'batch_curriculum_lecturer', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'batch_time_periods', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'curriculum', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'degree', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'department', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'dep_deg', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'faculty', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'fac_dep', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'manager', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'manager_detail', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'student', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'student_detail', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'manager', 'user', 'root@localhost', '0000-00-00 00:00:00', 'Select,Update', ''),
('%', 'exam_entry', 'manager', 'eligibility_log', 'root@localhost', '0000-00-00 00:00:00', 'Create', ''),
('%', 'exam_entry', 'hod', 'admission', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'batch', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'batch_curriculum_lecturer', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'batch_time_periods', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'curriculum', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'degree', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'department', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'dep_deg', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'faculty', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'fac_dep', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'manager', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'student', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'student_detail', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'hod', 'user', 'root@localhost', '0000-00-00 00:00:00', 'Select,Update', ''),
('%', 'exam_entry', 'hod', 'eligibility_log', 'root@localhost', '0000-00-00 00:00:00', 'Select,Create', ''),
('%', 'exam_entry', 'dean', 'admission', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'batch', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'batch_curriculum_lecturer', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'batch_time_periods', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'curriculum', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'degree', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'department', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'dep_deg', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'faculty', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'fac_dep', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'manager', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'student', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'student_detail', 'root@localhost', '0000-00-00 00:00:00', 'Select', ''),
('%', 'exam_entry', 'dean', 'user', 'root@localhost', '0000-00-00 00:00:00', 'Select,Update', ''),
('%', 'exam_entry', 'dean', 'eligibility_log', 'root@localhost', '0000-00-00 00:00:00', 'Select,Create', '');

-- --------------------------------------------------------

--
-- Stand-in structure for view `user`
-- (See below for the actual view)
--
CREATE TABLE `user` (
`Host` char(60)
,`User` char(80)
,`Password` longtext
,`Select_priv` varchar(1)
,`Insert_priv` varchar(1)
,`Update_priv` varchar(1)
,`Delete_priv` varchar(1)
,`Create_priv` varchar(1)
,`Drop_priv` varchar(1)
,`Reload_priv` varchar(1)
,`Shutdown_priv` varchar(1)
,`Process_priv` varchar(1)
,`File_priv` varchar(1)
,`Grant_priv` varchar(1)
,`References_priv` varchar(1)
,`Index_priv` varchar(1)
,`Alter_priv` varchar(1)
,`Show_db_priv` varchar(1)
,`Super_priv` varchar(1)
,`Create_tmp_table_priv` varchar(1)
,`Lock_tables_priv` varchar(1)
,`Execute_priv` varchar(1)
,`Repl_slave_priv` varchar(1)
,`Repl_client_priv` varchar(1)
,`Create_view_priv` varchar(1)
,`Show_view_priv` varchar(1)
,`Create_routine_priv` varchar(1)
,`Alter_routine_priv` varchar(1)
,`Create_user_priv` varchar(1)
,`Event_priv` varchar(1)
,`Trigger_priv` varchar(1)
,`Create_tablespace_priv` varchar(1)
,`Delete_history_priv` varchar(1)
,`ssl_type` varchar(9)
,`ssl_cipher` longtext
,`x509_issuer` longtext
,`x509_subject` longtext
,`max_questions` bigint(20) unsigned
,`max_updates` bigint(20) unsigned
,`max_connections` bigint(20) unsigned
,`max_user_connections` bigint(21)
,`plugin` longtext
,`authentication_string` longtext
,`password_expired` varchar(1)
,`is_role` varchar(1)
,`default_role` longtext
,`max_statement_time` decimal(12,6)
);

-- --------------------------------------------------------

--
-- Structure for view `user`
--
DROP TABLE IF EXISTS `user`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `user`  AS SELECT `global_priv`.`Host` AS `Host`, `global_priv`.`User` AS `User`, if(json_value(`global_priv`.`Priv`,'$.plugin') in ('mysql_native_password','mysql_old_password'),ifnull(json_value(`global_priv`.`Priv`,'$.authentication_string'),''),'') AS `Password`, if(json_value(`global_priv`.`Priv`,'$.access') & 1,'Y','N') AS `Select_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 2,'Y','N') AS `Insert_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 4,'Y','N') AS `Update_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 8,'Y','N') AS `Delete_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 16,'Y','N') AS `Create_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 32,'Y','N') AS `Drop_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 64,'Y','N') AS `Reload_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 128,'Y','N') AS `Shutdown_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 256,'Y','N') AS `Process_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 512,'Y','N') AS `File_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 1024,'Y','N') AS `Grant_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 2048,'Y','N') AS `References_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 4096,'Y','N') AS `Index_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 8192,'Y','N') AS `Alter_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 16384,'Y','N') AS `Show_db_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 32768,'Y','N') AS `Super_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 65536,'Y','N') AS `Create_tmp_table_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 131072,'Y','N') AS `Lock_tables_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 262144,'Y','N') AS `Execute_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 524288,'Y','N') AS `Repl_slave_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 1048576,'Y','N') AS `Repl_client_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 2097152,'Y','N') AS `Create_view_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 4194304,'Y','N') AS `Show_view_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 8388608,'Y','N') AS `Create_routine_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 16777216,'Y','N') AS `Alter_routine_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 33554432,'Y','N') AS `Create_user_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 67108864,'Y','N') AS `Event_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 134217728,'Y','N') AS `Trigger_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 268435456,'Y','N') AS `Create_tablespace_priv`, if(json_value(`global_priv`.`Priv`,'$.access') & 536870912,'Y','N') AS `Delete_history_priv`, elt(ifnull(json_value(`global_priv`.`Priv`,'$.ssl_type'),0) + 1,'','ANY','X509','SPECIFIED') AS `ssl_type`, ifnull(json_value(`global_priv`.`Priv`,'$.ssl_cipher'),'') AS `ssl_cipher`, ifnull(json_value(`global_priv`.`Priv`,'$.x509_issuer'),'') AS `x509_issuer`, ifnull(json_value(`global_priv`.`Priv`,'$.x509_subject'),'') AS `x509_subject`, cast(ifnull(json_value(`global_priv`.`Priv`,'$.max_questions'),0) as unsigned) AS `max_questions`, cast(ifnull(json_value(`global_priv`.`Priv`,'$.max_updates'),0) as unsigned) AS `max_updates`, cast(ifnull(json_value(`global_priv`.`Priv`,'$.max_connections'),0) as unsigned) AS `max_connections`, cast(ifnull(json_value(`global_priv`.`Priv`,'$.max_user_connections'),0) as signed) AS `max_user_connections`, ifnull(json_value(`global_priv`.`Priv`,'$.plugin'),'') AS `plugin`, ifnull(json_value(`global_priv`.`Priv`,'$.authentication_string'),'') AS `authentication_string`, 'N' AS `password_expired`, elt(ifnull(json_value(`global_priv`.`Priv`,'$.is_role'),0) + 1,'N','Y') AS `is_role`, ifnull(json_value(`global_priv`.`Priv`,'$.default_role'),'') AS `default_role`, cast(ifnull(json_value(`global_priv`.`Priv`,'$.max_statement_time'),0.0) as decimal(12,6)) AS `max_statement_time` FROM `global_priv` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `columns_priv`
--
ALTER TABLE `columns_priv`
  ADD PRIMARY KEY (`Host`,`Db`,`User`,`Table_name`,`Column_name`);

--
-- Indexes for table `db`
--
ALTER TABLE `db`
  ADD PRIMARY KEY (`Host`,`Db`,`User`),
  ADD KEY `User` (`User`);

--
-- Indexes for table `procs_priv`
--
ALTER TABLE `procs_priv`
  ADD PRIMARY KEY (`Host`,`Db`,`User`,`Routine_name`,`Routine_type`),
  ADD KEY `Grantor` (`Grantor`);

--
-- Indexes for table `tables_priv`
--
ALTER TABLE `tables_priv`
  ADD PRIMARY KEY (`Host`,`Db`,`User`,`Table_name`),
  ADD KEY `Grantor` (`Grantor`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
