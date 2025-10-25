/* *************************************************************************
Bible Database: SQLite, by Don Jewett
https://github.com/donjewett/bible-sql-sqlite

bible-010-schema.sql
Version: 2025.10.24

Implemented with STRICT keyword which requires SQLite 3.37+
To implement in earlier versions, omit this keyword.

MIT License

Copyright (c) 2025 by Don Jewett

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

************************************************************************* */

-- TO DO: test without comma between WITHOUT ROWID and STRICT

----------------------------------------------------------------------------
-- Languages
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Languages (
	Id text NOT NULL,
	Name text NOT NULL,
	HtmlCode text NOT NULL,
	IsAncient int NOT NULL DEFAULT (false),
 	CONSTRAINT PK_Language PRIMARY KEY (Id)
) WITHOUT ROWID, STRICT;

----------------------------------------------------------------------------
-- Canons
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Canons (
	Id int NOT NULL,
	Code text NOT NULL,
	Name text NOT NULL,
	LanguageId text NOT NULL,
	CONSTRAINT PK_Canons PRIMARY KEY (Id),
	CONSTRAINT FK_Canons_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id)
) STRICT;

----------------------------------------------------------------------------
-- Sections
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sections (
	Id int NOT NULL,
	Name text NOT NULL,
	CanonId int NOT NULL,
	CONSTRAINT PK_Sections PRIMARY KEY (Id),
	CONSTRAINT FK_Sections_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id)
) STRICT;

----------------------------------------------------------------------------
-- Books
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Books (
	Id int NOT NULL,
	Code text NOT NULL,
	Abbrev text NOT NULL,
	Name text NOT NULL,
	Book int NOT NULL,
	CanonId int NOT NULL, -- denormalized
	SectionId int NOT NULL,
	IsSectionEnd int NOT NULL DEFAULT (false),
	ChapterCount int NOT NULL,
	OsisCode text NOT NULL,
	Paratext text NOT NULL,
	CONSTRAINT PK_Books PRIMARY KEY (Id),
	CONSTRAINT FK_Books_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Books_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
) STRICT;

----------------------------------------------------------------------------
-- BookNames
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BookNames (
	Name text NOT NULL,
	BookId int NOT NULL,
	CONSTRAINT PK_BookNames PRIMARY KEY (Name),
	CONSTRAINT FK_BookNames_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
) WITHOUT ROWID, STRICT;

----------------------------------------------------------------------------
-- Chapters
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Chapters (
	Id int NOT NULL,
	Code text NOT NULL,
	Reference text NOT NULL,
	Chapter int NOT NULL,
	BookId int NOT NULL,
	IsBookEnd int NOT NULL DEFAULT (false),
	VerseCount int NOT NULL,
	CONSTRAINT PK_Chapters PRIMARY KEY (Id),
	CONSTRAINT FK_Chapters_Books FOREIGN KEY (BookId) REFERENCES Books (Id)
) STRICT;

----------------------------------------------------------------------------
-- Verses
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Verses (
	Id int NOT NULL,
	Code text NOT NULL,
	OsisCode text NOT NULL,
	Reference text NOT NULL,
	CanonId int NOT NULL, --denormalized
	SectionId int NOT NULL, --denormalized
	BookId int NOT NULL, --denormalized
	ChapterId int NOT NULL,
	IsChapterEnd int NOT NULL DEFAULT (false),
	Book int NOT NULL, --denormalized
	Chapter int NOT NULL, --denormalized
	Verse int NOT NULL,
	CONSTRAINT PK_Verses PRIMARY KEY (Id),
	CONSTRAINT FK_Verses_Books FOREIGN KEY (BookId) REFERENCES Books (Id),
	CONSTRAINT FK_Verses_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_Verses_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_Verses_Sections FOREIGN KEY (SectionId) REFERENCES Sections (Id)
) STRICT;

----------------------------------------------------------------------------
-- GreekTextForms
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS GreekTextForms (
	Id text NOT NULL,
	Name text NOT NULL,
	ParentId text NULL,
	CONSTRAINT PK_GreekTextForms PRIMARY KEY (Id),
	CONSTRAINT FK_GreekTextForms_GreekTextForms FOREIGN KEY (ParentId) REFERENCES GreekTextForms (Id)
) WITHOUT ROWID, STRICT;

----------------------------------------------------------------------------
-- HebrewTextForms
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS HebrewTextForms (
	Id text NOT NULL,
	Name text NOT NULL,
	ParentId text NULL,
	CONSTRAINT PK_HebrewTextForms PRIMARY KEY (Id),
	CONSTRAINT FK_HebrewTextForms_GHebrewTextForms FOREIGN KEY (ParentId) REFERENCES HebrewTextForms (Id)
) WITHOUT ROWID, STRICT;

----------------------------------------------------------------------------
-- LicensePermissions
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicensePermissions (
	Id integer NOT NULL, -- rowid
	Name text NOT NULL,
	Permissiveness int NOT NULL,
	CONSTRAINT PK_LicensePermissions PRIMARY KEY (Id)
) STRICT;

----------------------------------------------------------------------------
-- LicenseTypes
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS LicenseTypes (
	Id integer NOT NULL, -- rowid
	Name text NOT NULL,
	IsFree int NOT NULL DEFAULT (false),
	PermissionId int NULL,
	CONSTRAINT PK_LicenseType PRIMARY KEY (Id),
	CONSTRAINT FK_LicenseTypes_LicensePermissions FOREIGN KEY (PermissionId) REFERENCES LicensePermissions (Id)
) STRICT;

