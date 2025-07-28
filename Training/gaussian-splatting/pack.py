import subprocess
import os

path = os.path.abspath(os.path.dirname(__file__)) #当前路径
path_pack = os.path.join(path,"pack")

pack_py_file_list = ["run.py"]

for one_py_file in pack_py_file_list:

    command = ["pyinstaller", "-D",  one_py_file]

    command.append("-y") #如果dist文件夹内已经存在生成文件，则不询问用户，直接覆盖
    command.append("-i="+"{}/Xverse_Logo.png".format(path_pack) )
    command.append("--distpath=" +path_pack)
    command.append("--specpath=" +path_pack)
    command.append("--hidden-import=cv2")
    command.append("--hidden-import=torch.cuda")
    command.append("--clean") #彻底清空缓存重新编译

    subprocess.run(command)



