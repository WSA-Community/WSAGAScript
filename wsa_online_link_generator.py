import requests
from bs4 import BeautifulSoup
import fnmatch


def get_wsa_entry():
    """Returns a tuple containing the Windows Subsystem for Android link and its file name (used to check for
    updates) """
    store_id = "9p3395vx91nr"
    api_url = "https://store.rg-adguard.net/api/GetFiles"
    data = {
        "type": "ProductId",
        "url": store_id,
        "ring": "WIS",
        "lang": "en-US",
    }
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B179 Safari/7534.48.3",
    }
    r = requests.post(url=api_url, data=data, headers=headers)
    print(r.text)
    soup = BeautifulSoup(r.text, "html.parser")
    for link in soup.select("tr a"):
        if fnmatch.fnmatch(link.string.casefold(), "*windowssubsystemforandroid*.msixbundle"):
            return link['href'], link.string


if __name__ == '__main__':
    print(get_wsa_entry())
