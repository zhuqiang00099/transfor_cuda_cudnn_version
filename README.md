# transfor_cuda_cudnn_version
cuda_cudnn各版本在linux管理和切换的脚本
第一次写linux shell，很搓，希望高手能给个牛逼的！
脚本原理就是保存文件路径，然后用软链切换cuda_cudnn
# 准备步骤：
1. chmod +x cuda-cudnn
2. 默认软链为目录下的 cuda_cudnn_sflink 文件夹，要修改的话 修改cuda_cudnn_intern.sh里的softlink
3. 加环境变量：
   vim ~/.bashrc
   加入下面四行
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:[softlink路径]/lib64
   export PATH=$PATH:[softlink路径]/bin
   export CUDA_HOME=$CUDA_HOME:[softlink路径]
   export PATH=$PATH:[cuda_cudnn路径]
4. source ~/.bashrc
5. 重新登录一下

# 操作
1. cuda-cudnn --install [自定义版本名称] [cuda文件夹路径] [cudnn文件夹路径]
2. cuda-cudnn --list
3. cuda-cudnn --config change
4. cuda-cudnn --config remove

# 说明
脚本不够智能，如果链接删除失败，请手动删除；install/change的时候提示rm失败，文件不存在，没关系，因为切换软链的时候会无脑的先用rm删除文件。
