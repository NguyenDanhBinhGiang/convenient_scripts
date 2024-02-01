#!/usr/bin/python3
import datetime
import json
import os
import shutil
import sqlite3
import requests

MORNING_START = datetime.datetime.now().replace(hour=8, minute=30, second=0)
MORNING_END = datetime.datetime.now().replace(hour=12, minute=0, second=0)
AFTERNOON_START = datetime.datetime.now().replace(hour=13, minute=0, second=0)
AFTERNOON_END = datetime.datetime.now().replace(hour=17, minute=30, second=0)


def get_cookie(host: str = 'localhost'):
    def dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d

    ff_cookies = os.path.expanduser(os.path.join("~", r".tmp/cookies.sqlite"))
    if not os.path.exists(os.path.expanduser(os.path.join("~", '.tmp'))):
        os.system(f"mkdir -p ~/.tmp")
    shutil.copyfile(
        os.path.expanduser(os.path.join("~", r"snap/firefox/common/.mozilla/firefox/m2hrr1pn.default/cookies.sqlite")),
        ff_cookies)
    con = sqlite3.connect(ff_cookies)
    con.row_factory = dict_factory
    cur = con.cursor()
    cur.execute(f"SELECT * FROM moz_cookies WHERE host like '{host}'")
    a = cur.fetchall()
    cur.close()
    con.close()

    cookies = [x for x in a if x['lastAccessed'] == max([i['lastAccessed'] for i in a]) and x['name'] == 'session_id']
    if len(cookies) > 0:
        return {cookies[0]['name']: cookies[0]['value']}
    return False


def main():
    now = datetime.datetime.now()
    if not (MORNING_START < now < MORNING_END or AFTERNOON_START < now < AFTERNOON_END):
        return

    headers = {"Content-Type": "application/json", }

    cookie = get_cookie('odoo.hungnamecommerce.com')
    if not cookie:
        os.system(r'/usr/bin/notify-send -u critical "error when trying to check timesheet: no cookie found"')
        return

    body = json.dumps({
        "id": 524993461,
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "domain": [
                [
                    "project_id",
                    "!=",
                    False
                ]
            ],
            "fields": [
                "date",
                "task_code",
                "employee_id",
                "user_id",
                "company_id",
                "name",
                "date_start",
                "date_end",
                "project_id",
                "task_id",
            ],
            "limit": 80,
            "model": "account.analytic.line",
            "sort": ""
        }
    })

    url = r"https://odoo.hungnamecommerce.com/web/dataset/search_read"

    res = requests.post(url=url, data=body, headers=headers, cookies=cookie)
    try:
        res = res.json()
        if 'error' in res:
            raise Exception(r'"error when trying to check timesheet"')

        b = [x for x in res['result']['records']
             if datetime.datetime.strptime(x['date_start'], '%Y-%m-%d %H:%M:%S').date() == datetime.date.today()]
        c = [x for x in b if not x['date_end']]
        if len(c) < 1:
            os.system(r'/usr/bin/notify-send -u critical "timesheet" '
                      r'"https://odoo.hungnamecommerce.com/web#action=143&cids=1&menu_id=1634"')
            print(f"Send notify at {datetime.datetime.now()}")
        else:
            print("Timesheet OK!")
    except Exception as e:
        os.system(r'/usr/bin/notify-send -u critical  "error when trying to check timesheet"')
        raise e
    pass


if __name__ == '__main__':
    main()
