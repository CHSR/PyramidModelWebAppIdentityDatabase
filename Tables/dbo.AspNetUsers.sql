CREATE TABLE [dbo].[AspNetUsers]
(
[Id] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FirstName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastName] [nvarchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdateTime] [datetime] NULL,
[Email] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailConfirmed] [bit] NOT NULL,
[PasswordHash] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecurityStamp] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumberConfirmed] [bit] NOT NULL,
[TwoFactorEnabled] [bit] NOT NULL,
[LockoutEndDateUtc] [datetime] NULL,
[LockoutEnabled] [bit] NOT NULL,
[AccessFailedCount] [int] NOT NULL,
[UserName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountEnabled] [bit] NOT NULL CONSTRAINT [DF__AspNetUse__Accou__5BE2A6F2] DEFAULT ((0)),
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_AspNetUsers_CreatedBy] DEFAULT ('SYSTEM'),
[CreateTime] [datetime] NOT NULL CONSTRAINT [DF__AspNetUse__Creat__6EF57B66] DEFAULT (getdate()),
[UpdatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WorkPhoneNumber] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RegionLocation] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIPCode] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Street] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 09/23/2020
-- Description:	This trigger will update the related 'Changed' table
-- in order to provide a history of the actions performed on the records.
-- =============================================
CREATE TRIGGER [dbo].[TGR_AspNetUsers_Changed]
ON [dbo].[AspNetUsers]
AFTER UPDATE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Insert the rows that have the original values (if you changed a 4 to a 5, this will insert the row with the 4)
    INSERT INTO dbo.AspNetUserChanges
    (
        ChangeDatetime,
        ChangeType,
        Id,
        FirstName,
        LastName,
        UpdateTime,
        Email,
        EmailConfirmed,
        PasswordHash,
        SecurityStamp,
        PhoneNumber,
        PhoneNumberConfirmed,
        TwoFactorEnabled,
        LockoutEndDateUtc,
        LockoutEnabled,
        AccessFailedCount,
        UserName,
        AccountEnabled,
        CreatedBy,
        CreateTime,
        UpdatedBy,
		WorkPhoneNumber,
		State,
		City,
		ZIPCode,
		RegionLocation,
		Street
    )
    SELECT GETDATE(),
           'Update',
           d.Id,
           d.FirstName,
           d.LastName,
           d.UpdateTime,
           d.Email,
           d.EmailConfirmed,
           d.PasswordHash,
           d.SecurityStamp,
           d.PhoneNumber,
           d.PhoneNumberConfirmed,
           d.TwoFactorEnabled,
           d.LockoutEndDateUtc,
           d.LockoutEnabled,
           d.AccessFailedCount,
           d.UserName,
           d.AccountEnabled,
           d.CreatedBy,
           d.CreateTime,
           d.UpdatedBy,
		   d.WorkPhoneNumber,
		   d.State,
		   d.City,
		   d.ZIPCode,
		   d.RegionLocation,
		   d.Street
    FROM Deleted d
        INNER JOIN Inserted i
            ON i.Id = d.Id
    WHERE i.FirstName <> d.FirstName --Only record the change if one/many of these fields changed
          OR i.LastName <> d.LastName
          OR i.Email <> d.Email
          OR i.EmailConfirmed <> d.EmailConfirmed
          OR i.PasswordHash <> d.PasswordHash
          OR i.SecurityStamp <> d.SecurityStamp
          OR i.PhoneNumber <> d.PhoneNumber
          OR i.PhoneNumberConfirmed <> d.PhoneNumberConfirmed
          OR i.TwoFactorEnabled <> d.TwoFactorEnabled
          OR i.UserName <> d.UserName
          OR i.AccountEnabled <> d.AccountEnabled
		  OR i.WorkPhoneNumber <> d.WorkPhoneNumber
		  OR i.State <> d.State
		  OR i.City <> d.City
		  OR i.ZIPCode <> d.ZIPCode
		  OR i.RegionLocation<> d.RegionLocation
		  OR i.Street <> d.Street;

    --To hold any existing change rows
    DECLARE @ExistingChangeRows TABLE
    (
        Id NVARCHAR(128) NOT NULL,
        MinChangeDatetime DATETIME NOT NULL
    );

    --Get the existing change rows if there are more than 25
    INSERT INTO @ExistingChangeRows
    (
        Id,
        MinChangeDatetime
    )
    SELECT anuc.Id,
           CAST(MIN(anuc.ChangeDatetime) AS DATETIME)
    FROM dbo.AspNetUserChanges anuc
        INNER JOIN Deleted d
            ON d.Id = anuc.Id
    GROUP BY anuc.Id
    HAVING COUNT(anuc.Id) > 25;

    --Delete the excess change rows to keep the number of change rows at 25
    DELETE anuc
    FROM dbo.AspNetUserChanges anuc
        INNER JOIN @ExistingChangeRows ecr
            ON anuc.Id = ecr.Id
               AND anuc.ChangeDatetime = ecr.MinChangeDatetime
    WHERE anuc.Id = ecr.Id
          AND anuc.ChangeDatetime = ecr.MinChangeDatetime;

END;
GO
ALTER TABLE [dbo].[AspNetUsers] ADD CONSTRAINT [PK_dbo.AspNetUsers] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers] ([UserName]) ON [PRIMARY]
GO
