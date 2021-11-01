import os
import time
import shutil
import tkinter
from tkinter.font import Font
import ctypes
import sys
from sys import exit
from urllib import request, error
from speed_downloader import speed_download


def download_url(url, root=".", filename=None):
    """Download a file from a url and place it in root.
    Args:
        url (str): URL to download file from
        root (str): Directory to place downloaded file in
        filename (str, optional): Name to save the file under. If None, use the basename of the URL
    """

    root = os.path.expanduser(root)
    if not filename:
        filename = os.path.basename(url)
    fpath = os.path.join(root, filename)

    os.makedirs(root, exist_ok=True)
    try:
        print('Downloading ' + url + ' to ' + fpath)
        request.urlretrieve(url, fpath)
    except (error.URLError, IOError):
        if url[:5] == 'https':
            url = url.replace('https:', 'http:')
            print('Failed download. Trying https -> http instead.'
                  ' Downloading ' + url + ' to ' + fpath)
            request.urlretrieve(url, fpath)


def is_admin():
    """
    Checks if the user has admin permissions
    :return: admin true/false
    """
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception as e:
        print(e)
        return False


def get_admin_permission():
    """checks if the program has admin permissions, otherwise it requests admin permission once, then exits"""
    if is_admin():
        pass
    else:
        ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1)
        exit()


def ps_check_feature(feature):
    """Checks whether a Windows optional feature exists.
    Returns True if the component is installed. Otherwise returns False.
    Requires admin permissions."""
    _ = os.popen("powershell \"Get-WindowsOptionalFeature -FeatureName {} -Online\"".format(feature)).read().replace(
        " ", "")
    if "State:Disabled" in _:
        return False
    elif "State:Enabled" in _:
        return True
    else:
        return False


def is_wsl_framework_installed():
    """Checks if the WSL framework (excluding distros) is installed."""
    return ps_check_feature("Microsoft-Windows-Subsystem-Linux") and ps_check_feature(
        "VirtualMachinePlatform") and shutil.which("bash") and shutil.which("wsl")


def wsl_get_distro():
    """
    Returns the output of "wsl.exe --list"
    :return:
    """
    __ = os.popen("wsl --list").readlines()
    result = (_.replace("\x00", "") for _ in __)
    result = "".join(_ for _ in result if _ != "\n" and _ != "")
    return result.casefold()


class WindowError(tkinter.Tk):
    """
    A window displaying errors. May not be polished yet. Especially the quit() and destroy() not working properly.
    """

    def __init__(self, *messages, color="red", tx_color="white", yes_command="", yes_text="OK", no_text="Dismiss"):
        """
        Creates the windows. Mainloop needed after initializing
        :param messages: All the messages. Separate the strings to make a line break
        :param color: Background color
        :param tx_color: Text color
        :param yes_command: Executes this command in a string.
        :param yes_text: The label of the button.
        """
        super().__init__()
        self.title("WSAGAScript OneClickRun")
        self.geometry("640x240")
        self.minsize(height=240, width=640)
        self.maxsize(height=240, width=640)
        self.config(padx=8, pady=8, background=color)
        row_weight = 10000, 1
        for _, __ in enumerate(row_weight):
            self.rowconfigure(_, weight=__)
        column_weight = 100, 1
        for _, __ in enumerate(column_weight):
            self.columnconfigure(_, weight=__)
        error_frame = tkinter.Frame(self, background=color)
        error_frame.grid(row=0, column=0, sticky="new", columnspan=2)
        for message in messages:
            tkinter.Label(error_frame, text=message, font=Font(family="Arial", size=12), background=color,
                          fg=tx_color, wraplength=600, justify="left").pack(side="top", anchor="nw")
        if yes_command:
            button_accept = tkinter.Button(self, relief="raised", text=yes_text, command=self.accept_button_function)
            self.yes_command = yes_command
            button_accept.grid(row=1, column=0, sticky="e")
        button_exit = tkinter.Button(self, relief="raised", text=no_text, command=self.destroy)
        button_exit.grid(row=1, column=1, sticky="e")

    def accept_button_function(self):
        # self.quit()
        self.destroy()
        exec(f'{self.yes_command}')


def install_wsl():
    """Installs WSL and its dependencies, then reboots. Requires admin permission."""
    if is_admin():
        print("Installing Windows Subsystem for Linux. The system will restart in about a minute.")
        os.popen(
            "dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart").read()
        print("Installing Virtual Machine Platform. The system will restart in about 30 seconds.")
        os.popen("dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart").read()
        os.popen("shutdown.exe /r /t 0")


def is_linux_enabled(distro):
    """
    Checks if WSL distro is installed. If not, tries to install distro. Requires admin
     If WSL isn't present, prompts to install WSL and its prerequisites.
    :param distro:
    :return: TRUE if the specified WSL distro has already been installed.
    LINUX_INSTALLED if WSL is present but the distro is not.
    WSL_NOT_INSTALLED if WSL is not present.
    """
    if not is_wsl_framework_installed():
        _ = WindowError("WSL framework is not installed.",
                        "Please save your work before clicking install. The machine will reboot.",
                        yes_text="Install WSL",
                        yes_command="install_wsl()",
                        no_text="Exit")
        _.wait_window()
        exit()
    wsl_list_header = "windows subsystem for linux distributions"
    wsl_no_distributions = "no installed distributions"
    result = wsl_get_distro()
    if distro in result and wsl_list_header in result:  # checks if distro has been installed. Done
        os.popen("wsl -s {}".format(distro))
        return "TRUE"
    elif wsl_no_distributions in result or distro not in result and wsl_list_header in result:
        # checks if there is no distribution, or the distribution is not present
        print("An instance of {} is being installed on your device. Please wait.".format(distro))
        print("Downloading kernel.")
        speed_download("https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi", "./TEMP")
        os.popen("msiexec /i \"TEMP\\wsl_update_x64.msi\" /quiet").read()
        print(f"Downloading {distro} system image.")
        os.popen("wsl --install -d {}".format(distro)).read()
        # execution of the last line stops, but installation hasn't been completed. therefore must check again.
        while True:  # check again for the presence of the OS before exiting
            time.sleep(2)
            result = wsl_get_distro()
            # print(result)
            if distro in result and wsl_list_header in result:
                os.popen("wsl -s {}".format(distro))
                break
        return "LINUX_INSTALLED"


def remove(path):
    """ param <path> could either be relative or absolute. """
    if os.path.exists(path):
        if os.path.isfile(path) or os.path.islink(path):
            os.remove(path)  # remove the file
        elif os.path.isdir(path):
            shutil.rmtree(path)  # remove dir and all contains
