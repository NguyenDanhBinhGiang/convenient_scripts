#!/usr/bin/python3
import datetime
import json
import os
import shutil
import sqlite3
import requests


def get_cookie(host: str = 'localhost'):
    def dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d

    ff_cookies = r"/home/giang/.tmp/cookies.sqlite"
    shutil.copyfile(r"/home/giang/.mozilla/firefox/ykxnh7xb.default-release/cookies.sqlite", ff_cookies)
    con = sqlite3.connect(ff_cookies)
    con.row_factory = dict_factory
    cur = con.cursor()
    param = {
        'host': host,
    }
    cur.execute(f"""
        SELECT name, value FROM moz_cookies
        WHERE host like :host
--           AND name = 'session_id'
        ORDER BY lastAccessed DESC
--         LIMIT 1;
    """, param)
    result = cur.fetchall()
    cur.close()
    con.close()

    cookies = {
        res['name']: res['value']
        for res in result
    }
    if cookies:
        return cookies
    return None



def main():
    headers = {"Content-Type": "application/json", }

    cookie = get_cookie('odoo.hungnamecommerce.com')
    if not cookie:
        os.system(r'/usr/bin/notify-send -u critical "error when trying to check timesheet: no cookie found"')
        return

    body = json.dumps({
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "model": "hr.attendance",
            "domain": [],
            "fields": [
                "employee_id",
                "check_in",
                "check_out",
                "worked_hours"],
            "limit": 4,
            "sort": "check_in desc",
            "context": {
                "lang": "en_US",
                "tz": "Asia/Ho_Chi_Minh",
                "uid": 1241,
                "allowed_company_ids": [1],
                "create": False,
                "bin_size": True}},
        "id": 55289229
    })

    url = r"https://odoo.hungnamecommerce.com/web/dataset/search_read"

    res = requests.post(url=url, data=body, headers=headers, cookies=cookie)
    try:
        res = res.json()
        if 'error' in res:
            raise Exception(r'"error when trying to check attendances"')

        if datetime.datetime.fromisoformat(res['result']['records'][0]['check_in']).date() == datetime.date.today():
            index = 1
        else:
            return
        if not res['result']['records'][index]['check_out'] or res['result']['records'][index]['worked_hours'] < 5:
            os.system(r'/usr/bin/notify-send -u critical "Attendances" '
                      r'"https://odoo.hungnamecommerce.com/web#action=1755&model=hr.attendance&view_type=list&cids=1&menu_id=1472"')
            print(f"Send notify at {datetime.datetime.now()}")
        else:
            print("Attendances OK!")
    except Exception as e:
        os.system(r'/usr/bin/notify-send -u critical  "error when trying to check attendance"')
        raise e
    pass


if __name__ == '__main__':
    main()
