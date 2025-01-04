-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 02, 2024 at 07:21 PM
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

-- --------------------------------------------------------

--
-- Table structure for table `batch`
--

CREATE TABLE `batch` (
  `batch_id` int(11) NOT NULL,
  `batch_code` varchar(100) NOT NULL,
  `description` varchar(500) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batch_curriculum_lecturer`
--

CREATE TABLE `batch_curriculum_lecturer` (
  `id` int(11) NOT NULL,
  `batch_id` varchar(50) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `m_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `curriculum`
--

INSERT INTO `curriculum` (`sub_id`, `sub_code`, `sub_name`, `sem_no`, `deg_id`, `level`, `status`) VALUES
(7, 'TICT1114', 'Essentials of ICT', 1, 7, 1, 'true'),
(8, 'TICT1123', 'Mathematics for Technology', 1, 7, 1, 'true'),
(9, 'TICT1134', 'Fundamentals of Computer Programming', 1, 7, 1, 'true'),
(10, 'TICT1142', ' Fundamentals of Web Technologies', 1, 7, 1, 'true'),
(11, 'TICT1152', ' Principles of Management', 1, 7, 1, 'true'),
(12, 'AUX1113', ' English Language I', 1, 7, 1, 'true'),
(13, 'TICT1114(P)', 'Essentials of ICT (P)', 1, 7, 1, 'true'),
(14, 'TICT1134(P)', 'Fundamentals of Computer Programming (P)', 1, 7, 1, 'true'),
(15, 'TICT1142(P)', ' Fundamentals of Web Technologies (P)', 1, 7, 1, 'true'),
(16, 'IT3113', 'Knowledge Based Systems and Logic Programming', 1, 14, 3, 'true'),
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
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `degree`
--

INSERT INTO `degree` (`deg_id`, `deg_name`, `short`, `levels`, `no_of_sem_per_year`, `status`) VALUES
(7, 'Bachelor of Information and Communication Technology (Honours)', 'TICT', '1:2:3:4', '2', 'true'),
(8, 'Bachelor of Science Honours in Environmental Science', 'ASB', '1:2:3:4', '2', 'true'),
(9, 'Bachelor of Science in Applied Mathematics and Computing', 'ASP', '1:2:3', '2', 'true'),
(10, 'Bachelor of Science Honours in Computer Science', 'CSH', '3:4', '2', 'true'),
(11, 'Bachelor of Science Honours in Information Technology', 'ITH', '4', '2', 'true'),
(12, 'Bachelor of Business Management (Special) in Human Resource', 'BS', '1:2:3:4', '2', 'true'),
(13, 'Bachelor of Business Management Honours in Project Management', 'PM', '1:2:3:4', '2', 'true'),
(14, 'Bachelor of Science in Information Technology', 'IT', '1:2:3', '2', 'true'),
(15, 'Bachelor of Business Management in Business Economics', 'BS', '1:2:3', '2', 'true'),
(16, 'Bachelor of Business Management in Finance and Accountancy', 'BS', '1:2:3', '2', 'true'),
(17, 'Bachelor of Business Management in Management and Entrepreneurship', 'BS', '1:2:3', '2', 'true'),
(18, 'Bachelor of Business Management in Marketing Management', 'BS', '1:2:3', '2', 'true');

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `d_id` int(11) NOT NULL,
  `d_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`d_id`, `d_name`, `user_id`, `contact_no`, `status`) VALUES
(6, 'Physical Science', 24, '0246784561', 'true'),
(7, 'Bio Science', 25, '0245699001', 'true'),
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
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `f_id` int(11) NOT NULL,
  `f_name` varchar(250) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_no` varchar(50) NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`f_id`, `f_name`, `user_id`, `contact_no`, `status`) VALUES
(8, 'Applied Science', 21, '0246765431', 'true'),
(9, 'Business Studies', 22, '0246865433', 'true'),
(10, 'Technological Studies', 23, '0249060432', 'true');

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
(5, 127);

-- --------------------------------------------------------

--
-- Table structure for table `manager_detail`
--

