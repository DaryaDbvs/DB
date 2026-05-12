/*
Created: 29.04.2026
Modified: 29.04.2026
Model: Microsoft SQL Server 2019
Database: MS SQL Server 2019
*/
use master;
go

if exists(select 1 from sys.databases where name ='Orchestraa')
begin
alter database Orchestra set single_user with rollback IMMEDIATE;
drop database Orchestraa;
end;
go 
create database Orchestraa;
go

use Orchestraa

-- Table Musician

CREATE TABLE [Musician]
(
 [MusicianID] Int NOT NULL,
 [MusicianName] Nvarchar(50) NOT NULL,
 Age INT,
 ExperienceYears INT,
 CONSTRAINT [PK_Musician] PRIMARY KEY ([MusicianID])
)
AS NODE
go

-- Table Instrument

CREATE TABLE [Instrument]
(
 [InstrumentID] Int NOT NULL,
 [InstrumentType] Nvarchar(50) NOT NULL,
 CONSTRAINT [PK_Instrument] PRIMARY KEY ([InstrumentID])
)
AS NODE
go
CREATE TABLE Section (
    SectionID INT,
    SectionName NVARCHAR(50), 
    SeatsCount INT,
    OrchestraPosition NVARCHAR(50),
    CONSTRAINT [PK_Section] PRIMARY KEY ([SectionID])
) AS NODE
go

CREATE TABLE PlaysInstrument (
    JoinDate DATE,
    SkillLevel INT,
    IsPrimaryInstrument BIT
) AS EDGE


ALTER TABLE [PlaysInstrument] ADD CONSTRAINT [EC_Musician_Instrument] CONNECTION (
  [Musician] TO [Instrument])
go

CREATE TABLE BelongsToSection (
    JoinDate DATE,
    RoleInSection NVARCHAR(50),
    SeatNumber INT
) AS EDGE
go

ALTER TABLE [BelongsToSection] ADD CONSTRAINT [EC_Musician_Section] CONNECTION (
  [Musician] TO [Section])
go

CREATE TABLE BelongsToInstrumentGroup (
    Priority INT, 
    TypicalSeatingPosition NVARCHAR(50), 
    OrchestralScoreOrder INT 
) AS EDGE
go

ALTER TABLE [BelongsToInstrumentGroup] ADD CONSTRAINT [EC_Instrument_Section] CONNECTION (
  [Instrument] TO [Section])
go


INSERT INTO Musician VALUES 
    (1, 'Иван Петров', 34, 15),
    (2, 'Анна Смирнова', 28, 10),
    (3, 'Михаил Козлов', 41, 22),
    (4, 'Елена Васильева', 26, 8),
    (5, 'Дмитрий Соколов', 39, 18),
    (6, 'Ольга Новикова', 31, 12),
    (7, 'Алексей Морозов', 44, 25),
    (8, 'Татьяна Павлова', 29, 11),
    (9, 'Сергей Волков', 36, 16),
    (10, 'Мария Соловьева', 33, 14);
GO

INSERT INTO Instrument VALUES 
    (101, 'Скрипка'),
    (102, 'Альт'),
    (103, 'Виолончель'),
    (104, 'Контрабас'),
    (105, 'Флейта'),
    (106, 'Гобой'),
    (107, 'Кларнет'),
    (108, 'Фагот'),
    (109, 'Труба'),
    (110, 'Валторна');
GO

INSERT INTO Section VALUES 
    (201, 'Первые скрипки', 12, 'Левая сцена спереди'),
    (202, 'Вторые скрипки', 10, 'Левая сцена сзади'),
    (203, 'Альты', 8, 'Центр справа'),
    (204, 'Виолончели', 8, 'Справа спереди'),
    (205, 'Флейты', 4, 'Левая сцена верхний ярус'),
    (206, 'Контрабасы', 4, 'Справа сзади'),
    (207, 'Гобои', 3, 'Центр верхний ярус'),
    (208, 'Кларнеты', 4, 'Центр верхний ярус'),
    (209, 'Трубы', 4, 'Задняя сцена'),
    (210, 'Валторны', 4, 'Задняя сцена');
GO

