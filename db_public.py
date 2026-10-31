import urllib
from sqlalchemy import create_engine

# Put your server name between the quotes, exactly as SSMS shows it.
# Examples: r"localhost"   or   r"localhost\SQLEXPRESS"   or   r"YOUR-PC-NAME\SQLEXPRESS"
SERVER = r"YOUR-SERVER-NAME\SQLEXPRESS"

conn_str = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=" + SERVER + ";"
    "DATABASE=CapacityPlanning;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)
params = urllib.parse.quote_plus(conn_str)
engine = create_engine("mssql+pyodbc:///?odbc_connect=" + params, fast_executemany=True)