CREATE TABLE `manager_detail` (
  `id` int(11) NOT NULL,
  `m_id` int(11) NOT NULL,
  `name` varchar(500) NOT NULL,
  `contact_no` varchar(100) NOT NULL,
  `status` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manager_detail`
--

INSERT INTO `manager_detail` (`id`, `m_id`, `name`, `contact_no`, `status`) VALUES
(1, 1, 'S.Vadivel', '94770345128', 'true'),
(2, 2, 'J.Fernando', '94775587965', 'true'),
(3, 3, 'S.Rajesh', '95728754932', 'true'),
(4, 4, 'T.Anuradha', '94753267382', 'true'),
(5, 5, 'N.Sivakumar', '94772584321', 'true');

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
(95, 122);

-- --------------------------------------------------------

--
-- Table structure for table `student_detail`
--

CREATE TABLE `student_detail` (
  `id` int(11) NOT NULL,
  `s_id` int(11) NOT NULL,
  `name` varchar(150) NOT NULL,
  `batch_ids` varchar(150) NOT NULL,
  `d_id` int(11) NOT NULL,
  `status` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_detail`
--

INSERT INTO `student_detail` (`id`, `s_id`, `name`, `batch_ids`, `d_id`, `status`) VALUES
(7, 7, 'KELUM B.Η.Τ.', '', 6, 'true'),
(8, 8, 'JAYASINGHE M.D.', '', 6, 'true'),
(9, 9, 'WICKRAMASINGHE S.N.', '', 6, 'true'),
(10, 10, 'KARUNITHAA M.', '', 6, 'true'),
(11, 11, 'BANUJA V.', '', 6, 'true'),
(12, 12, 'DEWMINI AV', '', 6, 'true'),
(13, 13, 'GUNASEKARA HDD ', '', 6, 'true'),
(14, 14, 'ABEYSINGHEA.AK.C', '', 6, 'true'),
(15, 15, 'PEIRIS P.PH.B.', '', 6, 'true'),
(16, 16, 'PERERAKA.S.LD', '', 6, 'true'),
(17, 17, 'Udisha W.H.I.', '', 6, 'true'),
(18, 18, 'Imran BM', '', 6, 'true'),
(19, 19, 'Shanmugarajah D', '', 6, 'true'),
(20, 20, 'Muniweera K.G.U.K.', '', 6, 'true'),
(21, 21, 'Lourdes Jellorine C', '', 6, 'true'),
(22, 22, 'Nalawansa U.K', '', 6, 'true'),
(23, 23, 'Devakumar P.', '', 6, 'true'),
(24, 24, 'Senevirathne S.A', '', 6, 'true'),
(25, 25, 'Jegatheeswaran V.', '', 6, 'true'),
(26, 26, 'Shahla A.A.F.S.', '', 6, 'true'),
(27, 27, 'RANAWEERA T.R.M.D.S', '', 6, 'true'),
(28, 28, 'SUDARAKA R.A.V', '', 6, 'true'),
(29, 29, 'KARIYAWASAM K.K.S.M.V', '', 6, 'true'),
(30, 30, 'WEERAKOON W.A.D.L', '', 6, 'true'),
(31, 31, 'LAKSHIKA R.M.K', '', 6, 'true'),
(32, 32, 'WICKRAMASINGHE W.M.D.L', '', 6, 'true'),
(33, 33, 'DISSANAYAKA D.M.I.L', '', 6, 'true'),
(34, 34, 'CHITHRAKA P.R', '', 6, 'true'),
(35, 35, 'DISSANAYAKA D.M.S.P ', '', 6, 'true'),
(36, 36, 'PATHIRANA W.P.S.I', '', 6, 'true'),
(37, 37, 'KAWMADI L.G.A.S', '', 6, 'true'),
(38, 38, 'THARUSHI K.H.P', '', 6, 'true'),
(39, 39, 'CHANDRASIRI W.H.T.S', '', 6, 'true'),
(40, 40, 'HEMANTHA H.B.G.P.N', '', 6, 'true'),
(41, 41, 'HERATH H.P.N.I', '', 6, 'true'),
(42, 42, 'BUDDHIMA H.M.H', '', 6, 'true'),
(43, 43, 'MANAMPERI G.M.C', '', 6, 'true'),
(44, 44, 'DHARMASIRI P.C.M', '', 6, 'true'),
(45, 45, 'THILAKARATHNA D.M.I.D', '', 6, 'true'),
(46, 46, 'DISSANAYAKA I.L', '', 7, 'true'),
(47, 47, 'MOHOMMAD P.M.', '', 7, 'true'),
(48, 48, 'HETTIARACHCHI T.N', '', 7, 'true'),
(49, 49, 'RAJASINGHA G.R', '', 7, 'true'),
(50, 50, 'THARUSHI U.K', '', 7, 'true'),
(51, 51, 'LOKARAJA D.C', '', 7, 'true'),
(52, 52, 'PAVANI T.D.N', '', 7, 'true'),
(53, 53, 'RANAPATHI G.S.A', '', 7, 'true'),
(54, 54, 'SAGARIKA D.T.W.D', '', 7, 'true'),
(55, 55, 'KARUNARATHNA S.D', '', 7, 'true'),
(56, 56, 'KUMARI K.L', '', 7, 'true'),
(57, 57, 'DHARMAPRIYA G.D', '', 7, 'true'),
(58, 58, 'SANDUNI T.L', '', 7, 'true'),
(59, 59, 'DASSANAYAKA G.R', '', 7, 'true'),
(60, 60, 'RANIMIKA T.S', '', 7, 'true'),
(61, 61, 'SELVAM D.C', '', 7, 'true'),
(62, 62, 'HETTIGODA K.A', '', 7, 'true'),
(63, 63, 'RAJAPAKSHA R.D', '', 7, 'true'),
(64, 64, 'NIWANDANA T.U', '', 7, 'true'),
(65, 65, 'SENARATHNA R.L', '', 7, 'true'),
(66, 66, 'L. Hariharan', '', 6, 'true'),
(67, 67, 'T. Vartheeswaran', '', 6, 'true'),
(68, 68, 'V. Varaniya', '', 6, 'true'),
(69, 69, 'M. J. F. Ilma', '', 6, 'true'),
(70, 70, 'M. S. K. Alwis', '', 6, 'true'),
(71, 71, 'C. Thanushiga', '', 6, 'true'),
(72, 72, 'B. Ushanthika', '', 6, 'true'),
(73, 73, 'J. M. Kumari', '', 6, 'true'),
(74, 74, 'P. Nivithashini', '', 6, 'true'),
(75, 75, 'B. Kobika', '', 6, 'true'),
(76, 76, 'SOORIYAARACHCHI Y.P', '', 15, 'true'),
(77, 77, 'DARMADASA R.Y', '', 15, 'true'),
(78, 78, 'GAYANI D.H', '', 15, 'true'),
(79, 79, 'PALLIYAGURU G.M', '', 15, 'true'),
(80, 80, 'PIYUMIKA D.S', '', 15, 'true'),
(81, 81, 'RANATHUNGA D.S', '', 15, 'true'),
(82, 82, 'KARUNATHILAKA S.D', '', 15, 'true'),
(83, 83, 'JAYASINHA T.K', '', 15, 'true'),
(84, 84, 'KALANI F.D', '', 15, 'true'),
(85, 85, 'SENARATHNA R.L', '', 15, 'true'),
(86, 86, 'DARMIKAM J.L', '', 15, 'true'),
(87, 87, 'PERERA G.D', '', 15, 'true'),
(88, 88, 'TANAKA S.H', '', 15, 'true'),
(89, 89, 'DASSANAYAKA R.M', '', 15, 'true'),
(90, 90, 'SHANIKA T.S', '', 15, 'true'),
(91, 91, 'RANASINHA D.C', '', 15, 'true'),
(92, 92, 'MIHIRANI K.A', '', 15, 'true'),
(93, 93, 'RAJAPAKSHA T.N.D.R.S', '', 15, 'true'),
(94, 94, 'JAYASIRI T.U', '', 15, 'true'),
(95, 95, 'SENARATHNA R.L.B', '', 15, 'true');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(250) NOT NULL,
  `email` varchar(500) NOT NULL,
  `password` varchar(250) NOT NULL,
  `role_id` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `user_name`, `email`, `password`, `role_id`) VALUES
