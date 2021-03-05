import re
import csv
import pathlib
import tempfile
import zipfile
import logging

import requests

import psycopg2
from psycopg2 import sql
import psycopg2.extras

log = logging.getLogger('F1 DB Builder')
log.setLevel(logging.INFO)
ch = logging.StreamHandler()
formatter = logging.Formatter(
    "%(asctime)s | %(name)s | %(levelname)7s | %(message)s",
    "%Y-%m-%d %H:%M:%S"
)
ch.setFormatter(formatter)
log.addHandler(ch)


DBZIP_URL = "http://ergast.com/downloads/f1db_csv.zip"


def camel_to_snake(name):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()


def get_template_and_insert_stmt(rec, table, cursor):
    """Generate a SQL template to INSERT variable set of columns"""
    columns = sql.SQL(', ').join(
        [sql.Identifier(camel_to_snake(k)) for k in rec]
    )
    sqlstr = sql.SQL(
        'INSERT INTO {} ({}) VALUES %s ON CONFLICT DO NOTHING').format(
        sql.Identifier(table), columns
    )
    placeholders = sql.SQL(', ').join([sql.Placeholder(k) for k in rec])
    val_template = sql.SQL('({})').format(placeholders)
    return sqlstr.as_string(cursor), val_template.as_string(cursor)


def table_from_csv(data, table, conn):
    cursor = conn.cursor()
    insert_stmt, val_template = get_template_and_insert_stmt(data[0], table, cursor)
    log.info('Loading data into table "%s"', table)
    psycopg2.extras.execute_values(
        cursor, insert_stmt, data, val_template, page_size=10000
    )
    conn.commit()
    cursor.close()
    return table


def clean_mysql_null(data):
    for d in data:
        for k, v in d.items():
            if v == '\\N':
                d[k] = None


def download_zipfile(url, save_path, chunk_size=128):
    log.info('Downloading file from %s', url)
    r = requests.get(url, stream=True)
    with open(save_path, 'wb') as fd:
        for chunk in r.iter_content(chunk_size=chunk_size):
            fd.write(chunk)
    log.info('Download complete. Saved to %s', save_path)
    return save_path


def fetch_db_csv(dbdirpath):
    save_path = pathlib.Path(dbdirpath) / 'f1db.zip'
    download_zipfile(DBZIP_URL, save_path)
    zfile = zipfile.ZipFile(save_path)
    log.info('Extracting all files from %s', save_path)
    zfile.extractall(dbdirpath)
    return dbdirpath


def load_db(dbdirpath):
    log.info('Loading new records into DB')
    conn = psycopg2.connect(dbname='f1db')
    dbpth = pathlib.Path(dbdirpath)
    for t in TABLE_ORDER:
        pth = dbpth / f'{t}.csv'
        with open(pth, 'r') as dbf:
            data = [r for r in csv.DictReader(dbf)]
            clean_mysql_null(data)
            table_from_csv(data, t, conn)


def main():
    with tempfile.TemporaryDirectory() as dbdirpath:
        fetch_db_csv(dbdirpath)
        load_db(dbdirpath)


TABLE_ORDER = [
    'status',
    'seasons',
    'circuits',
    'drivers',
    'constructors',
    'races',
    'constructor_results',
    'constructor_standings',
    'driver_standings',
    'lap_times',
    'pit_stops',
    'qualifying',
    'results'
]

if __name__ == '__main__':
    main()
