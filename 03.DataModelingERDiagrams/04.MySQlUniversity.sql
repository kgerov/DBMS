-- phpMyAdmin SQL Dump
-- version 4.1.12
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Feb 11, 2015 at 05:17 PM
-- Server version: 5.6.16
-- PHP Version: 5.5.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

--
-- Database: `university`
--
CREATE DATABASE IF NOT EXISTS `university` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
USE `university`;

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
CREATE TABLE IF NOT EXISTS `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  `ProfessorId` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=2 ;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `Name`, `ProfessorId`) VALUES
(1, 'C# Basics', 1);

-- --------------------------------------------------------

--
-- Table structure for table `coursesstudetns`
--

DROP TABLE IF EXISTS `coursesstudetns`;
CREATE TABLE IF NOT EXISTS `coursesstudetns` (
  `CourseId` int(11) NOT NULL,
  `StudentId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `coursesstudetns`
--

INSERT INTO `coursesstudetns` (`CourseId`, `StudentId`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
CREATE TABLE IF NOT EXISTS `departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  `FacultyId` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=3 ;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `Name`, `FacultyId`) VALUES
(1, 'Computer Science', 2),
(2, 'Will Smith', 2);

-- --------------------------------------------------------

--
-- Table structure for table `faculties`
--

DROP TABLE IF EXISTS `faculties`;
CREATE TABLE IF NOT EXISTS `faculties` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=3 ;

--
-- Dumping data for table `faculties`
--

INSERT INTO `faculties` (`id`, `Name`) VALUES
(1, 'Fac1'),
(2, 'Fac2');

-- --------------------------------------------------------

--
-- Table structure for table `professors`
--

DROP TABLE IF EXISTS `professors`;
CREATE TABLE IF NOT EXISTS `professors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  `DepartmentId` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=2 ;

--
-- Dumping data for table `professors`
--

INSERT INTO `professors` (`id`, `Name`, `DepartmentId`) VALUES
(1, 'Will Smith', 1);

-- --------------------------------------------------------

--
-- Table structure for table `professorstitles`
--

DROP TABLE IF EXISTS `professorstitles`;
CREATE TABLE IF NOT EXISTS `professorstitles` (
  `ProfessorId` int(11) NOT NULL,
  `TitleId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `professorstitles`
--

INSERT INTO `professorstitles` (`ProfessorId`, `TitleId`) VALUES
(1, 1),
(1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
CREATE TABLE IF NOT EXISTS `students` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  `FacultyId` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=2 ;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `Name`, `FacultyId`) VALUES
(1, 'Gosheto', 1);

-- --------------------------------------------------------

--
-- Table structure for table `titles`
--

DROP TABLE IF EXISTS `titles`;
CREATE TABLE IF NOT EXISTS `titles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(50) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_bin AUTO_INCREMENT=3 ;

--
-- Dumping data for table `titles`
--

INSERT INTO `titles` (`id`, `Name`) VALUES
(1, 'Ph.D.'),
(2, 'Idiot');