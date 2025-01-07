docker build -t ${repository_name}:${tag} -f ${dockerfile_context} .
curl -sfL $url | sh -s -- -b /usr/local/bin > /dev/null
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
-v $HOME/Library/Caches:/root/.cache/ accuknox/accuknox-container-scan:latest image ${repository_name}:${tag} -f json --quiet > results.json
cat ./results.json
curl --location --request POST 'https://'"${endpoint}"'/api/v1/artifact/?tenant_id='"${tenant_id}"'&data_type=TR&save_to_s3=true&label_id='"${label_id}" --header 'Tenant-Id: '"${tenant_id}" --header 'Authorization: Bearer '"${token}" --form 'file=@"./results.json"'
severe=$(echo ${severity} | sed 's/,/\\|/g')
if [ ${exit_code} -eq 1 ];then
  if grep -qi "${severe}" results.json; then
    echo "\nAccuKnox Scan has halted the deployment because it detected vulnerabilities of severity ${severity}"
    exit 1
  else
    echo "\nAccuKnox Checks Passed"
  fi
fi