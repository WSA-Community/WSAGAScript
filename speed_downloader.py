import asyncio
import concurrent.futures
import traceback

import requests
import os


async def get_size(url):
    response = requests.head(url)
    size = int(response.headers['Content-Length'])
    return size


def download_range(url, start, end, output):
    headers = {'Range': f'bytes={start}-{end}'}
    response = requests.get(url, headers=headers)

    with open(output, 'wb') as f:
        for part in response.iter_content(1024):
            f.write(part)


async def download(executor, url, output, chunk_size=1024768):
    loop = asyncio.get_event_loop()
    file_size = await get_size(url)
    chunks = range(0, file_size, chunk_size)

    tasks = [
        loop.run_in_executor(
            executor,
            download_range,
            url,
            start,
            start + chunk_size - 1,
            f'{output}.part{i}',
        )
        for i, start in enumerate(chunks)
    ]

    await asyncio.wait(tasks)

    with open(output, 'wb') as o:
        for i in range(len(chunks)):
            chunk_path = f'{output}.part{i}'

            with open(chunk_path, 'rb') as s:
                o.write(s.read())

            os.remove(chunk_path)


def speed_download(url, root, filename=None):
    executor = concurrent.futures.ThreadPoolExecutor(max_workers=8)
    loop = asyncio.get_event_loop()
    url = url
    root = os.path.expanduser(root)

    if not filename:
        filename = os.path.basename(url)
    fpath = os.path.join(root, filename)

    os.makedirs(root, exist_ok=True)
    print(f"Downloading {url} to {fpath}")
    while True:
        try:
            loop.run_until_complete(download(executor, url, fpath))
        except Exception as e:
            print(e)
            print(traceback.format_exc())
            print("Trying download again.")
            continue
        else:
            break