----------------------------------------------------------------------------
-- Versions
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Versions (
	Id integer NOT NULL, -- rowid
	Code text NOT NULL,
	Name text NOT NULL,
	Subtitle text NULL,
	LanguageId text NOT NULL,
	YearPublished int NOT NULL,
	HebrewFormId text NULL,
	GreekFormId text NULL,
	ParentId int NULL,
	LicenseTypeId int NULL,
	ReadingLevel real NULL,
	CONSTRAINT PK_Versions PRIMARY KEY (Id),
	CONSTRAINT FK_Versions_Languages FOREIGN KEY (LanguageId) REFERENCES Languages (Id),
	CONSTRAINT FK_Versions_Versions FOREIGN KEY (ParentId) REFERENCES Versions (Id),
	CONSTRAINT FK_Versions_GreekTextForms FOREIGN KEY (GreekFormId) REFERENCES GreekTextForms (Id),
	CONSTRAINT FK_Versions_HebrewTextForms FOREIGN KEY (HebrewFormId) REFERENCES HebrewTextForms (Id),
	CONSTRAINT FK_Versions_LicenseTypes FOREIGN KEY (LicenseTypeId) REFERENCES LicenseTypes (Id)
) STRICT;

----------------------------------------------------------------------------
-- Revisions
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Revisions (
	Id integer NOT NULL, -- rowid
	Code text NOT NULL,
	VersionId int NOT NULL,
	YearPublished int NOT NULL,
	Subtitle text NULL,
	CONSTRAINT PK_Revisions PRIMARY KEY (Id),
	CONSTRAINT FK_Revisions_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id)
) STRICT;

----------------------------------------------------------------------------
-- Sites
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Sites (
	Id integer NOT NULL, -- rowid
	Name text NOT NULL,
	Url text NULL,
	CONSTRAINT PK_Sites PRIMARY KEY (Id)
) STRICT;

----------------------------------------------------------------------------
-- ResourceTypes
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ResourceTypes (
	Id text NOT NULL,
	Name text NOT NULL,
	CONSTRAINT PK_ResourceTypes PRIMARY KEY (Id)
) WITHOUT ROWID, STRICT;

----------------------------------------------------------------------------
-- Resources
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Resources (
	Id integer NOT NULL, -- rowid
	ResourceTypeId text NOT NULL,
	VersionId int NOT NULL,
	RevisionId int NULL,
	Url text NULL,
	IsOfficial int NOT NULL DEFAULT (false),
	SiteId int NULL,
	CONSTRAINT PK_Resources PRIMARY KEY (Id),
	CONSTRAINT FK_Resources_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Resources_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Resources_ResourceTypes FOREIGN KEY (ResourceTypeId) REFERENCES ResourceTypes (Id),
	CONSTRAINT FK_Resources_Sites FOREIGN KEY (SiteId) REFERENCES Sites (Id)
) STRICT;

----------------------------------------------------------------------------
-- Bibles
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Bibles (
	Id integer NOT NULL, -- rowid
	Code text NOT NULL,
	Name text NOT NULL,
	Subtitle text NULL,
	VersionId int NOT NULL,
	RevisionId int NULL,
	YearPublished int NULL,
	TextFormat text NOT NULL DEFAULT ('txt'),
	SourceId int NULL,
	CONSTRAINT PK_Bibles PRIMARY KEY (Id),
	CONSTRAINT FK_Bibles_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_Bibles_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_Bibles_Resources FOREIGN KEY (SourceId) REFERENCES Resources (Id)
) STRICT;

----------------------------------------------------------------------------
-- BibleVerses
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS BibleVerses (
	Id integer NOT NULL, -- rowid
	BibleId int NOT NULL,
	VerseId int NOT NULL,
	Markup text NOT NULL,
	PreMarkup text NULL,
	PostMarkup text NULL,
	Notes text NULL,
	CONSTRAINT PK_BibleVerses PRIMARY KEY (Id),
	CONSTRAINT FK_BibleVerses_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_BibleVerses_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
) STRICT;

CREATE UNIQUE INDEX IF NOT EXISTS UQ_BibleVerses_Version_Verse ON BibleVerses
(
	BibleId ASC,
	VerseId ASC
);

----------------------------------------------------------------------------
-- VersionNotes
----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VersionNotes (
	Id integer NOT NULL, -- rowid
	VersionId int NOT NULL,
	RevisionId int NULL,
	BibleId int NULL,
	CanonId int NULL,
	BookId int NULL,
	ChapterId int NULL,
	VerseId int NULL,
	Note text NOT NULL,
	Label text NULL,
	Ranking int NOT NULL DEFAULT (0),
	CONSTRAINT PK_VersionNotes PRIMARY KEY (Id),
	CONSTRAINT FK_VersionNotes_Versions FOREIGN KEY (VersionId) REFERENCES Versions (Id),
	CONSTRAINT FK_VersionNotes_Revisions FOREIGN KEY (RevisionId) REFERENCES Revisions (Id),
	CONSTRAINT FK_VersionNotes_Bibles FOREIGN KEY (BibleId) REFERENCES Bibles (Id),
	CONSTRAINT FK_VersionNotes_Canons FOREIGN KEY (CanonId) REFERENCES Canons (Id),
	CONSTRAINT FK_VersionNotes_Books FOREIGN KEY (CanonId) REFERENCES Books (Id),
	CONSTRAINT FK_VersionNotes_Chapters FOREIGN KEY (ChapterId) REFERENCES Chapters (Id),
	CONSTRAINT FK_VersionNotes_Verses FOREIGN KEY (VerseId) REFERENCES Verses (Id)
) STRICT;
