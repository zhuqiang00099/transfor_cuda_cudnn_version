softlink=cuda_cudnn_sflink
help(){ 
  echo "usage:
      for install : sh cuda_cudnn.sh --install [版本名称] [cuda路径] [cudnn路径]
      for config : sh cuda_cudnn.sh --config [remove change] 
      for list : sh cuda_cudnn.sh --list
      "
}
activate(){
  version=$1
  cuda=$2
  cudnn=$3
  ln -s $cuda $softlink
  rm $cuda/include/cudnn.h
  rm $cuda/lib64/libcudnn*
  ln -s $cudnn/include/cudnn.h $cuda/include
  ln -s $cudnn/lib64/libcudnn* $cuda/lib64
  sed -i '1c '''$version'''' version.conf

}
remove(){
  version=$1 
  cuda=$2
  cudnn=$3
  cur_version=`awk '{print $1}' version.conf`
  #sed 删除
  sed -i ''''$version'''d' cuda.conf
  rows=`awk 'END{print NR}' cuda.conf`
  if [ $rows -eq 0 ];then
    sed -i '1c 0' version.conf
  fi
  if [ $version -eq $cur_version ];then
     if [ ! -d "$cuda" ];then
        echo "$cuda目录不存在"
        exit -1
     fi 
  
     if [ ! -d "$cudnn" ];then
        echo "$cudnn目录不存在"
        exit -1
     fi

     if [ ! -L "$softlink" ];then
        echo "$softlink链接不存在"
        exit -1
     fi

     if [ $rows -ne 0 ];then
        cuda_n=`sed -n ''''$input_key''', 2p' cuda.conf | awk '{print $2}'`
        cudnn_n=`sed -n ''''$input_key''', 3p' cuda.conf | awk '{print $3}'`
        activate 1 $cuda_n $cudnn_n
        return
     fi

     rm $softlink
     rm $cuda/include/cudnn.h
     rm $cuda/lib64/libcudnn*

     
  fi
  
}
install(){
  name=$1
  cuda=$2
  cudnn=$3
  if [ ! -d "$cuda" ];then
    echo "$cuda 目录不存在"
    exit -1
  fi 
  
  if [ ! -d "$cudnn" ];then
    echo "$cudnn 目录不存在"
    exit -1
  fi
  #sed添加
  rows=`awk 'END{print NR}' cuda.conf`
  if [ $rows -eq 0 ];then
     echo "1" > cuda.conf
     sed -i '1c '''$name''' '''$cuda''' '''$cudnn'''' cuda.conf
     activate 1 $cuda $cudnn
  else
    sed -i '$a '''$name''' '''$cuda''' '''$cudnn'''' cuda.conf   
  fi
 
    
} 
config_change(){
  #打印安装版本的信息
  version=`awk '{print $1}' version.conf`
  awk -f config.awk cur_version=$version cuda.conf
  rows=`awk 'END{print NR}' cuda.conf`
  echo -n "输入要激活的版本，或者回车退出->"
  read input_key
  if [ $input_key -lt 0 ] || [ $input_key -gt $rows ];then
     echo "输入编号错误"
     exit -1 
  #同版本不要更新     
  elif [ $input_key -ne $version ] ;then
     name=`sed -n ''''$input_key''', 1p' cuda.conf | awk '{print $1}'`
     cuda=`sed -n ''''$input_key''', 2p' cuda.conf | awk '{print $2}'`
     cudnn=`sed -n ''''$input_key''', 3p' cuda.conf | awk '{print $3}'`
     activate $input_key $cuda $cudnn
    # echo "$name $cuda $cudnn"
  fi 
  
  
  
}

config_remove(){
  #打印安装版本的信息
  version=`awk '{print $1}' version.conf`
  awk -f config.awk cur_version=$version cuda.conf
  rows=`awk 'END{print NR}' cuda.conf`
  echo -n "输入要删除的版本，或者回车退出->"
  read input_key
  if [ $input_key -lt 0 ] || [ $input_key -gt $rows ];then
     echo "输入编号错误"
     exit -1
  #同版本不要更新     
  else
     name=`sed -n ''''$input_key''', 1p' cuda.conf | awk '{print $1}'`
     cuda=`sed -n ''''$input_key''', 2p' cuda.conf | awk '{print $2}'`
     cudnn=`sed -n ''''$input_key''', 3p' cuda.conf | awk '{print $3}'`
     remove $input_key $cuda $cudnn
    # echo "$name $cuda $cudnn"
  fi

}

list(){
  version=`awk '{print $1}' version.conf`
  awk -f config.awk cur_version=$version cuda.conf

 }
if [ ! -f "cuda.conf" ];then
   touch cuda.conf
fi

if [ ! -f "version.conf" ];then
  echo "0" > version.conf
fi


if [ $# -eq 2 ] ;then
       if [ $1 = "--config" ] ;then   
           if [ $2 = "remove" ] ;then
             config_remove
           elif [ $2 = "change" ] ;then
             config_change
           else
             echo "config 参数错误"
             help
             exit -1
           fi
       else
           echo "error unknow arg:$1"
           help
           exit -1
       fi
elif [ $# -eq 4 ] ;then
       if [ $1 = "--install" ] ;then
            install $2 $3 $4
       else
           echo "error unknow arg:$1"
           help
           exit -1
       fi
elif [ $# -eq 1 ];then
       if [ $1 = "--help" ];then
           help
           exit 0
       elif [ $1 = "--list" ];then
            list
            exit 0
       fi   
else
    echo "参数数目不对" 
    help
    exit -1
fi
 

       