INSERT INTO PlaysInstrument VALUES 
    -- Скрипка (101) - ТОЛЬКО 2 МУЗЫКАНТА (Иван и Анна)
    ((SELECT $node_id FROM Musician WHERE MusicianID = 1), (SELECT $node_id FROM Instrument WHERE InstrumentID = 101), '2010-09-01', 9, 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 2), (SELECT $node_id FROM Instrument WHERE InstrumentID = 101), '2012-08-15', 8, 1),
    
    -- Альт (102) - Сергей Волков
    ((SELECT $node_id FROM Musician WHERE MusicianID = 9), (SELECT $node_id FROM Instrument WHERE InstrumentID = 102), '2009-05-23', 8, 1),
    
    -- Виолончель (103) - Михаил Козлов
    ((SELECT $node_id FROM Musician WHERE MusicianID = 3), (SELECT $node_id FROM Instrument WHERE InstrumentID = 103), '2005-10-10', 9, 1),
    
    -- Контрабас (104) - Дмитрий Соколов
    ((SELECT $node_id FROM Musician WHERE MusicianID = 5), (SELECT $node_id FROM Instrument WHERE InstrumentID = 104), '2008-04-12', 8, 1),
    
    -- Флейта (105) - Елена Васильева
    ((SELECT $node_id FROM Musician WHERE MusicianID = 4), (SELECT $node_id FROM Instrument WHERE InstrumentID = 105), '2015-06-20', 7, 1),
    
    -- Гобой (106) - Татьяна Павлова
    ((SELECT $node_id FROM Musician WHERE MusicianID = 8), (SELECT $node_id FROM Instrument WHERE InstrumentID = 106), '2014-09-17', 7, 1),
    
    -- Кларнет (107) - Ольга Новикова (играет на кларнете как второй инструмент)
    ((SELECT $node_id FROM Musician WHERE MusicianID = 6), (SELECT $node_id FROM Instrument WHERE InstrumentID = 107), '2015-05-10', 6, 0),
    
    -- Фагот (108) - Сергей Волков (второй инструмент)
    ((SELECT $node_id FROM Musician WHERE MusicianID = 9), (SELECT $node_id FROM Instrument WHERE InstrumentID = 108), '2016-03-15', 5, 0),
    
    -- Труба (109) - Алексей Морозов
    ((SELECT $node_id FROM Musician WHERE MusicianID = 7), (SELECT $node_id FROM Instrument WHERE InstrumentID = 109), '2002-03-15', 10, 1),
    
    -- Валторна (110) - Иван Петров (второй инструмент)
    ((SELECT $node_id FROM Musician WHERE MusicianID = 1), (SELECT $node_id FROM Instrument WHERE InstrumentID = 110), '2014-11-20', 5, 0),
    
    -- Валторна (110) - Михаил Козлов (второй инструмент)
    ((SELECT $node_id FROM Musician WHERE MusicianID = 3), (SELECT $node_id FROM Instrument WHERE InstrumentID = 110), '2015-02-10', 4, 0);
GO


INSERT INTO BelongsToSection VALUES 
    ((SELECT $node_id FROM Musician WHERE MusicianID = 1), (SELECT $node_id FROM Section WHERE SectionID = 201), '2010-09-01', 'Концертмейстер', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 2), (SELECT $node_id FROM Section WHERE SectionID = 202), '2012-08-15', 'Второй пульт', 3),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 3), (SELECT $node_id FROM Section WHERE SectionID = 204), '2005-10-10', 'Концертмейстер', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 4), (SELECT $node_id FROM Section WHERE SectionID = 205), '2015-06-20', 'Солистка', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 5), (SELECT $node_id FROM Section WHERE SectionID = 206), '2008-04-12', 'Концертмейстер', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 6), (SELECT $node_id FROM Section WHERE SectionID = 208), '2015-05-10', 'Второй пульт', 2),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 7), (SELECT $node_id FROM Section WHERE SectionID = 209), '2002-03-15', 'Концертмейстер', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 8), (SELECT $node_id FROM Section WHERE SectionID = 207), '2014-09-17', 'Солистка', 1),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 9), (SELECT $node_id FROM Section WHERE SectionID = 203), '2009-05-23', 'Первый пульт', 2),
    ((SELECT $node_id FROM Musician WHERE MusicianID = 10), (SELECT $node_id FROM Section WHERE SectionID = 202), '2011-01-30', 'Первый пульт', 2);
GO
INSERT INTO BelongsToSection VALUES 
    ((SELECT $node_id FROM Musician WHERE MusicianID = 1),
     (SELECT $node_id FROM Section WHERE SectionID = 210),
     '2020-01-15', 'Второй пульт', 6);
GO

INSERT INTO BelongsToInstrumentGroup VALUES 
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 101), (SELECT $node_id FROM Section WHERE SectionID = 201), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 101), (SELECT $node_id FROM Section WHERE SectionID = 202), 1, 'Первый пульт', 2),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 102), (SELECT $node_id FROM Section WHERE SectionID = 203), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 103), (SELECT $node_id FROM Section WHERE SectionID = 204), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 104), (SELECT $node_id FROM Section WHERE SectionID = 206), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 105), (SELECT $node_id FROM Section WHERE SectionID = 205), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 106), (SELECT $node_id FROM Section WHERE SectionID = 207), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 107), (SELECT $node_id FROM Section WHERE SectionID = 208), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 108), (SELECT $node_id FROM Section WHERE SectionID = 207), 2, 'Второй пульт', 3),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 109), (SELECT $node_id FROM Section WHERE SectionID = 209), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 110), (SELECT $node_id FROM Section WHERE SectionID = 210), 1, 'Первый пульт', 1),
    ((SELECT $node_id FROM Instrument WHERE InstrumentID = 110), (SELECT $node_id FROM Section WHERE SectionID = 209), 2, 'Второй пульт', 2);
