import os
import pymssql  # Ensure you package this dependency with your lambda.zip

def lambda_handler(event, context):
    db_host = os.environ.get('DB_HOST')
    db_port = os.environ.get('DB_PORT')
    db_user = os.environ.get('DB_USER')
    db_name = os.environ.get('DB_NAME')
    db_password = os.environ.get('DB_PASSWORD')

    try:
        conn = pymssql.connect(
            server=f"{db_host}:{db_port}",
            user=db_user,
            password=db_password,
            database=db_name
        )
        cursor = conn.cursor()
        # Create table if not exists
        create_table_query = """
        CREATE DATABASE myapp;
        CREATE TABLE Users (
            UserID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incremented primary key
            FirstName NVARCHAR(50) NOT NULL,
            LastName NVARCHAR(50) NOT NULL,
            Email NVARCHAR(100) UNIQUE NOT NULL,
            DateOfBirth DATE,
            CreatedAt DATETIME DEFAULT GETDATE() -- Automatically set the creation timestamp
        );

        exec msdb.dbo.rds_cdc_enable_db 'myapp';


        EXEC sys.sp_cdc_enable_table  
            @source_schema = 'dbo',  
            @source_name = 'Users',  
            @role_name = NULL;

        SELECT * FROM sys.sp_cdc_help_change_data_capture;

        INSERT INTO Users (FirstName, LastName, Email, DateOfBirth)
        VALUES 
        ('John', 'Doe', 'john.doe@example.com', '1990-01-01'),
        ('Jane', 'Smith', 'jane.smith@example.com', '1992-02-14'),
        ('Alice', 'Johnson', 'alice.johnson@example.com', '1988-03-10'),
        ('Bob', 'Williams', 'bob.williams@example.com', '1995-04-25'),
        ('Charlie', 'Brown', 'charlie.brown@example.com', '1985-05-05'),
        ('David', 'Clark', 'david.clark@example.com', '1993-06-12'),
        ('Emma', 'Davis', 'emma.davis@example.com', '1991-07-18'),
        ('Frank', 'Garcia', 'frank.garcia@example.com', '1989-08-22'),
        ('Grace', 'Martinez', 'grace.martinez@example.com', '1994-09-30'),
        ('Hannah', 'Lopez', 'hannah.lopez@example.com', '1996-10-15');
        """
        cursor.execute(create_table_query)
        conn.commit()
        cursor.close()
        conn.close()
        return {"status": "Table created or already exists"}
    except Exception as e:
        print("Error creating table:", e)
        raise e