(21, 'fasadmin@gmail.com', 'fasadmin@gmail.com', '$2b$10$tjbGkyWyz5diZ58OuKJP/eAZRUhgo8as89PwtIxy5RqVL9zzrCrNq', '2'),
(22, 'fbsadmin@gmail.com', 'fbsadmin@gmail.com', '$2b$10$dWkx5Y3EPBMn5CFcSqoda.FQW7KmgYG7RrqJFZI8jQMK7LCBu5jZm', '2'),
(23, 'ftsadmin@gmail.com', 'ftsadmin@gmail.com', '$2b$10$hYNq16yVPHrj.5TMPbGvyeck0JsxsOejL2G7TvNi3OmvrilG2MwGm', '2'),
(24, 'phyadmin@gmail.com', 'phyadmin@gmail.com', '$2b$10$fRClBW4EyEwAMgdgjUzQlelgw9ujerfLMojPdm8plnvokHf7tIAhm', '3'),
(25, 'bioadmin@gmail.com', 'bioadmin@gmail.com', '$2b$10$epgwDYognXrJMTK0ySZ99u5rB/CRzp5GliSYEH4eGU0fpza8nAUwq', '3'),
(26, 'beadmin@gmail.com', 'beadmin@gmail.com', '$2b$10$qMUkLMZpb9K5SBSe0GUIi.1KxPwepgTLlG.NdVy4mmmLOltzBKn3m', '3'),
(27, 'eltadmin@gmail.com', 'eltadmin@gmail.com', '$2b$10$JmscW9BkeI0TEQ6L6zFSi.ALPt/hbt0uKzxB4fTZFX3Sy1RZ5JWhq', '3'),
(28, 'faadmin@gmail.com', 'faadmin@gmail.com', '$2b$10$x37rhTq8.SyIiRKhPUfAqOL042738NzCKDHg28kDgDOlZt7MPR/dm', '3'),
(29, 'hrmadmin@gmail.com', 'hrmadmin@gmail.com', '$2b$10$frwkLjZBbd7.LNKgLS8D4u4kNUMQxv2XMCrk/QxsV/O260/cQY8Vm', '3'),
(30, 'meadmin@gmail.com', 'meadmin@gmail.com', '$2b$10$4nRtHZfB0i4AWkb8uoD7pOPcPi8iRsMKveRoY1Z4R0u91emDEA6YO', '3'),
(31, 'mmadmin@gmail.com', 'mmadmin@gmail.com', '$2b$10$5jO0rlKeVj8lZWjlagGzLeV3BIUOiknntQPjBc8K1cq/hsSKfGPua', '3'),
(32, 'pmadmin@gmail.com', 'pmadmin@gmail.com', '$2b$10$EME7.xEfUgZiRZw4eLQ8oe9tasRWGIi/3wqYGBmIxI6DSIyFU7972', '3'),
(33, 'ictadmin@gmail.com', 'ictadmin@gmail.com', '$2b$10$D3UvMPr//9bMgZBFRyxT/.oVc18X4HZ9B/GPWsm2sURgU6/Rb.YD2', '3'),
(34, ' 2022/ICT/01', 'bkelum@gmail.com', '$2b$10$7n5bCycYkvSsF1DZGg5ZsuTT7fOJQuk3KRe8wM2LL7D10CmWJOfEK', '5'),
(35, '2022/ICT/02', 'mjayasinghe@gmail.com', '$2b$10$5fD/Z5ePoCHFx8HQXF7xN.AeKRPqy3t5sRhxIq.g.jQWfvg8oSSlS', '5'),
(36, '2022/ICT/03', 'swickramasinghe@gmail.com', '$2b$10$RvjcHSnhw.bOeJvIEibrRurFpPxWiPKDMVhQK6WSgcqgDQfF0cpkq', '5'),
(37, '2022/ICT/05', 'mkarunithaa@gmail.com', '$2b$10$nogcJrKCJ.JbTji9f6u8veTQ6m3DD6pofMUDLleABHbFrBmsAMYVm', '5'),
(38, '2022/ICT/06', 'vbanuja@gmail.com', '$2b$10$9H1Rm2iSjV.m05sLaXcRyuIxIj5kPbDcDlCfJoaf2t2km/MzkwJTy', '5'),
(39, '2022/ICT/09', 'adewmini@gmail.com', '$2b$10$C5IiMOWgo3KuAX96DK03wuLsHoDUDOqF0AgcDWIDrPSts/Sn6m61q', '5'),
(40, '2022/ICT/10', 'hgunasekara@gmail.com', '$2b$10$jLntnXsK2E4tF6vpiLHqg.vYEjxDPR0KXX4coXSTDOKIAlLEYgbtu', '5'),
(41, '2022/ICT/11', 'aabeysinghea@gmail.com', '$2b$10$TWtiP5kofH1h5/ADYLfIzOFk78NNIGDnqXFtCOC8TmRGXszUUID2S', '5'),
(42, '2022/ICT/12', 'ppeiris@gmail.com', '$2b$10$W.Wl9lkAVQcOySx6y.jWVum.z3DB8nxqxRMJ042htYHJpmZVIBZ2u', '5'),
(43, '2022/ICT/13', 'spereraka@gmail.com', '$2b$10$m3e/dKu84MNqF8FCh9DWje59YBnHkjgz.FAmri9TvpJn9SZkTKEc2', '5'),
(44, '2020/ICT/01', 'wudisha@gmail.com', '$2b$10$5bk84ZjHaWiFFdnNxItkeOUEFY1qMbghMUCJR2EbZDgc/3wdmtas6', '5'),
(45, '2020/ICT/02', 'bimran@gmail.com', '$2b$10$p.vJXU/ViwwW26h/lbdtq.ZpxBdCpJuqPpXO5/5AS/XU0J4pTD8G6', '5'),
(46, '2020/ICT/03', 'dshanmugarajah', '$2b$10$b6sPKM8s8NrczR6eGMZ/cONjzraYVHIqtQk7Kr9WbWrl8Q49Nl/RO', '5'),
(47, '2020/ICT/05', 'kmuniweera@gmail.com', '$2b$10$putP0n1sIGDlKjaXvkoNTu2to6FF.r2TD1gtHQMuamztyZfRgmUFy', '5'),
(48, '2020/ICT/06', 'cjellorine@gmail.com', '$2b$10$7QaUkCeoPJ5qheyRL3UJ.O.ycIIYPABRwSJ8Qb9Yp5HvZSpqShyeG', '5'),
(49, '2020/ICT/07', 'unalawansa@gmail.com', '$2b$10$I1Y6.e5a91z2xz5C5beg9uHaXbiL9D43XWx5Iwg/.KWJ6W1GHyXtC', '5'),
(50, '2020/ICT/08', 'pdevakumar@gmail.com', '$2b$10$Ao9Q7GHKUO4nAsAUbaSG3.HZNBZuDKDUe/M2EzYn9lHLVs8MiJ0g.', '5'),
(51, '2020/ICT/09', 'ssenevirathne@gmail.com', '$2b$10$glrPhKLSsi/Oh1Vl9E5ylOHigTJMPYSaqMmzPPRK39AoF5w7RzIJa', '5'),
(52, '2020/ICT/10', 'vjegatheeswaran@gmail.com', '$2b$10$vayLEWC62lD.oWC06ZT9XOdKOND4qja3QYIRegk7e/DTW/qxlOqz6', '5'),
(53, '2020/ICT/12', 'ashahla@gmail.com', '$2b$10$ZaP4OQsQM4fCTHnxgmAQnOaZQncN9adBLbwLIivjc4sYYFdr8gQwO', '5'),
(54, '2022/ASP/03', 'tranaweera@gmail.com', '$2b$10$A2StP4FRInMKwYMbbKgG1./6Yo/R7d4Gty1tfTtu6Te6ydER614xC', '5'),
(55, '2022/ASP/12', 'rsudarak@gmail.com', '$2b$10$J5587sbFAkgMfHsji5fK3eIztcZ9/Te03/O5KiQmA.GvGYbHf.WPG', '5'),
(56, '2022/ASP/17', 'kkariyawasam@gmail.com', '$2b$10$ZWpimvEvjUqZtKllpVfoZeDcvWNF4H4OW6/DHx4Gs99kZFBxIOdsy', '5'),
(57, '2022/ASP/21', 'wweerakoon@gmail.com', '$2b$10$mlY0OHxt8guwTQ3RUFECY.Jj66PHKm.Z/.lSGeOTASAJ3ZgpVNGIK', '5'),
(58, '2022/ASP/25', 'rlakshika@gmail.com', '$2b$10$1bdUJuz09uIpWzoKtLF/JeLB4gUGYOQOkkF4AnGwbsFga7j8I2SOi', '5'),
(59, '2022/ASP/27', 'lwickramasinghe@gmail.com', '$2b$10$bN8riE9A5ldzYdDcytypSOEQaQXBJRxZDRBCMd/eLgeE7l8u5HGZ6', '5'),
(60, '2022/ASP/32', 'ddissanayaka@gmail.com', '$2b$10$RkbhU4i6iJblC2O0KHcbje/.aPatAfZJm0ePmbz725UEiETqCFahi', '5'),
(61, '2022/ASP/37', 'pchithraka@gmail.com', '$2b$10$bbMuRf6hQ0iJb0W1lEfGfuDWORLs6w3m4ZZ.sh8RTKt2yXGUxCnW6', '5'),
(62, '2022/ASP/38', 'ddissanayaka123@gmail.com', '$2b$10$E5nXIn8C/byMTvvOt27Tj.5b.Bjmq4I1eNfIuMf6brJj./3MO33Ca', '5'),
(63, '2021/ASP/01', 'wpathirana@gmail.com', '$2b$10$rBcJ9Eup5apAtZ1opKCquekV3jm6BxtcmgOs7VwxiDGpzpYzbtQ8m', '5'),
(64, '2021/ASP/04', 'lkawmadi@gmail.com', '$2b$10$asBbu4cZQzEqD5bJo8cKKu2xNNsB0xi27ag9tZsOLL6H.tdQISU/m', '5'),
(65, '2021/ASP/05', 'ktharushi@gmail.com', '$2b$10$F9lUUUA3YIpWuuey.iHeCuNwxqgNQmyYH41/.r9RtjEudXXlH2Udu', '5'),
(66, '2021/ASP/09', 'wchandrasiri@gmail.com', '$2b$10$Ktf3Tw6hu9/R379zmlghce8BAw7LYrvX4lsKdSyQfVXeF4a0pa6x2', '5'),
(67, '2021/ASP/12', 'hhemantha@gmail.com', '$2b$10$vCa5PI/kFjXiexzBdm.rOeT12T2/Q99L1qRH8aGSvO9ariRtBo0qm', '5'),
(68, '2021/ASP/15', 'hherath@gmail.com', '$2b$10$SN66Mvx2lT9bIh8nj/cKv.qemyl4APllfzkLivgZQ5cfw6YHlI9SG', '5'),
(69, '2021/ASP/16', 'hbuddhima@gmail.com', '$2b$10$30A0NrZupTIM9hyR6a28E.jEPrYXMB1yw6ZgGFboh0ElUpCGCoLb2', '5'),
(70, ' 2021/ASP/20', 'gmanamperi@gmail.com', '$2b$10$xRscShrzu0gsLYR8YrQ1kujtH155MexWFrMUEjGplztkULzzEpy7O', '5'),
(71, '2021/ASP/24', 'pdharmasiri@gmail.com', '$2b$10$0Lpv8G.uwf5SQnGkMbchZO5rK1qaaFAypO0WQ2aaXpqXIFngIJvC.', '5'),
(72, '2021/ASP/29', 'dthilakarathna@gmail.com', '$2b$10$TNUaOYhB1uRek1CvwmuUtehHCyVVo7c1ZxZ8yDBbz/qTBwGN8hItW', '5'),
(73, '2021/ASB/01', 'idissanayaka@gmail.com', '$2b$10$MkB25mNJHgSNNSVZQ/ppCu2DvcbN56i752Vqkg4qru2qCTXlggIvu', '5'),
(74, '2021/ASB/02', 'pmohommad@gmail.com', '$2b$10$ZSSFOw2TlxSVL0.d2N3SsODmSsw9Uvh0Qd2hKAEOgRDgkuyhF0Jle', '5'),
(75, '2021/ASB/03', 'thettiarachchi@gmail.com', '$2b$10$lR8P1GNbdJQB29BMRRaYh.fg1H4LcEB4aec3F.2qKQJQnf6jWU6PK', '5'),
(76, '2021/ASB/05', 'grajasingha@gmail.com', '$2b$10$/UTotDPnfr7Fa392wmBr2OxeM2x0qWb8pRwagzVPVxvj1j48jlgfG', '5'),
(77, '2021/ASB/06', 'utharushi@gmail.com', '$2b$10$29qIatDczXejjB4/u5PFq.CBA9VN4aVSZ2jpEtXas9iPNB4mQs92m', '5'),
(78, '2021/ASB/07', 'dlokaraja@gmail.com', '$2b$10$S/6bAvo5mt/tAe04Y7H6E.cZ24pHzE.PHlEX6Fx.49SaOzEOpuDeq', '5'),
(79, '2021/ASB/08', 'tpavani@gmail.com', '$2b$10$1BPdeGxnK2N1qbp/4Gfj7eT9veoARsGl/YZrD7lGW18dCr/3rOz6i', '5'),
(80, '2021/ASB/09', 'granapathi@gmail.com', '$2b$10$MMHN1O69EhxOY6bOiulL.uKbFLq0LIkS.dYK19ZCTW6/2gfOarDhq', '5'),
(81, '2021/ASB/10', 'tsagarika@gmail.com', '$2b$10$OX4UZ5Pq4g1leY11sHh5bO5Us9kPJFjmITHy9457TdvDApDYxjJCC', '5'),
(82, '2021/ASB/12', 'skarunarathna@gmail.com', '$2b$10$TiqOi50nHd5trc0qfwOrEuEbDjcHq.gD3k97d5VuAidK6caM8S.NO', '5'),
(83, '2020/ASB/01', 'lkumari@gmail.com', '$2b$10$Xke7ryaJflxMnWUaVxh7DeHCfxYrfKSFvr4ZWchRXbOfZLHZrbwVm', '5'),
(84, '2020/ASB/02', 'gdharmapriya@gmail.com', '$2b$10$gufcSWlCckMJ/4TcoEpALedFEf/7p4Y8dXwNSSJVc9.hORsp.wS12', '5'),
(85, '2020/ASB/03', 'lsanduni@gmail.com', '$2b$10$9Q4GrdGlVKvbXqFYVMo93ODq3yB/DeolXDsMqhi6S1fgl.WL5syji', '5'),
(86, '2020/ASB/05', 'gdassanayaka1@gmail.com', '$2b$10$1pFDm4ihhZAnAAWLENABGeDpeXS1FNYZaj5njIgygbS5UD3AM1LDK', '5'),
(87, '2020/ASB/06', 'tranimika@gmail.com', '$2b$10$/yM23Ejf5IyMLh0slKRzcepsj5LAa6R9/qQayHUtohfiJ74385hqO', '5'),
(88, '2020/ASB/07', 'dselvam@gmail.com', '$2b$10$FuZMSIkpEuWNVeAep6IfFO8l3eKkogapj5frSAP7MFz2mXQ36UgeG', '5'),
(89, '2020/ASB/08', 'khettigoda@gmail.com', '$2b$10$ZdqirPoAeegu5XOCCzwCSuZaGl2uYhDiFtcg3.dPGi9f9HiHmoNj.', '5'),
(90, '2020/ASB/09', 'rrajapaksha@gmail.com', '$2b$10$hbGmCDbYW0iEeJuzx3dsKObl7MMs./A26DRbNm2rLf3wSreoECoHC', '5'),
(91, '2020/ASB/10', 'tniwandana@gmail.com', '$2b$10$Zm2a1cUCxp.vkn8oJ1xr2eNbAZyb0oOTvkg9lGDyoczI9qp.XANtS', '5'),
(92, '2020/ASB/12', 'rsenarathna@gmail.com', '$2b$10$xqsoo8ne5PTqjHhkHVOk5ud6TcmeRuXNiFvvCxyuz/6XXUHnQfmJq', '5'),
(93, '2019/ASP/01', 'lhariharan@gmail.com', '$2b$10$cQBUkzwNzVIm3StMQis0HOX8dPPAteMR0A0rNcHXtM/52x5eP9lwW', '5'),
(94, '2019/ASP/02', 'tvartheeswaran@gmail.com', '$2b$10$WW6uuKdWv0G/QZ/E8D9OFu/I82FdKWCTQmm4FSURWEKjoiwlRRdGO', '5'),
(95, '2019/ASP/03', 'vvaraniya@gmail.com', '$2b$10$y9mpQ0CJLMbFCL0LXr.OY.YbUd4YfJzWVW9Yq2qbn1kCXWqgsjeL6', '5'),
(96, '2019/ASP/04', 'filma@gmail.com', '$2b$10$weXduIOIWHh2NP9yFugVuuD6gJNnLRPTFLZulcMrOL2tAE/tKJ6MS', '5'),
(97, '2019/ASP/08', 'kalwis@gmail.com', '$2b$10$AiTVMIA515Oa8XVQISVAbe5B1ZX2txX77PXE78.HzDNdbnzNpGeJi', '5'),
(98, '2019/ASP/15', 'cthanusiga@gmail.com', '$2b$10$3/RLbPPvrnmvytsBspaL6OLBVeBMI4ydfdXkZq9dpTxaSkcyYApiC', '5'),
(99, '2019/ASP/17', 'bushanthika@gmail.com', '$2b$10$gNuT09czYZpBRkk1g/dUBewoqHtFqOGvO/Md56CUqyUegbVnAPU0O', '5'),
(100, '2019/ASP/21', 'mkumari@gmail.com', '$2b$10$7hTjllKFlS9QoO0hiri4A.EINvpWisGdAaocdRPxHl.PcJDZuk04G', '5'),
(101, '2019/ASP/24', 'pnivithashini@gmail.com', '$2b$10$RT0Nm4qLvBb9TRqIcMhZb.ysc1KIc1nLhj3qh1udtSnjtjsmQYmom', '5'),
(102, '2019/ASP/29', 'bkobika@gmail.com', '$2b$10$aJN8.HciWOdcgADvH.MLiuVAmkBxkcwKJXtVCq8XnzkuCZup1ffRW', '5'),
(103, '2022/TICT/01', 'ysooriyaarachchi@gmail.com', '$2b$10$gOQomAI3uqTxyM8G3XCcuuyL8LH71YwAUToObhnDho3E8KdoOgUN2', '5'),
(104, '2022/TICT/02', 'rdarmadasa@gmail.com', '$2b$10$DY60OL9LSOaM8k5.bdT2uubRYpE6AjsXrBPK0R8I8e5pLJxmCRgYi', '5'),
(105, '2022/TICT/03', 'dgayani@gmail.com', '$2b$10$./2YFtPiI7NOetefAH4r1eDGHFe3Q0OpJ1sT9xcM6FTMWgCKslG7q', '5'),
(106, '2022/TICT/04', 'gpalliyaguru@gmail.com', '$2b$10$Gs/acUJffd5gv7S3L0JHRO/MnN4b.06zVe7XCoafwG6lNGWOmHpyO', '5'),
(107, '2022/TICT/05', 'dpiyumika@gmail.com', '$2b$10$WZprdRElEU9Dsvm5xW2Eue4lh/B8FL/77CY8jtlTwMdsoCO1lb3Xq', '5'),
(108, '2022/TICT/06', 'dranathunga@gmail.com', '$2b$10$u8sLf8gT02.hW3KfHX7S9eWFF.X9jkfYKmoem9q9ysc94/C7R5EgO', '5'),
(109, '2022/TICT/07', 'skarunathilaka@gmail.com', '$2b$10$VwdvLg9gM/kdtNEkF7NOgeXoDUaor7J.8EHRzGhhHC3Y9aThoNuyC', '5'),
(110, '2022/TICT/08', 'tjayasinha@gmail.com', '$2b$10$ugiZs6LROWK24XzyKes/nOGWCGoYc6hryuXYf09ncO5Ns99rIkqwK', '5'),
(111, '2022/TICT/9', 'fkalani@gmail.com', '$2b$10$NqeBzZGQNm0ZPyp94lwvNulR7rUDO1cura66tXOyn5xb1aIEAXPCm', '5'),
(112, '2022/TICT/11', 'rlsenarathna@gmail.com', '$2b$10$YrwwaKmA3DjwcYuSCF5JoOoXaSbNv9qCOB2RlN5xufpLzf1i/0jEW', '5'),
(113, '2021/TICT/01', 'jdarmikam@gmail.com', '$2b$10$RA9Q30rxyThse4U16K0Bq.yzsa3.FfPfeUB8U0jZgXnbyNLkjAsKi', '5'),
(114, '2021/TICT/02', 'gperera@gmail.com', '$2b$10$T9YxuQTOXqD2fYS2nZzCVe1wXTgXz4t8h8JFi4f8iXDW8e4Wa4VpG', '5'),
(115, '2021/TICT/03', 'stanaka@gmail.com', '$2b$10$GZdhQu9B/qYi3di2BJAoP.tVUZM/siRgfVdAT0.avaKhVflH0h6RW', '5'),
(116, '2021/TICT/04', 'rmdassanayaka@gmail.com', '$2b$10$0jA0VFh1QcEuyaidfLXMT.GeoSuOm0G2GMuZm6kCvhWr4fQltgZWu', '5'),
(117, '2021/TICT/06', 'tsshanika@gmail.com', '$2b$10$HLxOH0rqZSAkt1st977L0.97dK07LDK6vXEdDM3x.vV6WOoVQve3u', '5'),
(118, '2021/TICT/07', 'dc1ranasinha@gmail.com', '$2b$10$SLHO5dtp7O6utgbkHb8RTuiHpbiwczQb58eDUo2NP7z3VTP1KiLsm', '5'),
(119, '2021/TICT/08', 'kamihirani@gmail.com', '$2b$10$4lZoqihhCEHvejM5MK9SNuUJZdUSw4SyA4bW90XDQ1sWS/YZYAYBC', '5'),
(120, '2021/TICT/09', 'tnrajapaksha', '$2b$10$V1zB.DJpCM3mJIRX2j3qou9v3F59BNYab9JbAB1j2pXAuoZGiO8te', '5'),
(121, '2021/TICT/10', 'tujayasiri@gmail.com', '$2b$10$0KYmVCsgZGfyh055XxJ23ubuy9HId2pVuqhxw9zUwkCJE7yO2loAO', '5'),
(122, '2021/TICT/11', 'rlbsenarathna@gmail.com', '$2b$10$ODYqeF5PEVzThqh9/oJUROcdlftXuPjRLVmEI1i/rFtmvwZiVaBjq', '5'),
(123, 'svadivel@vau.ac.lk', 'svadivel@gmail.com', '$2b$10$mS8bhHqntIOxpm0Or9LJhOb0arT9fXspS0yVaKCU.GVZcxJW0vUBm', '4'),
(124, 'jfernando@vau.ac.lk', 'jfernando@gmail.com', '$2b$10$51k8NNI/eimpYJKerHVBZOXPk1K8tkyt1/yO0bDi.P4TkpYY7Qy5i', '4'),
(125, 'srajesh@vau.ac.lk', 'srajesh@gmail.com', '$2b$10$aaFfvVcaiijBaq0GWUmz0ehOJEGGbWOYylDr8SbC14yPtyd/yU9MO', '4'),
(126, 'tanuradha@vau.ac.lk', 'tanuradha@gmail.com', '$2b$10$r2NXOqkjKf0x./N9DLa6QuzMIbTgqeIg6H6rflSNdbM4LpjyNpvni', '4'),
(127, 'nsivakumar@vau.ac.lk', 'nsivakumar@gmail.com', '$2b$10$jgFUkNuoXiR8n1nxUrkHuukjBGYtq5YLmCkPGlciuybfgFPHk3A42', '4');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `batch`
--
ALTER TABLE `batch`
  ADD PRIMARY KEY (`batch_id`);

