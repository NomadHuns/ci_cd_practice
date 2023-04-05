# 상대 경로 받아오기
project_dir=$(dirname $0)
# 배포할 프로젝트명
project_name="mybatis_project"
# 배포할 프로젝트 깃허브 주소
project_repo="https://github.com/jaybon1/${project_name}.git"

# 폴더가 없으면 fit clone
if [[ ! -d ${project_dir}/${project_name} ]];
then 
    # 깃 클론 실행
    echo "${project_name}을 클론합니다."
    git clone ${project_repo}

    # 해당 프로젝트 폴더 하위 파일 모두 권한 변경
    chmod -R 777 ${project_dir}/${project_name}
fi

git pull origin master

# 상대 경로로 프로젝트 폴더로 이동
echo "프로젝트 폴더로 이동합니다."
cd ${project_dir}/${project_name}

# 버전 파일이 없을 경우 버전 파일 생성
if [[ ! -e version.txt ]];
then
    echo "version.txt 파일을 생성합니다."
    touch version.txt
    chmod 777 version.txt
fi

# 버전이 같으면?
prev_version=$(cat version.txt)
now_version=$(git rev-parse master)

if [[ ${prev_version} == $now_version ]];
then
    echo "이전 버전과 현재 버전이 동일합니다."
    is_version_equals=true
else 
    echo "이전 버전과 현재 버전이 다릅니다."
    is_version_equals=false
fi

# 프로세스가 켜져 있으면?
if pgrep -f ${project_name}.*\.jar > /dev/null
then 
    echo "프로세스가 켜져 있습니다."
    is_process_on=true
else
    echo "프로세스가 꺼져 있습니다."
    is_process_on=false
fi

if [[ $is_version_equals == true && $is_process_on == true ]];
then
    echo "최신 버전 배포 상태입니다. 스크립트를 종료합니다."
    exit 0
elif [[ $is_process_on == true ]];
then
    echo "이전 프레서스를 중지합니다."
    pid=$(pgrep -f ${project_name}.*\.jar)
    kill -9 $pid
fi

# 빌드 진행
echo "빌드를 진행합니다."
./gradlew bootJar

# 빌드된 Jar 파일로 이동
echo "./build/libs로 이동합니다."
cd ./build/libs

# Jar 파일 실행
echo "프로젝트를 배포합니다."
nohup java -jar ${project_name}*.jar 1>log.out 2>err.out &

echo "프로젝트 폴더로 돌아옵니다."
cd ..
cd ..

echo "현재 버전을 version.txt에 입력합니다."
echo ${now_version} > version.txt