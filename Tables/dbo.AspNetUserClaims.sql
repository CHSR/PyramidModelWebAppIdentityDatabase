CREATE TABLE [dbo].[AspNetUserClaims]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[UserId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClaimType] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspNetUserClaims] ADD CONSTRAINT [PK_dbo.AspNetUserClaims] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserId] ON [dbo].[AspNetUserClaims] ([UserId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AspNetUserClaims] ADD CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE
GO