--
-- Indexes for table `batch_curriculum_lecturer`
--
ALTER TABLE `batch_curriculum_lecturer`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD PRIMARY KEY (`sub_id`);

--
-- Indexes for table `degree`
--
ALTER TABLE `degree`
  ADD PRIMARY KEY (`deg_id`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`d_id`);

--
-- Indexes for table `dep_deg`
--
ALTER TABLE `dep_deg`
  ADD PRIMARY KEY (`d_id`,`deg_id`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`f_id`);

--
-- Indexes for table `fac_dep`
--
ALTER TABLE `fac_dep`
  ADD PRIMARY KEY (`f_id`,`d_id`);

--
-- Indexes for table `manager`
--
ALTER TABLE `manager`
  ADD PRIMARY KEY (`m_id`);

--
-- Indexes for table `manager_detail`
--
ALTER TABLE `manager_detail`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`s_id`,`user_id`);

--
-- Indexes for table `student_detail`
--
ALTER TABLE `student_detail`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `batch`
--
ALTER TABLE `batch`
  MODIFY `batch_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `batch_curriculum_lecturer`
--
ALTER TABLE `batch_curriculum_lecturer`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `curriculum`
--
ALTER TABLE `curriculum`
  MODIFY `sub_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `degree`
--
ALTER TABLE `degree`
  MODIFY `deg_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `d_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `faculty`
--
ALTER TABLE `faculty`
  MODIFY `f_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `manager`
--
ALTER TABLE `manager`
  MODIFY `m_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `manager_detail`
--
ALTER TABLE `manager_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `student`
--
ALTER TABLE `student`
  MODIFY `s_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `student_detail`
--
ALTER TABLE `student_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=128;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
