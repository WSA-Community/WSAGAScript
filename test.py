# TESTING commands. No effect in app execution

import subprocess

a = subprocess.run("powershell")
print(a.returncode)