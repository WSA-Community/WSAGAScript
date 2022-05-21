# TESTING commands. No effect in app execution
import shutil
from functions import *
import platform

cpu_arch = platform.machine()

if cpu_arch.casefold() == "amd64":
    os.rename('./TEMP/WSAGAScript-main/misc/kernel-x86_64', "./TEMP/kernel")
else:
    os.rename('./TEMP/WSAGAScript-main/misc/kernel-arm64', "./TEMP/kernel")
shutil.copy("./TEMP/kernel", "./TEMP/wsa_main/Tools")