GO

SELECT 
    m.MusicianName AS Violinist,
    i.InstrumentType AS Instrument,
    s.SectionName AS TheirSection,
    bs.RoleInSection
FROM Musician m, 
     Instrument i, 
     Section s,
     PlaysInstrument [pi],
     BelongsToSection bs
WHERE MATCH(
    m-([pi])->i AND
    m-(bs)->s
)
AND i.InstrumentType = 'Скрипка'

SELECT 
    ref.MusicianName AS ReferenceMusician,
    refSection.SectionName AS RefSection,
    other.MusicianName AS MusicianWithSameRole,
    otherSection.SectionName AS TheirSection,
     bs_other.RoleInSection AS TheirRole
FROM Musician ref,
     Section refSection,
     Musician other,
     Section otherSection,
     BelongsToSection bs_ref,
     BelongsToSection bs_other
WHERE MATCH(
    ref-(bs_ref)->refSection AND
    other-(bs_other)->otherSection
)
AND ref.MusicianName = 'Мария Соловьева'
AND ref.MusicianID != other.MusicianID
AND bs_ref.RoleInSection = bs_other.RoleInSection

SELECT m1.MusicianName,
       bs_m1.RoleInSection,
       m2.MusicianName,
       bs_m2.RoleInSection,
       s.SectionName
FROM Musician m1,
     Section s,
     Musician m2,
     BelongsToSection bs_m1,
     BelongsToSection bs_m2
WHERE MATCH(
     m1-(bs_m1)->s AND
     m2-(bs_m2)->s
)
AND bs_m1.RoleInSection != bs_m2.RoleInSection
AND m1.MusicianID < m2.MusicianID

SELECT m.MusicianName,
       i.InstrumentType,
       s.SectionName,
       [pi].SkillLevel
FROM Musician m,
     Section s,
     Instrument i,
     BelongsToSection bs_m,
     PlaysInstrument [pi]
WHERE MATCH(
     m-(bs_m)->s AND
     m-([pi])->i
)
AND [pi].SkillLevel >8 
AND s.SectionName ='Трубы'

SELECT m.MusicianName,
       i.InstrumentType,
       s.SectionName,
       bs_m.JoinDate
FROM Musician m,
     Section s,
     Instrument i,
     BelongsToSection bs_m,
     PlaysInstrument [pi]
WHERE MATCH(
     m-(bs_m)->s AND
     m-([pi])->i
)
AND bs_m.JoinDate > '2010-09-01'
AND i.InstrumentType ='Скрипка'


SELECT Музыкант, Инструмент, Количество_инструментов
FROM (
    SELECT
        m.MusicianName AS Музыкант,
        STRING_AGG(i.InstrumentType, ' -> ') WITHIN GROUP (GRAPH PATH) AS Инструмент,
        COUNT(pi.SkillLevel) WITHIN GROUP (GRAPH PATH) AS Количество_инструментов 
    FROM
        Musician AS m,
        PlaysInstrument FOR PATH AS pi,
        Instrument FOR PATH AS i
    WHERE MATCH(SHORTEST_PATH(m(-(pi)->i){1,3}))
      AND m.MusicianName = 'Анна Смирнова'
) AS Q
WHERE Q.Количество_инструментов = 1;

SELECT Музыкант, Путь_к_секции, Количество_связей
FROM (
    SELECT
        m.MusicianName AS Музыкант,
        STRING_AGG(s.SectionName, ' -> ') WITHIN GROUP (GRAPH PATH) AS Путь_к_секции,
        COUNT(bts.SeatNumber) WITHIN GROUP (GRAPH PATH) AS Количество_связей 
    FROM
        Musician AS m,
        BelongsToSection FOR PATH AS bts,
        Section FOR PATH AS s
    WHERE MATCH(SHORTEST_PATH(m(-(bts)->s)+))
      AND m.MusicianName = 'Иван Петров'
) AS Q
WHERE Q.Количество_связей >= 1;

SELECT 
    m.MusicianID,
    m.MusicianName AS Musician,
    CONCAT(N'Musician', m.MusicianID) AS [first image name],
    s.SectionID,
    s.SectionName AS Section,
    CONCAT(N'Section', s.SectionID) AS [second image name]
FROM dbo.Musician AS m, 
     dbo.BelongsToSection AS bs, 
     dbo.Section AS s
WHERE MATCH(m-(bs)->s)