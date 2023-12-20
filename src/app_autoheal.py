import os
import time

import requests
from requests.exceptions import ConnectionError


def main(url):
    while True:
        try:
            r = requests.get(url, timeout=1)
            if r.status_code != 200:
                print("Приложение чувствует себя плохо. Перезапускаем...")
                os.system("systemctl restart bingo")
                time.sleep(15)
        except ConnectionError:
            print("Сервер не отвечает. Подождем немного...")
            time.sleep(5)
        time.sleep(5)


if __name__ == "__main__":
    url = "http://localhost:17534/ping"
    main(url)
