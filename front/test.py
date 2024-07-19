import psycopg2

host = "3.15.31.83"
port = "5432"
database = "academia"
user = "postgres"
password = "ci3391"

try:
    connection = psycopg2.connect(
        host=host,
        port=port,
        database=database,
        user=user,
        password=password
    )
    print("Connection successful")
    connection.close()
except Exception as e:
    print(f"Connection failed: {e}")