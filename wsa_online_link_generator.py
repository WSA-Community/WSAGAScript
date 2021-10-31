import requests
from bs4 import BeautifulSoup
import fnmatch


def get_wsa_linkstore_id():
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
    }
    r = requests.post(url=api_url, data=data, headers=headers)
    soup = BeautifulSoup(r.text, "html.parser")
    for link in soup.select("tr a"):
        if fnmatch.fnmatch(link.string.casefold(), "*windowssubsystemforandroid*.msixbundle"):
            return link['href']
    else:
        return False
